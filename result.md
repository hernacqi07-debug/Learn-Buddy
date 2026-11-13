# Result Build — Learn Buddy (MVP)

**Tanggal:** 12 November 2026  
**Status:** Build MVP selesai — backend Supabase live, seluruh fitur Flutter terimplementasi, `flutter analyze` bersih, `flutter test` lolos 10/10, dan APK release berhasil dibuat (`55.3 MB`).

---

## 1. Ringkasan Komponen yang Dibangun

### A. Backend Supabase (Project: `Learn Buddy` — `reoqmeygowfqubicsywl`)
- **Skema Database & RLS (`supabase/migrations/0001_init.sql`):**
  - 9 tabel aktif dengan RLS aktif: `profiles`, `topics`, `misconceptions`, `criteria`, `sessions`, `messages`, `session_criteria`, `turn_logs`, dan `teacher_invite_codes`.
  - Trigger `trg_prevent_profile_role_email_change` mengunci kolom `role` dan `email` agar tidak bisa diubah dari sisi client.
  - Guru **tidak memiliki akses `SELECT`** ke tabel `messages` (ditegakkan di RLS).
  - Siswa **tidak memiliki akses `SELECT`** langsung ke `correct_concept` maupun tabel `criteria` mentah; seluruh alur aman lewat RPC (`register_user_profile`, `get_student_topics_summary`, `start_learning_session`, `get_session_recap`, `end_learning_session`, `health_ping`).
  - Seluruh fungsi `SECURITY DEFINER` telah dicabut izin `EXECUTE`-nya dari `anon`.
- **Data Awal / Seed (`supabase/seed.sql`):**
  - **Topik 1 — Stack (Tumpukan)** (`is_active: true`): lengkap **ID + EN**, 3 miskonsepsi, 9 kriteria.
  - **Topik 2 — Linked List** (`is_active: false`): draf awal versi ID (3 miskonsepsi, 9 kriteria) — siap dipakai guru untuk mencoba toggle aktif dan fitur *Terjemahkan ke English*.
- **Edge Functions (`ACTIVE` di Supabase):**
  - `supabase/functions/teach-turn/index.ts` (`verify_jwt: true`):
    - Validasi kepemilikan sesi, status `active`, batas `20` input, dan panjang pesan `≤ 800` karakter.
    - **Panggilan 1 (Evaluator, temp `0`, JSON):** menilai kriteria miskonsepsi aktif saja + kutipan verbatim (`evidence`), dengan `1x` retry perbaikan JSON otomatis jika format tidak valid.
    - Pembaruan `meter_percent` monotonik (hanya naik), `stale_turns` (auto-geser ke miskonsepsi berikutnya jika tuntas atau **4 input berturut-turut** tanpa progres baru), dan status akhir (`completed` di 100% atau 20 input dengan ≥ 80%; `incomplete` di 20 input dengan < 80%).
    - **Panggilan 2 (Buddy, temp `0.7`):** memakai `active_meter_percent` (progres pada miskonsepsi aktif), **tanpa `correct_concept`** di prompt, serta dukungan penuh bahasa sesi `id` / `en`.
    - Penyimpanan atomik pesan (`student`, `buddy`, dan `next_buddy_intro` saat transisi) + pencatatan metrik ke `turn_logs` hanya setelah kedua panggilan LLM berhasil.
  - `supabase/functions/translate-content/index.ts` (`verify_jwt: true`): khusus guru, menerjemahkan miskonsepsi, konsep benar, `buddy_intro`, dan kriteria ke Bahasa Inggris dalam JSON untuk ditinjau & diedit guru sebelum disimpan.

### B. Aset Karakter Buddy 2D (`assets/images/buddy/`)
- 6 PNG transparan `512×512` (`RGBA`) terinspirasi gaya flat-vector Duolingo (Opsi 1):
  - `buddy_bingung.png` (0–19%)
  - `buddy_berpikir.png` (20–39%, pose tangan di dagu)
  - `buddy_ragu.png` (40–59%)
  - `buddy_mulai_paham.png` (60–79%)
  - `buddy_paham.png` (80–99%)
  - `buddy_senang.png` (100%)

### C. Aplikasi Flutter Android (`lib/`)
- **Arsitektur & Routing:** `flutter_riverpod` (`^3.5.0`), `go_router` (`^18.1.4`), `supabase_flutter` (`^2.18.3`), `google_fonts`, `shared_preferences`, `flutter_localizations` + `intl` (`.arb` ID & EN di `lib/core/l10n/`).
- **Auth (`lib/features/auth/`):** Login & Register manual (Nama, Email, Password min. 8 karakter, pilih peran Siswa/Guru, dukungan kode undangan guru bila tabel `teacher_invite_codes` memiliki kode aktif) + pemberitahuan privasi.
- **Halaman Siswa (`lib/features/student/`):**
  - **Beranda (`student_home_page.dart`):** daftar topik dengan meter terbaik & status, tombol *Lanjutkan Sesi* / *Mulai Sesi Baru*, dialog pilihan bahasa sesi (EN terkunci bila versi EN topik belum lengkap), daftar riwayat sesi + hapus sesi satuan.
  - **Chat (`chat_page.dart`):** avatar Buddy dinamis + bar Meter Paham, bubble Buddy kiri / siswa kanan, counter `Pesan x/20`, batas 800 karakter dengan counter, indikator *Buddy lagi mikir...*, tombol *Akhiri* dengan konfirmasi, banner error ramah bila timeout tanpa menghilangkan ketikan.
  - **Rekap (`recap_page.dart`):** meter akhir, status (`Tuntas` / `Belum Tuntas` / `Dihentikan Manual`), daftar miskonsepsi yang sudah/belum diluruskan (**hanya judul**, tanpa hint/kunci jawaban), lihat riwayat chat, coba lagi, atau pilih topik lain.
- **Halaman Guru (`lib/features/teacher/`):**
  - **Dashboard (`teacher_dashboard_page.dart`):** ringkasan topik + daftar siswa diurutkan dari meter terendah.
  - **Detail Progres Siswa (`teacher_student_detail_page.dart`):** banner privasi RLS, progres per sesi, per kriteria + `evidence_quote` (tanpa isi chat).
  - **Kelola Konten (`teacher_content_page.dart`):** CRUD topik, miskonsepsi, kriteria; toggle aktif/nonaktif; penguncian hapus untuk topik yang sudah memiliki sesi; tombol *Terjemahkan ke English* + dialog tinjau/edit sebelum simpan.
- **Pengaturan (`lib/features/settings/presentation/settings_page.dart`):** ganti bahasa aplikasi ID/EN langsung tanpa restart, ubah nama tampilan, hapus semua riwayat dengan konfirmasi ganda (khusus siswa), Tentang & Privasi, Logout.

---

## 2. Hasil Verifikasi Teknis

| Pemeriksaan | Hasil | Detail |
|---|---|---|
| `flutter gen-l10n` | Lulus | Generate `lib/l10n/app_localizations*.dart` (ID & EN) |
| `flutter analyze` | **0 issues** | Bersih tanpa error maupun warning |
| `flutter test` | **10/10 lulus** | `test/meter_and_mood_test.dart` (9 unit test) + `test/widget_test.dart` (1 widget test) |
| `flutter build apk --release` | **Berhasil** | `build\app\outputs\flutter-apk\app-release.apk` (**55.3 MB**) |
| Supabase DB & RLS | **Aktif** | 9 tabel, 6 RPC, data seed Stack & Linked List terpasang |
| Edge Functions | **Aktif** | `teach-turn` dan `translate-content` status `ACTIVE` |

*(Catatan teknis build Windows: ditambahkan `kotlin.incremental=false` di `android/gradle.properties` untuk mencegah error incremental cache Kotlin lintas-drive antara `C:\` Pub Cache dan `D:\` workspace.)*

---

## 3. Perintah Run / Build Ulang

Jalankan dengan `--dart-define` agar URL dan publishable key Supabase tidak di-hardcode di kode Dart:

```powershell
flutter run --dart-define=SUPABASE_URL=https://reoqmeygowfqubicsywl.supabase.co --dart-define=SUPABASE_ANON_KEY=sb_publishable_dRAQZBoYKC8PaItmsEEcxw_bjKuMes0
```

Atau untuk compile APK release:

```powershell
flutter build apk --release --dart-define=SUPABASE_URL=https://reoqmeygowfqubicsywl.supabase.co --dart-define=SUPABASE_ANON_KEY=sb_publishable_dRAQZBoYKC8PaItmsEEcxw_bjKuMes0
```

---

## 4. Langkah Lanjutan (Manual / Uji Lapangan)

1. **Install & Tes di Vivo X300 Pro:** pasang `build\app\outputs\flutter-apk\app-release.apk`, daftar 1 akun **Siswa** dan 1 akun **Guru** (Confirm email sudah dimatikan), lalu uji alur chat Stack (ID & EN) serta tombol *Terjemahkan ke English* di topik Linked List.
2. **Uji Kualitas AI (Sebelum & Sesudah 17 Nov):**
   - Uji **20 sampel Evaluator** (target akurasi ≥ 80%) dan **10 skenario anti-bocor** (target 0 kebocoran) menggunakan Gemini (`gemini-2.5-flash`).
   - Pada **17 Nov 2026**, ganti 4 Secrets di dashboard Supabase (`LLM_PROVIDER=deepseek`, `LLM_API_KEY=<key DeepSeek>`, `LLM_MODEL=deepseek-chat`, `LLM_BASE_URL=https://api.deepseek.com/v1/chat/completions`) lalu ulangi uji 20 sampel & 10 skenario — **tanpa perlu build ulang APK**.
3. **Kode Undangan Guru (Minggu ke-2):** sebelum aplikasi dipakai guru sebenarnya, tambahkan 1 baris kode rahasia ke tabel `teacher_invite_codes` (`is_active = true`) lewat Supabase Table Editor.
4. **Uji Coba & Manual Book:** uji ke 4 teman/dosen, ambil screenshot dari aplikasi nyata + data metrik dari `turn_logs`, lalu susun Manual Book (Teori, Flowchart, Screenshot, Hasil Uji).
5. **Stretch (Opsional):** AR Level 2 dikerjakan terpisah setelah inti MVP dan Manual Book beres.
