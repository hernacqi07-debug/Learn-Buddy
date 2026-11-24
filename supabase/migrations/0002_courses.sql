-- Learn Buddy — Migration 0002: Courses (Mata Pelajaran) & Topic Associations
-- Target: Supabase PostgreSQL 17

-- 1. Courses Table
create table if not exists public.courses (
  id uuid primary key default gen_random_uuid(),
  code text unique not null,
  title_id text not null,
  title_en text not null,
  description_id text not null default '',
  description_en text not null default '',
  icon text not null default 'layers',
  accent_color text not null default '#06B6D4',
  teacher_id uuid references public.profiles(id) on delete set null,
  sort_order int not null default 1,
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

-- Indexes
create index if not exists idx_courses_active_order on public.courses (is_active, sort_order);
create index if not exists idx_courses_teacher on public.courses (teacher_id);

-- RLS
alter table public.courses enable row level security;

-- Policies
create policy "courses_select_authenticated"
  on public.courses
  for select
  to authenticated
  using (is_active or public.is_teacher());

create policy "courses_teacher_manage"
  on public.courses
  for all
  to authenticated
  using (public.is_teacher())
  with check (public.is_teacher());

-- 2. Link Topics to Courses
alter table public.topics
  add column if not exists course_id uuid references public.courses(id) on delete cascade;

create index if not exists idx_topics_course on public.topics (course_id);

-- 3. Seed Courses (Struktur Data, Java, Python)
insert into public.courses (id, code, title_id, title_en, description_id, description_en, icon, accent_color, teacher_id, sort_order, is_active)
values
  (
    'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa',
    'STRUKTUR-DATA',
    'Struktur Data',
    'Data Structures',
    'Konsep pengorganisasian data dalam memori: Stack, Queue, Linked List, dan Tree.',
    'Data organization concepts in memory: Stack, Queue, Linked List, and Tree.',
    'layers',
    '#06B6D4',
    '8f18758f-fb70-4783-a728-e95453a2f5d6', -- Pak Andi Prasetyo
    1,
    true
  ),
  (
    'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
    'PEMROGRAMAN-JAVA',
    'Pemrograman Java (OOP)',
    'Java Programming (OOP)',
    'Paradigma Object-Oriented Programming: Class, Object, Encapsulation, Inheritance, dan Polymorphism.',
    'Object-Oriented Programming Paradigm: Class, Object, Encapsulation, Inheritance, and Polymorphism.',
    'coffee',
    '#F59E0B',
    '4c7bd8e5-fc3b-4147-97e2-56b585ab8c56', -- Ahmad Farid Hernacqi
    2,
    true
  ),
  (
    'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
    'PEMROGRAMAN-PYTHON',
    'Pemrograman Python',
    'Python Programming',
    'Dasar logika pemrograman, manipulasi tipe data, struktur kontrol perulangan, dan modul fungsi.',
    'Foundational programming logic, data types, loops, and modular functions.',
    'terminal',
    '#10B981',
    null,
    3,
    true
  )
on conflict (id) do update set
  title_id = excluded.title_id,
  title_en = excluded.title_en,
  description_id = excluded.description_id,
  description_en = excluded.description_en,
  icon = excluded.icon,
  accent_color = excluded.accent_color,
  teacher_id = excluded.teacher_id,
  sort_order = excluded.sort_order,
  is_active = excluded.is_active;

-- 4. Associate existing topics to Struktur Data
update public.topics
set course_id = 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa'
where course_id is null;

-- 5. Seed Java Topic & Misconceptions
insert into public.topics (id, course_id, title_id, title_en, description_id, description_en, sort_order, is_active, created_by)
values (
  '33333333-3333-4333-8333-333333333301',
  'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb',
  'Class & Objek (Dasar OOP)',
  'Class & Object (OOP Basics)',
  'Memahami perbedaan cetak biru (Class) dengan wujud nyata instansiasi (Objek) dalam memori.',
  'Understanding the difference between the blueprint (Class) and memory instance (Object).',
  1,
  true,
  '4c7bd8e5-fc3b-4147-97e2-56b585ab8c56'
)
on conflict (id) do update set
  course_id = excluded.course_id,
  title_id = excluded.title_id,
  title_en = excluded.title_en,
  description_id = excluded.description_id,
  description_en = excluded.description_en,
  sort_order = excluded.sort_order,
  is_active = excluded.is_active;

insert into public.misconceptions (id, topic_id, misconception_text, misconception_text_en, correct_concept, correct_concept_en, buddy_intro, buddy_intro_en, sort_order)
values (
  '33333333-3333-4333-8333-333333333302',
  '33333333-3333-4333-8333-333333333301',
  'Class dan Objek itu sama saja, cuma beda istilah penulisan kode',
  'Class and Object are the exact same thing, just different naming',
  'Class adalah cetak biru (blueprint/template) yang belum memakan memori instance, sedangkan Objek adalah hasil instansiasi konkret (new) dari Class',
  'Class is a blueprint that does not allocate instance memory, while Object is a concrete instantiation (new) created from the Class',
  'Aku baca kode Java, katanya Class itu cetak biru tapi Objek itu benda nyata. Emang bedanya apa sih? Kalau aku bikin Class Mobil, berarti mobilnya udah langsung ada di memori kan?',
  'I read Java code saying Class is a blueprint and Object is real. What is the difference? If I make a Car class, does the car already exist in memory?',
  1
)
on conflict (id) do update set
  misconception_text = excluded.misconception_text,
  correct_concept = excluded.correct_concept,
  buddy_intro = excluded.buddy_intro,
  sort_order = excluded.sort_order;

insert into public.criteria (id, misconception_id, criterion_text, criterion_text_en, weight, sort_order)
values
  (
    '33333333-3333-4333-8333-333333333303',
    '33333333-3333-4333-8333-333333333302',
    'Menjelaskan bahwa Class adalah cetak biru/definisi template, bukan benda nyatanya',
    'Explains that Class is a blueprint/template definition, not the actual object',
    1,
    1
  ),
  (
    '33333333-3333-4333-8333-333333333304',
    '33333333-3333-4333-8333-333333333302',
    'Menjelaskan bahwa Objek baru tercipta di memori saat dilakukan instansiasi (kata kunci new)',
    'Explains that an Object is created in memory when instantiated (new keyword)',
    1,
    2
  ),
  (
    '33333333-3333-4333-8333-333333333305',
    '33333333-3333-4333-8333-333333333302',
    'Memberikan analogi nyata seperti cetakan kue (Class) vs kue (Objek), atau denah vs rumah asli',
    'Provides real-world analogy like cookie cutter vs cookie, or blueprint vs house',
    1,
    3
  )
on conflict (id) do update set
  criterion_text = excluded.criterion_text,
  weight = excluded.weight,
  sort_order = excluded.sort_order;

-- 6. Seed Python Topic & Misconceptions
insert into public.topics (id, course_id, title_id, title_en, description_id, description_en, sort_order, is_active)
values (
  '44444444-4444-4444-8444-444444444401',
  'cccccccc-cccc-4ccc-8ccc-cccccccccccc',
  'List vs Tuple (Mutabilitas)',
  'List vs Tuple (Mutability)',
  'Memahami konsep mutable (dapat diubah) pada List dan immutable (tetap) pada Tuple.',
  'Understanding mutable concept in Lists and immutable concept in Tuples.',
  1,
  true
)
on conflict (id) do update set
  course_id = excluded.course_id,
  title_id = excluded.title_id,
  title_en = excluded.title_en,
  description_id = excluded.description_id,
  description_en = excluded.description_en,
  sort_order = excluded.sort_order,
  is_active = excluded.is_active;

insert into public.misconceptions (id, topic_id, misconception_text, misconception_text_en, correct_concept, correct_concept_en, buddy_intro, buddy_intro_en, sort_order)
values (
  '44444444-4444-4444-8444-444444444402',
  '44444444-4444-4444-8444-444444444401',
  'List dan Tuple fungsinya sama persis, cuma beda kurung siku [ ] dan kurung biasa ( )',
  'List and Tuple are identical in functionality, only differing in brackets [ ] vs parentheses ( )',
  'List bersifat mutable (bisa diedit, ditambah, atau dihapus isinya), sedangkan Tuple bersifat immutable (isinya terkunci setelah dibuat)',
  'List is mutable (can be edited, added, or removed), while Tuple is immutable (fixed after creation)',
  'Kemarin aku belajar Python, ada list pakai tanda [] dan tuple pakai tanda (). Kenapa harus ada dua ya? Kan sama-sama nyimpan kumpulan data, apa bedanya selain bentuk kurungnya?',
  'I learned Python yesterday: list with [] and tuple with (). Why are there two? They both store data collections, what is the difference besides bracket styles?',
  1
)
on conflict (id) do update set
  misconception_text = excluded.misconception_text,
  correct_concept = excluded.correct_concept,
  buddy_intro = excluded.buddy_intro,
  sort_order = excluded.sort_order;

insert into public.criteria (id, misconception_id, criterion_text, criterion_text_en, weight, sort_order)
values
  (
    '44444444-4444-4444-8444-444444444403',
    '44444444-4444-4444-8444-444444444402',
    'Menyebutkan konsep mutabilitas (mutable vs immutable)',
    'Mentions mutability concept (mutable vs immutable)',
    1,
    1
  ),
  (
    '44444444-4444-4444-8444-444444444404',
    '44444444-4444-4444-8444-444444444402',
    'Menjelaskan bahwa elemen List bisa diubah/diedit/ditambah sedangkan Tuple tidak bisa diubah setelah dibuat',
    'Explains that List elements can be modified/added while Tuple cannot be changed after creation',
    1,
    2
  ),
  (
    '44444444-4444-4444-8444-444444444405',
    '44444444-4444-4444-8444-444444444402',
    'Memberikan contoh situasi penggunaan Tuple seperti koordinat GPS atau konstanta konfigurasi',
    'Provides example use case for Tuple like GPS coordinates or constant configurations',
    1,
    3
  )
on conflict (id) do update set
  criterion_text = excluded.criterion_text,
  weight = excluded.weight,
  sort_order = excluded.sort_order;
