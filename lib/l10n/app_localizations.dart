import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In id, this message translates to:
  /// **'Learn Buddy'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In id, this message translates to:
  /// **'Belajar Struktur Data dengan Mengajari Buddy'**
  String get appTagline;

  /// No description provided for @privacyNotice.
  ///
  /// In id, this message translates to:
  /// **'Riwayat chat disimpan di server untuk evaluasi pembelajaran. Jangan menulis data pribadi.'**
  String get privacyNotice;

  /// No description provided for @loginTitle.
  ///
  /// In id, this message translates to:
  /// **'Masuk ke Learn Buddy'**
  String get loginTitle;

  /// No description provided for @registerTitle.
  ///
  /// In id, this message translates to:
  /// **'Buat Akun Baru'**
  String get registerTitle;

  /// No description provided for @emailLabel.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In id, this message translates to:
  /// **'Password (min. 8 karakter)'**
  String get passwordLabel;

  /// No description provided for @displayNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama Lengkap'**
  String get displayNameLabel;

  /// No description provided for @roleLabel.
  ///
  /// In id, this message translates to:
  /// **'Peran'**
  String get roleLabel;

  /// No description provided for @roleStudent.
  ///
  /// In id, this message translates to:
  /// **'Siswa'**
  String get roleStudent;

  /// No description provided for @roleTeacher.
  ///
  /// In id, this message translates to:
  /// **'Guru'**
  String get roleTeacher;

  /// No description provided for @inviteCodeLabel.
  ///
  /// In id, this message translates to:
  /// **'Kode Undangan Guru (opsional jika belum diaktifkan)'**
  String get inviteCodeLabel;

  /// No description provided for @loginButton.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get loginButton;

  /// No description provided for @registerButton.
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get registerButton;

  /// No description provided for @noAccountPrompt.
  ///
  /// In id, this message translates to:
  /// **'Belum punya akun? Daftar'**
  String get noAccountPrompt;

  /// No description provided for @hasAccountPrompt.
  ///
  /// In id, this message translates to:
  /// **'Sudah punya akun? Masuk'**
  String get hasAccountPrompt;

  /// No description provided for @roleLockedHint.
  ///
  /// In id, this message translates to:
  /// **'Peran tidak bisa diubah setelah pendaftaran.'**
  String get roleLockedHint;

  /// No description provided for @invalidEmail.
  ///
  /// In id, this message translates to:
  /// **'Masukkan alamat email yang valid.'**
  String get invalidEmail;

  /// No description provided for @passwordTooShort.
  ///
  /// In id, this message translates to:
  /// **'Password minimal 8 karakter.'**
  String get passwordTooShort;

  /// No description provided for @nameRequired.
  ///
  /// In id, this message translates to:
  /// **'Nama tidak boleh kosong.'**
  String get nameRequired;

  /// No description provided for @authErrorGeneric.
  ///
  /// In id, this message translates to:
  /// **'Gagal masuk. Periksa email dan password kamu.'**
  String get authErrorGeneric;

  /// No description provided for @inviteCodeInvalid.
  ///
  /// In id, this message translates to:
  /// **'Kode undangan guru tidak valid.'**
  String get inviteCodeInvalid;

  /// No description provided for @studentHomeTitle.
  ///
  /// In id, this message translates to:
  /// **'Beranda Siswa'**
  String get studentHomeTitle;

  /// No description provided for @welcomeUser.
  ///
  /// In id, this message translates to:
  /// **'Halo, {name}!'**
  String welcomeUser(String name);

  /// No description provided for @topicsSectionTitle.
  ///
  /// In id, this message translates to:
  /// **'Topik Struktur Data'**
  String get topicsSectionTitle;

  /// No description provided for @historySectionTitle.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Sesi'**
  String get historySectionTitle;

  /// No description provided for @noTopicsAvailable.
  ///
  /// In id, this message translates to:
  /// **'Belum ada topik aktif.'**
  String get noTopicsAvailable;

  /// No description provided for @noHistoryYet.
  ///
  /// In id, this message translates to:
  /// **'Belum ada riwayat sesi belajar.'**
  String get noHistoryYet;

  /// No description provided for @bestMeterLabel.
  ///
  /// In id, this message translates to:
  /// **'Meter terbaik: {percent}%'**
  String bestMeterLabel(int percent);

  /// No description provided for @statusNotStarted.
  ///
  /// In id, this message translates to:
  /// **'Belum mulai'**
  String get statusNotStarted;

  /// No description provided for @statusInProgress.
  ///
  /// In id, this message translates to:
  /// **'Sedang berjalan'**
  String get statusInProgress;

  /// No description provided for @statusTargetReached.
  ///
  /// In id, this message translates to:
  /// **'Sudah 80%+'**
  String get statusTargetReached;

  /// No description provided for @continueSession.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan Sesi'**
  String get continueSession;

  /// No description provided for @startNewSession.
  ///
  /// In id, this message translates to:
  /// **'Mulai Sesi Baru'**
  String get startNewSession;

  /// No description provided for @chooseSessionLanguage.
  ///
  /// In id, this message translates to:
  /// **'Pilih Bahasa Sesi'**
  String get chooseSessionLanguage;

  /// No description provided for @sessionLanguageNote.
  ///
  /// In id, this message translates to:
  /// **'Bahasa sesi tidak bisa diganti di tengah percakapan.'**
  String get sessionLanguageNote;

  /// No description provided for @indonesianLabel.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Indonesia'**
  String get indonesianLabel;

  /// No description provided for @englishLabel.
  ///
  /// In id, this message translates to:
  /// **'English'**
  String get englishLabel;

  /// No description provided for @enLockedNote.
  ///
  /// In id, this message translates to:
  /// **'Terkunci: versi English topik ini belum disimpan guru.'**
  String get enLockedNote;

  /// No description provided for @cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In id, this message translates to:
  /// **'Ya, Lanjutkan'**
  String get confirm;

  /// No description provided for @save.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In id, this message translates to:
  /// **'Ubah'**
  String get edit;

  /// No description provided for @close.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get close;

  /// No description provided for @retry.
  ///
  /// In id, this message translates to:
  /// **'Coba Lagi'**
  String get retry;

  /// No description provided for @loading.
  ///
  /// In id, this message translates to:
  /// **'Memuat...'**
  String get loading;

  /// No description provided for @inputCounter.
  ///
  /// In id, this message translates to:
  /// **'Pesan {used}/{max}'**
  String inputCounter(int used, int max);

  /// No description provided for @messageHint.
  ///
  /// In id, this message translates to:
  /// **'Jelaskan pemahamanmu ke Buddy...'**
  String get messageHint;

  /// No description provided for @buddyThinking.
  ///
  /// In id, this message translates to:
  /// **'Buddy lagi mikir...'**
  String get buddyThinking;

  /// No description provided for @buddyTimeoutError.
  ///
  /// In id, this message translates to:
  /// **'Buddy lagi mikir terlalu lama, coba kirim ulang ya.'**
  String get buddyTimeoutError;

  /// No description provided for @endSessionButton.
  ///
  /// In id, this message translates to:
  /// **'Akhiri'**
  String get endSessionButton;

  /// No description provided for @endSessionConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Akhiri Sesi Ini?'**
  String get endSessionConfirmTitle;

  /// No description provided for @endSessionConfirmBody.
  ///
  /// In id, this message translates to:
  /// **'Jika meter sudah ≥ 80%, sesi tercatat tuntas. Jika belum, sesi berhenti sebagai dihentikan manual.'**
  String get endSessionConfirmBody;

  /// No description provided for @sessionCompletedBanner.
  ///
  /// In id, this message translates to:
  /// **'Sesi selesai! Yuk lihat rekap miskonsepsinya.'**
  String get sessionCompletedBanner;

  /// No description provided for @viewRecap.
  ///
  /// In id, this message translates to:
  /// **'Lihat Rekap'**
  String get viewRecap;

  /// No description provided for @moodConfused.
  ///
  /// In id, this message translates to:
  /// **'Bingung'**
  String get moodConfused;

  /// No description provided for @moodThinking.
  ///
  /// In id, this message translates to:
  /// **'Berpikir'**
  String get moodThinking;

  /// No description provided for @moodDoubtful.
  ///
  /// In id, this message translates to:
  /// **'Ragu'**
  String get moodDoubtful;

  /// No description provided for @moodStarting.
  ///
  /// In id, this message translates to:
  /// **'Mulai paham'**
  String get moodStarting;

  /// No description provided for @moodUnderstands.
  ///
  /// In id, this message translates to:
  /// **'Paham'**
  String get moodUnderstands;

  /// No description provided for @moodHappy.
  ///
  /// In id, this message translates to:
  /// **'Senang'**
  String get moodHappy;

  /// No description provided for @recapTitle.
  ///
  /// In id, this message translates to:
  /// **'Rekap Miskonsepsi'**
  String get recapTitle;

  /// No description provided for @finalMeterLabel.
  ///
  /// In id, this message translates to:
  /// **'Meter Akhir'**
  String get finalMeterLabel;

  /// No description provided for @sessionStatusCompleted.
  ///
  /// In id, this message translates to:
  /// **'Tuntas'**
  String get sessionStatusCompleted;

  /// No description provided for @sessionStatusIncomplete.
  ///
  /// In id, this message translates to:
  /// **'Belum Tuntas (20/20 pesan)'**
  String get sessionStatusIncomplete;

  /// No description provided for @sessionStatusAbandoned.
  ///
  /// In id, this message translates to:
  /// **'Dihentikan Manual'**
  String get sessionStatusAbandoned;

  /// No description provided for @sessionStatusActive.
  ///
  /// In id, this message translates to:
  /// **'Sedang Berjalan'**
  String get sessionStatusActive;

  /// No description provided for @resolvedTitle.
  ///
  /// In id, this message translates to:
  /// **'Sudah Diluruskan'**
  String get resolvedTitle;

  /// No description provided for @unresolvedTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum Diluruskan'**
  String get unresolvedTitle;

  /// No description provided for @unresolvedNoHintNote.
  ///
  /// In id, this message translates to:
  /// **'Untuk tantangan belajar, hanya judul miskonsepsi yang ditampilkan tanpa kunci jawaban.'**
  String get unresolvedNoHintNote;

  /// No description provided for @tryAgainTopic.
  ///
  /// In id, this message translates to:
  /// **'Coba Lagi Topik Ini'**
  String get tryAgainTopic;

  /// No description provided for @chooseOtherTopic.
  ///
  /// In id, this message translates to:
  /// **'Pilih Topik Lain'**
  String get chooseOtherTopic;

  /// No description provided for @deleteSessionTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus Sesi Ini?'**
  String get deleteSessionTitle;

  /// No description provided for @deleteSessionBody.
  ///
  /// In id, this message translates to:
  /// **'Riwayat chat dan progres sesi ini akan dihapus permanen.'**
  String get deleteSessionBody;

  /// No description provided for @settingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settingsTitle;

  /// No description provided for @appLanguageLabel.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Aplikasi'**
  String get appLanguageLabel;

  /// No description provided for @profileSectionTitle.
  ///
  /// In id, this message translates to:
  /// **'Profil Akun'**
  String get profileSectionTitle;

  /// No description provided for @updateNameSuccess.
  ///
  /// In id, this message translates to:
  /// **'Nama berhasil diperbarui.'**
  String get updateNameSuccess;

  /// No description provided for @deleteAllHistoryButton.
  ///
  /// In id, this message translates to:
  /// **'Hapus Semua Riwayat Sesi'**
  String get deleteAllHistoryButton;

  /// No description provided for @deleteAllConfirm1Title.
  ///
  /// In id, this message translates to:
  /// **'Hapus Semua Riwayat?'**
  String get deleteAllConfirm1Title;

  /// No description provided for @deleteAllConfirm1Body.
  ///
  /// In id, this message translates to:
  /// **'Semua sesi mengajar dan riwayat chat milikmu akan terhapus permanen.'**
  String get deleteAllConfirm1Body;

  /// No description provided for @deleteAllConfirm2Title.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi Terakhir'**
  String get deleteAllConfirm2Title;

  /// No description provided for @deleteAllConfirm2Body.
  ///
  /// In id, this message translates to:
  /// **'Yakin 100%? Data riwayat yang dihapus tidak bisa dikembalikan.'**
  String get deleteAllConfirm2Body;

  /// No description provided for @deleteAllSuccess.
  ///
  /// In id, this message translates to:
  /// **'Semua riwayat berhasil dihapus.'**
  String get deleteAllSuccess;

  /// No description provided for @aboutTitle.
  ///
  /// In id, this message translates to:
  /// **'Tentang Learn Buddy'**
  String get aboutTitle;

  /// No description provided for @aboutBody.
  ///
  /// In id, this message translates to:
  /// **'Learn Buddy adalah aplikasi pembelajaran Struktur Data berbasis metode Learning by Teaching. Dikembangkan oleh Ahmad Farid Hernacqi (S1 PTI UNESA, 2026).'**
  String get aboutBody;

  /// No description provided for @logoutButton.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get logoutButton;

  /// No description provided for @teacherDashboardTitle.
  ///
  /// In id, this message translates to:
  /// **'Dashboard Guru'**
  String get teacherDashboardTitle;

  /// No description provided for @manageContentButton.
  ///
  /// In id, this message translates to:
  /// **'Kelola Konten'**
  String get manageContentButton;

  /// No description provided for @studentsProgressTitle.
  ///
  /// In id, this message translates to:
  /// **'Progres Siswa (Terendah Dulu)'**
  String get studentsProgressTitle;

  /// No description provided for @noStudentsYet.
  ///
  /// In id, this message translates to:
  /// **'Belum ada data siswa.'**
  String get noStudentsYet;

  /// No description provided for @sessionsCountLabel.
  ///
  /// In id, this message translates to:
  /// **'{count} sesi'**
  String sessionsCountLabel(int count);

  /// No description provided for @studentDetailTitle.
  ///
  /// In id, this message translates to:
  /// **'Detail Progres Siswa'**
  String get studentDetailTitle;

  /// No description provided for @teacherPrivacyBanner.
  ///
  /// In id, this message translates to:
  /// **'Privasi aktif: isi chat siswa tidak ditampilkan dan diblokir di level database (RLS).'**
  String get teacherPrivacyBanner;

  /// No description provided for @evidenceLabel.
  ///
  /// In id, this message translates to:
  /// **'Bukti kutipan:'**
  String get evidenceLabel;

  /// No description provided for @noEvidenceYet.
  ///
  /// In id, this message translates to:
  /// **'Belum terpenuhi'**
  String get noEvidenceYet;

  /// No description provided for @contentManagementTitle.
  ///
  /// In id, this message translates to:
  /// **'Kelola Konten'**
  String get contentManagementTitle;

  /// No description provided for @addTopic.
  ///
  /// In id, this message translates to:
  /// **'Tambah Topik'**
  String get addTopic;

  /// No description provided for @activeLabel.
  ///
  /// In id, this message translates to:
  /// **'Aktif'**
  String get activeLabel;

  /// No description provided for @inactiveLabel.
  ///
  /// In id, this message translates to:
  /// **'Nonaktif'**
  String get inactiveLabel;

  /// No description provided for @enReadyBadge.
  ///
  /// In id, this message translates to:
  /// **'EN Siap'**
  String get enReadyBadge;

  /// No description provided for @enMissingBadge.
  ///
  /// In id, this message translates to:
  /// **'EN Belum'**
  String get enMissingBadge;

  /// No description provided for @translateToEnglish.
  ///
  /// In id, this message translates to:
  /// **'Terjemahkan ke English'**
  String get translateToEnglish;

  /// No description provided for @translating.
  ///
  /// In id, this message translates to:
  /// **'Menerjemahkan...'**
  String get translating;

  /// No description provided for @reviewTranslationTitle.
  ///
  /// In id, this message translates to:
  /// **'Cek & Edit Terjemahan EN'**
  String get reviewTranslationTitle;

  /// No description provided for @addMisconception.
  ///
  /// In id, this message translates to:
  /// **'Tambah Miskonsepsi'**
  String get addMisconception;

  /// No description provided for @addCriterion.
  ///
  /// In id, this message translates to:
  /// **'Tambah Kriteria'**
  String get addCriterion;

  /// No description provided for @misconceptionTextLabel.
  ///
  /// In id, this message translates to:
  /// **'Miskonsepsi Buddy (ID)'**
  String get misconceptionTextLabel;

  /// No description provided for @correctConceptLabel.
  ///
  /// In id, this message translates to:
  /// **'Konsep Benar (ID)'**
  String get correctConceptLabel;

  /// No description provided for @buddyIntroLabel.
  ///
  /// In id, this message translates to:
  /// **'Kalimat Pembuka Buddy (ID)'**
  String get buddyIntroLabel;

  /// No description provided for @criterionTextLabel.
  ///
  /// In id, this message translates to:
  /// **'Teks Kriteria (ID)'**
  String get criterionTextLabel;

  /// No description provided for @titleIdLabel.
  ///
  /// In id, this message translates to:
  /// **'Judul Topik (ID)'**
  String get titleIdLabel;

  /// No description provided for @titleEnLabel.
  ///
  /// In id, this message translates to:
  /// **'Judul Topik (EN)'**
  String get titleEnLabel;

  /// No description provided for @descIdLabel.
  ///
  /// In id, this message translates to:
  /// **'Deskripsi (ID)'**
  String get descIdLabel;

  /// No description provided for @descEnLabel.
  ///
  /// In id, this message translates to:
  /// **'Deskripsi (EN)'**
  String get descEnLabel;

  /// No description provided for @sortOrderLabel.
  ///
  /// In id, this message translates to:
  /// **'Urutan'**
  String get sortOrderLabel;

  /// No description provided for @topicCannotDeleteNote.
  ///
  /// In id, this message translates to:
  /// **'Topik yang sudah punya sesi hanya bisa dinonaktifkan, tidak dihapus.'**
  String get topicCannotDeleteNote;

  /// No description provided for @navChat.
  ///
  /// In id, this message translates to:
  /// **'Chat'**
  String get navChat;

  /// No description provided for @navHome.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get navHome;

  /// No description provided for @navSettings.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get navSettings;

  /// No description provided for @back.
  ///
  /// In id, this message translates to:
  /// **'Kembali'**
  String get back;

  /// No description provided for @seeAll.
  ///
  /// In id, this message translates to:
  /// **'Lihat Semua'**
  String get seeAll;

  /// No description provided for @switchedToEn.
  ///
  /// In id, this message translates to:
  /// **'Beralih ke Bahasa Inggris (English)'**
  String get switchedToEn;

  /// No description provided for @switchedToId.
  ///
  /// In id, this message translates to:
  /// **'Beralih ke Bahasa Indonesia'**
  String get switchedToId;

  /// No description provided for @failedToLoad.
  ///
  /// In id, this message translates to:
  /// **'Gagal memuat data: {error}'**
  String failedToLoad(String error);

  /// No description provided for @learningProgressTitle.
  ///
  /// In id, this message translates to:
  /// **'Progres Belajar'**
  String get learningProgressTitle;

  /// No description provided for @activeTopicLabel.
  ///
  /// In id, this message translates to:
  /// **'Topik Aktif: {topic}'**
  String activeTopicLabel(String topic);

  /// No description provided for @understoodBadge.
  ///
  /// In id, this message translates to:
  /// **'{percent}% Paham'**
  String understoodBadge(int percent);

  /// No description provided for @continueTeaching.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan Mengajar'**
  String get continueTeaching;

  /// No description provided for @startTeachingBuddy.
  ///
  /// In id, this message translates to:
  /// **'Mulai Mengajar Buddy'**
  String get startTeachingBuddy;

  /// No description provided for @studentFeaturesTitle.
  ///
  /// In id, this message translates to:
  /// **'Fitur Pembelajaran Siswa'**
  String get studentFeaturesTitle;

  /// No description provided for @featureMaterials.
  ///
  /// In id, this message translates to:
  /// **'Modul Materi'**
  String get featureMaterials;

  /// No description provided for @featureMaterialsSub.
  ///
  /// In id, this message translates to:
  /// **'Teori & analogi LIFO'**
  String get featureMaterialsSub;

  /// No description provided for @featureQuiz.
  ///
  /// In id, this message translates to:
  /// **'Kuis Pemahaman'**
  String get featureQuiz;

  /// No description provided for @featureQuizSub.
  ///
  /// In id, this message translates to:
  /// **'Evaluasi konsep Stack'**
  String get featureQuizSub;

  /// No description provided for @featureHistory.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Sesi'**
  String get featureHistory;

  /// No description provided for @featureHistorySub.
  ///
  /// In id, this message translates to:
  /// **'{count} sesi mengajar'**
  String featureHistorySub(int count);

  /// No description provided for @featureAssignments.
  ///
  /// In id, this message translates to:
  /// **'Papan Tugas'**
  String get featureAssignments;

  /// No description provided for @featureAssignmentsSub.
  ///
  /// In id, this message translates to:
  /// **'{count} tugas aktif'**
  String featureAssignmentsSub(int count);

  /// No description provided for @featureAiRoom.
  ///
  /// In id, this message translates to:
  /// **'Ruang AI Buddy'**
  String get featureAiRoom;

  /// No description provided for @featureAiRoomSub.
  ///
  /// In id, this message translates to:
  /// **'Bimbing murid AI'**
  String get featureAiRoomSub;

  /// No description provided for @featureProtege.
  ///
  /// In id, this message translates to:
  /// **'Panduan Protégé'**
  String get featureProtege;

  /// No description provided for @featureProtegeSub.
  ///
  /// In id, this message translates to:
  /// **'Belajar lewat mengajar'**
  String get featureProtegeSub;

  /// No description provided for @featurePreTest.
  ///
  /// In id, this message translates to:
  /// **'Pre-Test Awal'**
  String get featurePreTest;

  /// No description provided for @featurePreTestSub.
  ///
  /// In id, this message translates to:
  /// **'Uji pemahaman dasar'**
  String get featurePreTestSub;

  /// No description provided for @featureSettings.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan Akun'**
  String get featureSettings;

  /// No description provided for @featureSettingsSub.
  ///
  /// In id, this message translates to:
  /// **'Profil & sandi akun'**
  String get featureSettingsSub;

  /// No description provided for @teacherTasksTitle.
  ///
  /// In id, this message translates to:
  /// **'Tugas & Pengumuman Guru'**
  String get teacherTasksTitle;

  /// No description provided for @noNewTasks.
  ///
  /// In id, this message translates to:
  /// **'Belum ada tugas baru yang diberikan.'**
  String get noNewTasks;

  /// No description provided for @protegeModalTitle.
  ///
  /// In id, this message translates to:
  /// **'Metode Protégé Effect'**
  String get protegeModalTitle;

  /// No description provided for @protegeWhatIs.
  ///
  /// In id, this message translates to:
  /// **'Apa itu Protégé Effect?'**
  String get protegeWhatIs;

  /// No description provided for @protegeWhatIsBody.
  ///
  /// In id, this message translates to:
  /// **'Protégé Effect adalah fenomena psikologi pendidikan di mana seseorang memahami suatu materi secara jauh lebih mendalam ketika ia mengajarkannya kepada orang lain.'**
  String get protegeWhatIsBody;

  /// No description provided for @protegeYourRole.
  ///
  /// In id, this message translates to:
  /// **'Peran Anda di Learn Buddy:'**
  String get protegeYourRole;

  /// No description provided for @protegeYourRoleBody.
  ///
  /// In id, this message translates to:
  /// **'Buddy adalah murid AI Anda yang sedang bingung dengan konsep Struktur Data. Jelaskan prinsip-prinsipnya dengan bahasa Anda sendiri, gunakan analogi riil, dan koreksi kekeliruan Buddy hingga meter pemahamannya mencapai 100%!'**
  String get protegeYourRoleBody;

  /// No description provided for @protegeGotIt.
  ///
  /// In id, this message translates to:
  /// **'Saya Paham, Siap Mengajar!'**
  String get protegeGotIt;

  /// No description provided for @startSessionBtn.
  ///
  /// In id, this message translates to:
  /// **'Mulai Sesi'**
  String get startSessionBtn;

  /// No description provided for @startSessionFailed.
  ///
  /// In id, this message translates to:
  /// **'Gagal memulai sesi: {error}'**
  String startSessionFailed(String error);

  /// No description provided for @studyModuleTitle.
  ///
  /// In id, this message translates to:
  /// **'Modul Materi'**
  String get studyModuleTitle;

  /// No description provided for @moduleLinkCopied.
  ///
  /// In id, this message translates to:
  /// **'Tautan modul disalin ke papan klip!'**
  String get moduleLinkCopied;

  /// No description provided for @moduleNotFound.
  ///
  /// In id, this message translates to:
  /// **'Data materi tidak ditemukan'**
  String get moduleNotFound;

  /// No description provided for @basicDataStructuresBadge.
  ///
  /// In id, this message translates to:
  /// **'Struktur Data Dasar'**
  String get basicDataStructuresBadge;

  /// No description provided for @readingTimeMinutes.
  ///
  /// In id, this message translates to:
  /// **'{minutes} Menit Baca'**
  String readingTimeMinutes(int minutes);

  /// No description provided for @tabBasicTheory.
  ///
  /// In id, this message translates to:
  /// **'Teori Dasar'**
  String get tabBasicTheory;

  /// No description provided for @tabRealAnalogy.
  ///
  /// In id, this message translates to:
  /// **'Analogi Riil'**
  String get tabRealAnalogy;

  /// No description provided for @tabCodeExample.
  ///
  /// In id, this message translates to:
  /// **'Contoh Kode'**
  String get tabCodeExample;

  /// No description provided for @mainConceptTitle.
  ///
  /// In id, this message translates to:
  /// **'Konsep Utama Stack'**
  String get mainConceptTitle;

  /// No description provided for @coreOperationsTitle.
  ///
  /// In id, this message translates to:
  /// **'Operasi Pokok Stack'**
  String get coreOperationsTitle;

  /// No description provided for @realWorldAnalogyTitle.
  ///
  /// In id, this message translates to:
  /// **'Analogi Dunia Nyata'**
  String get realWorldAnalogyTitle;

  /// No description provided for @realAppsExamplesTitle.
  ///
  /// In id, this message translates to:
  /// **'Contoh Aplikasi Nyata dalam Pemrograman:'**
  String get realAppsExamplesTitle;

  /// No description provided for @codeCopied.
  ///
  /// In id, this message translates to:
  /// **'Kode berhasil disalin!'**
  String get codeCopied;

  /// No description provided for @preTestTitle.
  ///
  /// In id, this message translates to:
  /// **'Pre-Test Evaluasi'**
  String get preTestTitle;

  /// No description provided for @postTestTitle.
  ///
  /// In id, this message translates to:
  /// **'Post-Test Pemahaman'**
  String get postTestTitle;

  /// No description provided for @preTestTab.
  ///
  /// In id, this message translates to:
  /// **'Pre-Test (Awal)'**
  String get preTestTab;

  /// No description provided for @postTestTab.
  ///
  /// In id, this message translates to:
  /// **'Post-Test (Akhir)'**
  String get postTestTab;

  /// No description provided for @noQuestionsYet.
  ///
  /// In id, this message translates to:
  /// **'Belum ada soal untuk kategori ini.'**
  String get noQuestionsYet;

  /// No description provided for @answerAllPrompt.
  ///
  /// In id, this message translates to:
  /// **'Harap jawab semua soal sebelum mengumpulkan!'**
  String get answerAllPrompt;

  /// No description provided for @quizLoadError.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kesalahan memuat kuis: {error}'**
  String quizLoadError(String error);

  /// No description provided for @quizSaveError.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan hasil: {error}'**
  String quizSaveError(String error);

  /// No description provided for @questionCounter.
  ///
  /// In id, this message translates to:
  /// **'Soal {current} dari {total}'**
  String questionCounter(int current, int total);

  /// No description provided for @answeredCounter.
  ///
  /// In id, this message translates to:
  /// **'{answered}/{total} Terjawab'**
  String answeredCounter(int answered, int total);

  /// No description provided for @previousBtn.
  ///
  /// In id, this message translates to:
  /// **'Sebelumnya'**
  String get previousBtn;

  /// No description provided for @nextBtn.
  ///
  /// In id, this message translates to:
  /// **'Selanjutnya'**
  String get nextBtn;

  /// No description provided for @submitQuizBtn.
  ///
  /// In id, this message translates to:
  /// **'Kumpulkan Kuis'**
  String get submitQuizBtn;

  /// No description provided for @yourScoreLabel.
  ///
  /// In id, this message translates to:
  /// **'Nilai Evaluasi Anda: {score} / 100'**
  String yourScoreLabel(int score);

  /// No description provided for @scorePassedMsg.
  ///
  /// In id, this message translates to:
  /// **'Pemahaman Anda mengenai konsep Stack sudah sangat baik!'**
  String get scorePassedMsg;

  /// No description provided for @scoreNeedsWorkMsg.
  ///
  /// In id, this message translates to:
  /// **'Masih ada beberapa konsep yang perlu diperkuat bersama AI Buddy.'**
  String get scoreNeedsWorkMsg;

  /// No description provided for @answerReviewTitle.
  ///
  /// In id, this message translates to:
  /// **'Pembahasan Soal & Kunci Jawaban:'**
  String get answerReviewTitle;

  /// No description provided for @questionNumber.
  ///
  /// In id, this message translates to:
  /// **'Soal {num}'**
  String questionNumber(int num);

  /// No description provided for @yourAnswerLabel.
  ///
  /// In id, this message translates to:
  /// **'Jawaban Anda: {ans}'**
  String yourAnswerLabel(String ans);

  /// No description provided for @correctAnswerLabel.
  ///
  /// In id, this message translates to:
  /// **'Jawaban Benar: {ans}'**
  String correctAnswerLabel(String ans);

  /// No description provided for @explanationLabel.
  ///
  /// In id, this message translates to:
  /// **'Penjelasan: {exp}'**
  String explanationLabel(String exp);

  /// No description provided for @backToDashboard.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke Dashboard'**
  String get backToDashboard;

  /// No description provided for @announcementsTitle.
  ///
  /// In id, this message translates to:
  /// **'Papan Pengumuman & Tugas'**
  String get announcementsTitle;

  /// No description provided for @noAnnouncementsYet.
  ///
  /// In id, this message translates to:
  /// **'Belum ada tugas atau pengumuman dari guru.'**
  String get noAnnouncementsYet;

  /// No description provided for @typePracticum.
  ///
  /// In id, this message translates to:
  /// **'Tugas Praktikum'**
  String get typePracticum;

  /// No description provided for @typeAnnouncement.
  ///
  /// In id, this message translates to:
  /// **'Pengumuman Kelas'**
  String get typeAnnouncement;

  /// No description provided for @typeIndividual.
  ///
  /// In id, this message translates to:
  /// **'Tugas Individu'**
  String get typeIndividual;

  /// No description provided for @defaultTeacherName.
  ///
  /// In id, this message translates to:
  /// **'Guru Pengampu'**
  String get defaultTeacherName;

  /// No description provided for @openModuleBtn.
  ///
  /// In id, this message translates to:
  /// **'Buka Modul'**
  String get openModuleBtn;

  /// No description provided for @historyPageTitle.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Sesi Belajar'**
  String get historyPageTitle;

  /// No description provided for @sessionFinishedUnderstood.
  ///
  /// In id, this message translates to:
  /// **'Selesai Paham'**
  String get sessionFinishedUnderstood;

  /// No description provided for @sessionRunning.
  ///
  /// In id, this message translates to:
  /// **'Sedang Berjalan'**
  String get sessionRunning;

  /// No description provided for @sessionIncomplete.
  ///
  /// In id, this message translates to:
  /// **'Belum Tuntas'**
  String get sessionIncomplete;

  /// No description provided for @teachingTurnsLang.
  ///
  /// In id, this message translates to:
  /// **'{count} Giliran Mengajar Buddy · Bahasa: {lang}'**
  String teachingTurnsLang(int count, String lang);

  /// No description provided for @viewEvalRecapBtn.
  ///
  /// In id, this message translates to:
  /// **'Lihat Evaluasi & Rekap'**
  String get viewEvalRecapBtn;

  /// No description provided for @buddyAiLabel.
  ///
  /// In id, this message translates to:
  /// **'Buddy (Murid AI)'**
  String get buddyAiLabel;

  /// No description provided for @buddyUnderstandingLabel.
  ///
  /// In id, this message translates to:
  /// **'Tingkat Pemahaman Buddy'**
  String get buddyUnderstandingLabel;

  /// No description provided for @buddyTypingHint.
  ///
  /// In id, this message translates to:
  /// **'Buddy sedang mengetik & mencerna penjelasanmu...'**
  String get buddyTypingHint;

  /// No description provided for @finishBtn.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get finishBtn;

  /// No description provided for @endSessionModalTitle.
  ///
  /// In id, this message translates to:
  /// **'Akhiri Sesi Belajar?'**
  String get endSessionModalTitle;

  /// No description provided for @endSessionModalQuestion.
  ///
  /// In id, this message translates to:
  /// **'Apakah Anda yakin ingin menyelesaikan sesi mengajar ini?'**
  String get endSessionModalQuestion;

  /// No description provided for @endSessionModalDesc.
  ///
  /// In id, this message translates to:
  /// **'Sistem akan menyusun Rekap Capaian & Evaluasi Pemahaman berdasarkan konsep yang telah Anda ajarkan kepada Buddy.'**
  String get endSessionModalDesc;

  /// No description provided for @continueLearningBtn.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan Belajar'**
  String get continueLearningBtn;

  /// No description provided for @endAndViewRecapBtn.
  ///
  /// In id, this message translates to:
  /// **'Akhiri & Lihat Rekap'**
  String get endAndViewRecapBtn;

  /// No description provided for @rubricModalTitle.
  ///
  /// In id, this message translates to:
  /// **'Rubrik Penilaian AI Buddy'**
  String get rubricModalTitle;

  /// No description provided for @rubricModalDesc.
  ///
  /// In id, this message translates to:
  /// **'Ajarkan dan jelaskan poin-poin berikut agar Buddy paham sepenuhnya:'**
  String get rubricModalDesc;

  /// No description provided for @viewCriteriaTooltip.
  ///
  /// In id, this message translates to:
  /// **'Lihat Kriteria Penilaian'**
  String get viewCriteriaTooltip;

  /// No description provided for @sessionNotFound.
  ///
  /// In id, this message translates to:
  /// **'Sesi belajar tidak ditemukan'**
  String get sessionNotFound;

  /// No description provided for @viewThisRecapBtn.
  ///
  /// In id, this message translates to:
  /// **'Lihat Rekap Sesi Ini'**
  String get viewThisRecapBtn;

  /// No description provided for @recapPageTitle.
  ///
  /// In id, this message translates to:
  /// **'Rekap Capaian Belajar'**
  String get recapPageTitle;

  /// No description provided for @recapCompletedBadge.
  ///
  /// In id, this message translates to:
  /// **'Tuntas Paham (>=80%)'**
  String get recapCompletedBadge;

  /// No description provided for @recapNeedsWorkBadge.
  ///
  /// In id, this message translates to:
  /// **'Perlu Diperkuat'**
  String get recapNeedsWorkBadge;

  /// No description provided for @teachingTurnsGiven.
  ///
  /// In id, this message translates to:
  /// **'{count} Giliran Mengajar Diberikan'**
  String teachingTurnsGiven(int count);

  /// No description provided for @resolvedConceptsTitle.
  ///
  /// In id, this message translates to:
  /// **'Konsep yang Berhasil Diluruskan'**
  String get resolvedConceptsTitle;

  /// No description provided for @unresolvedConceptsTitle.
  ///
  /// In id, this message translates to:
  /// **'Konsep yang Masih Perlu Diperkuat'**
  String get unresolvedConceptsTitle;

  /// No description provided for @unresolvedConceptsHint.
  ///
  /// In id, this message translates to:
  /// **'Buddy masih bingung di butir-butir ini. Coba ajari lagi dengan analogi baru.'**
  String get unresolvedConceptsHint;

  /// No description provided for @rereadChatBtn.
  ///
  /// In id, this message translates to:
  /// **'Baca Ulang Riwayat Chat'**
  String get rereadChatBtn;

  /// No description provided for @teachAgainBtn.
  ///
  /// In id, this message translates to:
  /// **'Coba Ajari Lagi (Sesi Baru)'**
  String get teachAgainBtn;

  /// No description provided for @backToHomeBtn.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke Beranda Utama'**
  String get backToHomeBtn;

  /// No description provided for @chatBubbleYou.
  ///
  /// In id, this message translates to:
  /// **'KAMU (PENGAJAR)'**
  String get chatBubbleYou;

  /// No description provided for @chatBubbleBuddy.
  ///
  /// In id, this message translates to:
  /// **'BUDDY (MURID AI)'**
  String get chatBubbleBuddy;

  /// No description provided for @accountSettingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan Akun'**
  String get accountSettingsTitle;

  /// No description provided for @chooseAvatarTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih Avatar Akun'**
  String get chooseAvatarTitle;

  /// No description provided for @profileUpdatedMsg.
  ///
  /// In id, this message translates to:
  /// **'Profil berhasil diperbarui!'**
  String get profileUpdatedMsg;

  /// No description provided for @profileUpdateError.
  ///
  /// In id, this message translates to:
  /// **'Gagal menyimpan profil: {error}'**
  String profileUpdateError(String error);

  /// No description provided for @accountInfoSection.
  ///
  /// In id, this message translates to:
  /// **'Informasi Akun'**
  String get accountInfoSection;

  /// No description provided for @enterYourNameHint.
  ///
  /// In id, this message translates to:
  /// **'Masukkan nama Anda'**
  String get enterYourNameHint;

  /// No description provided for @saveChangesBtn.
  ///
  /// In id, this message translates to:
  /// **'Simpan Perubahan'**
  String get saveChangesBtn;

  /// No description provided for @appLanguageSub.
  ///
  /// In id, this message translates to:
  /// **'Pilih bahasa antarmuka aplikasi'**
  String get appLanguageSub;

  /// No description provided for @securityDataSection.
  ///
  /// In id, this message translates to:
  /// **'Keamanan & Data'**
  String get securityDataSection;

  /// No description provided for @changePasswordTitle.
  ///
  /// In id, this message translates to:
  /// **'Ubah Kata Sandi'**
  String get changePasswordTitle;

  /// No description provided for @changePasswordSub.
  ///
  /// In id, this message translates to:
  /// **'Ganti kata sandi akun secara berkala'**
  String get changePasswordSub;

  /// No description provided for @clearChatHistoryTitle.
  ///
  /// In id, this message translates to:
  /// **'Bersihkan Riwayat Chat'**
  String get clearChatHistoryTitle;

  /// No description provided for @clearChatHistorySub.
  ///
  /// In id, this message translates to:
  /// **'Hapus seluruh percakapan dengan Buddy'**
  String get clearChatHistorySub;

  /// No description provided for @clearChatConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus Riwayat Chat?'**
  String get clearChatConfirmTitle;

  /// No description provided for @clearChatConfirmBody.
  ///
  /// In id, this message translates to:
  /// **'Semua riwayat percakapan dan sesi bimbingan bersama AI Buddy akan dihapus permanen. Tindakan ini tidak dapat dibatalkan.'**
  String get clearChatConfirmBody;

  /// No description provided for @yesDeleteAllBtn.
  ///
  /// In id, this message translates to:
  /// **'Ya, Hapus Semua'**
  String get yesDeleteAllBtn;

  /// No description provided for @clearChatSuccess.
  ///
  /// In id, this message translates to:
  /// **'Semua riwayat sesi berhasil dibersihkan.'**
  String get clearChatSuccess;

  /// No description provided for @clearChatError.
  ///
  /// In id, this message translates to:
  /// **'Gagal menghapus riwayat: {error}'**
  String clearChatError(String error);

  /// No description provided for @logoutFullBtn.
  ///
  /// In id, this message translates to:
  /// **'Keluar dari Akun (Logout)'**
  String get logoutFullBtn;

  /// No description provided for @accountSecurityTitle.
  ///
  /// In id, this message translates to:
  /// **'Keamanan Akun'**
  String get accountSecurityTitle;

  /// No description provided for @changePasswordDesc.
  ///
  /// In id, this message translates to:
  /// **'Masukkan kata sandi baru untuk akun Anda. Pastikan kata sandi kuat dan tidak mudah ditebak.'**
  String get changePasswordDesc;

  /// No description provided for @newPasswordLabel.
  ///
  /// In id, this message translates to:
  /// **'Kata Sandi Baru'**
  String get newPasswordLabel;

  /// No description provided for @minCharsHint.
  ///
  /// In id, this message translates to:
  /// **'Minimal 6 karakter'**
  String get minCharsHint;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi Kata Sandi Baru'**
  String get confirmPasswordLabel;

  /// No description provided for @repeatPasswordHint.
  ///
  /// In id, this message translates to:
  /// **'Ulangi kata sandi baru'**
  String get repeatPasswordHint;

  /// No description provided for @saveNewPasswordBtn.
  ///
  /// In id, this message translates to:
  /// **'Simpan Kata Sandi Baru'**
  String get saveNewPasswordBtn;

  /// No description provided for @passwordMin6Error.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi minimal 6 karakter.'**
  String get passwordMin6Error;

  /// No description provided for @passwordMismatchError.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi kata sandi tidak cocok.'**
  String get passwordMismatchError;

  /// No description provided for @passwordChangedMsg.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi berhasil diubah!'**
  String get passwordChangedMsg;

  /// No description provided for @passwordChangeError.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengubah kata sandi: {error}'**
  String passwordChangeError(String error);

  /// No description provided for @teacherPanelSub.
  ///
  /// In id, this message translates to:
  /// **'Panel Guru · Struktur Data'**
  String get teacherPanelSub;

  /// No description provided for @totalStudentsKpi.
  ///
  /// In id, this message translates to:
  /// **'Total Siswa'**
  String get totalStudentsKpi;

  /// No description provided for @classAverageKpi.
  ///
  /// In id, this message translates to:
  /// **'Rata-rata Kelas'**
  String get classAverageKpi;

  /// No description provided for @needsGuidanceKpi.
  ///
  /// In id, this message translates to:
  /// **'Perlu Bimbingan'**
  String get needsGuidanceKpi;

  /// No description provided for @masteredKpi.
  ///
  /// In id, this message translates to:
  /// **'Tuntas Paham'**
  String get masteredKpi;

  /// No description provided for @teacherActionsTitle.
  ///
  /// In id, this message translates to:
  /// **'Aksi Manajemen Guru'**
  String get teacherActionsTitle;

  /// No description provided for @manageModulesRubricBtn.
  ///
  /// In id, this message translates to:
  /// **'Kelola Modul & Rubrik'**
  String get manageModulesRubricBtn;

  /// No description provided for @createPracticumTaskBtn.
  ///
  /// In id, this message translates to:
  /// **'Buat Tugas Praktikum'**
  String get createPracticumTaskBtn;

  /// No description provided for @createTaskModalTitle.
  ///
  /// In id, this message translates to:
  /// **'Buat Tugas / Pengumuman Baru'**
  String get createTaskModalTitle;

  /// No description provided for @taskTitleLabel.
  ///
  /// In id, this message translates to:
  /// **'Judul Tugas / Pengumuman'**
  String get taskTitleLabel;

  /// No description provided for @taskTitleHint.
  ///
  /// In id, this message translates to:
  /// **'Contoh: Praktikum Stack Menggunakan Dart'**
  String get taskTitleHint;

  /// No description provided for @taskDescLabel.
  ///
  /// In id, this message translates to:
  /// **'Instruksi / Deskripsi'**
  String get taskDescLabel;

  /// No description provided for @taskDescHint.
  ///
  /// In id, this message translates to:
  /// **'Tuliskan deskripsi tugas untuk siswa...'**
  String get taskDescHint;

  /// No description provided for @categoryLabel.
  ///
  /// In id, this message translates to:
  /// **'Kategori:'**
  String get categoryLabel;

  /// No description provided for @dueDateLabel.
  ///
  /// In id, this message translates to:
  /// **'Tenggat Pengumpulan: {date}'**
  String dueDateLabel(String date);

  /// No description provided for @publishTaskBtn.
  ///
  /// In id, this message translates to:
  /// **'Publikasikan Tugas'**
  String get publishTaskBtn;

  /// No description provided for @taskPublishedMsg.
  ///
  /// In id, this message translates to:
  /// **'Tugas berhasil dipublikasikan ke siswa!'**
  String get taskPublishedMsg;

  /// No description provided for @monitoringListTitle.
  ///
  /// In id, this message translates to:
  /// **'Monitoring & Daftar Siswa'**
  String get monitoringListTitle;

  /// No description provided for @filterAll.
  ///
  /// In id, this message translates to:
  /// **'Semua ({count})'**
  String filterAll(int count);

  /// No description provided for @filterRemedial.
  ///
  /// In id, this message translates to:
  /// **'Remedial ({count})'**
  String filterRemedial(int count);

  /// No description provided for @filterMastered.
  ///
  /// In id, this message translates to:
  /// **'Tuntas ({count})'**
  String filterMastered(int count);

  /// No description provided for @noStudentsInCategory.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada siswa dalam kategori ini.'**
  String get noStudentsInCategory;

  /// No description provided for @sessionsWithBuddy.
  ///
  /// In id, this message translates to:
  /// **'{count} Sesi Pembelajaran Bersama Buddy'**
  String sessionsWithBuddy(int count);

  /// No description provided for @viewTranscriptBtn.
  ///
  /// In id, this message translates to:
  /// **'Detail Transkrip'**
  String get viewTranscriptBtn;

  /// No description provided for @transcriptDetailTitle.
  ///
  /// In id, this message translates to:
  /// **'Detail Transkrip & Rapor'**
  String get transcriptDetailTitle;

  /// No description provided for @teacherPrivacyDesc.
  ///
  /// In id, this message translates to:
  /// **'Privasi Terjaga: Guru hanya melihat capaian rubrik kompetensi & bukti konseptual siswa, tanpa mengintip obrolan mentah.'**
  String get teacherPrivacyDesc;

  /// No description provided for @sessionHistoryRubricTitle.
  ///
  /// In id, this message translates to:
  /// **'Riwayat Sesi Pembelajaran & Rubrik'**
  String get sessionHistoryRubricTitle;

  /// No description provided for @noStudentSessions.
  ///
  /// In id, this message translates to:
  /// **'Siswa belum memiliki sesi pembelajaran bersama Buddy.'**
  String get noStudentSessions;

  /// No description provided for @criteriaAchievementTitle.
  ///
  /// In id, this message translates to:
  /// **'Pencapaian Kriteria Pemahaman:'**
  String get criteriaAchievementTitle;

  /// No description provided for @studentEvidenceQuote.
  ///
  /// In id, this message translates to:
  /// **'Bukti Penjelasan Siswa: \"{quote}\"'**
  String studentEvidenceQuote(String quote);

  /// No description provided for @forgotPasswordLink.
  ///
  /// In id, this message translates to:
  /// **'Lupa Kata Sandi?'**
  String get forgotPasswordLink;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In id, this message translates to:
  /// **'Reset Kata Sandi'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordDesc.
  ///
  /// In id, this message translates to:
  /// **'Masukkan email akun Anda. Kami akan mengirimkan tautan pemulihan kata sandi ke kotak masuk Anda.'**
  String get resetPasswordDesc;

  /// No description provided for @accountEmailLabel.
  ///
  /// In id, this message translates to:
  /// **'Email Akun'**
  String get accountEmailLabel;

  /// No description provided for @sendLinkBtn.
  ///
  /// In id, this message translates to:
  /// **'Kirim Tautan'**
  String get sendLinkBtn;

  /// No description provided for @resetLinkSentMsg.
  ///
  /// In id, this message translates to:
  /// **'Tautan reset kata sandi telah dikirim ke email Anda!'**
  String get resetLinkSentMsg;

  /// No description provided for @chooseFromGalleryBtn.
  ///
  /// In id, this message translates to:
  /// **'Pilih Foto dari Galeri'**
  String get chooseFromGalleryBtn;

  /// No description provided for @chooseFromFilesGalleryBtn.
  ///
  /// In id, this message translates to:
  /// **'Pilih Foto (Galeri / File)'**
  String get chooseFromFilesGalleryBtn;

  /// No description provided for @chooseFromCameraBtn.
  ///
  /// In id, this message translates to:
  /// **'Ambil Foto dari Kamera'**
  String get chooseFromCameraBtn;

  /// No description provided for @permissionDeniedMsg.
  ///
  /// In id, this message translates to:
  /// **'Izin akses foto/kamera ditolak. Aktifkan di Pengaturan HP.'**
  String get permissionDeniedMsg;

  /// No description provided for @removeProfilePhotoBtn.
  ///
  /// In id, this message translates to:
  /// **'Hapus Foto Profil'**
  String get removeProfilePhotoBtn;

  /// No description provided for @orChooseEmojiLabel.
  ///
  /// In id, this message translates to:
  /// **'Atau pilih avatar emoji:'**
  String get orChooseEmojiLabel;

  /// No description provided for @uploadingPhotoMsg.
  ///
  /// In id, this message translates to:
  /// **'Mengunggah foto profil...'**
  String get uploadingPhotoMsg;

  /// No description provided for @photoUpdatedMsg.
  ///
  /// In id, this message translates to:
  /// **'Foto profil berhasil diperbarui!'**
  String get photoUpdatedMsg;

  /// No description provided for @photoRemovedMsg.
  ///
  /// In id, this message translates to:
  /// **'Foto profil dihapus.'**
  String get photoRemovedMsg;

  /// No description provided for @photoUploadError.
  ///
  /// In id, this message translates to:
  /// **'Gagal mengunggah foto: {error}'**
  String photoUploadError(String error);

  /// No description provided for @arPageTitle.
  ///
  /// In id, this message translates to:
  /// **'Mode AR Struktur Data'**
  String get arPageTitle;

  /// No description provided for @arCameraActive.
  ///
  /// In id, this message translates to:
  /// **'Kamera ARCore Aktif'**
  String get arCameraActive;

  /// No description provided for @arUnsupportedTitle.
  ///
  /// In id, this message translates to:
  /// **'ARCore Tidak Didukung'**
  String get arUnsupportedTitle;

  /// No description provided for @arUnsupportedDesc.
  ///
  /// In id, this message translates to:
  /// **'Perangkat ini tidak mendukung Google ARCore. Anda tetap dapat mencoba simulasi interaktif di layar.'**
  String get arUnsupportedDesc;

  /// No description provided for @arCameraRequired.
  ///
  /// In id, this message translates to:
  /// **'Izin kamera diperlukan untuk mengaktifkan tampilan Real AR.'**
  String get arCameraRequired;

  /// No description provided for @arGrantCameraBtn.
  ///
  /// In id, this message translates to:
  /// **'Izinkan Kamera'**
  String get arGrantCameraBtn;

  /// No description provided for @arValueHint.
  ///
  /// In id, this message translates to:
  /// **'Nilai elemen (mis. 42, Buku A)'**
  String get arValueHint;

  /// No description provided for @arCapacityLabel.
  ///
  /// In id, this message translates to:
  /// **'Kapasitas: {count}/{max}'**
  String arCapacityLabel(int count, int max);

  /// No description provided for @arStackEmpty.
  ///
  /// In id, this message translates to:
  /// **'Stack masih kosong (0/5). Tekan PUSH untuk menambah data.'**
  String get arStackEmpty;

  /// No description provided for @arQueueEmpty.
  ///
  /// In id, this message translates to:
  /// **'Queue masih kosong (0/5). Tekan ENQUEUE untuk menambah antrean.'**
  String get arQueueEmpty;

  /// No description provided for @arPushSuccess.
  ///
  /// In id, this message translates to:
  /// **'PUSH \"{item}\" berhasil ditambahkan ke posisi TOP (LIFO).'**
  String arPushSuccess(String item);

  /// No description provided for @arPopSuccess.
  ///
  /// In id, this message translates to:
  /// **'POP mengambil \"{item}\" dari posisi paling atas (Last In, First Out).'**
  String arPopSuccess(String item);

  /// No description provided for @arEnqueueSuccess.
  ///
  /// In id, this message translates to:
  /// **'ENQUEUE \"{item}\" masuk ke antrean posisi REAR (FIFO).'**
  String arEnqueueSuccess(String item);

  /// No description provided for @arDequeueSuccess.
  ///
  /// In id, this message translates to:
  /// **'DEQUEUE mengeluarkan \"{item}\" dari posisi FRONT (First In, First Out).'**
  String arDequeueSuccess(String item);

  /// No description provided for @arPeekSuccess.
  ///
  /// In id, this message translates to:
  /// **'PEEK melihat elemen terdepan/teratas: \"{item}\" tanpa menghapusnya.'**
  String arPeekSuccess(String item);

  /// No description provided for @arOverflowAlert.
  ///
  /// In id, this message translates to:
  /// **'OVERFLOW! Kapasitas maksimal (5/5) sudah penuh.'**
  String get arOverflowAlert;

  /// No description provided for @arUnderflowAlert.
  ///
  /// In id, this message translates to:
  /// **'UNDERFLOW! Struktur data kosong, tidak ada elemen.'**
  String get arUnderflowAlert;

  /// No description provided for @arResetDone.
  ///
  /// In id, this message translates to:
  /// **'Simulasi dikosongkan kembali (Reset).'**
  String get arResetDone;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
