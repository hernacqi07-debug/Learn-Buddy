-- Learn Buddy — Migration 0004: Admin Role, RLS Policies & Demo Admin Account
-- Target: Supabase PostgreSQL 17

-- 1. Allow 'admin' in public.profiles.role
do $$
declare
  v_conname text;
begin
  select conname into v_conname
  from pg_constraint
  where conrelid = 'public.profiles'::regclass
    and contype = 'c'
    and pg_get_constraintdef(oid) ilike '%role%';

  if v_conname is not null then
    execute format('alter table public.profiles drop constraint %I', v_conname);
  end if;
end $$;

alter table public.profiles
  add constraint profiles_role_check
  check (role in ('student', 'teacher', 'admin'));

-- 2. Helper function public.is_admin()
create or replace function public.is_admin()
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
      and role = 'admin'
  );
$$;

revoke all on function public.is_admin() from public;
grant execute on function public.is_admin() to authenticated;

-- 3. Admin RLS Policies
drop policy if exists "profiles_select_admin" on public.profiles;
create policy "profiles_select_admin"
  on public.profiles
  for select
  to authenticated
  using (public.is_admin());

drop policy if exists "profiles_update_admin" on public.profiles;
create policy "profiles_update_admin"
  on public.profiles
  for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

drop policy if exists "courses_select_admin" on public.courses;
create policy "courses_select_admin"
  on public.courses
  for select
  to authenticated
  using (public.is_admin());

drop policy if exists "courses_update_admin" on public.courses;
create policy "courses_update_admin"
  on public.courses
  for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

drop policy if exists "topics_select_admin" on public.topics;
create policy "topics_select_admin"
  on public.topics
  for select
  to authenticated
  using (public.is_admin());

drop policy if exists "topics_update_admin" on public.topics;
create policy "topics_update_admin"
  on public.topics
  for update
  to authenticated
  using (public.is_admin())
  with check (public.is_admin());

drop policy if exists "sessions_select_admin" on public.sessions;
create policy "sessions_select_admin"
  on public.sessions
  for select
  to authenticated
  using (public.is_admin());

drop policy if exists "turn_logs_select_admin" on public.turn_logs;
create policy "turn_logs_select_admin"
  on public.turn_logs
  for select
  to authenticated
  using (public.is_admin());

drop policy if exists "teacher_invite_codes_select_admin" on public.teacher_invite_codes;
create policy "teacher_invite_codes_select_admin"
  on public.teacher_invite_codes
  for select
  to authenticated
  using (public.is_admin());
