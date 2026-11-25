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

  @override
  String get navChat => 'Chat';

  @override
  String get navHome => 'Beranda';

  @override
  String get navSettings => 'Pengaturan';

  @override
  String get back => 'Kembali';

  @override
  String get seeAll => 'Lihat Semua';

  @override
  String get switchedToEn => 'Beralih ke Bahasa Inggris (English)';

  @override
  String get switchedToId => 'Beralih ke Bahasa Indonesia';

  @override
  String failedToLoad(String error) {
    return 'Gagal memuat data: $error';
  }

  @override
  String get learningProgressTitle => 'Progres Belajar';

  @override
  String activeTopicLabel(String topic) {
    return 'Topik Aktif: $topic';
  }

  @override
  String understoodBadge(int percent) {
    return '$percent% Paham';
  }

  @override
  String get continueTeaching => 'Lanjutkan Mengajar';

  @override
  String get startTeachingBuddy => 'Mulai Mengajar Buddy';

  @override
  String get studentFeaturesTitle => 'Fitur Pembelajaran Siswa';

  @override
  String get featureMaterials => 'Modul Materi';

  @override
  String get featureMaterialsSub => 'Teori & analogi LIFO';

  @override
  String get featureQuiz => 'Kuis Pemahaman';

  @override
  String get featureQuizSub => 'Evaluasi konsep Stack';

  @override
  String get featureHistory => 'Riwayat Sesi';

  @override
  String featureHistorySub(int count) {
    return '$count sesi mengajar';
  }

  @override
  String get featureAssignments => 'Papan Tugas';

  @override
  String featureAssignmentsSub(int count) {
    return '$count tugas aktif';
  }

  @override
  String get featureAiRoom => 'Ruang AI Buddy';

  @override
  String get featureAiRoomSub => 'Bimbing murid AI';

  @override
  String get featureProtege => 'Panduan Protégé';

  @override
  String get featureProtegeSub => 'Belajar lewat mengajar';

  @override
  String get featurePreTest => 'Pre-Test Awal';

  @override
  String get featurePreTestSub => 'Uji pemahaman dasar';

  @override
  String get featureSettings => 'Pengaturan Akun';

  @override
  String get featureSettingsSub => 'Profil & sandi akun';

  @override
  String get teacherTasksTitle => 'Tugas & Pengumuman Guru';

  @override
  String get noNewTasks => 'Belum ada tugas baru yang diberikan.';

  @override
  String get protegeModalTitle => 'Metode Protégé Effect';

  @override
  String get protegeWhatIs => 'Apa itu Protégé Effect?';

  @override
  String get protegeWhatIsBody =>
      'Protégé Effect adalah fenomena psikologi pendidikan di mana seseorang memahami suatu materi secara jauh lebih mendalam ketika ia mengajarkannya kepada orang lain.';

  @override
  String get protegeYourRole => 'Peran Anda di Learn Buddy:';

  @override
  String get protegeYourRoleBody =>
      'Buddy adalah murid AI Anda yang sedang bingung dengan konsep Struktur Data. Jelaskan prinsip-prinsipnya dengan bahasa Anda sendiri, gunakan analogi riil, dan koreksi kekeliruan Buddy hingga meter pemahamannya mencapai 100%!';

  @override
  String get protegeGotIt => 'Saya Paham, Siap Mengajar!';

  @override
  String get startSessionBtn => 'Mulai Sesi';

  @override
  String startSessionFailed(String error) {
    return 'Gagal memulai sesi: $error';
  }

  @override
  String get studyModuleTitle => 'Modul Materi';

  @override
  String get moduleLinkCopied => 'Tautan modul disalin ke papan klip!';

  @override
  String get moduleNotFound => 'Data materi tidak ditemukan';

  @override
  String get basicDataStructuresBadge => 'Struktur Data Dasar';

  @override
  String readingTimeMinutes(int minutes) {
    return '$minutes Menit Baca';
  }

  @override
  String get tabBasicTheory => 'Teori Dasar';

  @override
  String get tabRealAnalogy => 'Analogi Riil';

  @override
  String get tabCodeExample => 'Contoh Kode';

  @override
  String get mainConceptTitle => 'Konsep Utama Stack';

  @override
  String get coreOperationsTitle => 'Operasi Pokok Stack';

  @override
  String get realWorldAnalogyTitle => 'Analogi Dunia Nyata';

  @override
  String get realAppsExamplesTitle =>
      'Contoh Aplikasi Nyata dalam Pemrograman:';

  @override
  String get codeCopied => 'Kode berhasil disalin!';

  @override
  String get preTestTitle => 'Pre-Test Evaluasi';

  @override
  String get postTestTitle => 'Post-Test Pemahaman';

  @override
  String get preTestTab => 'Pre-Test (Awal)';

  @override
  String get postTestTab => 'Post-Test (Akhir)';

  @override
  String get noQuestionsYet => 'Belum ada soal untuk kategori ini.';

  @override
  String get answerAllPrompt => 'Harap jawab semua soal sebelum mengumpulkan!';

  @override
  String quizLoadError(String error) {
    return 'Terjadi kesalahan memuat kuis: $error';
  }

  @override
  String quizSaveError(String error) {
    return 'Gagal menyimpan hasil: $error';
  }

  @override
  String questionCounter(int current, int total) {
    return 'Soal $current dari $total';
  }

  @override
  String answeredCounter(int answered, int total) {
    return '$answered/$total Terjawab';
  }

  @override
  String get previousBtn => 'Sebelumnya';

  @override
  String get nextBtn => 'Selanjutnya';

  @override
  String get submitQuizBtn => 'Kumpulkan Kuis';

  @override
  String yourScoreLabel(int score) {
    return 'Nilai Evaluasi Anda: $score / 100';
  }

  @override
  String get scorePassedMsg =>
      'Pemahaman Anda mengenai konsep Stack sudah sangat baik!';

  @override
  String get scoreNeedsWorkMsg =>
      'Masih ada beberapa konsep yang perlu diperkuat bersama AI Buddy.';

  @override
  String get answerReviewTitle => 'Pembahasan Soal & Kunci Jawaban:';

  @override
  String questionNumber(int num) {
    return 'Soal $num';
  }

  @override
  String yourAnswerLabel(String ans) {
    return 'Jawaban Anda: $ans';
  }

  @override
  String correctAnswerLabel(String ans) {
    return 'Jawaban Benar: $ans';
  }

  @override
  String explanationLabel(String exp) {
    return 'Penjelasan: $exp';
  }

  @override
  String get backToDashboard => 'Kembali ke Dashboard';

  @override
  String get announcementsTitle => 'Papan Pengumuman & Tugas';

  @override
  String get noAnnouncementsYet => 'Belum ada tugas atau pengumuman dari guru.';

  @override
  String get typePracticum => 'Tugas Praktikum';

  @override
  String get typeAnnouncement => 'Pengumuman Kelas';

  @override
  String get typeIndividual => 'Tugas Individu';

  @override
  String get defaultTeacherName => 'Guru Pengampu';

  @override
  String get openModuleBtn => 'Buka Modul';

  @override
  String get historyPageTitle => 'Riwayat Sesi Belajar';

  @override
  String get sessionFinishedUnderstood => 'Selesai Paham';

  @override
  String get sessionRunning => 'Sedang Berjalan';

  @override
  String get sessionIncomplete => 'Belum Tuntas';

  @override
  String teachingTurnsLang(int count, String lang) {
    return '$count Giliran Mengajar Buddy · Bahasa: $lang';
  }

  @override
  String get viewEvalRecapBtn => 'Lihat Evaluasi & Rekap';

  @override
  String get buddyAiLabel => 'Buddy (Murid AI)';

  @override
  String get buddyUnderstandingLabel => 'Tingkat Pemahaman Buddy';

  @override
  String get buddyTypingHint =>
      'Buddy sedang mengetik & mencerna penjelasanmu...';

  @override
  String get finishBtn => 'Selesai';

  @override
  String get endSessionModalTitle => 'Akhiri Sesi Belajar?';

  @override
  String get endSessionModalQuestion =>
      'Apakah Anda yakin ingin menyelesaikan sesi mengajar ini?';

  @override
  String get endSessionModalDesc =>
      'Sistem akan menyusun Rekap Capaian & Evaluasi Pemahaman berdasarkan konsep yang telah Anda ajarkan kepada Buddy.';

  @override
  String get continueLearningBtn => 'Lanjutkan Belajar';

  @override
  String get endAndViewRecapBtn => 'Akhiri & Lihat Rekap';

  @override
  String get rubricModalTitle => 'Rubrik Penilaian AI Buddy';

  @override
  String get rubricModalDesc =>
      'Ajarkan dan jelaskan poin-poin berikut agar Buddy paham sepenuhnya:';

  @override
  String get viewCriteriaTooltip => 'Lihat Kriteria Penilaian';

  @override
  String get sessionNotFound => 'Sesi belajar tidak ditemukan';

  @override
  String get viewThisRecapBtn => 'Lihat Rekap Sesi Ini';

  @override
  String get recapPageTitle => 'Rekap Capaian Belajar';

  @override
  String get recapCompletedBadge => 'Tuntas Paham (>=80%)';

  @override
  String get recapNeedsWorkBadge => 'Perlu Diperkuat';

  @override
  String teachingTurnsGiven(int count) {
    return '$count Giliran Mengajar Diberikan';
  }

  @override
  String get resolvedConceptsTitle => 'Konsep yang Berhasil Diluruskan';

  @override
  String get unresolvedConceptsTitle => 'Konsep yang Masih Perlu Diperkuat';

  @override
  String get unresolvedConceptsHint =>
      'Buddy masih bingung di butir-butir ini. Coba ajari lagi dengan analogi baru.';

  @override
  String get rereadChatBtn => 'Baca Ulang Riwayat Chat';

  @override
  String get teachAgainBtn => 'Coba Ajari Lagi (Sesi Baru)';

  @override
  String get backToHomeBtn => 'Kembali ke Beranda Utama';

  @override
  String get chatBubbleYou => 'KAMU (PENGAJAR)';

  @override
  String get chatBubbleBuddy => 'BUDDY (MURID AI)';

  @override
  String get accountSettingsTitle => 'Pengaturan Akun';

  @override
  String get chooseAvatarTitle => 'Pilih Avatar Akun';

  @override
  String get profileUpdatedMsg => 'Profil berhasil diperbarui!';

  @override
  String profileUpdateError(String error) {
    return 'Gagal menyimpan profil: $error';
  }

  @override
  String get accountInfoSection => 'Informasi Akun';

  @override
  String get enterYourNameHint => 'Masukkan nama Anda';

  @override
  String get saveChangesBtn => 'Simpan Perubahan';

  @override
  String get appLanguageSub => 'Pilih bahasa antarmuka aplikasi';

  @override
  String get securityDataSection => 'Keamanan & Data';

  @override
  String get changePasswordTitle => 'Ubah Kata Sandi';

  @override
  String get changePasswordSub => 'Ganti kata sandi akun secara berkala';

  @override
  String get clearChatHistoryTitle => 'Bersihkan Riwayat Chat';

  @override
  String get clearChatHistorySub => 'Hapus seluruh percakapan dengan Buddy';

  @override
  String get clearChatConfirmTitle => 'Hapus Riwayat Chat?';

  @override
  String get clearChatConfirmBody =>
      'Semua riwayat percakapan dan sesi bimbingan bersama AI Buddy akan dihapus permanen. Tindakan ini tidak dapat dibatalkan.';

  @override
  String get yesDeleteAllBtn => 'Ya, Hapus Semua';

  @override
  String get clearChatSuccess => 'Semua riwayat sesi berhasil dibersihkan.';

  @override
  String clearChatError(String error) {
    return 'Gagal menghapus riwayat: $error';
  }

  @override
  String get logoutFullBtn => 'Keluar dari Akun (Logout)';

  @override
  String get accountSecurityTitle => 'Keamanan Akun';

  @override
  String get changePasswordDesc =>
      'Masukkan kata sandi baru untuk akun Anda. Pastikan kata sandi kuat dan tidak mudah ditebak.';

  @override
  String get newPasswordLabel => 'Kata Sandi Baru';

  @override
  String get minCharsHint => 'Minimal 6 karakter';

  @override
  String get confirmPasswordLabel => 'Konfirmasi Kata Sandi Baru';

  @override
  String get repeatPasswordHint => 'Ulangi kata sandi baru';

  @override
  String get saveNewPasswordBtn => 'Simpan Kata Sandi Baru';

  @override
  String get passwordMin6Error => 'Kata sandi minimal 6 karakter.';

  @override
  String get passwordMismatchError => 'Konfirmasi kata sandi tidak cocok.';

  @override
  String get passwordChangedMsg => 'Kata sandi berhasil diubah!';

  @override
  String passwordChangeError(String error) {
    return 'Gagal mengubah kata sandi: $error';
  }

  @override
  String get teacherPanelSub => 'Panel Guru · Struktur Data';

  @override
  String get totalStudentsKpi => 'Total Siswa';

  @override
  String get classAverageKpi => 'Rata-rata Kelas';

  @override
  String get needsGuidanceKpi => 'Perlu Bimbingan';

  @override
  String get masteredKpi => 'Tuntas Paham';

  @override
  String get teacherActionsTitle => 'Aksi Manajemen Guru';

  @override
  String get manageModulesRubricBtn => 'Kelola Modul & Rubrik';

  @override
  String get createPracticumTaskBtn => 'Buat Tugas Praktikum';

  @override
  String get createTaskModalTitle => 'Buat Tugas / Pengumuman Baru';

  @override
  String get taskTitleLabel => 'Judul Tugas / Pengumuman';

  @override
  String get taskTitleHint => 'Contoh: Praktikum Stack Menggunakan Dart';

  @override
  String get taskDescLabel => 'Instruksi / Deskripsi';

  @override
  String get taskDescHint => 'Tuliskan deskripsi tugas untuk siswa...';

  @override
  String get categoryLabel => 'Kategori:';

  @override
  String dueDateLabel(String date) {
    return 'Tenggat Pengumpulan: $date';
  }

  @override
  String get publishTaskBtn => 'Publikasikan Tugas';

  @override
  String get taskPublishedMsg => 'Tugas berhasil dipublikasikan ke siswa!';

  @override
  String get monitoringListTitle => 'Monitoring & Daftar Siswa';

  @override
  String filterAll(int count) {
    return 'Semua ($count)';
  }

  @override
  String filterRemedial(int count) {
    return 'Remedial ($count)';
  }

  @override
  String filterMastered(int count) {
    return 'Tuntas ($count)';
  }

  @override
  String get noStudentsInCategory => 'Tidak ada siswa dalam kategori ini.';

  @override
  String sessionsWithBuddy(int count) {
    return '$count Sesi Pembelajaran Bersama Buddy';
  }

  @override
  String get viewTranscriptBtn => 'Detail Transkrip';

  @override
  String get transcriptDetailTitle => 'Detail Transkrip & Rapor';

  @override
  String get teacherPrivacyDesc =>
      'Privasi Terjaga: Guru hanya melihat capaian rubrik kompetensi & bukti konseptual siswa, tanpa mengintip obrolan mentah.';

  @override
  String get sessionHistoryRubricTitle => 'Riwayat Sesi Pembelajaran & Rubrik';

  @override
  String get noStudentSessions =>
      'Siswa belum memiliki sesi pembelajaran bersama Buddy.';

  @override
  String get criteriaAchievementTitle => 'Pencapaian Kriteria Pemahaman:';

  @override
  String studentEvidenceQuote(String quote) {
    return 'Bukti Penjelasan Siswa: \"$quote\"';
  }

  @override
  String get forgotPasswordLink => 'Lupa Kata Sandi?';

  @override
  String get resetPasswordTitle => 'Reset Kata Sandi';

  @override
  String get resetPasswordDesc =>
      'Masukkan email akun Anda. Kami akan mengirimkan tautan pemulihan kata sandi ke kotak masuk Anda.';

  @override
  String get accountEmailLabel => 'Email Akun';

  @override
  String get sendLinkBtn => 'Kirim Tautan';

  @override
  String get resetLinkSentMsg =>
      'Tautan reset kata sandi telah dikirim ke email Anda!';

  @override
  String get chooseFromGalleryBtn => 'Pilih Foto dari Galeri';

  @override
  String get chooseFromFilesGalleryBtn => 'Pilih Foto (Galeri / File)';

  @override
  String get chooseFromCameraBtn => 'Ambil Foto dari Kamera';

  @override
  String get permissionDeniedMsg =>
      'Izin akses foto/kamera ditolak. Aktifkan di Pengaturan HP.';

  @override
  String get removeProfilePhotoBtn => 'Hapus Foto Profil';

  @override
  String get orChooseEmojiLabel => 'Atau pilih avatar emoji:';

  @override
  String get uploadingPhotoMsg => 'Mengunggah foto profil...';

  @override
  String get photoUpdatedMsg => 'Foto profil berhasil diperbarui!';

  @override
  String get photoRemovedMsg => 'Foto profil dihapus.';

  @override
  String photoUploadError(String error) {
    return 'Gagal mengunggah foto: $error';
  }

  @override
  String get arPageTitle => 'Mode AR Struktur Data';

  @override
  String get arCameraActive => 'Kamera ARCore Aktif';

  @override
  String get arUnsupportedTitle => 'ARCore Tidak Didukung';

  @override
  String get arUnsupportedDesc =>
      'Perangkat ini tidak mendukung Google ARCore. Anda tetap dapat mencoba simulasi interaktif di layar.';

  @override
  String get arCameraRequired =>
      'Izin kamera diperlukan untuk mengaktifkan tampilan Real AR.';

  @override
  String get arGrantCameraBtn => 'Izinkan Kamera';

  @override
  String get arValueHint => 'Nilai elemen (mis. 42, Buku A)';

  @override
  String arCapacityLabel(int count, int max) {
    return 'Kapasitas: $count/$max';
  }

  @override
  String get arStackEmpty =>
      'Stack masih kosong (0/5). Tekan PUSH untuk menambah data.';

  @override
  String get arQueueEmpty =>
      'Queue masih kosong (0/5). Tekan ENQUEUE untuk menambah antrean.';

  @override
  String arPushSuccess(String item) {
    return 'PUSH \"$item\" berhasil ditambahkan ke posisi TOP (LIFO).';
  }

  @override
  String arPopSuccess(String item) {
    return 'POP mengambil \"$item\" dari posisi paling atas (Last In, First Out).';
  }

  @override
  String arEnqueueSuccess(String item) {
    return 'ENQUEUE \"$item\" masuk ke antrean posisi REAR (FIFO).';
  }

  @override
  String arDequeueSuccess(String item) {
    return 'DEQUEUE mengeluarkan \"$item\" dari posisi FRONT (First In, First Out).';
  }

  @override
  String arPeekSuccess(String item) {
    return 'PEEK melihat elemen terdepan/teratas: \"$item\" tanpa menghapusnya.';
  }

  @override
  String get arOverflowAlert =>
      'OVERFLOW! Kapasitas maksimal (5/5) sudah penuh.';

  @override
  String get arUnderflowAlert =>
      'UNDERFLOW! Struktur data kosong, tidak ada elemen.';

  @override
  String get arResetDone => 'Simulasi dikosongkan kembali (Reset).';
}
