-- Learn Buddy — Migration 0007: Teacher Questions RLS & Quiz Attempts Sync
-- Target: Supabase PostgreSQL 17

-- 1. Ensure quiz_attempts has answers jsonb column used by QuizPage
alter table public.quiz_attempts
  add column if not exists answers jsonb not null default '{}'::jsonb;

-- 2. Add helpful indexes for question & quiz attempt queries
create index if not exists idx_questions_topic_type
  on public.questions (topic_id, type, sort_order);

create index if not exists idx_quiz_attempts_student_topic
  on public.quiz_attempts (student_id, topic_id);

-- 3. Enable RLS on questions and replace permissive policies with teacher/admin scoped policies
alter table public.questions enable row level security;

drop policy if exists "Allow read questions" on public.questions;
drop policy if exists "Allow insert questions" on public.questions;
drop policy if exists "questions_select_authenticated" on public.questions;
drop policy if exists "questions_insert_teacher_admin" on public.questions;
drop policy if exists "questions_update_teacher_admin" on public.questions;
drop policy if exists "questions_delete_teacher_admin" on public.questions;

create policy "questions_select_authenticated"
  on public.questions
  for select
  to authenticated
  using (true);

create policy "questions_insert_teacher_admin"
  on public.questions
  for insert
  to authenticated
  with check (
    public.is_admin()
    or (
      public.is_teacher()
      and exists (
        select 1
        from public.topics t
        where t.id = topic_id
          and (
            public.my_teacher_course_id() is null
            or t.course_id = public.my_teacher_course_id()
          )
      )
    )
  );

create policy "questions_update_teacher_admin"
  on public.questions
  for update
  to authenticated
  using (
    public.is_admin()
    or (
      public.is_teacher()
      and exists (
        select 1
        from public.topics t
        where t.id = topic_id
          and (
            public.my_teacher_course_id() is null
            or t.course_id = public.my_teacher_course_id()
          )
      )
    )
  )
  with check (
    public.is_admin()
    or (
      public.is_teacher()
      and exists (
        select 1
        from public.topics t
        where t.id = topic_id
          and (
            public.my_teacher_course_id() is null
            or t.course_id = public.my_teacher_course_id()
          )
      )
    )
  );

create policy "questions_delete_teacher_admin"
  on public.questions
  for delete
  to authenticated
  using (
    public.is_admin()
    or (
      public.is_teacher()
      and exists (
        select 1
        from public.topics t
        where t.id = topic_id
          and (
            public.my_teacher_course_id() is null
            or t.course_id = public.my_teacher_course_id()
          )
      )
    )
  );
