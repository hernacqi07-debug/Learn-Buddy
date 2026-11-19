-- Seed initial topics for Learn Buddy
-- Topic 1: Stack (active, full ID + EN ready)
-- Topic 2: Linked List (inactive draft, ID only — ready to test "Terjemahkan ke English" & activation in Kelola Konten)

do $$
declare
  v_stack_id uuid := '11111111-1111-4111-8111-111111111101';
  v_s1_id uuid := '11111111-1111-4111-8111-111111111201';
  v_s2_id uuid := '11111111-1111-4111-8111-111111111202';
  v_s3_id uuid := '11111111-1111-4111-8111-111111111203';

  v_ll_id uuid := '22222222-2222-4222-8222-222222222101';
  v_l1_id uuid := '22222222-2222-4222-8222-222222222201';
  v_l2_id uuid := '22222222-2222-4222-8222-222222222202';
  v_l3_id uuid := '22222222-2222-4222-8222-222222222203';
begin
  -- 1. Topic: Stack (active, ID + EN)
  insert into public.topics (id, title_id, title_en, description_id, description_en, sort_order, is_active)
  values (
    v_stack_id,
    'Stack (Tumpukan)',
    'Stack',
    'Memahami prinsip LIFO, operasi push & pop, akses elemen teratas, dan batas kapasitas stack.',
    'Understand the LIFO principle, push & pop operations, top-only access, and stack capacity limits.',
    1,
    true
  )
  on conflict (id) do nothing;

  insert into public.misconceptions (
    id, topic_id,
    misconception_text, misconception_text_en,
    correct_concept, correct_concept_en,
    buddy_intro, buddy_intro_en,
    sort_order
  ) values
  (
    v_s1_id, v_stack_id,
    'Stack itu seperti antrean (FIFO)',
    'A stack works like a queue (FIFO)',
    'Stack bersifat LIFO (Last In, First Out): elemen yang terakhir masuk lewat push adalah yang pertama keluar lewat pop.',
    'A stack follows LIFO (Last In, First Out): the last element pushed onto the top is the first one popped out.',
    'Aku tuh bingung, kemarin antre di kantin yang datang duluan dilayani duluan. Stack juga gitu kan? Yang masuk duluan keluar duluan?',
    'I am confused—at the canteen yesterday, whoever lined up first got served first. A stack works the same way, right? First in, first out?',
    1
  ),
  (
    v_s2_id, v_stack_id,
    'Elemen tengah stack bisa diambil langsung',
    'You can grab an item directly from the middle of a stack',
    'Hanya elemen teratas (top) yang bisa diakses langsung. Untuk mengambil elemen di bawahnya, elemen di atasnya harus di-pop satu per satu dulu.',
    'Only the top element can be accessed directly. To reach an item underneath, every element above it must be popped off first.',
    'Kalau aku mau ambil buku yang ada di tengah tumpukan stack, tinggal tarik langsung dari tengah aja kan? Nggak perlu angkat yang di atasnya?',
    'If I want to take a book from the middle of a stack, I can just pull it straight out from the middle, right? No need to remove the ones on top?',
    2
  ),
  (
    v_s3_id, v_stack_id,
    'Stack tidak pernah penuh',
    'A stack can never become full',
    'Stack memiliki batas kapasitas memori. Memaksakan push saat stack sudah penuh akan gagal dan menyebabkan stack overflow.',
    'A stack has a finite capacity. Trying to push onto a full stack fails and causes a stack overflow.',
    'Aku push data terus-terusan ke stack, aman-aman aja kan? Stack itu nggak ada batasnya, ya?',
    'If I keep pushing data into a stack over and over, it is totally fine, right? A stack has no limit at all?',
    3
  )
  on conflict (id) do nothing;

  insert into public.criteria (id, misconception_id, criterion_text, criterion_text_en, sort_order) values
  ('11111111-1111-4111-8111-111111111301', v_s1_id, 'Menyebut LIFO atau menjelaskan terakhir masuk pertama keluar', 'Mentions LIFO or explains last in, first out', 1),
  ('11111111-1111-4111-8111-111111111302', v_s1_id, 'Memberi contoh nyata yang tepat seperti tumpukan piring, buku, atau Undo', 'Gives an accurate real-world example like stacked plates, books, or Undo', 2),
  ('11111111-1111-4111-8111-111111111303', v_s1_id, 'Menjelaskan operasi push (menaruh di atas) dan pop (mengambil dari atas)', 'Explains push (adding to the top) and pop (removing from the top)', 3),

  ('11111111-1111-4111-8111-111111111304', v_s2_id, 'Menyebut hanya elemen teratas (top) yang bisa diakses atau diambil langsung', 'States that only the top element can be accessed or removed directly', 1),
  ('11111111-1111-4111-8111-111111111305', v_s2_id, 'Menjelaskan elemen di atasnya harus dikeluarkan (di-pop) dulu secara berurutan', 'Explains that elements above it must be popped off in order first', 2),
  ('11111111-1111-4111-8111-111111111306', v_s2_id, 'Memberi contoh atau ilustrasi seperti tumpukan piring/buku atau fitur Undo berurutan', 'Gives an example or illustration such as stacked plates/books or sequential Undo', 3),

  ('11111111-1111-4111-8111-111111111307', v_s3_id, 'Menyebut stack memiliki batas kapasitas atau ruang memori terbatas', 'States that a stack has a maximum capacity or limited memory', 1),
  ('11111111-1111-4111-8111-111111111308', v_s3_id, 'Menjelaskan push saat penuh akan gagal atau menyebabkan stack overflow', 'Explains that pushing when full fails or causes stack overflow', 2),
  ('11111111-1111-4111-8111-111111111309', v_s3_id, 'Memberi contoh nyata atau kasus seperti tumpukan roboh atau rekursi tanpa berhenti', 'Gives a real example or case like an overflowing pile or infinite recursion', 3)
  on conflict (id) do nothing;

  -- 2. Topic: Linked List (inactive draft, ID only)
  insert into public.topics (id, title_id, title_en, description_id, description_en, sort_order, is_active)
  values (
    v_ll_id,
    'Linked List',
    'Linked List',
    'Memahami node dan pointer, akses berurutan dari head, serta penyambungan ulang saat menghapus node.',
    'Understand nodes and pointers, sequential traversal from head, and relinking when deleting nodes.',
    2,
    false
  )
  on conflict (id) do nothing;

  insert into public.misconceptions (
    id, topic_id, misconception_text, correct_concept, buddy_intro, sort_order
  ) values
  (
    v_l1_id, v_ll_id,
    'Linked list sama dengan array di memori',
    'Node linked list tersebar di memori dan dihubungkan oleh pointer next; menyisipkan atau menghapus node tidak perlu menggeser elemen lain.',
    'Aku kira linked list itu sama aja kayak array, datanya nyambung berurutan rapat di memori. Bener gitu, kan?',
    1
  ),
  (
    v_l2_id, v_ll_id,
    'Elemen ke-5 bisa diloncati langsung seperti array[4]',
    'Linked list tidak punya akses indeks acak; harus menelusuri satu per satu dari head sehingga posisi yang lebih jauh lebih lambat diakses.',
    'Kalau aku mau ambil data kelima di linked list, tinggal loncat langsung ke sana kayak array[4], kan?',
    2
  ),
  (
    v_l3_id, v_ll_id,
    'Setelah hapus node tengah, list tersambung sendiri',
    'Penunjuk node sebelumnya harus diarahkan secara manual ke node setelah node yang dihapus agar list tidak terputus.',
    'Kalau aku hapus node yang di tengah, terus sisa node-nya langsung nyambung sendiri ya? Nggak perlu diapa-apain lagi?',
    3
  )
  on conflict (id) do nothing;

  insert into public.criteria (id, misconception_id, criterion_text, sort_order) values
  ('22222222-2222-4222-8222-222222222301', v_l1_id, 'Menyebut node dan pointer (next) sebagai penghubung antar data', 1),
  ('22222222-2222-4222-8222-222222222302', v_l1_id, 'Menjelaskan lokasi node tersebar di memori dan tidak harus berurutan seperti array', 2),
  ('22222222-2222-4222-8222-222222222303', v_l1_id, 'Menjelaskan sisip atau hapus node tidak perlu menggeser semua elemen lain', 3),

  ('22222222-2222-4222-8222-222222222304', v_l2_id, 'Menyebut harus menelusuri (traversal) dari head satu per satu', 1),
  ('22222222-2222-4222-8222-222222222305', v_l2_id, 'Menjelaskan tidak ada akses indeks langsung seperti array', 2),
  ('22222222-2222-4222-8222-222222222306', v_l2_id, 'Menyebut akses lebih lambat seiring posisi makin jauh (menyebut O(n) nilai tambah)', 3),

  ('22222222-2222-4222-8222-222222222307', v_l3_id, 'Menyebut pointer node sebelumnya harus diarahkan ke node setelah yang dihapus (prev.next nilai tambah)', 1),
  ('22222222-2222-4222-8222-222222222308', v_l3_id, 'Menjelaskan tanpa pengubahan pointer, list terputus dan node berikutnya tidak terjangkau dari head', 2),
  ('22222222-2222-4222-8222-222222222309', v_l3_id, 'Memberi contoh 3 node (mis. A -> B -> C, hapus B lalu A menunjuk ke C)', 3)
  on conflict (id) do nothing;
end $$;
