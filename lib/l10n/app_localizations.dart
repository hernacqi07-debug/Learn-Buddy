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
