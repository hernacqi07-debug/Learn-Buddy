-- Learn Buddy — Migration 0008: Avatar Column, 8 Topics Learning Content, & Course-Scoped RLS
-- Target: Supabase PostgreSQL 17

-- 1. Ensure profiles.avatar_url exists
alter table public.profiles
  add column if not exists avatar_url text;

-- 2. Populate theory_content, analogy_content, code_snippet, and reading_time_minutes for all 8 remaining active topics
update public.topics
set
  theory_content = 'Queue (Antrean) adalah struktur data linier yang bekerja dengan prinsip FIFO (First-In, First-Out). Elemen yang pertama kali masuk melalui bagian belakang (REAR/TAIL) akan menjadi elemen pertama yang keluar dari bagian depan (FRONT/HEAD). Operasi utamanya adalah enqueue (menambah data di belakang), dequeue (mengambil data di depan), dan peek/front (melihat elemen terdepan).',
  analogy_content = 'Bayangkan antrean pembeli tiket di kasir atau loket bioskop. Orang yang datang lebih dulu berdiri paling depan dan dilayani lebih dahulu, sedangkan orang baru yang datang harus masuk di baris paling belakang.',
  code_snippet = E'import ''dart:collection'';\n\nvoid main() {\n  final queue = Queue<String>();\n  queue.addLast(''Antre A''); // Enqueue\n  queue.addLast(''Antre B'');\n  print(queue.removeFirst()); // Dequeue -> Antre A\n  print(queue.first);         // Front   -> Antre B\n}',
  reading_time_minutes = 5
where id = '9af7ea7d-6e66-45c7-9ba7-36ddaac6644b';

update public.topics
set
  theory_content = 'Linked List adalah struktur data linier dinamis yang terdiri dari kumpulan Node. Setiap Node menyimpan dua bagian: data (nilai) dan pointer/referensi (next) yang menunjuk ke Node berikutnya. Node pertama disebut HEAD, dan Node terakhir menunjuk ke null. Berbeda dengan array, Linked List tidak membutuhkan blok memori bersebelahan dan mudah untuk menyisipkan atau menghapus elemen di awal/tengah.',
  analogy_content = 'Bayangkan rangkaian gerbong kereta api atau permainan berburu harta karun. Setiap gerbong membawa penumpang (data) sekaligus pengait (pointer next) yang terhubung ke gerbong berikutnya hingga gerbong terakhir.',
  code_snippet = E'class Node<T> {\n  T data;\n  Node<T>? next;\n  Node(this.data, [this.next]);\n}\n\nvoid main() {\n  final n3 = Node(30);\n  final n2 = Node(20, n3);\n  final head = Node(10, n2);\n  for (var cur = head; cur != null; cur = cur.next) {\n    print(cur.data); // 10, 20, 30\n  }\n}',
  reading_time_minutes = 6
where id = '22222222-2222-4222-8222-222222222101';

update public.topics
set
  theory_content = 'Dalam Pemrograman Berorientasi Objek (OOP) di Java, Class adalah cetak biru (blueprint) atau rancangan yang mendefinisikan atribut (field/properti) dan perilaku (method). Object adalah wujud nyata (instance) yang dibuat dari Class menggunakan kata kunci new. Dari satu Class, kita dapat membuat banyak Object berbeda yang masing-masing memiliki nilai atribut sendiri.',
  analogy_content = 'Class ibarat cetakan kue atau denah arsitektur rumah, sedangkan Object adalah kue atau rumah nyata yang dihasilkan dari cetakan tersebut. Satu denah rumah bisa dibangun menjadi banyak rumah dengan warna cat berbeda.',
  code_snippet = E'public class Mobil {\n  String merk;\n  int kecepatan;\n\n  public Mobil(String merk) {\n    this.merk = merk;\n  }\n\n  public void gas() {\n    kecepatan += 10;\n    System.out.println(merk + " melaju " + kecepatan + " km/j");\n  }\n}\n\n// Membuat Object:\nMobil m1 = new Mobil("Avanza");\nm1.gas();',
  reading_time_minutes = 5
where id = '33333333-3333-4333-8333-333333333301';

update public.topics
set
  theory_content = 'Enkapsulasi (Encapsulation) adalah mekanisme membungkus data (atribut) dan method dalam satu Class serta menyembunyikan detail internal menggunakan access modifier private. Akses dan perubahan data dari luar Class dilakukan secara terkontrol melalui method public Getter dan Setter, sehingga kita dapat menambahkan validasi agar data tidak rusak (misalnya saldo tidak boleh negatif).',
  analogy_content = 'Bayangkan mesin ATM atau kapsul obat. Nasabah tidak bisa langsung mengambil uang dari brankas di dalam mesin ATM; semua transaksi harus melewati antarmuka resmi (PIN, cek saldo, tarik tunai) yang memvalidasi aturan.',
  code_snippet = E'public class RekeningBank {\n  private double saldo;\n\n  public double getSaldo() {\n    return saldo;\n  }\n\n  public void setor(double jumlah) {\n    if (jumlah > 0) {\n      saldo += jumlah;\n    }\n  }\n}',
  reading_time_minutes = 5
where id = '33333333-3333-4333-8333-333333333302';

update public.topics
set
  theory_content = 'Pewarisan (Inheritance) memungkinkan sebuah kelas anak (Subclass) mewarisi atribut dan method dari kelas induk (Superclass) menggunakan kata kunci extends. Subclass dapat menambahkan fitur baru atau menimpa perilaku method milik induknya menggunakan @Override (polimorfisme), sehingga kode menjadi lebih rapi dan dapat digunakan kembali (reusable).',
  analogy_content = 'Seperti silsilah kendaraan: Kendaraan adalah induk yang punya roda dan bisa bergerak. Mobil dan Motor adalah anak yang mewarisi sifat Kendaraan, namun masing-masing punya cara khusus sendiri (misalnya jumlah roda atau bunyi klakson).',
  code_snippet = E'class Hewan {\n  void bersuara() {\n    System.out.println("Hewan bersuara");\n  }\n}\n\nclass Kucing extends Hewan {\n  @Override\n  void bersuara() {\n    System.out.println("Meong!");\n  }\n}',
  reading_time_minutes = 6
where id = '33333333-3333-4333-8333-333333333303';

update public.topics
set
  theory_content = 'Di Python, List ([ ]) dan Tuple (( )) sama-sama menyimpan koleksi data berurutan yang bisa diakses lewat indeks. Perbedaan mendasarnya adalah mutabilitas: List bersifat mutable (elemen dapat diubah, ditambah dengan append, atau dihapus), sedangkan Tuple bersifat immutable (tidak dapat diubah setelah dibuat; mencoba mengubah elemennya akan memicu TypeError). Tuple cocok untuk data tetap seperti koordinat GPS atau konfigurasi.',
  analogy_content = 'List seperti papan tulis yang isinya bisa dihapus, ditulis ulang, atau ditambah kapan saja. Tuple seperti prasasti batu atau tiket cetak: sekali dibuat, isinya tetap aman dan tidak bisa diubah sembarangan.',
  code_snippet = E'buah = ["apel", "jeruk"]   # List (mutable)\nbuah.append("mangga")       # Berhasil\nbuah[0] = "pisang"          # Berhasil\n\nkoordinat = (-6.20, 106.81) # Tuple (immutable)\n# koordinat[0] = -7.0       # Error: TypeError!',
  reading_time_minutes = 5
where id = '44444444-4444-4444-8444-444444444401';

update public.topics
set
  theory_content = 'Dictionary ({key: value}) di Python menyimpan data dalam pasangan kunci (key) dan nilai (value). Setiap key harus unik dan bersifat immutable (seperti string atau integer). Pencarian nilai menggunakan key sangat cepat (rata-rata O(1)) karena Python menggunakan struktur tabel hash di balik layar. Gunakan method .get(key, default) agar aman saat key tidak ditemukan.',
  analogy_content = 'Dictionary persis seperti kamus bahasa atau buku kontak di HP. Kamu tidak perlu membuka satu per satu halaman dari awal; cukup cari berdasarkan kata/nama (key) untuk langsung mendapatkan artinya atau nomor teleponnya (value).',
  code_snippet = E'siswa = {\n  "nama": "Ani",\n  "umur": 17,\n  "nilai": 95\n}\nprint(siswa["nama"])             # Ani\nprint(siswa.get("kelas", "XI"))  # XI (aman tanpa KeyError)\nsiswa["nilai"] = 98              # Update value',
  reading_time_minutes = 5
where id = '44444444-4444-4444-8444-444444444402';

update public.topics
set
  theory_content = 'Perulangan (Loop) di Python terdiri dari for (mengulang sejumlah elemen atau rentang dengan range()) dan while (mengulang selama kondisi bernilai True). Fungsi (def) membungkus blok kode agar dapat dipanggil berulang kali dengan parameter dan mengembalikan hasil menggunakan return (berbeda dengan print yang hanya menampilkan ke layar tanpa mengembalikan nilai ke pemanggil).',
  analogy_content = 'Loop seperti mesin fotokopi yang mencetak 10 lembar otomatis tanpa kita harus menekan tombol satu per satu. Fungsi seperti resep masakan bernama "buat_kopi(gula)" yang bisa dipanggil kapan pun dibutuhkan dan menghasilkan secangkir kopi (return).',
  code_snippet = E'def hitung_kuadrat(n):\n  return n * n\n\nfor i in range(1, 5):\n  hasil = hitung_kuadrat(i)\n  print(f"{i}^2 = {hasil}")',
  reading_time_minutes = 5
where id = '44444444-4444-4444-8444-444444444403';

-- 3. Remove legacy permissive policies on assignments
drop policy if exists "Allow read assignments" on public.assignments;
drop policy if exists "Allow insert assignments" on public.assignments;
drop policy if exists "Allow update assignments" on public.assignments;
