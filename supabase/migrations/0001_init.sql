-- Learn Buddy — Initial Schema, RLS, Safe RPCs, and Indexes
-- Target: Supabase PostgreSQL 17

create extension if not exists pgcrypto;

-- 1. Profiles
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  email text not null,
  display_name text not null,
  role text not null check (role in ('student', 'teacher')),
  language_pref text not null default 'id' check (language_pref in ('id', 'en')),
  created_at timestamptz not null default now()
);

-- 2. Topics
create table if not exists public.topics (
  id uuid primary key default gen_random_uuid(),
  title_id text not null,
  title_en text not null,
  description_id text not null default '',
  description_en text not null default '',
  sort_order int not null default 1,
  is_active boolean not null default true,
  created_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now()
);

-- 3. Misconceptions
create table if not exists public.misconceptions (
  id uuid primary key default gen_random_uuid(),
  topic_id uuid not null references public.topics (id) on delete cascade,
  misconception_text text not null,
  misconception_text_en text,
  correct_concept text not null,
  correct_concept_en text,
  buddy_intro text not null,
  buddy_intro_en text,
  sort_order int not null default 1,
  created_at timestamptz not null default now()
);

-- 4. Criteria
create table if not exists public.criteria (
  id uuid primary key default gen_random_uuid(),
  misconception_id uuid not null references public.misconceptions (id) on delete cascade,
  criterion_text text not null,
  criterion_text_en text,
  weight int not null default 1 check (weight > 0),
  sort_order int not null default 1,
  created_at timestamptz not null default now()
);

-- 5. Sessions
create table if not exists public.sessions (
  id uuid primary key default gen_random_uuid(),
  student_id uuid not null references public.profiles (id) on delete cascade,
  topic_id uuid not null references public.topics (id) on delete restrict,
  active_misconception_id uuid references public.misconceptions (id) on delete set null,
  language text not null default 'id' check (language in ('id', 'en')),
  status text not null default 'active' check (status in ('active', 'completed', 'incomplete', 'abandoned')),
  meter_percent int not null default 0 check (meter_percent >= 0 and meter_percent <= 100),
  student_inputs int not null default 0 check (student_inputs >= 0 and student_inputs <= 20),
  stale_turns int not null default 0 check (stale_turns >= 0),
  started_at timestamptz not null default now(),
  ended_at timestamptz
);

-- 6. Messages (teachers have NO SELECT access)
create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.sessions (id) on delete cascade,
  role text not null check (role in ('student', 'buddy')),
  content text not null,
  created_at timestamptz not null default now()
);

-- 7. Session Criteria (truth source for Meter Paham + snapshot)
create table if not exists public.session_criteria (
  session_id uuid not null references public.sessions (id) on delete cascade,
  criterion_id uuid not null references public.criteria (id) on delete cascade,
  criterion_text_snapshot text not null,
  fulfilled boolean not null default false,
  evidence_quote text,
  fulfilled_at timestamptz,
  primary key (session_id, criterion_id)
);

-- 8. Turn Logs (LLM metrics & evaluator notes)
create table if not exists public.turn_logs (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.sessions (id) on delete cascade,
  provider text not null,
  model text not null,
  latency_ms int not null,
  evaluator_tokens int,
  buddy_tokens int,
  json_retried boolean not null default false,
  evaluator_notes text,
  created_at timestamptz not null default now()
);

-- 9. Teacher Invite Codes (activated in week 2 when active codes exist)
create table if not exists public.teacher_invite_codes (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

-- Indexes
create index if not exists idx_topics_active_order on public.topics (is_active, sort_order);
create index if not exists idx_misconceptions_topic_order on public.misconceptions (topic_id, sort_order);
create index if not exists idx_criteria_misc_order on public.criteria (misconception_id, sort_order);
create index if not exists idx_sessions_student_topic on public.sessions (student_id, topic_id, started_at desc);
create index if not exists idx_sessions_topic_status on public.sessions (topic_id, status);
create index if not exists idx_messages_session_created on public.messages (session_id, created_at);
create index if not exists idx_session_criteria_session on public.session_criteria (session_id);
create index if not exists idx_session_criteria_criterion on public.session_criteria (criterion_id);
create index if not exists idx_sessions_active_misc on public.sessions (active_misconception_id);
create index if not exists idx_topics_created_by on public.topics (created_by);
create index if not exists idx_turn_logs_session on public.turn_logs (session_id, created_at desc);

-- Helper: check teacher role safely
create or replace function public.is_teacher()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.profiles
    where id = (select auth.uid())
      and role = 'teacher'
  );
$$;

revoke all on function public.is_teacher() from public, anon;
grant execute on function public.is_teacher() to authenticated;

-- Trigger: lock profiles.role and profiles.email against client-side tampering
create or replace function public.prevent_profile_role_email_change()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if (select auth.uid()) is not null then
    if new.role is distinct from old.role then
      raise exception 'Role cannot be changed from client';
    end if;
    if new.email is distinct from old.email then
      raise exception 'Email cannot be changed from client';
    end if;
  end if;
  return new;
end;
$$;

create or replace trigger trg_prevent_profile_role_email_change
before update on public.profiles
for each row
execute function public.prevent_profile_role_email_change();

revoke all on function public.prevent_profile_role_email_change() from public, anon, authenticated;

-- Enable RLS on all tables
alter table public.profiles enable row level security;
alter table public.topics enable row level security;
alter table public.misconceptions enable row level security;
alter table public.criteria enable row level security;
alter table public.sessions enable row level security;
alter table public.messages enable row level security;
alter table public.session_criteria enable row level security;
alter table public.turn_logs enable row level security;
alter table public.teacher_invite_codes enable row level security;

-- RLS Policies: profiles
create policy "profiles_select_own_or_teacher_students"
on public.profiles for select
to authenticated
using (
  (select auth.uid()) = id
  or (public.is_teacher() and role = 'student')
);

create policy "profiles_insert_own"
on public.profiles for insert
to authenticated
with check (
  (select auth.uid()) = id
  and (
    role = 'student'
    or (
      role = 'teacher'
      and not exists (select 1 from public.teacher_invite_codes where is_active = true)
    )
  )
);

create policy "profiles_update_own"
on public.profiles for update
to authenticated
using ((select auth.uid()) = id)
with check ((select auth.uid()) = id);

-- RLS Policies: topics
create policy "topics_select_active_or_teacher"
on public.topics for select
to authenticated
using (is_active = true or public.is_teacher());

create policy "topics_teacher_insert"
on public.topics for insert
to authenticated
with check (public.is_teacher());

create policy "topics_teacher_update"
on public.topics for update
to authenticated
using (public.is_teacher())
with check (public.is_teacher());

create policy "topics_teacher_delete"
on public.topics for delete
to authenticated
using (public.is_teacher());

-- RLS Policies: misconceptions (students NEVER select correct_concept directly; use RPCs)
create policy "misconceptions_teacher_all"
on public.misconceptions for all
to authenticated
using (public.is_teacher())
with check (public.is_teacher());

-- RLS Policies: criteria (students NEVER select raw criteria; use RPCs / Edge Functions)
create policy "criteria_teacher_all"
on public.criteria for all
to authenticated
using (public.is_teacher())
with check (public.is_teacher());

-- RLS Policies: sessions
create policy "sessions_select_own_or_teacher"
on public.sessions for select
to authenticated
using (student_id = (select auth.uid()) or public.is_teacher());

create policy "sessions_delete_own"
on public.sessions for delete
to authenticated
using (student_id = (select auth.uid()));

-- RLS Policies: messages (students read own only; teachers have ZERO access; inserts via Edge Function / RPC)
create policy "messages_select_own_student"
on public.messages for select
to authenticated
using (
  exists (
    select 1 from public.sessions s
    where s.id = session_id
      and s.student_id = (select auth.uid())
  )
);

-- RLS Policies: session_criteria (teachers read all for progress; students read via safe recap RPC)
create policy "session_criteria_teacher_select"
on public.session_criteria for select
to authenticated
using (public.is_teacher());

-- Note: turn_logs and teacher_invite_codes intentionally have NO authenticated SELECT/WRITE policies (service_role / RPC only).

-- ============================================================================
-- Safe RPCs for Client App
-- ============================================================================

-- RPC 1: Register profile (supports optional teacher invite code when active codes exist)
create or replace function public.register_user_profile(
  p_display_name text,
  p_role text,
  p_invite_code text default null,
  p_language_pref text default 'id'
)
returns public.profiles
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_email text;
  v_has_active_invites boolean;
  v_lang text;
  v_profile public.profiles;
begin
  if v_uid is null then
    raise exception 'Not authenticated';
  end if;
  if p_role not in ('student', 'teacher') then
    raise exception 'Invalid role';
  end if;

  v_lang := case when p_language_pref in ('id', 'en') then p_language_pref else 'id' end;

  select email into v_email from auth.users where id = v_uid;

  if p_role = 'teacher' then
    select exists(select 1 from public.teacher_invite_codes where is_active = true)
      into v_has_active_invites;
    if v_has_active_invites then
      if p_invite_code is null or not exists (
        select 1 from public.teacher_invite_codes
        where code = trim(p_invite_code) and is_active = true
      ) then
        raise exception 'INVALID_INVITE_CODE';
      end if;
    end if;
  end if;

  insert into public.profiles (id, email, display_name, role, language_pref)
  values (v_uid, coalesce(v_email, ''), trim(p_display_name), p_role, v_lang)
  on conflict (id) do update
    set display_name = excluded.display_name,
        language_pref = excluded.language_pref
  returning * into v_profile;

  return v_profile;
end;
$$;

revoke all on function public.register_user_profile(text, text, text, text) from public, anon;
grant execute on function public.register_user_profile(text, text, text, text) to authenticated;

-- RPC 2: Get active topics with student's best meter, active session, and EN readiness
create or replace function public.get_student_topics_summary()
returns table (
  id uuid,
  title_id text,
  title_en text,
  description_id text,
  description_en text,
  sort_order int,
  en_ready boolean,
  best_meter_percent int,
  has_completed_80 boolean,
  active_session_id uuid
)
language sql
stable
security definer
set search_path = ''
as $$
  with uid as (select (select auth.uid()) as id)
  select
    t.id,
    t.title_id,
    t.title_en,
    t.description_id,
    t.description_en,
    t.sort_order,
    (
      exists (select 1 from public.misconceptions m where m.topic_id = t.id)
      and not exists (
        select 1 from public.misconceptions m
        where m.topic_id = t.id
          and (
            coalesce(trim(m.misconception_text_en), '') = ''
            or coalesce(trim(m.correct_concept_en), '') = ''
            or coalesce(trim(m.buddy_intro_en), '') = ''
          )
      )
      and not exists (
        select 1
        from public.criteria c
        join public.misconceptions m on m.id = c.misconception_id
        where m.topic_id = t.id
          and coalesce(trim(c.criterion_text_en), '') = ''
      )
    ) as en_ready,
    coalesce(
      (
        select max(s.meter_percent)
        from public.sessions s, uid
        where s.topic_id = t.id and s.student_id = uid.id
      ),
      0
    ) as best_meter_percent,
    exists (
      select 1
      from public.sessions s, uid
      where s.topic_id = t.id and s.student_id = uid.id and s.meter_percent >= 80
    ) as has_completed_80,
    (
      select s.id
      from public.sessions s, uid
      where s.topic_id = t.id and s.student_id = uid.id and s.status = 'active'
      order by s.started_at desc
      limit 1
    ) as active_session_id
  from public.topics t
  where t.is_active = true
  order by t.sort_order asc, t.created_at asc;
$$;

revoke all on function public.get_student_topics_summary() from public, anon;
grant execute on function public.get_student_topics_summary() to authenticated;

-- RPC 3: Start a new learning session (snapshots criteria & inserts first buddy_intro)
create or replace function public.start_learning_session(
  p_topic_id uuid,
  p_language text default 'id'
)
returns public.sessions
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_topic public.topics;
  v_first_misc public.misconceptions;
  v_intro text;
  v_session public.sessions;
  v_en_ready boolean;
begin
  if v_uid is null then
    raise exception 'Not authenticated';
  end if;
  if p_language not in ('id', 'en') then
    raise exception 'Invalid session language';
  end if;

  select * into v_topic from public.topics where id = p_topic_id and is_active = true;
  if v_topic.id is null then
    raise exception 'Topic not found or inactive';
  end if;

  if p_language = 'en' then
    select (
      exists (select 1 from public.misconceptions m where m.topic_id = p_topic_id)
      and not exists (
        select 1 from public.misconceptions m
        where m.topic_id = p_topic_id
          and (
            coalesce(trim(m.misconception_text_en), '') = ''
            or coalesce(trim(m.correct_concept_en), '') = ''
            or coalesce(trim(m.buddy_intro_en), '') = ''
          )
      )
      and not exists (
        select 1
        from public.criteria c
        join public.misconceptions m on m.id = c.misconception_id
        where m.topic_id = p_topic_id
          and coalesce(trim(c.criterion_text_en), '') = ''
      )
    ) into v_en_ready;
    if not v_en_ready then
      raise exception 'EN_CONTENT_NOT_READY';
    end if;
  end if;

  select * into v_first_misc
  from public.misconceptions
  where topic_id = p_topic_id
  order by sort_order asc, created_at asc
  limit 1;

  if v_first_misc.id is null then
    raise exception 'Topic has no misconceptions';
  end if;

  insert into public.sessions (
    student_id,
    topic_id,
    active_misconception_id,
    language,
    status,
    meter_percent,
    student_inputs,
    stale_turns
  )
  values (
    v_uid,
    p_topic_id,
    v_first_misc.id,
    p_language,
    'active',
    0,
    0,
    0
  )
  returning * into v_session;

  insert into public.session_criteria (
    session_id,
    criterion_id,
    criterion_text_snapshot,
    fulfilled
  )
  select
    v_session.id,
    c.id,
    case
      when p_language = 'en' and coalesce(trim(c.criterion_text_en), '') <> ''
        then c.criterion_text_en
      else c.criterion_text
    end,
    false
  from public.criteria c
  join public.misconceptions m on m.id = c.misconception_id
  where m.topic_id = p_topic_id;

  v_intro := case
    when p_language = 'en' and coalesce(trim(v_first_misc.buddy_intro_en), '') <> ''
      then v_first_misc.buddy_intro_en
    else v_first_misc.buddy_intro
  end;

  insert into public.messages (session_id, role, content)
  values (v_session.id, 'buddy', v_intro);

  return v_session;
end;
$$;

revoke all on function public.start_learning_session(uuid, text) from public, anon;
grant execute on function public.start_learning_session(uuid, text) to authenticated;

-- RPC 4: Get safe student recap (ONLY misconception titles + resolved status, NO hints/criteria/correct_concept)
create or replace function public.get_session_recap(p_session_id uuid)
returns table (
  misconception_id uuid,
  title_id text,
  title_en text,
  sort_order int,
  total_criteria int,
  fulfilled_criteria int,
  is_resolved boolean
)
language sql
stable
security definer
set search_path = ''
as $$
  select
    m.id as misconception_id,
    m.misconception_text as title_id,
    m.misconception_text_en as title_en,
    m.sort_order,
    count(c.id)::int as total_criteria,
    count(sc.criterion_id) filter (where sc.fulfilled)::int as fulfilled_criteria,
    coalesce(bool_and(coalesce(sc.fulfilled, false)), false) as is_resolved
  from public.sessions s
  join public.misconceptions m on m.topic_id = s.topic_id
  join public.criteria c on c.misconception_id = m.id
  left join public.session_criteria sc
    on sc.session_id = s.id and sc.criterion_id = c.id
  where s.id = p_session_id
    and s.student_id = (select auth.uid())
  group by m.id, m.misconception_text, m.misconception_text_en, m.sort_order
  order by m.sort_order asc;
$$;

revoke all on function public.get_session_recap(uuid) from public, anon;
grant execute on function public.get_session_recap(uuid) to authenticated;

-- RPC 5: Manually end an active session (>= 80% -> completed, < 80% -> abandoned)
create or replace function public.end_learning_session(p_session_id uuid)
returns public.sessions
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_uid uuid := (select auth.uid());
  v_session public.sessions;
begin
  if v_uid is null then
    raise exception 'Not authenticated';
  end if;

  update public.sessions
  set
    status = case when meter_percent >= 80 then 'completed' else 'abandoned' end,
    ended_at = now()
  where id = p_session_id
    and student_id = v_uid
    and status = 'active'
  returning * into v_session;

  if v_session.id is null then
    raise exception 'Active session not found';
  end if;

  return v_session;
end;
$$;

revoke all on function public.end_learning_session(uuid) from public, anon;
grant execute on function public.end_learning_session(uuid) to authenticated;

-- RPC 6: Keep-alive ping (prevents free-tier auto-pause when called periodically)
create or replace function public.health_ping()
returns timestamptz
language sql
stable
set search_path = ''
as $$
  select now();
$$;
