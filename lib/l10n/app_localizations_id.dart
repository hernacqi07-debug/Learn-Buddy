// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get appTitle => 'Learn Buddy';

  @override
  String get appTagline => 'Belajar Struktur Data dengan Mengajari Buddy';

  @override
  String get privacyNotice =>
      'Riwayat chat disimpan di server untuk evaluasi pembelajaran. Jangan menulis data pribadi.';

  @override
  String get loginTitle => 'Masuk ke Learn Buddy';

  @override
  String get registerTitle => 'Buat Akun Baru';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password (min. 8 karakter)';

  @override
  String get displayNameLabel => 'Nama Lengkap';

  @override
  String get roleLabel => 'Peran';

  @override
  String get roleStudent => 'Siswa';

  @override
  String get roleTeacher => 'Guru';

  @override
  String get inviteCodeLabel =>
      'Kode Undangan Guru (opsional jika belum diaktifkan)';

  @override
  String get loginButton => 'Masuk';

  @override
  String get registerButton => 'Daftar';

  @override
  String get noAccountPrompt => 'Belum punya akun? Daftar';

  @override
  String get hasAccountPrompt => 'Sudah punya akun? Masuk';

  @override
  String get roleLockedHint => 'Peran tidak bisa diubah setelah pendaftaran.';

  @override
  String get invalidEmail => 'Masukkan alamat email yang valid.';

  @override
  String get passwordTooShort => 'Password minimal 8 karakter.';

  @override
  String get nameRequired => 'Nama tidak boleh kosong.';

  @override
  String get authErrorGeneric =>
      'Gagal masuk. Periksa email dan password kamu.';

  @override
  String get inviteCodeInvalid => 'Kode undangan guru tidak valid.';

  @override
  String get studentHomeTitle => 'Beranda Siswa';

  @override
  String welcomeUser(String name) {
    return 'Halo, $name!';
  }

  @override
  String get topicsSectionTitle => 'Topik Struktur Data';

  @override
  String get historySectionTitle => 'Riwayat Sesi';

  @override
  String get noTopicsAvailable => 'Belum ada topik aktif.';

  @override
  String get noHistoryYet => 'Belum ada riwayat sesi belajar.';

  @override
  String bestMeterLabel(int percent) {
    return 'Meter terbaik: $percent%';
  }

  @override
  String get statusNotStarted => 'Belum mulai';

  @override
  String get statusInProgress => 'Sedang berjalan';

  @override
  String get statusTargetReached => 'Sudah 80%+';

  @override
  String get continueSession => 'Lanjutkan Sesi';

  @override
  String get startNewSession => 'Mulai Sesi Baru';

  @override
  String get chooseSessionLanguage => 'Pilih Bahasa Sesi';

  @override
  String get sessionLanguageNote =>
      'Bahasa sesi tidak bisa diganti di tengah percakapan.';

  @override
  String get indonesianLabel => 'Bahasa Indonesia';

  @override
  String get englishLabel => 'English';

  @override
  String get enLockedNote =>
      'Terkunci: versi English topik ini belum disimpan guru.';

  @override
  String get cancel => 'Batal';

  @override
  String get confirm => 'Ya, Lanjutkan';

  @override
  String get save => 'Simpan';

  @override
  String get delete => 'Hapus';

  @override
  String get edit => 'Ubah';

  @override
  String get close => 'Tutup';

  @override
  String get retry => 'Coba Lagi';

  @override
  String get loading => 'Memuat...';

  @override
  String inputCounter(int used, int max) {
    return 'Pesan $used/$max';
  }

  @override
  String get messageHint => 'Jelaskan pemahamanmu ke Buddy...';

  @override
  String get buddyThinking => 'Buddy lagi mikir...';

  @override
  String get buddyTimeoutError =>
      'Buddy lagi mikir terlalu lama, coba kirim ulang ya.';

  @override
  String get endSessionButton => 'Akhiri';

  @override
  String get endSessionConfirmTitle => 'Akhiri Sesi Ini?';

  @override
  String get endSessionConfirmBody =>
      'Jika meter sudah ≥ 80%, sesi tercatat tuntas. Jika belum, sesi berhenti sebagai dihentikan manual.';

  @override
  String get sessionCompletedBanner =>
      'Sesi selesai! Yuk lihat rekap miskonsepsinya.';

  @override
  String get viewRecap => 'Lihat Rekap';

  @override
  String get moodConfused => 'Bingung';

  @override
  String get moodThinking => 'Berpikir';

  @override
  String get moodDoubtful => 'Ragu';

  @override
  String get moodStarting => 'Mulai paham';

  @override
  String get moodUnderstands => 'Paham';

  @override
  String get moodHappy => 'Senang';

  @override
  String get recapTitle => 'Rekap Miskonsepsi';

  @override
  String get finalMeterLabel => 'Meter Akhir';

  @override
  String get sessionStatusCompleted => 'Tuntas';

  @override
  String get sessionStatusIncomplete => 'Belum Tuntas (20/20 pesan)';

  @override
  String get sessionStatusAbandoned => 'Dihentikan Manual';

  @override
  String get sessionStatusActive => 'Sedang Berjalan';

  @override
  String get resolvedTitle => 'Sudah Diluruskan';

  @override
  String get unresolvedTitle => 'Belum Diluruskan';

  @override
  String get unresolvedNoHintNote =>
      'Untuk tantangan belajar, hanya judul miskonsepsi yang ditampilkan tanpa kunci jawaban.';

  @override
  String get tryAgainTopic => 'Coba Lagi Topik Ini';

  @override
  String get chooseOtherTopic => 'Pilih Topik Lain';

  @override
  String get deleteSessionTitle => 'Hapus Sesi Ini?';

  @override
  String get deleteSessionBody =>
      'Riwayat chat dan progres sesi ini akan dihapus permanen.';

  @override
  String get settingsTitle => 'Pengaturan';

  @override
  String get appLanguageLabel => 'Bahasa Aplikasi';

  @override
  String get profileSectionTitle => 'Profil Akun';

  @override
  String get updateNameSuccess => 'Nama berhasil diperbarui.';

  @override
  String get deleteAllHistoryButton => 'Hapus Semua Riwayat Sesi';

  @override
  String get deleteAllConfirm1Title => 'Hapus Semua Riwayat?';

  @override
  String get deleteAllConfirm1Body =>
      'Semua sesi mengajar dan riwayat chat milikmu akan terhapus permanen.';

  @override
  String get deleteAllConfirm2Title => 'Konfirmasi Terakhir';

  @override
  String get deleteAllConfirm2Body =>
      'Yakin 100%? Data riwayat yang dihapus tidak bisa dikembalikan.';

  @override
  String get deleteAllSuccess => 'Semua riwayat berhasil dihapus.';

  @override
  String get aboutTitle => 'Tentang Learn Buddy';

  @override
  String get aboutBody =>
      'Learn Buddy adalah aplikasi pembelajaran Struktur Data berbasis metode Learning by Teaching. Dikembangkan oleh Ahmad Farid Hernacqi (S1 PTI UNESA, 2026).';

  @override
  String get logoutButton => 'Keluar';

  @override
  String get teacherDashboardTitle => 'Dashboard Guru';

  @override
  String get manageContentButton => 'Kelola Konten';

  @override
  String get studentsProgressTitle => 'Progres Siswa (Terendah Dulu)';

  @override
  String get noStudentsYet => 'Belum ada data siswa.';

  @override
  String sessionsCountLabel(int count) {
    return '$count sesi';
  }

  @override
  String get studentDetailTitle => 'Detail Progres Siswa';

  @override
  String get teacherPrivacyBanner =>
      'Privasi aktif: isi chat siswa tidak ditampilkan dan diblokir di level database (RLS).';

  @override
  String get evidenceLabel => 'Bukti kutipan:';

  @override
  String get noEvidenceYet => 'Belum terpenuhi';

  @override
  String get contentManagementTitle => 'Kelola Konten';

  @override
  String get addTopic => 'Tambah Topik';

  @override
  String get activeLabel => 'Aktif';

  @override
  String get inactiveLabel => 'Nonaktif';

  @override
  String get enReadyBadge => 'EN Siap';

  @override
  String get enMissingBadge => 'EN Belum';

  @override
  String get translateToEnglish => 'Terjemahkan ke English';

  @override
  String get translating => 'Menerjemahkan...';

  @override
  String get reviewTranslationTitle => 'Cek & Edit Terjemahan EN';

  @override
  String get addMisconception => 'Tambah Miskonsepsi';

  @override
  String get addCriterion => 'Tambah Kriteria';

  @override
  String get misconceptionTextLabel => 'Miskonsepsi Buddy (ID)';

  @override
  String get correctConceptLabel => 'Konsep Benar (ID)';

  @override
  String get buddyIntroLabel => 'Kalimat Pembuka Buddy (ID)';

  @override
  String get criterionTextLabel => 'Teks Kriteria (ID)';

  @override
  String get titleIdLabel => 'Judul Topik (ID)';

  @override
  String get titleEnLabel => 'Judul Topik (EN)';

  @override
  String get descIdLabel => 'Deskripsi (ID)';

  @override
  String get descEnLabel => 'Deskripsi (EN)';

  @override
  String get sortOrderLabel => 'Urutan';

  @override
  String get topicCannotDeleteNote =>
      'Topik yang sudah punya sesi hanya bisa dinonaktifkan, tidak dihapus.';
}
