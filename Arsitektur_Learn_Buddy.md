# Arsitektur Learn Buddy

**Status:** draf arsitektur v2 — diperbarui 12 November 2026 (10:48 WIB)
**Keputusan dasar:** Flutter / Android Studio, Android saja, online only, 1 topik pembuka (**Stack**, 3 miskonsepsi)
**Target:** clear done 100% dalam 2 minggu (masih November 2026); deadline SiDia 10 Des 2026 sebagai buffer
**Referensi:** `Ringkasan_Project_Learn_Buddy.md` (v3) · keputusan Rid 12 Nov 2026 s.d. 10:48 WIB

---

## 1. Keputusan yang Sudah Terkunci (dari jawaban Rid)

| # | Keputusan |
|---|---|
| 1 | Materi Struktur Data sudah ada, dikirim menyusul. Fokus sekarang: arsitektur dulu. |
| 2 | 1 topik pembuka, 2–3 miskonsepsi per topik. |
| 3 | Tanpa target kelas SMK khusus. Uji coba ke teman dan/atau dosen. |
| 4 | Guru = Rid sebagai demo dulu, lalu guru sebenarnya. Akun siswa dan guru dibuat manual di halaman Login (register dengan pilih peran). |
| 5 | Bahasa aplikasi dipilih di Settings (Indonesia / English). Buddy bisa keduanya (bahasa dipilih per sesi, default mengikuti bahasa aplikasi). |
| 6 | LLM sementara Gemini free tier → **DeepSeek, Rid beli API key 17 Nov 2026**. Pergantian provider tidak boleh mengubah aplikasi. |
| 7 | Supabase project **baru**, terpisah dari project cafe (PM.CoffeShop). |
| 8 | **Meter Paham (final):** rumus = kriteria terpenuhi / total × 100%, bobot sama rata, hanya naik, satu miskonsepsi aktif berurutan (auto-geser setelah 4 input berturut-turut tanpa kriteria baru terpenuhi). Target akhir 100%; batas tuntas 80% dalam 20 input. |
| 9 | Batas sesi **20 input chat siswa** (maks 800 karakter). Sesi berhenti otomatis di 100% atau 20 input (`completed` bila ≥ 80%, `incomplete` bila < 80%; berhenti manual di < 80% = `abandoned`). |
| 10 | Siswa boleh hapus riwayat chat sendiri. **Guru TIDAK bisa melihat isi riwayat chat** — hanya progres/rekap. Ini perubahan dari ringkasan awal, dan ditegakkan di RLS. |
| 11 | Karakter 2D terinspirasi gaya Duolingo (ramah, ekspresif, sederhana). Bukan aset Duolingo asli. |
| 12 | HP uji Vivo X300 Pro milik Rid, mendukung ARCore. |
| 13 | Manual book tanpa template. Isi: Teori, Flowchart, Screenshot (+ hasil uji). |
| 14 | Rekan kelompok pasif tetap dicantumkan namanya. |

**Keputusan terbuka:** isi silabus Minggu 7, 9, dan 12+ (opsional untuk topik lanjutan pasca-UTS). Semua keputusan inti arsitektur dan MVP sudah dikunci.

---

## 2. Prinsip Arsitektur

1. **Satu topik matang dulu.** Semua lapisan (DB, Edge Function, UI) dibuat generik berbasis data, jadi nambah topik ke-2 hanya isi konten, bukan ubah kode.
2. **Keputusan "paham" di server + kode aplikasi, bukan di Buddy.** Buddy tidak pernah memutuskan sendiri.
3. **API key tidak pernah masuk APK.** Semua panggilan LLM lewat Supabase Edge Function.
4. **Satu fungsi pemanggil LLM.** Ganti Gemini → DeepSeek cukup ganti environment variable di Edge Function, tanpa rilis APK baru.
5. **Privasi by design.** Guru tidak bisa membaca chat siswa, ditegakkan di database (RLS), bukan sekadar disembunyikan di UI.
6. **Mirror proyek cafe sebisa mungkin.** Struktur folder, `go_router`, `supabase_flutter`, dan pola AuthRepository yang sama — supaya Rid tidak belajar pola baru dari nol.

---

## 3. Stack

| Lapisan | Pilihan | Alasan / catatan |
|---|---|---|
| Aplikasi | Flutter, Android saja, Dart SDK `^3.13.5` | Sama seperti cafe_order; build di Android Studio / laptop Rid (VM tidak bisa build APK) |
| Routing | `go_router ^18.0.2` | Sama seperti cafe; auth guard + redirect berbasis peran |
| State | `flutter_riverpod` | State chat, sesi, dan bahasa aplikasi; testable dan tidak tercampur dengan UI |
| Backend | Supabase project baru (PostgreSQL + Auth + Edge Functions) | Terpisah dari cafe (`Learn Buddy`, region `ap-south-1`) |
| Supabase client | `supabase_flutter ^2.18.0` | Sama seperti cafe; URL + anon key via `--dart-define` |
| Bahasa aplikasi | `flutter_localizations` + `intl`, file `.arb` ID/EN | Pilihan bahasa di Settings, tersimpan di `profiles.language_pref` + cache lokal |
| Font | `google_fonts` | Sama seperti cafe |
| AI (sementara) | Gemini free tier (`gemini-2.5-flash`) via Edge Function | Sampai 16 Nov 2026 |
| AI (17 Nov →) | DeepSeek `deepseek-chat` via Edge Function | Endpoint OpenAI-compatible; ganti `LLM_PROVIDER` + secret saja |
| AR Level 2 saja (stretch) | `ar_flutter_plugin`; cadangan `model_viewer_plus` | Visualisasi struktur data 3D. Level 1 (Buddy 3D) DICORET Rid 12 Nov 10:17. Dikerjakan SETELAH MVP stabil; di branch terpisah |
| Aset Buddy | PNG transparan 512px, 6 ekspresi | Generate AI dengan style prompt konsisten lalu dirapikan (disetujui Rid 12 Nov 10:48) |

**Yang sengaja TIDAK dipakai:** Unity (terlalu berat untuk chat + evaluator), halaman admin (sesuai keputusan — pengelolaan teknis lewat dashboard Supabase), mode offline, iOS.

---

## 4. Arsitektur Lapisan

```
┌─────────────────────────────────────────────────────────┐
│  Presentation (Flutter)                                 │
│  Login/Register · Home Siswa · Chat Buddy · Rekap       │
│  Dashboard Guru · Kelola Konten · Settings (bahasa)     │
├─────────────────────────────────────────────────────────┤
│  State (Riverpod providers)                             │
│  authProvider · sessionProvider · languageProvider      │
│  topicProvider · meterProvider                          │
├─────────────────────────────────────────────────────────┤
│  Data (Repositories)                                    │
│  AuthRepository · TopicRepository · SessionRepository   │
│  ChatRepository (panggil Edge Function, bukan LLM)      │
├─────────────────────────────────────────────────────────┤
│  Supabase                                               │
│  PostgreSQL + RLS · Auth · Edge Function `teach-turn`   │
├─────────────────────────────────────────────────────────┤
│  LLM (di balik Edge Function saja)                      │
│  Gemini (sementara) → DeepSeek (17 Nov)                 │
└─────────────────────────────────────────────────────────┘
```

Aturan: UI tidak pernah memanggil LLM langsung, tidak pernah menilai jawaban, dan tidak pernah menyimpan API key. UI hanya menampilkan apa yang dikembalikan Edge Function + data dari Supabase.

---

## 5. Struktur Project Flutter

Mengikuti pola `cafe_order` supaya familiar:

```
learn_buddy/
├── lib/
│   ├── main.dart                 # Supabase.initialize + runApp
│   ├── app.dart                  # MaterialApp.router
│   ├── config/
│   │   └── app_config.dart       # SUPABASE_URL / ANON_KEY via --dart-define
│   ├── core/
│   │   ├── router/               # app_router.dart (auth guard + role redirect)
│   │   ├── theme/                # warna, tipografi (ikuti gaya Buddy)
│   │   ├── l10n/                 # app_id.arb, app_en.arb
│   │   └── widgets/              # BuddyAvatar, MeterPaham, ChatBubble
│   ├── features/
│   │   ├── auth/
│   │   │   ├── data/auth_repository.dart
│   │   │   └── presentation/     # login_page, register_page (pilih peran)
│   │   ├── student/
│   │   │   ├── home/             # pilih topik, lanjutkan sesi, riwayat
│   │   │   ├── teach/            # chat_page, meter, rekap_page
│   │   │   └── data/             # session_repository, chat_repository
│   │   ├── teacher/
│   │   │   ├── dashboard/        # progres siswa (tanpa isi chat)
│   │   │   ├── content/          # CRUD topik, miskonsepsi, kriteria
│   │   │   └── data/             # teacher_repository
│   │   └── settings/
│   │       └── presentation/     # bahasa aplikasi, hapus riwayat, logout
│   └── l10n/                     # generated localizations
├── assets/images/buddy/          # buddy_bingung.png, berpikir, ragu,
│                                 # mulai_paham, paham, senang
├── supabase/
│   ├── migrations/0001_init.sql  # skema + RLS (bagian 6)
│   └── functions/teach-turn/     # Edge Function (bagian 7)
└── test/                         # unit: meter, parsing JSON evaluator
```

---

## 6. Skema Database Supabase (Konseptual)

### 6.1 Tabel

**`profiles`** — satu baris per pengguna, dibuat saat register (upsert seperti cafe).

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | uuid PK, FK `auth.users` | |
| email | text | |
| display_name | text | |
| role | enum `student` / `teacher` | Dipilih manual saat register |
| language_pref | text `id` / `en`, default `id` | Bahasa aplikasi |
| created_at | timestamptz | |

**`topics`**

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | uuid PK | |
| title_id / title_en | text | Judul topik dua bahasa |
| description_id / description_en | text | |
| sort_order | int | |
| is_active | boolean | Topik nonaktif disembunyikan dari siswa |
| created_by | uuid FK profiles | Guru yang membuat |

**`misconceptions`** — 2–3 baris per topik.

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | uuid PK | |
| topic_id | uuid FK topics, cascade delete | |
| misconception_text | text | Yang diyakini Buddy (salah, ID), mis. "Stack itu seperti antrean (FIFO)" |
| misconception_text_en | text, nullable | Versi EN (diisi via *Terjemahkan ke English* + dicek guru) |
| correct_concept | text | Konsep benar (ID), mis. "Stack bersifat LIFO" — hanya untuk evaluator + guru, JANGAN ditampilkan ke siswa |
| correct_concept_en | text, nullable | Konsep benar versi EN — hanya untuk evaluator + guru |
| buddy_intro | text | Kalimat pembuka Buddy (ID) yang menyampaikan miskonsepsinya |
| buddy_intro_en | text, nullable | Kalimat pembuka Buddy versi EN |
| sort_order | int | |

**`criteria`** — kriteria "paham" per miskonsepsi (1 miskonsepsi biasanya 2–4 kriteria).

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | uuid PK | |
| misconception_id | uuid FK, cascade delete | |
| criterion_text | text | Kriteria versi ID, mis. "menyebut LIFO", "memberi contoh nyata", "menjelaskan push/pop" |
| criterion_text_en | text, nullable | Kriteria versi EN |
| weight | int, default 1 | Supaya rumus Meter bisa diubah tanpa ubah kode |
| sort_order | int | |

**`sessions`** — satu sesi mengajar per siswa per topik.

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | uuid PK | |
| student_id | uuid FK profiles | |
| topic_id | uuid FK topics | |
| active_misconception_id | uuid nullable FK misconceptions | Miskonsepsi yang sedang aktif dibahas saat ini |
| language | text `id` / `en` | Bahasa sesi, dipilih di awal sesi (EN terkunci bila versi EN topik belum lengkap) |
| status | enum `active` / `completed` / `incomplete` / `abandoned` | `completed` bila meter 100% atau berhenti/20 input dengan meter ≥ 80%; `incomplete` bila 20 input habis dengan meter < 80%; `abandoned` bila berhenti manual dengan meter < 80% |
| meter_percent | int 0–100 | Dihitung server dari `session_criteria` (hanya naik) |
| student_inputs | int, default 0 | Dihitung server; batas 20 |
| stale_turns | int, default 0 | Jumlah input berturut-turut pada miskonsepsi aktif tanpa kriteria baru terpenuhi; reset ke 0 saat ada progres atau pindah miskonsepsi (batas geser otomatis: 4) |
| started_at / ended_at | timestamptz | |

**`messages`** — riwayat chat per sesi. **Paling sensitif.**

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | uuid PK | |
| session_id | uuid FK sessions, cascade delete | |
| role | enum `student` / `buddy` | |
| content | text | |
| created_at | timestamptz | |

**`session_criteria`** — progres per kriteria, sumber kebenaran Meter Paham.

| Kolom | Tipe | Keterangan |
|---|---|---|
| session_id + criterion_id | PK komposit | |
| criterion_text_snapshot | text | **(Disetujui Rid 12 Nov 10:48)** Salinan teks kriteria sesuai bahasa sesi saat sesi dibuat |
| fulfilled | boolean, default false | |
| evidence_quote | text, nullable | Kutipan jawaban siswa yang memenuhi kriteria (untuk guru + uji evaluator) |
| fulfilled_at | timestamptz, nullable | |

**`turn_logs`** — log teknis tiap giliran `teach-turn` (untuk bahan uji & manual book).

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | uuid PK | |
| session_id | uuid FK sessions, cascade delete | |
| provider | text | `gemini` / `deepseek` |
| model | text | Nama model yang dipakai |
| latency_ms | int | Total waktu proses `teach-turn` |
| evaluator_tokens / buddy_tokens | int, nullable | Pemakaian token |
| json_retried | boolean, default false | Apakah Evaluator sempat retry JSON |
| evaluator_notes | text, nullable | Catatan singkat internal Evaluator (bukan untuk siswa) |
| created_at | timestamptz | |

**`teacher_invite_codes`** — kode undangan guru (dipasang minggu ke-2).

| Kolom | Tipe | Keterangan |
|---|---|---|
| id | uuid PK | |
| code | text unique | Kode rahasia untuk validasi register peran `teacher` di server |
| is_active | boolean, default true | |
| created_at | timestamptz | |

### 6.2 RLS — inti privasi

| Tabel | Siswa | Guru |
|---|---|---|
| profiles | Baca/update `display_name` & `language_pref` milik sendiri (**`role` & `email` dikunci**, tidak bisa diubah via API) | Baca daftar siswa (`id`, `display_name`, `email`, `role`) |
| topics | Baca yang `is_active` | Baca + tulis semua (CRUD konten) |
| misconceptions | Baca lewat `VIEW` / RPC aman yang hanya mengekspos `id`, `topic_id`, `misconception_text(_en)`, `buddy_intro(_en)`, `sort_order` (**TANPA `correct_concept`**) | Baca + tulis semua (CRUD konten) |
| criteria | **TIDAK ADA akses `SELECT`** langsung (mencegah main kata kunci); hanya dibaca Edge Function (`service_role`) | Baca + tulis semua (CRUD konten) |
| sessions | Baca/buat/hapus milik sendiri (update status `abandoned`/`completed` saat akhiri manual, atau kelola lewat Edge Function) | Baca semua sesi (id siswa, topik, meter, jumlah input, status, waktu) — **tanpa isi chat** |
| messages | Baca & hapus (via cascade `sessions`) hanya sesi milik sendiri; `INSERT` dilakukan Edge Function (`service_role`) agar batas 800 karakter & `student_inputs` terjaga | **TIDAK ADA akses SELECT** — guru tidak bisa melihat isi chat, lewat aplikasi maupun query langsung |
| session_criteria | **TIDAK ADA akses `SELECT` mentah** ke teks kriteria; progres & daftar miskonsepsi yang sudah/belum diluruskan dikembalikan aman lewat RPC/Edge Function | Baca semua (untuk rekap progres per kriteria + `evidence_quote`) |
| turn_logs, teacher_invite_codes | Tidak ada akses langsung (hanya `service_role` / Edge Function) | Tidak ada akses langsung di aplikasi (cek via dashboard Supabase) |

Hapus riwayat oleh siswa = hapus baris `sessions` miliknya → `messages` + `session_criteria` ikut terhapus (cascade). Konfirmasi dialog dulu, dan tampilkan pemberitahuan di aplikasi bahwa chat disimpan serta jangan menulis data pribadi.

### 6.3 Catatan implementasi Supabase

- Matikan "Confirm email" di dashboard (Auth → Providers → Email), seperti cafe, supaya register langsung dapat session.
- Login & Akun (disetujui Rid 12 Nov 10:19): password minimal 8 karakter; peran tidak bisa diubah dari aplikasi; tidak ada hapus akun di aplikasi; kode undangan guru + Lupa password minggu ke-2.
- Bilingual (disetujui Rid 12 Nov 10:27–10:28): konten EN dibuat lewat Edge Function `translate-content` (dipanggil dari Kelola Konten, temp 0, JSON berisi versi EN miskonsepsi/kriteria/buddy_intro) — guru cek & edit, baru disimpan ke kolom `*_en`; sesi English terkunci sampai versi EN tersimpan. Judul/deskripsi topik wajib dua bahasa.
- Pasang keep-alive sejak awal (project free tier bisa auto-pause seperti cafe) — jangan sampai mati saat demo ke dosen.
- `SUPABASE_URL` + anon key via `--dart-define`, tidak di-hardcode di repo.

---

## 7. Edge Function `teach-turn` — Otak Aplikasi

Satu-satunya pintu ke LLM. Flutter tidak pernah memanggil Gemini/DeepSeek langsung.

### 7.1 Alur per giliran

```
Flutter kirim: session_id + student_message + (language dari sesi)
        ↓
1. Validasi: sesi milik user, status active, student_inputs < 20,
   panjang pesan ≤ 800 karakter (diputuskan Rid 12 Nov 10:02)
        ↓
2. Muat dari DB (service role): topik, miskonsepsi + kriteria,
   6 pesan terakhir (konteks, bukan seluruh riwayat)
        ↓
3. PANGGILAN 1 — Evaluator
   Input: kriteria + jawaban siswa (+ konteks singkat)
   Output: JSON baku (lihat 7.2). Temperature 0.
        ↓
4. Update DB: tandai criteria yang terpenuhi + evidence_quote,
   hitung ulang meter_percent = kriteria terpenuhi / total kriteria × 100%
   (bobot sama rata, hanya naik), student_inputs + 1.
   Update stale_turns (reset 0 bila ada kriteria baru terpenuhi, selain itu +1).
   Aturan selesai (disetujui Rid 12 Nov 10:40):
   - meter == 100 → status = completed.
   - student_inputs == 20 & meter >= 80 → status = completed.
   - student_inputs == 20 & meter < 80 → status = incomplete.
   Aturan pindah miskonsepsi aktif (jika masih active & belum di miskonsepsi terakhir):
   - semua kriteria miskonsepsi aktif fulfilled ATAU stale_turns >= 4
     → geser active_misconception_id ke berikutnya, reset stale_turns = 0,
       sertakan next_buddy_intro dari DB.
        ↓
5. PANGGILAN 2 — Buddy
   Input: persona + miskonsepsi aktif + tingkat pemahaman miskonsepsi aktif (`active_meter_percent`,
   bukan meter global sesi) + jawaban siswa.
   Output: balasan Buddy sesuai persona, TIDAK membocorkan jawaban.
   Temperature 0.7. (Jika barusan pindah miskonsepsi, beri balasan transisi singkat
   sebelum menambahkan next_buddy_intro.)
        ↓
6. Simpan pesan ke `messages` (`student_message`, `buddy_reply`, dan bila ada transisi
   simpan juga `next_buddy_intro` sebagai pesan `buddy` berikutnya agar riwayat saat
   *Lanjutkan Sesi* utuh) + catat `turn_logs`, lalu kembalikan ke Flutter:
   { buddy_reply, next_buddy_intro, active_misconception_id,
     meter_percent, newly_fulfilled[], inputs_used, inputs_max: 20, session_status }
```

### 7.2 JSON Evaluator (baku, tidak berubah saat ganti provider)

```json
{
  "criteria": [
    { "criterion_id": "uuid", "fulfilled": true, "evidence": "kutipan jawaban siswa" },
    { "criterion_id": "uuid", "fulfilled": false, "evidence": "" }
  ],
  "notes": "alasan singkat untuk guru/uji, bukan untuk siswa"
}
```

Jika JSON tidak valid: coba sekali lagi dengan prompt perbaikan. Jika masih gagal, anggap tidak ada kriteria baru terpenuhi dan Buddy meminta siswa menjelaskan dengan contoh. Jangan pernah mengarang `fulfilled: true`.

### 7.3 Pergantian Gemini → DeepSeek (17 Nov)

Satu wrapper pemanggil, provider dipilih dari environment variable Edge Function:

| Variable | Gemini (sementara) | DeepSeek (17 Nov) |
|---|---|---|
| `LLM_PROVIDER` | `gemini` | `deepseek` |
| `LLM_API_KEY` | secret Gemini | secret DeepSeek (Rid beli 17 Nov) |
| `LLM_MODEL` | `gemini-2.5-flash` | `deepseek-chat` |
| `LLM_BASE_URL` | `https://generativelanguage.googleapis.com/v1beta/openai/chat/completions` | `https://api.deepseek.com/v1/chat/completions` |

Prompt Evaluator + Buddy, format JSON, dan skema DB **tidak berubah**. Setelah ganti provider, uji ulang akurasi evaluator dengan 20 sampel yang sama sebelum dipakai demo.

### 7.4 Batas & performa

- Maksimal 20 input siswa per sesi; pesan maksimal 800 karakter (diputuskan Rid 12 Nov 10:02).
- Konteks LLM: 6 pesan terakhir + kriteria saja — hemat token, target respons rata-rata < 8 detik.
- Timeout Edge Function: jika LLM lambat, kembalikan error ramah ("Buddy lagi mikir, coba kirim ulang") dan JANGAN menambah `student_inputs`.
- Log tiap giliran (waktu respons, provider, token) ke tabel log terpisah untuk bahan manual book + uji.

---

## 8. Alur Layar

### 8.1 Route (go_router)

| Route | Siapa | Keterangan |
|---|---|---|
| `/login`, `/register` | Semua | Register manual pilih peran siswa/guru. Auth guard: belum login tidak bisa ke mana-mana. |
| `/student` | Siswa | Pilih topik, lanjutkan sesi aktif, riwayat sesi + rekap. |
| `/student/teach/:sessionId` | Siswa | Chat Buddy, ekspresi 2D, Meter Paham, counter `x/20`, tombol akhiri sesi. |
| `/student/recap/:sessionId` | Siswa | Miskonsepsi yang diluruskan, meter akhir, tombol hapus riwayat. |
| `/teacher` | Guru | Dashboard: daftar topik + progres siswa per topik (nama, meter, jumlah sesi). Tanpa isi chat. |
| `/teacher/content` | Guru | CRUD topik, miskonsepsi, kriteria. |
| `/teacher/student/:studentId` | Guru | Detail progres: kriteria terpenuhi per sesi + evidence (bukan isi chat). |
| `/settings` | Semua | Bahasa aplikasi (ID/EN), hapus riwayat (siswa), logout, tentang aplikasi. |

### 8.2 Alur sesi mengajar (siswa)

```
Login → Pilih topik → Pilih bahasa sesi (default = bahasa aplikasi)
 → Buddy menyampaikan miskonsepsinya (buddy_intro)
 → Siswa menjelaskan (teks) → Evaluator menilai → Meter naik
 → Ekspresi Buddy berubah → Pindah ke miskonsepsi berikutnya jika tuntas atau stale_turns = 4
 → Ulangi sampai meter 100% atau 20 input (`completed` bila ≥ 80%, `incomplete` bila < 80%)
 → Rekap → Sesi tersimpan
```

### 8.3 Ekspresi Buddy 2D (gaya Duolingo)

Satu karakter, 6 ekspresi, dipetakan dari meter — rumus pemetaan bisa diubah, angkanya usulan awal:

| Meter | Ekspresi | File |
|---|---|---|
| 0–19% | Bingung | `buddy_bingung.png` |
| 20–39% | Berpikir | `buddy_berpikir.png` |
| 40–59% | Ragu | `buddy_ragu.png` |
| 60–79% | Mulai paham | `buddy_mulai_paham.png` |
| 80–99% | Paham | `buddy_paham.png` |
| 100% | Senang | `buddy_senang.png` |

Aset dibuat dengan style prompt yang konsisten (karakter sama, hanya ekspresi berubah), PNG transparan 512px. Jangan pakai aset Duolingo asli — hanya inspirasinya. Model 3D Buddy TIDAK dibuat (AR Level 1 dicoret 12 Nov); AR Level 2 memakai bentuk 3D sederhana (blok, node, panah) per topik, bukan karakter Buddy.

---

## 9. Bahasa (ID / EN)

- **Bahasa aplikasi:** file `.arb` (`app_id.arb`, `app_en.arb`) + `flutter_localizations`. Pilihan di Settings, disimpan di `profiles.language_pref` dan cache lokal supaya langsung diterapkan setelah login.
- **Bahasa Buddy:** dipilih per sesi (default mengikuti bahasa aplikasi). Disimpan di `sessions.language` dan dikirim ke kedua prompt LLM. Evaluator menilai isi penjelasan, bukan bahasa — siswa boleh campur istilah teknis Inggris dalam penjelasan Indonesia.
- Kriteria dan `buddy_intro` disimpan dua bahasa di konten guru (atau satu bahasa dulu untuk MVP, lalu dilengkapi — diputuskan saat materi diterima).

---

## 10. Keamanan & Privasi

- API key LLM hanya di secrets Edge Function. Anon key Supabase via `--dart-define`, seperti cafe.
- RLS seperti bagian 6.2 — guru tidak bisa membaca `messages` meskipun lewat query langsung.
- Pemberitahuan di aplikasi: chat disimpan, jangan tulis data pribadi; siswa bisa hapus riwayat sendiri.
- **Risiko peran guru:** register manual dengan pilih peran berarti siapa pun bisa daftar sebagai guru di MVP. Mitigasi sebelum dipakai guru sebenarnya: kode undangan guru sederhana (kode disimpan di DB, diminta saat register sebagai guru) — dipasang di minggu ke-2, bukan di MVP hari pertama.
- Jangan simpan API key, password, atau token di repo / di `assets`.

---

## 11. Jadwal 2 Minggu (Target November)

| Waktu | Fokus | Hasil |
|---|---|---|
| 12–14 Nov | Project Supabase baru + migrasi `0001_init.sql` (skema + RLS), Auth + peran, scaffold Flutter (struktur bagian 5) | Login/register jalan, DB siap diisi |
| 15–16 Nov | Edge Function `teach-turn` (Gemini), chat dasar + Meter v1, batas 20 input | Alur inti jalan di HP Vivo |
| 17 Nov | **Ganti ke DeepSeek** (Rid beli key) — ganti env saja, uji ulang evaluator 20 sampel | Provider baru terverifikasi, tanpa ubah aplikasi |
| 18–20 Nov | Konten topik 1 (dari materi Rid), karakter 2D 6 ekspresi, halaman guru, rekap | MVP lengkap |
| 21–23 Nov | Bilingual ID/EN, Settings, hapus riwayat, kode undangan guru, uji internal | MVP stabil |
| 24–26 Nov | Uji coba 4 teman/dosen, perbaikan, manual book (Teori + Flowchart + Screenshot) | **Clear done 100%** |
| 27 Nov–10 Des | Buffer + AR Level 2 (jika sempat) | Demo + submit SiDia |

AR sengaja di luar target 2 minggu. Spike test 1 hari di minggu pertama: pastikan `ar_flutter_plugin` jalan di Vivo X300 Pro; kalau gagal, fallback `model_viewer_plus` diputuskan lebih awal, bukan di akhir.

---

## 12. Risiko & Mitigasi

| Risiko | Mitigasi |
|---|---|
| Buddy terlalu cepat "paham" / membocorkan jawaban | Evaluator terpisah, temperature 0, JSON baku, uji 10 skenario memancing jawaban |
| Kuota Gemini habis sebelum 17 Nov | Batas 20 input/sesi, pesan ≤ 800 karakter, konteks 6 pesan terakhir |
| DeepSeek hasilnya beda dari Gemini | Uji ulang 20 sampel yang sama setelah ganti provider; prompt tidak berubah |
| Supabase free tier auto-pause | Keep-alive sejak awal; jangan tunggu demo |
| AR plugin tidak stabil | Spike test awal; AR tetap stretch; cadangan `model_viewer_plus` |
| Cakupan membengkak (1 orang) | 1 topik dulu; Meter Paham v1 sederhana, didetailkan nanti tanpa ubah skema (pakai `weight`) |
| Pendaftar guru palsu | Kode undangan guru di minggu ke-2 |

---

## 13. Keputusan Terkunci (Update 12 Nov 10:48 WIB)

1. **Topik pembuka — DIPUTUSKAN 12 Nov 10:48:** **Stack** (3 miskonsepsi), disusul Linked List sebagai topik ke-2; istilah operasi dasar dipakai, kedalaman `O(n)` & `prev.next` dinilai secara konseptual.
2. **Rumus Meter Paham & Transisi — SUDAH DIPUTUSKAN (12 Nov 09:57 & 10:44):** kriteria terpenuhi / total × 100%, bobot sama rata, hanya naik, target akhir 100%, batas tuntas 80% dalam 20 input (`completed` vs `incomplete`), tampilkan angka % ke siswa, boleh retry sesi baru bila belum tuntas, auto-geser miskonsepsi aktif setelah 4 input tanpa progres (`stale_turns`).
3. **Batas panjang pesan — DIPUTUSKAN 12 Nov 10:02:** 800 karakter.
4. **Model Gemini free tier sementara — DIPUTUSKAN 12 Nov 10:48:** **`gemini-2.5-flash`**.
5. **Aset karakter 2D — DIPUTUSKAN 12 Nov 10:48:** generate AI dengan style prompt konsisten lalu dirapikan menjadi 6 PNG transparan 512px.
6. **Kode undangan guru — SUDAH DIPUTUSKAN 12 Nov 10:19:** dipasang minggu ke-2 (bersama Lupa password).
7. **Halaman Guru — DIPUTUSKAN 12 Nov 10:09:** Dashboard (siswa diurutkan meter terendah dulu), Detail Progres (per sesi + per kriteria + kutipan bukti, tanpa isi chat), Kelola Konten (CRUD topik/miskonsepsi/kriteria); TIDAK perlu ekspor CSV; identifikasi siswa Nama+Email saja; topik yang sudah punya sesi hanya dinonaktifkan, tidak dihapus.
8. **Snapshot kriteria — DIPUTUSKAN 12 Nov 10:48:** salin teks kriteria (`criterion_text_snapshot`) ke `session_criteria` saat sesi dibuat, edit konten hanya berlaku untuk sesi baru, sesi berjalan tidak berubah.
9. **Prompt Buddy — DIPUTUSKAN 12 Nov 10:48:** `{{correct_concept}}` dihapus dari system prompt Buddy (hanya diberikan ke Evaluator) untuk meminimalkan risiko kebocoran jawaban.

*(Satu-satunya info yang masih terbuka: isi silabus Minggu 7, 9, dan 12+ untuk topik lanjutan pasca-UTS.)*

## 14. Langkah Berikutnya

*(Menunggu instruksi eksplisit Rid sebelum memulai setup/scaffold.)*
1. Buat project Supabase baru + jalankan migrasi `0001_init.sql`.
2. Scaffold project Flutter `learn_buddy` (struktur bagian 5) + Auth + routing peran.
3. Edge Function `teach-turn` (`gemini-2.5-flash`) + prompt Evaluator & Buddy.
4. 17 Nov: ganti ke `deepseek-chat`, uji ulang evaluator 20 sampel.
