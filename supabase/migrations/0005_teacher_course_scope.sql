-- Learn Buddy — Migration 0005: Teacher Course Scoping & Admin Course Creation
-- Target: Supabase PostgreSQL 17

-- 1. Add course_id to public.profiles (many teachers can share 1 course)
alter table public.profiles
  add column if not exists course_id uuid references public.courses(id) on delete set null;

create index if not exists idx_profiles_course_id on public.profiles (course_id);

-- 2. Assign existing teachers to initial courses
update public.profiles
set course_id = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'
where id = '8f18758f-fb70-4783-a728-e95453a2f5d6' and role = 'teacher' and course_id is null;

update public.profiles
set course_id = 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb'
where id = 'b222ce47-3e6e-4688-80f6-b7f74a72ca11' and role = 'teacher' and course_id is null;

update public.profiles
set course_id = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'
where role = 'teacher' and course_id is null;

-- 3. Allow anon to list active courses for the teacher registration dropdown
create policy "courses_select_anon_active"
  on public.courses
  for select
  to anon
  using (is_active = true);

-- 4. Allow admin to create new courses
create policy "courses_insert_admin"
  on public.courses
  for insert
  to authenticated
  with check (public.is_admin());

-- 5. Helper to get current teacher's assigned course_id
create or replace function public.my_teacher_course_id()
returns uuid
language sql
stable
security definer
set search_path = ''
as $$
  select course_id
  from public.profiles
  where id = (select auth.uid())
    and role = 'teacher';
$$;

revoke all on function public.my_teacher_course_id() from public;
grant execute on function public.my_teacher_course_id() to authenticated;

-- 6. Update register_user_profile RPC to accept p_course_id for teachers
create or replace function public.register_user_profile(
  p_display_name text,
  p_role text,
  p_invite_code text default null,
  p_language_pref text default 'id',
  p_course_id uuid default null
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
  v_course_id uuid := null;
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

    if p_course_id is null or not exists (
      select 1 from public.courses where id = p_course_id and is_active = true
    ) then
      raise exception 'COURSE_REQUIRED';
    end if;
    v_course_id := p_course_id;
  end if;

  insert into public.profiles (id, email, display_name, role, language_pref, course_id)
  values (v_uid, coalesce(v_email, ''), trim(p_display_name), p_role, v_lang, v_course_id)
  on conflict (id) do update set
    display_name = excluded.display_name,
    role = excluded.role,
    language_pref = excluded.language_pref,
    course_id = excluded.course_id
  returning * into v_profile;

  return v_profile;
end;
$$;
