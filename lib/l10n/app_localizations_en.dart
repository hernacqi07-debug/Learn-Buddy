// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Learn Buddy';

  @override
  String get appTagline => 'Learn Data Structures by Teaching Buddy';

  @override
  String get privacyNotice =>
      'Chat history is saved on the server for learning & testing. Do not write personal data.';

  @override
  String get loginTitle => 'Sign In to Learn Buddy';

  @override
  String get registerTitle => 'Create Account';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password (min. 8 characters)';

  @override
  String get displayNameLabel => 'Full Name';

  @override
  String get roleLabel => 'Role';

  @override
  String get roleStudent => 'Student';

  @override
  String get roleTeacher => 'Teacher';

  @override
  String get inviteCodeLabel =>
      'Teacher Invite Code (optional if not enforced)';

  @override
  String get loginButton => 'Sign In';

  @override
  String get registerButton => 'Register';

  @override
  String get noAccountPrompt => 'Don\'t have an account? Register';

  @override
  String get hasAccountPrompt => 'Already have an account? Sign In';

  @override
  String get roleLockedHint =>
      'Your role cannot be changed after registration.';

  @override
  String get invalidEmail => 'Please enter a valid email address.';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters.';

  @override
  String get nameRequired => 'Name cannot be empty.';

  @override
  String get authErrorGeneric =>
      'Sign in failed. Please check your email and password.';

  @override
  String get inviteCodeInvalid => 'Invalid teacher invite code.';

  @override
  String get studentHomeTitle => 'Student Home';

  @override
  String welcomeUser(String name) {
    return 'Hi, $name!';
  }

  @override
  String get topicsSectionTitle => 'Data Structures Topics';

  @override
  String get historySectionTitle => 'Session History';

  @override
  String get noTopicsAvailable => 'No active topics yet.';

  @override
  String get noHistoryYet => 'No learning sessions yet.';

  @override
  String bestMeterLabel(int percent) {
    return 'Best meter: $percent%';
  }

  @override
  String get statusNotStarted => 'Not started';

  @override
  String get statusInProgress => 'In progress';

  @override
  String get statusTargetReached => '80%+ achieved';

  @override
  String get continueSession => 'Continue Session';

  @override
  String get startNewSession => 'Start New Session';

  @override
  String get chooseSessionLanguage => 'Choose Session Language';

  @override
  String get sessionLanguageNote =>
      'Session language cannot be changed mid-conversation.';

  @override
  String get indonesianLabel => 'Bahasa Indonesia';

  @override
  String get englishLabel => 'English';

  @override
  String get enLockedNote =>
      'Locked: English content for this topic is not saved yet.';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Yes, Continue';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get close => 'Close';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Loading...';

  @override
  String inputCounter(int used, int max) {
    return 'Msg $used/$max';
  }

  @override
  String get messageHint => 'Explain your understanding to Buddy...';

  @override
  String get buddyThinking => 'Buddy is thinking...';

  @override
  String get buddyTimeoutError =>
      'Buddy is taking too long, please resend your message.';

  @override
  String get endSessionButton => 'End';

  @override
  String get endSessionConfirmTitle => 'End This Session?';

  @override
  String get endSessionConfirmBody =>
      'If meter is >= 80%, it counts as completed. Otherwise it is saved as stopped manually.';

  @override
  String get sessionCompletedBanner =>
      'Session finished! View your misconception recap.';

  @override
  String get viewRecap => 'View Recap';

  @override
  String get moodConfused => 'Confused';

  @override
  String get moodThinking => 'Thinking';

  @override
  String get moodDoubtful => 'Doubtful';

  @override
  String get moodStarting => 'Getting it';

  @override
  String get moodUnderstands => 'Understands';

  @override
  String get moodHappy => 'Happy';

  @override
  String get recapTitle => 'Misconception Recap';

  @override
  String get finalMeterLabel => 'Final Meter';

  @override
  String get sessionStatusCompleted => 'Completed';

  @override
  String get sessionStatusIncomplete => 'Incomplete (20/20 msgs)';

  @override
  String get sessionStatusAbandoned => 'Stopped Manually';

  @override
  String get sessionStatusActive => 'Active';

  @override
  String get resolvedTitle => 'Resolved';

  @override
  String get unresolvedTitle => 'Still Unresolved';

  @override
  String get unresolvedNoHintNote =>
      'Only misconception titles are shown—no hints or answer keys.';

  @override
  String get tryAgainTopic => 'Retry This Topic';

  @override
  String get chooseOtherTopic => 'Choose Another Topic';

  @override
  String get deleteSessionTitle => 'Delete This Session?';

  @override
  String get deleteSessionBody =>
      'This session\'s chat history and progress will be permanently deleted.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get appLanguageLabel => 'App Language';

  @override
  String get profileSectionTitle => 'Account Profile';

  @override
  String get updateNameSuccess => 'Display name updated.';

  @override
  String get deleteAllHistoryButton => 'Delete All Session History';

  @override
  String get deleteAllConfirm1Title => 'Delete All History?';

  @override
  String get deleteAllConfirm1Body =>
      'All of your teaching sessions and chat messages will be permanently deleted.';

  @override
  String get deleteAllConfirm2Title => 'Final Confirmation';

  @override
  String get deleteAllConfirm2Body =>
      'Are you 100% sure? Deleted history cannot be recovered.';

  @override
  String get deleteAllSuccess => 'All session history deleted.';

  @override
  String get aboutTitle => 'About Learn Buddy';

  @override
  String get aboutBody =>
      'Learn Buddy is a Data Structures mobile learning app powered by Learning by Teaching. Developed by Ahmad Farid Hernacqi (S1 PTI UNESA, 2026).';

  @override
  String get logoutButton => 'Sign Out';

  @override
  String get teacherDashboardTitle => 'Teacher Dashboard';

  @override
  String get manageContentButton => 'Manage Content';

  @override
  String get studentsProgressTitle => 'Students Progress (Lowest First)';

  @override
  String get noStudentsYet => 'No student data yet.';

  @override
  String sessionsCountLabel(int count) {
    return '$count sessions';
  }

  @override
  String get studentDetailTitle => 'Student Progress Detail';

  @override
  String get teacherPrivacyBanner =>
      'Privacy enforced: student chat contents are hidden and blocked at database RLS level.';

  @override
  String get evidenceLabel => 'Evidence quote:';

  @override
  String get noEvidenceYet => 'Not fulfilled yet';

  @override
  String get contentManagementTitle => 'Manage Content';

  @override
  String get addTopic => 'Add Topic';

  @override
  String get activeLabel => 'Active';

  @override
  String get inactiveLabel => 'Inactive';

  @override
  String get enReadyBadge => 'EN Ready';

  @override
  String get enMissingBadge => 'EN Missing';

  @override
  String get translateToEnglish => 'Translate to English';

  @override
  String get translating => 'Translating...';

  @override
  String get reviewTranslationTitle => 'Review & Edit EN Translation';

  @override
  String get addMisconception => 'Add Misconception';

  @override
  String get addCriterion => 'Add Criterion';

  @override
  String get misconceptionTextLabel => 'Buddy Misconception (ID)';

  @override
  String get correctConceptLabel => 'Correct Concept (ID)';

  @override
  String get buddyIntroLabel => 'Buddy Opening Line (ID)';

  @override
  String get criterionTextLabel => 'Criterion Text (ID)';

  @override
  String get titleIdLabel => 'Topic Title (ID)';

  @override
  String get titleEnLabel => 'Topic Title (EN)';

  @override
  String get descIdLabel => 'Description (ID)';

  @override
  String get descEnLabel => 'Description (EN)';

  @override
  String get sortOrderLabel => 'Order';

  @override
  String get topicCannotDeleteNote =>
      'Topics with existing sessions can only be deactivated, not deleted.';
}
