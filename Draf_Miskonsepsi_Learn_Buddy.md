# Draf Miskonsepsi Learn Buddy — dari Daftar Topik (tanpa Modul Lengkap)

**Status:** draf v2 — diperbarui 12 November 2026 (10:48 WIB), topik pembuka **Stack** disetujui Rid
**Sumber topik:** screenshot silabus Struktur Data kiriman Rid, 12 Nov 09:45 WIB
**Catatan penting:** Rid tidak memiliki modul lengkapnya. Draf ini disusun dari konsep standar Struktur Data + pengalaman Rid sendiri (laprak Modul 4 Stack & Modul 5 Queue, tugas Searching, PPT Linked List Rekursif dari video Neso Academy). Semua miskonsepsi di bawah ini **harus dicek Rid** — terutama istilah yang dipakai dosennya — sebelum masuk ke database.

## Daftar Topik (dari screenshot)

| Minggu | Topik |
|---|---|
| 1 | Memahami struktur data linked-list 1 |
| 2 | Memahami struktur data linked-list |
| 3 | Memahami bentuk-bentuk linked-list dan penerapannya |
| 4 | Memahami struktur data stack dan penerapannya |
| 5 | Memahami struktur data queue dan penerapannya |
| 6 | Memahami struktur data tree dan penerapannya |
| 8 | Ujian Tengah Semester (UTS) |
| 10 | Memahami algoritma searching |
| 11 | Memahami algoritma sorting (pengurutan) |

Tidak tercantum di screenshot: minggu 7, 9, dan 12 ke atas. Perlu dikonfirmasi Rid apakah ada topik lain di minggu-minggu itu, atau memang kosong/libur/UTS dan proyek.

---

## Topik Pembuka (DIPUTUSKAN Rid 12 Nov 10:48)

**Pilihan A — Stack (DISETUJUI sebagai topik pembuka MVP).** Miskonsepsinya paling jelas dan paling objektif dinilai Evaluator (FIFO vs LIFO, akses tengah, overflow). **Linked List** disiapkan sebagai topik ke-2, disusul Queue dan Tree.

Format per miskonsepsi mengikuti skema database di `Arsitektur_Learn_Buddy.md`:
`miskonsepsi` (yang diyakini Buddy) → `konsep_benar` (hanya untuk evaluator + guru) → `kriteria_paham` → `buddy_intro` (kalimat pembuka Buddy).

---

## Topik 1 — Stack (Minggu 4)

### Miskonsepsi S-1: Stack itu seperti antrean (FIFO)

- **Miskonsepsi (Buddy):** "Stack itu seperti antrean, kan? Yang masuk duluan keluar duluan."
- **Konsep benar:** Stack bersifat LIFO (Last In, First Out). Yang terakhir masuk, pertama keluar.
- **Kriteria paham:**
  1. Menyebut LIFO / "terakhir masuk, pertama keluar"
  2. Memberi contoh nyata (tumpukan piring, tumpukan buku, tombol Undo)
  3. Menjelaskan push (menaruh di atas) dan pop (mengambil dari atas)
- **Buddy intro:** "Aku tuh bingung, kemarin antre di kantin yang datang duluan dilayani duluan. Stack juga gitu kan? Yang masuk duluan keluar duluan?"

### Miskonsepsi S-2: Elemen tengah stack bisa diambil langsung

- **Miskonsepsi (Buddy):** "Kalau aku mau ambil piring yang di tengah tumpukan, tinggal ambil aja kan? Nggak perlu angkat yang di atasnya."
- **Konsep benar:** Hanya elemen teratas (top) yang bisa diakses. Untuk mencapai elemen di bawahnya, semua elemen di atasnya harus di-pop dulu.
- **Kriteria paham:**
  1. Menyebut hanya top yang bisa diakses/diambil
  2. Menjelaskan elemen di atasnya harus di-pop dulu
  3. Memberi contoh (Undo harus urut, tidak bisa loncat ke langkah yang lama)
- **Buddy intro:** "Aku mau ambil buku yang di tengah tumpukan, tapi kok susah ya? Emang nggak bisa diambil langsung dari tengah?"

### Miskonsepsi S-3: Stack tidak pernah penuh

- **Miskonsepsi (Buddy):** "Stack kan bisa di-push terus, nggak ada habisnya. Nggak mungkin penuh."
- **Konsep benar:** Stack punya batas kapasitas. Push ke stack yang sudah penuh gagal / menyebabkan stack overflow. Contoh nyata: rekursi yang terlalu dalam.
- **Kriteria paham:**
  1. Menyebut stack punya batas/kapasitas
  2. Menjelaskan push saat penuh gagal atau overflow
  3. Memberi contoh (tumpukan piring yang roboh, rekursi tanpa berhenti)
- **Buddy intro:** "Aku push data terus-terusan ke stack, aman-aman aja kan? Stack itu nggak ada batasnya, ya?"

---

## Topik 2 — Linked List (Minggu 1–3)

### Miskonsepsi L-1: Linked list sama dengan array

- **Miskonsepsi (Buddy):** "Linked list itu sama aja kayak array, kan? Datanya tersimpan berurutan di memori."
- **Konsep benar:** Node linked list tersebar di memori dan dihubungkan oleh pointer (`next`). Tidak ada jaminan posisi berurutan, dan tidak ada akses indeks langsung.
- **Kriteria paham:**
  1. Menyebut node + pointer / `next`
  2. Menjelaskan node tersebar, dihubungkan pointer, bukan tersimpan berurutan
  3. Menjelaskan kelebihan: sisip/hapus tidak perlu menggeser semua elemen
- **Buddy intro:** "Aku kira linked list itu kayak array, datanya nyambung berurutan di memori. Bener gitu, kan?"

### Miskonsepsi L-2: Elemen ke-5 bisa diloncati langsung seperti array[4]

- **Miskonsepsi (Buddy):** "Mau ambil data ke-5 tinggal loncat aja langsung ke sana, kayak `array[4]`, kan?"
- **Konsep benar:** Tidak ada akses acak. Harus traversal dari `head`, satu node demi satu node, sampai ke posisi yang dicari. Makin jauh posisinya, makin lama.
- **Kriteria paham:**
  1. Menyebut traversal / jalan dari `head` satu per satu
  2. Menjelaskan tidak ada akses indeks langsung seperti array
  3. Menyebut akses lebih lambat seiring posisi makin jauh karena harus menelusuri satu per satu (menyebut `O(n)` adalah nilai tambah, bukan syarat wajib)
- **Buddy intro:** "Kalau aku mau data yang kelima, aku loncat aja langsung ke sana. Kan sama aja kayak array?"

### Miskonsepsi L-3: Setelah hapus node tengah, list tersambung sendiri

- **Miskonsepsi (Buddy):** "Kalau node tengah dihapus, list-nya nyambung sendiri kan? Kan sudah otomatis."
- **Konsep benar:** Pointer node sebelumnya harus diubah manual agar menunjuk ke node setelah yang dihapus. Kalau tidak, list terputus dan node setelahnya tidak bisa dijangkau dari `head`.
- **Kriteria paham:**
  1. Menyebut penunjuk/pointer node sebelumnya harus diarahkan ke node setelah yang dihapus (menulis `prev.next = hapus.next` adalah nilai tambah, bukan syarat wajib)
  2. Menjelaskan tanpa itu list terputus / node setelahnya hilang dari jangkauan
  3. Memberi contoh hapus node tengah dengan 3 node (A → B → C, hapus B, A harus menunjuk C)
- **Buddy intro:** "Aku hapus node yang di tengah, terus list-nya langsung nyambung sendiri, ya? Kan nggak perlu diapa-apain lagi."

---

## Topik 3 — Queue (Minggu 5, draf singkat)

### Miskonsepsi Q-1: Queue itu LIFO seperti stack

- **Miskonsepsi (Buddy):** "Queue sama aja kayak stack, yang terakhir masuk keluar duluan."
- **Konsep benar:** Queue bersifat FIFO. Masuk lewat `rear` (enqueue), keluar lewat `front` (dequeue).
- **Kriteria paham:**
  1. Menyebut FIFO / "masuk duluan, keluar duluan"
  2. Menjelaskan enqueue di belakang dan dequeue di depan
  3. Memberi contoh nyata (antrean kasir, antrean printer)
- **Buddy intro:** "Queue itu kayak stack kan? Yang terakhir datang dilayani duluan?"

### Miskonsepsi Q-2: Dequeue mengambil dari belakang

- **Miskonsepsi (Buddy):** "Dequeue itu ambil dari belakang antrean, kan? Yang baru datang langsung dilayani."
- **Konsep benar:** Dequeue selalu dari `front` (depan). Yang baru datang harus antre di belakang.
- **Kriteria paham:**
  1. Menyebut dequeue dari depan / `front`
  2. Menjelaskan yang baru datang masuk ke belakang
  3. Menyebut `front` dan `rear` sebagai dua ujung yang berbeda
- **Buddy intro:** "Kalau dequeue, kita ambil orang yang paling belakang ya? Soalnya dia yang paling baru?"

---

## Topik 4 — Tree (Minggu 6, draf singkat)

### Miskonsepsi T-1: Tree sama dengan linked list biasa

- **Miskonsepsi (Buddy):** "Tree itu kan linked list juga, satu node nyambung ke satu node lain. Sama aja."
- **Konsep benar:** Node tree bisa punya lebih dari satu anak (di binary tree maksimal 2: kiri dan kanan). Ada konsep root, parent, child, leaf, dan level yang tidak ada di linked list biasa.
- **Kriteria paham:**
  1. Menyebut satu node bisa punya lebih dari satu anak / cabang
  2. Menyebut root sebagai titik awal dan leaf sebagai ujung
  3. Memberi contoh (silsilah keluarga, struktur folder)
- **Buddy intro:** "Tree itu linked list yang bercabang dikit, ya? Intinya sama aja, satu node nyambung ke node lain."

### Miskonsepsi T-2: Semua node di binary tree punya dua anak

- **Miskonsepsi (Buddy):** "Binary tree itu berarti semua node pasti punya dua anak, kiri dan kanan. Kalau cuma satu, bukan binary tree."
- **Konsep benar:** "Binary" berarti maksimal dua anak, bukan wajib dua. Node boleh punya 0, 1, atau 2 anak. Node tanpa anak disebut leaf.
- **Kriteria paham:**
  1. Menyebut maksimal dua anak, bukan wajib dua
  2. Menyebut node boleh punya 0 atau 1 anak
  3. Menyebut leaf sebagai node tanpa anak
- **Buddy intro:** "Binary tree itu semua nodenya punya dua anak, ya? Kalau ada yang cuma satu anak, berarti bukan binary tree dong?"

---

## Topik 5–6 — Searching & Sorting (Minggu 10–11, belum dibuat)

Belum dibuat drafnya karena urutannya setelah UTS dan bentuk miskonsepsinya berbeda (lebih ke algoritma dan perbandingan efisiensi, bukan struktur data). Dibuat setelah topik pembuka selesai, atau sekaligus kalau Rid mau.

Calon miskonsepsi (ide awal, belum draf):
- Searching: "Binary search bisa dipakai di data yang belum diurutkan."
- Sorting: "Sorting yang paling cepat selalu yang paling bagus, tidak peduli datanya."

---

## Status Keputusan Konten (Update 12 Nov 10:48)

1. **Topik pembuka — DIPUTUSKAN 12 Nov 10:48:** **Stack** (Pilihan A), dengan Linked List sebagai topik ke-2.
2. **Istilah operasi — DIPUTUSKAN 12 Nov 10:48:** `push/pop`, `enqueue/dequeue`, `head`, `front/rear`, `root/leaf` tetap dipakai.
3. **Kedalaman materi SMK — DIPUTUSKAN 12 Nov 10:48:** `O(n)` dan `prev.next` dinilai secara konseptual (notasi/sintaks hanya nilai tambah).
4. **Masih terbuka (opsional pasca-UTS):** isi silabus Minggu 7, 9, 12+.
5. **Koreksi isi:** tetap terbuka bila nanti ditemukan bagian yang kurang sesuai dengan catatan kuliah Rid.
