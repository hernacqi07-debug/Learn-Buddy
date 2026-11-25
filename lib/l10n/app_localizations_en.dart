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

  @override
  String get navChat => 'Chat';

  @override
  String get navHome => 'Home';

  @override
  String get navSettings => 'Settings';

  @override
  String get back => 'Back';

  @override
  String get seeAll => 'See All';

  @override
  String get switchedToEn => 'Switched to English';

  @override
  String get switchedToId => 'Switched to Indonesian';

  @override
  String failedToLoad(String error) {
    return 'Failed to load data: $error';
  }

  @override
  String get learningProgressTitle => 'Learning Progress';

  @override
  String activeTopicLabel(String topic) {
    return 'Active Topic: $topic';
  }

  @override
  String understoodBadge(int percent) {
    return '$percent% Understood';
  }

  @override
  String get continueTeaching => 'Continue Teaching';

  @override
  String get startTeachingBuddy => 'Start Teaching Buddy';

  @override
  String get studentFeaturesTitle => 'Student Learning Features';

  @override
  String get featureMaterials => 'Study Modules';

  @override
  String get featureMaterialsSub => 'LIFO theory & analogies';

  @override
  String get featureQuiz => 'Comprehension Quiz';

  @override
  String get featureQuizSub => 'Stack concept evaluation';

  @override
  String get featureHistory => 'Session History';

  @override
  String featureHistorySub(int count) {
    return '$count teaching sessions';
  }

  @override
  String get featureAssignments => 'Tasks Board';

  @override
  String featureAssignmentsSub(int count) {
    return '$count active tasks';
  }

  @override
  String get featureAiRoom => 'AI Buddy Room';

  @override
  String get featureAiRoomSub => 'Tutor the AI student';

  @override
  String get featureProtege => 'Protégé Guide';

  @override
  String get featureProtegeSub => 'Learn by teaching';

  @override
  String get featurePreTest => 'Initial Pre-Test';

  @override
  String get featurePreTestSub => 'Test basic knowledge';

  @override
  String get featureSettings => 'Account Settings';

  @override
  String get featureSettingsSub => 'Profile & password';

  @override
  String get teacherTasksTitle => 'Teacher Tasks & Announcements';

  @override
  String get noNewTasks => 'No new tasks assigned yet.';

  @override
  String get protegeModalTitle => 'The Protégé Effect Method';

  @override
  String get protegeWhatIs => 'What is the Protégé Effect?';

  @override
  String get protegeWhatIsBody =>
      'The Protégé Effect is an educational psychology phenomenon where a person understands a subject much more deeply by teaching it to someone else.';

  @override
  String get protegeYourRole => 'Your Role in Learn Buddy:';

  @override
  String get protegeYourRoleBody =>
      'Buddy is your AI student who is confused about Data Structures. Explain the principles in your own words, use real-world analogies, and correct Buddy\'s misconceptions until its understanding reaches 100%!';

  @override
  String get protegeGotIt => 'Got It, Ready to Teach!';

  @override
  String get startSessionBtn => 'Start Session';

  @override
  String startSessionFailed(String error) {
    return 'Failed to start session: $error';
  }

  @override
  String get studyModuleTitle => 'Study Module';

  @override
  String get moduleLinkCopied => 'Module link copied to clipboard!';

  @override
  String get moduleNotFound => 'Module data not found';

  @override
  String get basicDataStructuresBadge => 'Basic Data Structures';

  @override
  String readingTimeMinutes(int minutes) {
    return '$minutes Min Read';
  }

  @override
  String get tabBasicTheory => 'Basic Theory';

  @override
  String get tabRealAnalogy => 'Real Analogy';

  @override
  String get tabCodeExample => 'Code Example';

  @override
  String get mainConceptTitle => 'Core Stack Concept';

  @override
  String get coreOperationsTitle => 'Core Stack Operations';

  @override
  String get realWorldAnalogyTitle => 'Real-World Analogy';

  @override
  String get realAppsExamplesTitle => 'Real Programming Examples:';

  @override
  String get codeCopied => 'Code copied to clipboard!';

  @override
  String get preTestTitle => 'Evaluation Pre-Test';

  @override
  String get postTestTitle => 'Comprehension Post-Test';

  @override
  String get preTestTab => 'Pre-Test (Initial)';

  @override
  String get postTestTab => 'Post-Test (Final)';

  @override
  String get noQuestionsYet => 'No questions available for this category yet.';

  @override
  String get answerAllPrompt =>
      'Please answer all questions before submitting!';

  @override
  String quizLoadError(String error) {
    return 'Error loading quiz: $error';
  }

  @override
  String quizSaveError(String error) {
    return 'Failed to save result: $error';
  }

  @override
  String questionCounter(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String answeredCounter(int answered, int total) {
    return '$answered/$total Answered';
  }

  @override
  String get previousBtn => 'Previous';

  @override
  String get nextBtn => 'Next';

  @override
  String get submitQuizBtn => 'Submit Quiz';

  @override
  String yourScoreLabel(int score) {
    return 'Your Evaluation Score: $score / 100';
  }

  @override
  String get scorePassedMsg =>
      'Your understanding of Stack concepts is very good!';

  @override
  String get scoreNeedsWorkMsg =>
      'There are still some concepts to strengthen with AI Buddy.';

  @override
  String get answerReviewTitle => 'Answer Review & Key:';

  @override
  String questionNumber(int num) {
    return 'Question $num';
  }

  @override
  String yourAnswerLabel(String ans) {
    return 'Your Answer: $ans';
  }

  @override
  String correctAnswerLabel(String ans) {
    return 'Correct Answer: $ans';
  }

  @override
  String explanationLabel(String exp) {
    return 'Explanation: $exp';
  }

  @override
  String get backToDashboard => 'Back to Dashboard';

  @override
  String get announcementsTitle => 'Announcements & Tasks Board';

  @override
  String get noAnnouncementsYet =>
      'No tasks or announcements from your teacher yet.';

  @override
  String get typePracticum => 'Practicum Task';

  @override
  String get typeAnnouncement => 'Class Announcement';

  @override
  String get typeIndividual => 'Individual Task';

  @override
  String get defaultTeacherName => 'Instructor';

  @override
  String get openModuleBtn => 'Open Module';

  @override
  String get historyPageTitle => 'Learning Session History';

  @override
  String get sessionFinishedUnderstood => 'Completed';

  @override
  String get sessionRunning => 'In Progress';

  @override
  String get sessionIncomplete => 'Incomplete';

  @override
  String teachingTurnsLang(int count, String lang) {
    return '$count Teaching Turns · Language: $lang';
  }

  @override
  String get viewEvalRecapBtn => 'View Evaluation & Recap';

  @override
  String get buddyAiLabel => 'Buddy (AI Student)';

  @override
  String get buddyUnderstandingLabel => 'Buddy Understanding Level';

  @override
  String get buddyTypingHint =>
      'Buddy is typing & processing your explanation...';

  @override
  String get finishBtn => 'Finish';

  @override
  String get endSessionModalTitle => 'End Learning Session?';

  @override
  String get endSessionModalQuestion =>
      'Are you sure you want to finish this teaching session?';

  @override
  String get endSessionModalDesc =>
      'The system will generate an Achievement Recap & Comprehension Evaluation based on the concepts you taught Buddy.';

  @override
  String get continueLearningBtn => 'Continue Learning';

  @override
  String get endAndViewRecapBtn => 'End & View Recap';

  @override
  String get rubricModalTitle => 'AI Buddy Assessment Rubric';

  @override
  String get rubricModalDesc =>
      'Teach and explain these key points so Buddy fully understands:';

  @override
  String get viewCriteriaTooltip => 'View Assessment Criteria';

  @override
  String get sessionNotFound => 'Learning session not found';

  @override
  String get viewThisRecapBtn => 'View This Session Recap';

  @override
  String get recapPageTitle => 'Learning Achievement Recap';

  @override
  String get recapCompletedBadge => 'Mastered (>=80%)';

  @override
  String get recapNeedsWorkBadge => 'Needs Strengthening';

  @override
  String teachingTurnsGiven(int count) {
    return '$count Teaching Turns Given';
  }

  @override
  String get resolvedConceptsTitle => 'Concepts Successfully Clarified';

  @override
  String get unresolvedConceptsTitle => 'Concepts Still Needing Reinforcement';

  @override
  String get unresolvedConceptsHint =>
      'Buddy is still confused on these points. Try teaching again with a new analogy.';

  @override
  String get rereadChatBtn => 'Review Chat History';

  @override
  String get teachAgainBtn => 'Teach Again (New Session)';

  @override
  String get backToHomeBtn => 'Back to Main Home';

  @override
  String get chatBubbleYou => 'YOU (TEACHER)';

  @override
  String get chatBubbleBuddy => 'BUDDY (AI STUDENT)';

  @override
  String get accountSettingsTitle => 'Account Settings';

  @override
  String get chooseAvatarTitle => 'Choose Account Avatar';

  @override
  String get profileUpdatedMsg => 'Profile updated successfully!';

  @override
  String profileUpdateError(String error) {
    return 'Failed to save profile: $error';
  }

  @override
  String get accountInfoSection => 'Account Information';

  @override
  String get enterYourNameHint => 'Enter your name';

  @override
  String get saveChangesBtn => 'Save Changes';

  @override
  String get appLanguageSub => 'Choose app interface language';

  @override
  String get securityDataSection => 'Security & Data';

  @override
  String get changePasswordTitle => 'Change Password';

  @override
  String get changePasswordSub => 'Change your account password periodically';

  @override
  String get clearChatHistoryTitle => 'Clear Chat History';

  @override
  String get clearChatHistorySub => 'Delete all conversations with Buddy';

  @override
  String get clearChatConfirmTitle => 'Delete Chat History?';

  @override
  String get clearChatConfirmBody =>
      'All conversation history and tutoring sessions with AI Buddy will be permanently deleted. This action cannot be undone.';

  @override
  String get yesDeleteAllBtn => 'Yes, Delete All';

  @override
  String get clearChatSuccess => 'All session history has been cleared.';

  @override
  String clearChatError(String error) {
    return 'Failed to delete history: $error';
  }

  @override
  String get logoutFullBtn => 'Sign Out (Logout)';

  @override
  String get accountSecurityTitle => 'Account Security';

  @override
  String get changePasswordDesc =>
      'Enter a new password for your account. Make sure it is strong and hard to guess.';

  @override
  String get newPasswordLabel => 'New Password';

  @override
  String get minCharsHint => 'Minimum 6 characters';

  @override
  String get confirmPasswordLabel => 'Confirm New Password';

  @override
  String get repeatPasswordHint => 'Repeat new password';

  @override
  String get saveNewPasswordBtn => 'Save New Password';

  @override
  String get passwordMin6Error => 'Password must be at least 6 characters.';

  @override
  String get passwordMismatchError => 'Password confirmation does not match.';

  @override
  String get passwordChangedMsg => 'Password changed successfully!';

  @override
  String passwordChangeError(String error) {
    return 'Failed to change password: $error';
  }

  @override
  String get teacherPanelSub => 'Teacher Panel · Data Structures';

  @override
  String get totalStudentsKpi => 'Total Students';

  @override
  String get classAverageKpi => 'Class Average';

  @override
  String get needsGuidanceKpi => 'Needs Guidance';

  @override
  String get masteredKpi => 'Mastered';

  @override
  String get teacherActionsTitle => 'Teacher Management Actions';

  @override
  String get manageModulesRubricBtn => 'Manage Modules & Rubric';

  @override
  String get createPracticumTaskBtn => 'Create Practicum Task';

  @override
  String get createTaskModalTitle => 'Create New Task / Announcement';

  @override
  String get taskTitleLabel => 'Task / Announcement Title';

  @override
  String get taskTitleHint => 'E.g., Stack Practicum Using Dart';

  @override
  String get taskDescLabel => 'Instructions / Description';

  @override
  String get taskDescHint => 'Write task instructions for students...';

  @override
  String get categoryLabel => 'Category:';

  @override
  String dueDateLabel(String date) {
    return 'Due Date: $date';
  }

  @override
  String get publishTaskBtn => 'Publish Task';

  @override
  String get taskPublishedMsg => 'Task published to students successfully!';

  @override
  String get monitoringListTitle => 'Monitoring & Student List';

  @override
  String filterAll(int count) {
    return 'All ($count)';
  }

  @override
  String filterRemedial(int count) {
    return 'Remedial ($count)';
  }

  @override
  String filterMastered(int count) {
    return 'Mastered ($count)';
  }

  @override
  String get noStudentsInCategory => 'No students in this category.';

  @override
  String sessionsWithBuddy(int count) {
    return '$count Learning Sessions with Buddy';
  }

  @override
  String get viewTranscriptBtn => 'View Transcript';

  @override
  String get transcriptDetailTitle => 'Transcript & Report Detail';

  @override
  String get teacherPrivacyDesc =>
      'Privacy Protected: Teachers only view competency rubric achievements & conceptual evidence quotes, without viewing raw chats.';

  @override
  String get sessionHistoryRubricTitle => 'Learning Session History & Rubric';

  @override
  String get noStudentSessions =>
      'This student has no learning sessions with Buddy yet.';

  @override
  String get criteriaAchievementTitle => 'Comprehension Criteria Achievement:';

  @override
  String studentEvidenceQuote(String quote) {
    return 'Student Explanation Evidence: \"$quote\"';
  }

  @override
  String get forgotPasswordLink => 'Forgot Password?';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String get resetPasswordDesc =>
      'Enter your account email. We will send a password recovery link to your inbox.';

  @override
  String get accountEmailLabel => 'Account Email';

  @override
  String get sendLinkBtn => 'Send Link';

  @override
  String get resetLinkSentMsg =>
      'Password reset link has been sent to your email!';

  @override
  String get chooseFromGalleryBtn => 'Choose Photo from Gallery';

  @override
  String get chooseFromFilesGalleryBtn => 'Choose Photo (Gallery / Files)';

  @override
  String get chooseFromCameraBtn => 'Take Photo with Camera';

  @override
  String get permissionDeniedMsg =>
      'Photo/camera permission denied. Please enable it in device Settings.';

  @override
  String get removeProfilePhotoBtn => 'Remove Profile Photo';

  @override
  String get orChooseEmojiLabel => 'Or choose an emoji avatar:';

  @override
  String get uploadingPhotoMsg => 'Uploading profile photo...';

  @override
  String get photoUpdatedMsg => 'Profile photo updated!';

  @override
  String get photoRemovedMsg => 'Profile photo removed.';

  @override
  String photoUploadError(String error) {
    return 'Failed to upload photo: $error';
  }

  @override
  String get arPageTitle => 'Data Structures AR Mode';

  @override
  String get arCameraActive => 'ARCore Camera Active';

  @override
  String get arUnsupportedTitle => 'ARCore Not Supported';

  @override
  String get arUnsupportedDesc =>
      'This device does not support Google ARCore. You can still test the interactive simulation on screen.';

  @override
  String get arCameraRequired =>
      'Camera permission is required to enable Real AR view.';

  @override
  String get arGrantCameraBtn => 'Allow Camera';

  @override
  String get arValueHint => 'Element value (e.g. 42, Book A)';

  @override
  String arCapacityLabel(int count, int max) {
    return 'Capacity: $count/$max';
  }

  @override
  String get arStackEmpty =>
      'Stack is empty (0/5). Press PUSH to add an element.';

  @override
  String get arQueueEmpty =>
      'Queue is empty (0/5). Press ENQUEUE to add to the queue.';

  @override
  String arPushSuccess(String item) {
    return 'PUSH \"$item\" added to the TOP position (LIFO).';
  }

  @override
  String arPopSuccess(String item) {
    return 'POP removed \"$item\" from the top (Last In, First Out).';
  }

  @override
  String arEnqueueSuccess(String item) {
    return 'ENQUEUE \"$item\" entered at the REAR position (FIFO).';
  }

  @override
  String arDequeueSuccess(String item) {
    return 'DEQUEUE removed \"$item\" from the FRONT (First In, First Out).';
  }

  @override
  String arPeekSuccess(String item) {
    return 'PEEK inspects element \"$item\" without removing it.';
  }

  @override
  String get arOverflowAlert => 'OVERFLOW! Maximum capacity (5/5) is full.';

  @override
  String get arUnderflowAlert =>
      'UNDERFLOW! Data structure is empty, no elements left.';

  @override
  String get arResetDone => 'Simulation cleared (Reset).';
}
