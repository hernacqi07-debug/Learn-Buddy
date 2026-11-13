# Ringkasan Project: Learn Buddy

**Aplikasi mobile pembelajaran Struktur Data: belajar dengan mengajari AI**

Disusun untuk Farid · 12 November 2026 · Mata kuliah Pengembangan Bahan Ajar (PTI UNESA, Dr. Muhammad Hakiki) · Status: tahap perancangan, arsitektur & aturan sesi diperbarui
**Versi:** v3 — diperbarui 12 November 2026, 10:48 WIB, dari seluruh diskusi sesi ini

Dokumen pendukung (satu paket dengan ringkasan ini):
- Arsitektur lengkap → `Arsitektur_Learn_Buddy.md`
- Draf miskonsepsi per topik → `Draf_Miskonsepsi_Learn_Buddy.md`
- Draf prompt Evaluator & Buddy → `Draf_Prompt_Evaluator_Buddy.md`

---

## Perubahan di v3 (dari v2, 12 Nov 10:48 WIB)

- **Target akhir 100% & status `incomplete`:** Sesi baru otomatis berhenti jika Meter Paham mencapai **100%** atau **20 input** tercapai. Jika 20 input habis dengan meter **≥ 80%** (atau berhenti manual saat sudah ≥ 80%), status terhitung **`completed`** (tuntas). Jika 20 input habis dengan meter **< 80%**, status terhitung **`incomplete`** (terpisah dari `abandoned` untuk berhenti manual di < 80%).
- **Auto-geser miskonsepsi (`stale_turns`):** Miskonsepsi aktif berpindah berurutan jika seluruh kriteria miskonsepsi aktif terpenuhi, **atau** setelah **4 input berturut-turut** tanpa ada kriteria baru yang terpenuhi (supaya siswa tidak terjebak di satu miskonsepsi sampai 20 input habis). Sisa kriteria yang terlewat tetap `false` di Rekap.
- **Sinkronisasi Skema DB & RLS:** Penambahan kolom `*_en` di `misconceptions` & `criteria`, kolom `active_misconception_id` + `stale_turns` di `sessions`, tabel `turn_logs` & `teacher_invite_codes`, serta proteksi RLS agar `correct_concept`, `criteria`, dan perubahan `profiles.role` tidak bisa diakses/dimanipulasi siswa.
- **Keputusan ACC 1–6 (12 Nov 10:48 WIB):** topik pembuka **Stack** (Linked List topik ke-2); **snapshot kriteria** (`criterion_text_snapshot`) disetujui; `O(n)` dan `prev.next` dinilai **konseptual** (istilah `push/pop`, `head`, `front/rear`, `root/leaf` tetap dipakai); model Gemini sementara **`gemini-2.5-flash`**; aset 2D Buddy **generate AI + rapikan** (6 PNG transparan 512px); **`{{correct_concept}}` dihapus dari prompt Buddy**.

---

## Perubahan di v2 (dari v1)

Semua perubahan di bawah ini berasal dari jawaban Rid pada 12 Nov 2026 dan diskusi sesi ini:

- **Bukan Unity.** Learn Buddy dibangun dengan **Flutter / Android Studio**. Unity hanya sempat ditanyakan 11 Nov, tidak dipakai untuk proyek ini.
- **Batas sesi: 20 input chat siswa**, bukan 10 giliran.
- **Guru TIDAK bisa melihat isi riwayat chat siswa** — hanya progres dan rekap. Ditegakkan di database (RLS), bukan sekadar disembunyikan di UI.
- **LLM pengganti sudah ditentukan: DeepSeek.** Gemini free tier hanya sementara, sampai Rid membeli API key DeepSeek **17 Nov 2026**.
- **Supabase project baru**, terpisah dari project cafe (PM.CoffeShop).
- **Bahasa aplikasi dipilih di Settings** (Indonesia / English). Buddy bisa keduanya, bahasa dipilih per sesi.
- **Akun dibuat manual di halaman Login** (register dengan pilih peran siswa/guru). Guru = Rid sebagai demo dulu, lalu guru sebenarnya.
- **Target waktu diperketat:** deadline SiDia 10 Des 2026, tapi target Rid **clear done 100% dalam 2 minggu, masih di bulan November 2026**.
- **Karakter 2D terinspirasi Duolingo**, 6 ekspresi.
- **HP uji Vivo X300 Pro adalah HP Rid sendiri**, mendukung ARCore.
- **Uji coba ke teman dan/atau dosen**, tanpa target kelas SMK khusus.
- **Topik sudah ada daftarnya** (dari screenshot silabus, lihat bagian 12). Rid **tidak memiliki modul lengkapnya** — draf miskonsepsi dibuat dari konsep standar + pengalaman Rid (laprak Modul 4 Stack & 5 Queue, tugas Searching, PPT Linked List Rekursif).
- **Manual book tanpa template.** Isi: Teori, Flowchart, Screenshot (+ hasil uji).
- **Meter Paham didiskusikan detail nanti** — arsitektur sudah dibuat fleksibel untuk itu.
- **Rekan kelompok pasif tetap dicantumkan namanya.**

---

## 1. Tujuan & Konteks

- Tugas proyek: **aplikasi mobile pembelajaran dengan fitur unggulan** yang berbeda dari LMS pada umumnya.
- Konsep: siswa belajar dengan **mengajari Buddy**, murid AI yang memiliki miskonsepsi tersembunyi. Buddy hanya "paham" jika penjelasan siswa benar.
- Target pengguna: **siswa SMK**, mapel **Struktur Data**. Tanpa target kelas khusus. Daftar topik sudah ada (bagian 12); Rid tidak memiliki modul lengkapnya, jadi konten diturunkan dari konsep standar + pengalaman kuliah Rid.
- Output tugas: **aplikasi Android + manual book**. Tidak ada rubrik, model pengembangan khusus, maupun TP/CP.
- Pelaksana: **1 orang** (kelompok 2 orang, rekan pasif, namanya tetap dicantumkan). Target selesai **2 minggu (masih November 2026)**; deadline SiDia **10 Des 2026** sebagai buffer.

## 2. Masalah yang Diselesaikan

- Siswa merasa paham padahal hanya hafal; kuis pilihan ganda tidak menunjukkan apakah konsep benar-benar dimengerti.
- Struktur data bersifat abstrak dan sering disalahpahami (contoh: stack dianggap antrean).
- Aplikasi belajar umum bersifat satu arah (baca lalu kuis) dan kurang melatih kemampuan menjelaskan.
- Guru sulit melihat miskonsepsi spesifik tiap siswa; yang terlihat hanya skor. Learn Buddy memberi guru progres per kriteria (miskonsepsi mana yang sudah diluruskan), tanpa membuka isi chat siswa.

## 3. Landasan Pedagogi

- **Learning by teaching (protégé effect):** menjelaskan ke orang lain memaksa siswa menyusun pemahamannya sendiri.
- **Pembelajaran berbasis miskonsepsi:** meluruskan salah paham lebih tajam daripada mengulang materi yang benar.
- **Prinsip multimedia / kedekatan spasial (untuk AR):** visual 3D membantu memahami konsep abstrak.

Rujukan teori dan jurnal dilengkapi pada manual book.

## 4. Fitur Utama

| Fitur | Deskripsi | Status |
|---|---|---|
| ⭐ Chat mengajar Buddy | Siswa menjelaskan konsep lewat teks; Buddy bertanya balik sesuai miskonsepsinya. | MVP — **Unggulan 1 (disetujui Rid 12 Nov)** |
| ⭐ Evaluator + Meter Paham | Evaluator AI terpisah menilai penjelasan terhadap kriteria (JSON); keputusan paham diambil kode aplikasi. Rumus: kriteria terpenuhi / total kriteria × 100%, bobot sama rata, hanya naik, target akhir 100% (tuntas/completed bila ≥ 80% dalam 20 input), tampilkan angka % ke siswa. | MVP — **Unggulan 2 (disetujui Rid 12 Nov)** |
| ⭐ Rekap miskonsepsi | Daftar miskonsepsi yang berhasil diluruskan di akhir sesi. | MVP — **Unggulan 3 (disetujui Rid 12 Nov)** |
| Halaman siswa | Pilih topik, sesi mengajar, riwayat sesi. Siswa boleh hapus riwayat chat sendiri. | MVP |
| Halaman guru | Kelola topik, miskonsepsi, dan kriteria; lihat progres siswa (meter, kriteria terpenuhi, jumlah sesi). **Tidak bisa melihat isi chat siswa.** | MVP |
| Bahasa Indonesia & English | Bahasa aplikasi dipilih di Settings (ID/EN). Buddy bisa keduanya, bahasa dipilih per sesi (default mengikuti bahasa aplikasi). Sesi English = Buddy full English, tanpa selipan Indonesia (diputuskan Rid 12 Nov 10:02). Konten EN: "Terjemahkan sekali saat guru input, lalu simpan" (Rid 12 Nov 10:27) — tombol Terjemahkan ke English di Kelola Konten, LLM terjemahkan sekali, guru cek & edit, baru disimpan; sesi English terkunci sampai versi EN tersimpan. | MVP |
| Akun manual | Akun siswa dan guru dibuat manual di halaman Login (register dengan pilih peran). | MVP |
| AR Buddy (Level 2 saja) | Visualisasi struktur data 3D di dunia nyata lewat kamera HP (mis. tumpukan blok Stack). Level 1 (Buddy 3D di meja) DICORET atas permintaan Rid 12 Nov 10:17. | Stretch |
| Input suara/gambar, gamifikasi lanjutan | Dikembangkan setelah MVP stabil. | Nanti |

## 5. Karakter Buddy

- Persona: murid SMK yang ramah, penasaran, dan sedikit polos.
- Memiliki **miskonsepsi tersembunyi** per topik dan tidak membocorkan jawaban benar.
- Berubah paham hanya jika kriteria terpenuhi; keputusan "paham" diambil oleh **kode aplikasi** dari hasil evaluator, bukan oleh Buddy sendiri.
- **Tampilan: 2D** dengan 6 ekspresi (bingung, berpikir, ragu, mulai paham, paham, senang), dipetakan dari Meter Paham. Gaya visual terinspirasi Duolingo (bukan aset Duolingo asli). Model 3D hanya dibuat untuk AR.

## 6. Alur Penggunaan

1. Siswa login dan memilih topik.
2. Siswa memilih bahasa sesi (default mengikuti bahasa aplikasi).
3. Buddy menyampaikan miskonsepsinya.
4. Siswa menjelaskan lewat teks (maksimal 20 input per sesi; batas panjang pesan 800 karakter (diputuskan Rid 12 Nov 10:02)).
5. Evaluator menilai penjelasan terhadap kriteria (keluaran JSON).
6. Aplikasi memperbarui Meter Paham.
7. Buddy bereaksi sesuai tingkat pemahaman terkini (ekspresi 2D berubah).
8. Ulangi sampai Meter Paham mencapai **100%**, **20 input** tercapai, atau sesi dihentikan manual:
   - Meter = **100%** (di input ke berapa pun ≤ 20) → otomatis selesai (`completed`).
   - 20 input tercapai dengan meter **≥ 80%** → berhenti & terhitung tuntas (`completed`).
   - 20 input tercapai dengan meter **< 80%** → berhenti dengan status `incomplete`.
   - Berhenti manual sebelum 20 input → `completed` jika sudah ≥ 80%, atau `abandoned` jika masih < 80%.
   - Jika belum tuntas, siswa boleh mencoba sesi baru untuk topik yang sama; meter lama tersimpan sebagai riwayat.
   - Jika siswa *stuck* pada satu miskonsepsi (**4 input berturut-turut** tanpa kriteria baru terpenuhi), miskonsepsi aktif otomatis bergeser ke miskonsepsi berikutnya agar siswa tidak menghabiskan 20 input di satu bagian saja.
9. Rekap: daftar judul miskonsepsi yang sudah diluruskan dan yang belum (untuk siswa: hanya judul miskonsepsi tanpa hint, tanpa kunci jawaban, dan tanpa daftar kriteria mentah; rincian per kriteria + kutipan bukti hanya untuk guru); sesi, riwayat chat, dan progres tersimpan.

## 7. Peran Pengguna

- **Siswa:** memilih topik, mengajari Buddy, melihat rekap dan riwayat sesi, menghapus riwayat chat sendiri.
- **Guru:** mengelola konten (topik, miskonsepsi, kriteria) dan melihat progres siswa. **Tidak bisa melihat isi riwayat chat siswa.** Guru pertama adalah Rid sebagai demo; setelah tidak ada masalah, dipakai guru sebenarnya.
- **Admin:** **tidak ada** halaman admin. Pengelolaan akun dan data teknis lewat dashboard Supabase.

## 8. Arsitektur & Stack

Detail lengkap → `Arsitektur_Learn_Buddy.md`.

| Lapisan | Pilihan | Catatan |
|---|---|---|
| Aplikasi | Flutter (Android saja), Android Studio | UI chat, Meter Paham, halaman siswa dan guru. Online only. **Bukan Unity.** |
| Routing / State | `go_router`, `flutter_riverpod` | Mengikuti pola proyek cafe Rid supaya familiar. |
| Backend | Supabase project **baru** (PostgreSQL, Auth, Edge Functions) | Terpisah dari project cafe. Peran siswa/guru lewat Auth dan aturan akses data (RLS). |
| AI | Gemini free tier (sementara) → **DeepSeek** (17 Nov 2026) | Dipanggil dari Edge Function; API key di secrets, tidak di dalam aplikasi. Ganti provider cukup ganti environment variable, tanpa ubah aplikasi. |
| AR | ar_flutter_plugin; cadangan model_viewer_plus | HP uji Vivo X300 Pro (milik Rid) sudah mendukung ARCore. |
| Konten | Tabel topik, miskonsepsi, kriteria | Diisi dari daftar topik bagian 12 + draf di `Draf_Miskonsepsi_Learn_Buddy.md`. |

Pemanggilan LLM dibungkus dalam satu fungsi agar penggantian provider (Gemini ke DeepSeek) tidak mengubah aplikasi.

## 9. Desain AI

- **2 panggilan per giliran, 1 API key:** (1) Evaluator menilai penjelasan dan menghasilkan JSON; (2) Buddy membalas sesuai persona dan tingkat pemahaman.
- Keputusan paham/belum diambil kode aplikasi dari JSON evaluator, supaya Buddy tidak tiba-tiba setuju.
- **Batas sesi: maksimal 20 input chat siswa.** Konteks yang dikirim ke LLM hanya 6 pesan terakhir + kriteria, supaya hemat kuota dan respons cepat.
- **Meter Paham (disetujui Rid 12 Nov 09:57, diperbarui 10:44):** rumus = kriteria terpenuhi / total kriteria × 100%, bobot sama rata, kriteria ya/tidak tanpa nilai sebagian, hanya naik (jawaban salah tidak mengurangi meter), per sesi per topik (sesi baru mulai dari 0%), satu miskonsepsi aktif berurutan (Evaluator hanya menilai kriteria miskonsepsi yang sedang aktif; otomatis bergeser ke miskonsepsi berikutnya jika semua kriteria aktif terpenuhi atau setelah **4 input berturut-turut tanpa kriteria baru terpenuhi**). Target akhir tetap **100%**; sesi berhenti otomatis saat mencapai 100% atau 20 input (bila ≥ 80% di 20 input tetap terhitung `completed`/tuntas, bila < 80% berstatus `incomplete`). Tampilkan angka % + bar + label ke siswa beserta checklist miskonsepsi yang sudah diluruskan (tanpa daftar kriteria mentah); guru melihat rincian per kriteria + kutipan bukti.
- Evaluator: temperature 0, output JSON baku. Buddy: temperature 0,7, persona murid SMK yang penasaran.
- Jika JSON evaluator tidak valid, coba sekali lagi; jika masih gagal, anggap tidak ada kriteria baru terpenuhi dan Buddy meminta siswa menjelaskan dengan contoh.

Contoh profil miskonsepsi (data per topik):

```json
{
  "topik": "Stack",
  "miskonsepsi": "Stack itu seperti antrean (FIFO)",
  "konsep_benar": "Stack bersifat LIFO",
  "kriteria_paham": ["menyebut LIFO", "memberi contoh nyata", "menjelaskan push/pop"]
}
```

## 10. Penyimpanan Data

- **Riwayat chat disimpan** di Supabase per sesi, bersama progres (Meter Paham, miskonsepsi terselesaikan).
- Alasan: LLM tidak punya memori, jadi konteks percakapan dikirim ulang tiap giliran; riwayat menjadi bahan uji coba dan manual book.
- **Privasi (diperbarui v2): guru TIDAK bisa melihat isi riwayat chat siswa.** Guru hanya melihat progres: nama siswa, topik, Meter Paham, kriteria yang terpenuhi (+ kutipan bukti per kriteria), jumlah sesi. Pembatasan ini ditegakkan di RLS database, bukan sekadar disembunyikan di UI.
- Siswa diberi tahu bahwa chat disimpan dan diminta tidak menulis data pribadi. Siswa boleh menghapus riwayat chat sendiri (hapus sesi → pesan dan progres ikut terhapus).

## 11. Rencana AR (Bertahap)

- **Dukungan perangkat:** Vivo X300 Pro milik Rid, sudah mendukung ARCore.
- **Level 1: DICORET (Rid 12 Nov 10:17).** Buddy 3D di meja tidak dibuat; model 3D Buddy tidak perlu.
- **Level 2 (satu-satunya AR, stretch):** visualisasi struktur data 3D, misalnya tumpukan blok stack yang berubah dari salah menjadi benar setelah penjelasan siswa. Dibuat per topik (Stack dulu, lalu Linked List, dan seterusnya). Dibuka dari layar Chat (tombol di header chat), bukan dari Beranda/Rekap (Rid 12 Nov 10:18).
- **Cadangan:** model_viewer_plus jika plugin AR bermasalah. AR dikerjakan setelah inti (chat dan evaluator) stabil. Spike test 1 hari di awal untuk memastikan plugin jalan di HP Rid.

## 12. Topik & Draf Miskonsepsi

Daftar topik dari screenshot silabus Struktur Data kiriman Rid (12 Nov 09:45). Rid tidak memiliki modul lengkapnya.

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

Minggu 7, 9, dan 12 ke atas tidak tercantum di screenshot — perlu konfirmasi Rid.

Draf miskonsepsi lengkap (konsep benar + kriteria + kalimat pembuka Buddy) → `Draf_Miskonsepsi_Learn_Buddy.md`. Ringkasnya:

- **Stack (3 miskonsepsi):** Stack dikira antrean FIFO; elemen tengah bisa diambil langsung; stack tidak pernah penuh.
- **Linked List (3 miskonsepsi):** dikira sama dengan array; elemen ke-5 bisa diloncati langsung seperti `array[4]`; setelah hapus node tengah, list tersambung sendiri.
- **Queue (2 miskonsepsi):** Queue dikira LIFO seperti stack; dequeue dikira mengambil dari belakang.
- **Tree (2 miskonsepsi):** Tree dikira sama dengan linked list biasa; semua node binary tree dikira wajib punya dua anak.
- **Searching & Sorting:** belum dibuat drafnya (urutannya setelah UTS).

**Topik pembuka (DISETUJUI Rid 12 Nov 10:48):** **Stack** dulu — miskonsepsinya paling jelas, evaluator paling objektif menilainya, dan visualisasi AR Level 2-nya paling sederhana bila sempat. Linked List menjadi topik ke-2.

## 13. Lingkup MVP

1. Login dan peran siswa/guru (Supabase), akun dibuat manual di halaman Login.
2. 1 topik Struktur Data (**Stack**, 3 miskonsepsi; siap ditambah Linked List / Queue lewat Kelola Konten).
3. Chat Buddy berbasis teks, Indonesia dan English, karakter 2D 6 ekspresi.
4. Evaluator dan Meter Paham (kriteria terpenuhi / total × 100%, target 100%, batas tuntas 80%).
5. Rekap miskonsepsi, penyimpanan sesi dan riwayat chat (siswa bisa hapus sendiri; guru tidak bisa lihat isi chat).
6. Halaman guru: input konten, lihat progres siswa.
7. Stretch: AR Level 2 (visualisasi struktur data 3D; Level 1 dicoret).

## 14. Ditunda / Di Luar Lingkup

- Input suara dan gambar/diagram, gamifikasi (poin, level, badge).
- Pre-test/post-test dan angket Likert (tidak dipakai).
- iOS, mode offline, halaman admin, AR Level 1 (Buddy 3D — dicoret Rid 12 Nov).

## 15. Indikator Keberhasilan

Target di bawah adalah usulan awal dan dapat disesuaikan setelah uji pertama. Seluruhnya diukur dari uji coba ke 4 teman dan/atau dosen dan log aplikasi, tanpa pre/post-test maupun Likert.

| Indikator | Target | Cara ukur |
|---|---|---|
| Alur inti berjalan | 4 dari 4 penguji menyelesaikan 1 sesi penuh tanpa bantuan | Observasi uji coba |
| Akurasi evaluator | Minimal 80% keputusan sesuai penilaian manual pada 20 sampel penjelasan | Uji sampel |
| Buddy tidak membocorkan jawaban | 0 kebocoran pada 10 skenario "memancing jawaban" | Uji skenario |
| Waktu respons | Rata-rata di bawah 8 detik per giliran | Log aplikasi |
| Miskonsepsi terselesaikan | Minimal 60% sesi mencapai ambang Meter Paham 80% dalam 20 input | Data sesi |
| Stabilitas | 0 crash pada alur utama | Uji fungsional |

## 16. Jadwal (Target 2 Minggu, November 2026)

Deadline SiDia 10 Des 2026 adalah buffer; target Rid clear done 100% masih di November.

| Waktu | Fokus | Hasil |
|---|---|---|
| 12–14 Nov | Project Supabase baru + migrasi skema + RLS, Auth + peran, scaffold Flutter | Login/register jalan, DB siap diisi |
| 15–16 Nov | Edge Function `teach-turn` (Gemini), chat dasar + Meter Paham v1, batas 20 input | Alur inti jalan di HP Vivo |
| 17 Nov | **Ganti ke DeepSeek** (Rid beli API key) — ganti environment variable saja, uji ulang evaluator 20 sampel | Provider baru terverifikasi, tanpa ubah aplikasi |
| 18–20 Nov | Konten topik 1 (**Stack**), karakter 2D 6 ekspresi (generate AI + rapikan), halaman guru, rekap | MVP lengkap |
| 21–23 Nov | Bilingual ID/EN, Settings, hapus riwayat, kode undangan guru, uji internal | MVP stabil |
| 24–26 Nov | Uji coba 4 teman/dosen, perbaikan, manual book (Teori + Flowchart + Screenshot) | **Clear done 100%** |
| 27 Nov–10 Des | Buffer + AR Level 2 (jika sempat) | Demo + submit SiDia |

Jika fokus penuh, jadwal bisa dipadatkan menjadi sekitar 1 minggu untuk inti aplikasi, dengan AR dan manual book menyusul.

## 17. Risiko & Mitigasi

| Risiko | Mitigasi |
|---|---|
| Buddy terlalu cepat "paham" | Keputusan di kode aplikasi, evaluator terpisah, uji skenario memancing jawaban. |
| Kuota free tier Gemini habis sebelum 17 Nov | Batas 20 input/sesi, pesan ≤ 800 karakter, konteks 6 pesan terakhir. |
| DeepSeek hasilnya beda dari Gemini | Uji ulang 20 sampel yang sama setelah ganti provider; prompt tidak berubah. |
| Pergantian provider LLM | Satu fungsi pemanggil, format JSON evaluator baku, uji ulang akurasi setelah pindah. |
| Plugin AR Flutter kurang stabil | Spike test di awal; cadangan model_viewer_plus; AR tetap stretch. |
| Cakupan membengkak (1 orang) | Satu topik matang dulu; AR dikerjakan terakhir. |
| API key bocor | Simpan di secrets Edge Function, tidak di dalam APK. |
| Data siswa (riwayat chat) | Pemberitahuan penyimpanan, larangan menulis data pribadi, guru tidak bisa membaca isi chat (RLS), siswa bisa hapus sendiri. |
| Supabase free tier auto-pause | Keep-alive sejak awal; jangan tunggu demo. |
| Pendaftar guru palsu | Kode undangan guru di minggu ke-2. |

## 18. Keputusan Terbuka

- Minggu 7, 9, dan 12+ di silabus: ada topik apa? (Opsional untuk topik lanjutan pasca-UTS; tidak menghambat MVP.)

## 19. Keputusan yang Sudah Diambil

- **Topik pembuka — DIPUTUSKAN 12 Nov 10:48:** **Stack** (3 miskonsepsi); Linked List sebagai topik ke-2.
- **Kedalaman istilah SMK — DIPUTUSKAN 12 Nov 10:48:** istilah `push/pop`, `enqueue/dequeue`, `head`, `front/rear`, `root/leaf` tetap dipakai; `O(n)` dan `prev.next` dinilai secara konseptual (notasi/sintaks hanya nilai tambah).
- **Model Gemini sementara — DIPUTUSKAN 12 Nov 10:48:** **`gemini-2.5-flash`** (hingga pindah ke `deepseek-chat` 17 Nov).
- **Aset karakter 2D — DIPUTUSKAN 12 Nov 10:48:** generate AI dengan style konsisten + dirapikan (PNG transparan 512px, 6 ekspresi). Model 3D Buddy TIDAK dibuat.
- **Snapshot kriteria & prompt Buddy — DIPUTUSKAN 12 Nov 10:48:** `criterion_text_snapshot` disalin saat sesi dibuat; `{{correct_concept}}` dihapus dari prompt Buddy (hanya di Evaluator).
- **Batas panjang pesan — DIPUTUSKAN 12 Nov 10:02:** 800 karakter.

- Nama aplikasi **Learn Buddy**, karakter AI bernama **Buddy** (2D, gaya Duolingo).
- Hanya halaman **siswa dan guru**, tanpa admin.
- **Riwayat chat disimpan; siswa boleh hapus sendiri; guru tidak bisa melihat isi chat.**
- Stack: **Flutter + Supabase (project baru) + Gemini sementara → DeepSeek 17 Nov**; Android saja; online only. **Bukan Unity.**
- Input teks dan Meter Paham dulu; fitur lain dikembangkan nanti.
- Batas sesi **20 input chat**.
- **Meter Paham final (12 Nov 09:57, diperbarui 10:44):** rumus kriteria terpenuhi / total × 100%, bobot sama rata, hanya naik, per sesi per topik, target akhir **100%**, batas tuntas **80%** (jika 20 input habis dengan ≥ 80% terhitung `completed`; jika < 80% berstatus `incomplete`), tampilkan angka %, boleh retry sesi baru bila belum tuntas, auto-geser miskonsepsi aktif jika 4 input berturut-turut tanpa kriteria baru terpenuhi.
- Bahasa aplikasi di Settings (ID/EN); Buddy bisa keduanya.
- Akun dibuat manual di halaman Login; guru = Rid sebagai demo dulu.
- **Halaman Guru — DISETUJUI 12 Nov 10:11:** Dashboard, Detail Progres Siswa (tanpa isi chat), Kelola Konten. Tanpa ekspor CSV; siswa diidentifikasi Nama+Email saja; topik yang sudah punya sesi hanya dinonaktifkan, tidak dihapus. Fungsi guru: pembuat materi, pengatur alur, pendeteksi miskonsepsi kelas, penindak lanjut di kelas nyata. TIDAK ada koreksi manual Evaluator dan TIDAK ada pesan guru ke siswa.
- **Halaman Siswa — DISETUJUI 12 Nov 10:13:** Beranda tampilkan meter terbaik per topik + tombol Lanjutkan Sesi; bahasa sesi dipilih di awal sesi saja; sesi aktif yang ditutup dilanjutkan dari pesan terakhir; Rekap miskonsepsi belum diluruskan hanya tampilkan judulnya tanpa hint.
- **AR — DIPUTUSKAN 12 Nov 10:17–10:18:** HANYA AR Level 2 (visualisasi struktur data 3D), Level 1 (Buddy 3D) DICORET; dibuka dari layar Chat; tetap stretch, tidak memengaruhi Meter/Evaluator.
- **Login & Akun — DISETUJUI 12 Nov 10:19:** register manual (nama, email, password, pilih peran), login email+password, tanpa Google SSO, tanpa mode tamu, Confirm email mati (langsung dapat sesi), password minimal 8 karakter, peran tidak bisa diubah dari aplikasi, tidak ada hapus akun di aplikasi. Kode undangan guru + Lupa password dipasang minggu ke-2 (reset manual via dashboard Supabase saat uji coba).
- **Bilingual & Settings — DISETUJUI 12 Nov 10:28:** bahasa aplikasi di Settings (ID/EN, default ID, langsung diterapkan, tersimpan di profil); bahasa sesi dipilih di awal sesi saja; Settings berisi bahasa + profil (nama bisa diubah, email tidak) + Tentang + Logout; siswa saja bisa hapus riwayat (hapus semua konfirmasi 2x). TIDAK ada ganti peran, ganti password di aplikasi, hapus akun, atau pengaturan notifikasi. Konten EN: "Terjemahkan sekali saat guru input, lalu simpan" (tombol di Kelola Konten, guru cek & edit sebelum simpan; sesi English terkunci sampai versi EN tersimpan).
- Uji coba ke 4 teman dan/atau dosen, tanpa pre/post-test dan Likert.
- HP uji Vivo X300 Pro milik Rid, mendukung ARCore.
- Target clear done 100% dalam 2 minggu (November 2026); deadline SiDia 10 Des 2026.
- Manual book tanpa template: Teori, Flowchart, Screenshot.
- Rekan kelompok pasif tetap dicantumkan namanya.

## 20. Langkah Berikutnya

1. *(Menunggu instruksi eksplisit Rid untuk mulai implementasi — belum ada scaffold/kode yang dibuat.)*
2. Buat project Supabase baru + jalankan migrasi skema + RLS (dari `Arsitektur_Learn_Buddy.md` bagian 6).
3. Scaffold project Flutter `learn_buddy` + Auth + routing peran.
4. Edge Function `teach-turn` (`gemini-2.5-flash`) + prompt Evaluator & Buddy.
5. 17 Nov: ganti ke DeepSeek (`deepseek-chat`), uji ulang evaluator 20 sampel.
