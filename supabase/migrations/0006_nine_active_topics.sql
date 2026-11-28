-- Learn Buddy — Migration 0006: 9 Active Topics (3 per Course) with ID + EN Buddy Rubrics
-- Target: Supabase PostgreSQL 17

do $$
declare
  c_sd uuid := 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa';
  c_java uuid := 'bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb';
  c_py uuid := 'cccccccc-cccc-4ccc-8ccc-cccccccccccc';

  t_ll uuid := '22222222-2222-4222-8222-222222222101';
  t_java_encap uuid := '33333333-3333-4333-8333-333333333302';
  t_java_inh uuid := '33333333-3333-4333-8333-333333333303';
  t_py_dict uuid := '44444444-4444-4444-8444-444444444402';
  t_py_loop uuid := '44444444-4444-4444-8444-444444444403';

  m_je1 uuid := '33333333-3333-4333-8333-333333334201';
  m_ji1 uuid := '33333333-3333-4333-8333-333333334301';
  m_pd1 uuid := '44444444-4444-4444-8444-444444445201';
  m_pl1 uuid := '44444444-4444-4444-8444-444444445301';
begin
  -- 1. Activate Linked List in Struktur Data (so Struktur Data has 3 active: Stack, Queue Antrean, Linked List)
  update public.topics
  set is_active = true,
      sort_order = 3,
      course_id = c_sd
  where id = t_ll;

  -- Ensure Queue Antrean has sort_order = 2 and EN fields filled
  update public.topics
  set sort_order = 2
  where course_id = c_sd and title_id ilike '%Queue%';

  -- 2. Java Topic 2: Encapsulation
  insert into public.topics (id, course_id, title_id, title_en, description_id, description_en, sort_order, is_active)
  values (
    t_java_encap, c_java,
    'Enkapsulasi (Private & Getter/Setter)',
    'Encapsulation (Private & Getter/Setter)',
    'Melindungi data internal objek dengan modifier private dan menyediakan akses terkontrol lewat getter dan setter.',
    'Protecting internal object data with private modifiers and exposing controlled access via getters and setters.',
    2, true
  )
  on conflict (id) do update set
    is_active = true,
    sort_order = excluded.sort_order,
    title_id = excluded.title_id,
    title_en = excluded.title_en,
    description_id = excluded.description_id,
    description_en = excluded.description_en;

  insert into public.misconceptions (
    id, topic_id,
    misconception_text, misconception_text_en,
    correct_concept, correct_concept_en,
    buddy_intro, buddy_intro_en, sort_order
  ) values (
    m_je1, t_java_encap,
    'Semua atribut di Java sebaiknya dibuat public agar gampang diakses',
    'All fields in Java should be public so they are easy to access',
    'Atribut sebaiknya dibuat private untuk mencegah perubahan data sembarangan, lalu diakses melalui method getter dan setter yang bisa memvalidasi nilai.',
    'Fields should be private to prevent arbitrary invalid mutations, and accessed via getter and setter methods that can validate values.',
    'Kenapa sih atribut class di Java harus dibuat private? Kalau dibuat public semua kan lebih cepat langsung diubah dari luar tanpa ribet bikin getter dan setter?',
    'Why do class fields in Java need to be private? Making them all public is faster to change directly from outside without writing getters and setters, right?',
    1
  ) on conflict (id) do nothing;

  insert into public.criteria (id, misconception_id, criterion_text, criterion_text_en, sort_order) values
    ('33333333-3333-4333-8333-333333334211', m_je1, 'Menjelaskan modifier private menyembunyikan data agar tidak diubah sembarangan dari luar class', 'Explains that private hides data so external code cannot mutate it arbitrarily', 1),
    ('33333333-3333-4333-8333-333333334212', m_je1, 'Menyebut peran getter (membaca) dan setter (mengubah dengan validasi)', 'Explains the role of getter (reading) and setter (updating with validation)', 2),
    ('33333333-3333-4333-8333-333333334213', m_je1, 'Memberi contoh nyata seperti saldo rekening tidak boleh negatif atau umur harus positif', 'Gives a concrete example like preventing negative bank balance or invalid age', 3)
  on conflict (id) do nothing;

  -- 3. Java Topic 3: Inheritance
  insert into public.topics (id, course_id, title_id, title_en, description_id, description_en, sort_order, is_active)
  values (
    t_java_inh, c_java,
    'Pewarisan (Inheritance & Override)',
    'Inheritance & Method Overriding',
    'Mewariskan atribut dan method dari superclass ke subclass menggunakan extends serta menyesuaikan perilaku dengan override.',
    'Inheriting fields and methods from a superclass to a subclass using extends and customizing behavior with override.',
    3, true
  )
  on conflict (id) do update set
    is_active = true,
    sort_order = excluded.sort_order,
    title_id = excluded.title_id,
    title_en = excluded.title_en,
    description_id = excluded.description_id,
    description_en = excluded.description_en;

  insert into public.misconceptions (
    id, topic_id,
    misconception_text, misconception_text_en,
    correct_concept, correct_concept_en,
    buddy_intro, buddy_intro_en, sort_order
  ) values (
    m_ji1, t_java_inh,
    'Subclass harus menulis ulang semua kode dari superclass',
    'A subclass must rewrite all code from its superclass',
    'Dengan kata kunci extends, subclass otomatis mewarisi atribut dan method non-private dari superclass, dan hanya perlu menambahkan fitur baru atau meng-override method tertentu.',
    'Using extends, a subclass automatically inherits non-private fields and methods from its superclass, and only adds new features or overrides specific methods.',
    'Kalau aku bikin class Kucing yang mewarisi class Hewan pakai extends, aku tetap harus copy-paste semua method makan() dan tidur() ke dalam class Kucing kan?',
    'If I create a Cat class extending Animal, do I still have to copy-paste eat() and sleep() into Cat?',
    1
  ) on conflict (id) do nothing;

  insert into public.criteria (id, misconception_id, criterion_text, criterion_text_en, sort_order) values
    ('33333333-3333-4333-8333-333333334311', m_ji1, 'Menjelaskan subclass otomatis mewarisi atribut dan method superclass lewat extends tanpa copy-paste', 'Explains that a subclass inherits superclass fields and methods via extends without copy-pasting', 1),
    ('33333333-3333-4333-8333-333333334312', m_ji1, 'Menyebut konsep method overriding untuk mengubah perilaku khusus di subclass', 'Mentions method overriding to customize specific behavior in the subclass', 2),
    ('33333333-3333-4333-8333-333333334313', m_ji1, 'Memberi contoh nyata hubungan superclass dan subclass seperti Hewan -> Kucing atau Kendaraan -> Mobil', 'Gives a concrete example of superclass and subclass such as Animal -> Cat or Vehicle -> Car', 3)
  on conflict (id) do nothing;

  -- 4. Python Topic 2: Dictionary (Key-Value)
  insert into public.topics (id, course_id, title_id, title_en, description_id, description_en, sort_order, is_active)
  values (
    t_py_dict, c_py,
    'Dictionary (Key-Value Pair)',
    'Dictionary (Key-Value Pair)',
    'Menyimpan dan mengakses data secara cepat menggunakan pasangan kunci unik (key) dan nilai (value) pada Python.',
    'Storing and retrieving data quickly using unique key-value pairs in Python.',
    2, true
  )
  on conflict (id) do update set
    is_active = true,
    sort_order = excluded.sort_order,
    title_id = excluded.title_id,
    title_en = excluded.title_en,
    description_id = excluded.description_id,
    description_en = excluded.description_en;

  insert into public.misconceptions (
    id, topic_id,
    misconception_text, misconception_text_en,
    correct_concept, correct_concept_en,
    buddy_intro, buddy_intro_en, sort_order
  ) values (
    m_pd1, t_py_dict,
    'Dictionary diakses pakai indeks angka 0, 1, 2 seperti List dan boleh punya key kembar',
    'Dictionaries are indexed by 0, 1, 2 like Lists and allow duplicate keys',
    'Dictionary diakses menggunakan key (kunci) uniknya, bukan indeks posisi. Jika key yang sama dimasukkan lagi, nilai lamanya akan tertimpa.',
    'A dictionary is accessed by its unique key, not numeric position index. Assigning an existing key overwrites its previous value.',
    'Di Python, kalau aku punya dictionary siswa = {"nama": "Budi", "nilai": 90}, untuk ambil "Budi" aku tinggal tulis siswa[0] kan? Terus boleh punya dua key "nama" sekaligus?',
    'In Python, if I have student = {"name": "Budi", "score": 90}, can I get "Budi" with student[0] and have two "name" keys at once?',
    1
  ) on conflict (id) do nothing;

  insert into public.criteria (id, misconception_id, criterion_text, criterion_text_en, sort_order) values
    ('44444444-4444-4444-8444-444444445211', m_pd1, 'Menjelaskan data di dictionary diakses melalui key (mis. siswa["nama"]), bukan indeks angka 0', 'Explains dictionary values are accessed via key (e.g. student["name"]), not numeric index 0', 1),
    ('44444444-4444-4444-8444-444444445212', m_pd1, 'Menyebut setiap key harus unik dan key yang sama akan menimpa nilai lama', 'States that keys must be unique and assigning a duplicate key overwrites the old value', 2),
    ('44444444-4444-4444-8444-444444445213', m_pd1, 'Memberi contoh operasi menambah, membaca, atau menghapus pasangan key-value', 'Gives an example of adding, reading, or deleting a key-value pair', 3)
  on conflict (id) do nothing;

  -- 5. Python Topic 3: Perulangan & Fungsi
  insert into public.topics (id, course_id, title_id, title_en, description_id, description_en, sort_order, is_active)
  values (
    t_py_loop, c_py,
    'Perulangan & Fungsi (Loop & Def)',
    'Loops & Functions (For/While & Def)',
    'Mengotomatisasi tugas berulang dengan for/while serta membungkus logika agar bisa dipakai ulang lewat fungsi def dan return.',
    'Automating repetitive tasks with for/while loops and packaging reusable logic using def and return.',
    3, true
  )
  on conflict (id) do update set
    is_active = true,
    sort_order = excluded.sort_order,
    title_id = excluded.title_id,
    title_en = excluded.title_en,
    description_id = excluded.description_id,
    description_en = excluded.description_en;

  insert into public.misconceptions (
    id, topic_id,
    misconception_text, misconception_text_en,
    correct_concept, correct_concept_en,
    buddy_intro, buddy_intro_en, sort_order
  ) values (
    m_pl1, t_py_loop,
    'print() di dalam fungsi sama dengan return dan range(5) menghitung sampai angka 5',
    'print() inside a function is the same as return, and range(5) counts up to 5',
    'return mengembalikan nilai hasil fungsi agar bisa disimpan/diolah lagi, sedangkan print() hanya menampilkan ke layar. Selain itu, range(5) menghasilkan 0, 1, 2, 3, 4 (berhenti sebelum 5).',
    'return hands a value back to the caller so it can be reused, while print() only displays text. Also, range(5) produces 0, 1, 2, 3, 4 (stops before 5).',
    'Buddy bingung nih: kalau aku tulis for i in range(5), angka 5 ikut keluar kan? Terus di dalam fungsi def, pakai print() saja sudah sama dengan return kan?',
    'I am confused: in for i in range(5), does 5 get printed too? And inside a def function, is print() the same as return?',
    1
  ) on conflict (id) do nothing;

  insert into public.criteria (id, misconception_id, criterion_text, criterion_text_en, sort_order) values
    ('44444444-4444-4444-8444-444444445311', m_pl1, 'Menjelaskan range(5) menghasilkan 0 sampai 4 (batas atas tidak termasuk)', 'Explains that range(5) yields 0 through 4 (stop bound is exclusive)', 1),
    ('44444444-4444-4444-8444-444444445312', m_pl1, 'Membedakan print() (hanya cetak ke layar) dengan return (mengembalikan nilai ke pemanggil fungsi)', 'Distinguishes print() (displays only) from return (sends value back to caller)', 2),
    ('44444444-4444-4444-8444-444444445313', m_pl1, 'Menjelaskan manfaat fungsi/loop agar kode rapi dan dapat dipakai berulang', 'Explains how loops/functions keep code clean and reusable', 3)
  on conflict (id) do nothing;
end $$;
