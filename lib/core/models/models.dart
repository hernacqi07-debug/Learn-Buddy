enum UserRole {
  student,
  teacher,
  admin;

  static UserRole fromString(String value) {
    return switch (value) {
      'admin' => UserRole.admin,
      'teacher' => UserRole.teacher,
      _ => UserRole.student,
    };
  }
}

enum SessionStatus {
  active,
  completed,
  incomplete,
  abandoned;

  static SessionStatus fromString(String value) {
    return switch (value) {
      'completed' => SessionStatus.completed,
      'incomplete' => SessionStatus.incomplete,
      'abandoned' => SessionStatus.abandoned,
      _ => SessionStatus.active,
    };
  }
}

enum BuddyMood {
  confused('assets/images/buddy/buddy_bingung.png'),
  thinking('assets/images/buddy/buddy_berpikir.png'),
  doubtful('assets/images/buddy/buddy_ragu.png'),
  starting('assets/images/buddy/buddy_mulai_paham.png'),
  understands('assets/images/buddy/buddy_paham.png'),
  happy('assets/images/buddy/buddy_senang.png');

  const BuddyMood(this.assetPath);
  final String assetPath;

  static BuddyMood fromMeter(int meterPercent) {
    final m = meterPercent.clamp(0, 100);
    if (m >= 100) return BuddyMood.happy;
    if (m >= 80) return BuddyMood.understands;
    if (m >= 60) return BuddyMood.starting;
    if (m >= 40) return BuddyMood.doubtful;
    if (m >= 20) return BuddyMood.thinking;
    return BuddyMood.confused;
  }
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    required this.languagePref,
    this.nisn,
    this.className,
    this.schoolName,
    this.avatarUrl,
  });

  final String id;
  final String email;
  final String displayName;
  final UserRole role;
  final String languagePref;
  final String? nisn;
  final String? className;
  final String? schoolName;
  final String? avatarUrl;

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      email: (map['email'] as String?) ?? '',
      displayName: (map['display_name'] as String?) ?? '',
      role: UserRole.fromString((map['role'] as String?) ?? 'student'),
      languagePref: (map['language_pref'] as String?) ?? 'id',
      nisn: map['nisn'] as String?,
      className: map['class_name'] as String?,
      schoolName: map['school_name'] as String?,
      avatarUrl: map['avatar_url'] as String?,
    );
  }
}

class Course {
  const Course({
    required this.id,
    required this.code,
    required this.titleId,
    required this.titleEn,
    required this.descriptionId,
    required this.descriptionEn,
    required this.icon,
    required this.accentColor,
    this.teacherId,
    this.teacherName,
    required this.sortOrder,
    required this.isActive,
    this.topicCount = 0,
  });

  final String id;
  final String code;
  final String titleId;
  final String titleEn;
  final String descriptionId;
  final String descriptionEn;
  final String icon;
  final String accentColor;
  final String? teacherId;
  final String? teacherName;
  final int sortOrder;
  final bool isActive;
  final int topicCount;

  String localizedTitle(String lang) =>
      lang == 'en' && titleEn.isNotEmpty ? titleEn : titleId;

  String localizedDesc(String lang) =>
      lang == 'en' && descriptionEn.isNotEmpty ? descriptionEn : descriptionId;

  factory Course.fromMap(Map<String, dynamic> map, {int topicCount = 0, String? teacherName}) {
    return Course(
      id: map['id'] as String,
      code: (map['code'] as String?) ?? '',
      titleId: (map['title_id'] as String?) ?? '',
      titleEn: (map['title_en'] as String?) ?? '',
      descriptionId: (map['description_id'] as String?) ?? '',
      descriptionEn: (map['description_en'] as String?) ?? '',
      icon: (map['icon'] as String?) ?? 'layers',
      accentColor: (map['accent_color'] as String?) ?? '#06B6D4',
      teacherId: map['teacher_id'] as String?,
      teacherName: teacherName ?? (map['profiles'] as Map<String, dynamic>?)?['display_name'] as String?,
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 1,
      isActive: (map['is_active'] as bool?) ?? true,
      topicCount: topicCount,
    );
  }
}

class TopicSummary {
  const TopicSummary({
    required this.id,
    this.courseId,
    required this.titleId,
    required this.titleEn,
    required this.descriptionId,
    required this.descriptionEn,
    required this.sortOrder,
    required this.enReady,
    required this.bestMeterPercent,
    required this.hasCompleted80,
    this.activeSessionId,
    this.theoryContent,
    this.analogyContent,
    this.codeSnippet,
    this.readingTimeMinutes = 5,
  });

  final String id;
  final String? courseId;
  final String titleId;
  final String titleEn;
  final String descriptionId;
  final String descriptionEn;
  final int sortOrder;
  final bool enReady;
  final int bestMeterPercent;
  final bool hasCompleted80;
  final String? activeSessionId;
  final String? theoryContent;
  final String? analogyContent;
  final String? codeSnippet;
  final int readingTimeMinutes;

  String localizedTitle(String lang) =>
      lang == 'en' && titleEn.isNotEmpty ? titleEn : titleId;

  String localizedDesc(String lang) =>
      lang == 'en' && descriptionEn.isNotEmpty ? descriptionEn : descriptionId;

  factory TopicSummary.fromMap(Map<String, dynamic> map) {
    return TopicSummary(
      id: map['id'] as String,
      courseId: map['course_id'] as String?,
      titleId: (map['title_id'] as String?) ?? '',
      titleEn: (map['title_en'] as String?) ?? '',
      descriptionId: (map['description_id'] as String?) ?? '',
      descriptionEn: (map['description_en'] as String?) ?? '',
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 1,
      enReady: (map['en_ready'] as bool?) ?? false,
      bestMeterPercent: (map['best_meter_percent'] as num?)?.toInt() ?? 0,
      hasCompleted80: (map['has_completed_80'] as bool?) ?? false,
      activeSessionId: map['active_session_id'] as String?,
      theoryContent: map['theory_content'] as String?,
      analogyContent: map['analogy_content'] as String?,
      codeSnippet: map['code_snippet'] as String?,
      readingTimeMinutes: (map['reading_time_minutes'] as num?)?.toInt() ?? 5,
    );
  }
}

class LearningSession {
  const LearningSession({
    required this.id,
    required this.studentId,
    required this.topicId,
    required this.language,
    required this.status,
    required this.meterPercent,
    required this.studentInputs,
    required this.startedAt,
    this.activeMisconceptionId,
    this.endedAt,
    this.topicTitleId,
    this.topicTitleEn,
  });

  final String id;
  final String studentId;
  final String topicId;
  final String? activeMisconceptionId;
  final String language;
  final SessionStatus status;
  final int meterPercent;
  final int studentInputs;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? topicTitleId;
  final String? topicTitleEn;

  String localizedTopicTitle(String lang) {
    if (lang == 'en' && (topicTitleEn ?? '').isNotEmpty) {
      return topicTitleEn!;
    }
    return topicTitleId ?? 'Topic';
  }

  factory LearningSession.fromMap(Map<String, dynamic> map) {
    final topicMap = map['topics'] as Map<String, dynamic>?;
    return LearningSession(
      id: map['id'] as String,
      studentId: map['student_id'] as String,
      topicId: map['topic_id'] as String,
      activeMisconceptionId: map['active_misconception_id'] as String?,
      language: (map['language'] as String?) ?? 'id',
      status: SessionStatus.fromString((map['status'] as String?) ?? 'active'),
      meterPercent: (map['meter_percent'] as num?)?.toInt() ?? 0,
      studentInputs: (map['student_inputs'] as num?)?.toInt() ?? 0,
      startedAt: DateTime.parse(map['started_at'] as String),
      endedAt: map['ended_at'] != null
          ? DateTime.parse(map['ended_at'] as String)
          : null,
      topicTitleId: topicMap?['title_id'] as String?,
      topicTitleEn: topicMap?['title_en'] as String?,
    );
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.sessionId,
    required this.role,
    required this.content,
    required this.createdAt,
  });

  final String id;
  final String sessionId;
  final String role; // 'student' | 'buddy'
  final String content;
  final DateTime createdAt;

  bool get isStudent => role == 'student';

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String,
      sessionId: map['session_id'] as String,
      role: (map['role'] as String?) ?? 'buddy',
      content: (map['content'] as String?) ?? '',
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }
}

class RecapMisconception {
  const RecapMisconception({
    required this.misconceptionId,
    required this.titleId,
    this.titleEn,
    required this.sortOrder,
    required this.totalCriteria,
    required this.fulfilledCriteria,
    required this.isResolved,
  });

  final String misconceptionId;
  final String titleId;
  final String? titleEn;
  final int sortOrder;
  final int totalCriteria;
  final int fulfilledCriteria;
  final bool isResolved;

  String localizedTitle(String lang) =>
      lang == 'en' && (titleEn ?? '').isNotEmpty ? titleEn! : titleId;

  factory RecapMisconception.fromMap(Map<String, dynamic> map) {
    return RecapMisconception(
      misconceptionId: map['misconception_id'] as String,
      titleId: (map['title_id'] as String?) ?? '',
      titleEn: map['title_en'] as String?,
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 1,
      totalCriteria: (map['total_criteria'] as num?)?.toInt() ?? 0,
      fulfilledCriteria: (map['fulfilled_criteria'] as num?)?.toInt() ?? 0,
      isResolved: (map['is_resolved'] as bool?) ?? false,
    );
  }
}

class TeachTurnResult {
  const TeachTurnResult({
    required this.buddyReply,
    this.nextBuddyIntro,
    required this.meterPercent,
    required this.inputsUsed,
    required this.inputsMax,
    required this.sessionStatus,
    this.activeMisconceptionId,
  });

  final String buddyReply;
  final String? nextBuddyIntro;
  final int meterPercent;
  final int inputsUsed;
  final int inputsMax;
  final SessionStatus sessionStatus;
  final String? activeMisconceptionId;

  factory TeachTurnResult.fromMap(Map<String, dynamic> map) {
    return TeachTurnResult(
      buddyReply: (map['buddy_reply'] as String?) ?? '',
      nextBuddyIntro: map['next_buddy_intro'] as String?,
      meterPercent: (map['meter_percent'] as num?)?.toInt() ?? 0,
      inputsUsed: (map['inputs_used'] as num?)?.toInt() ?? 0,
      inputsMax: (map['inputs_max'] as num?)?.toInt() ?? 20,
      sessionStatus: SessionStatus.fromString(
        (map['session_status'] as String?) ?? 'active',
      ),
      activeMisconceptionId: map['active_misconception_id'] as String?,
    );
  }
}

class TeacherCriterion {
  const TeacherCriterion({
    required this.id,
    required this.misconceptionId,
    required this.criterionText,
    this.criterionTextEn,
    required this.sortOrder,
  });

  final String id;
  final String misconceptionId;
  final String criterionText;
  final String? criterionTextEn;
  final int sortOrder;

  factory TeacherCriterion.fromMap(Map<String, dynamic> map) {
    return TeacherCriterion(
      id: map['id'] as String,
      misconceptionId: map['misconception_id'] as String,
      criterionText: (map['criterion_text'] as String?) ?? '',
      criterionTextEn: map['criterion_text_en'] as String?,
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 1,
    );
  }
}

class TeacherMisconception {
  const TeacherMisconception({
    required this.id,
    required this.topicId,
    required this.misconceptionText,
    this.misconceptionTextEn,
    required this.correctConcept,
    this.correctConceptEn,
    required this.buddyIntro,
    this.buddyIntroEn,
    required this.sortOrder,
    required this.criteria,
  });

  final String id;
  final String topicId;
  final String misconceptionText;
  final String? misconceptionTextEn;
  final String correctConcept;
  final String? correctConceptEn;
  final String buddyIntro;
  final String? buddyIntroEn;
  final int sortOrder;
  final List<TeacherCriterion> criteria;

  bool get hasCompleteEn =>
      (misconceptionTextEn ?? '').trim().isNotEmpty &&
      (correctConceptEn ?? '').trim().isNotEmpty &&
      (buddyIntroEn ?? '').trim().isNotEmpty &&
      criteria.isNotEmpty &&
      criteria.every((c) => (c.criterionTextEn ?? '').trim().isNotEmpty);

  factory TeacherMisconception.fromMap(
    Map<String, dynamic> map,
    List<TeacherCriterion> criteria,
  ) {
    return TeacherMisconception(
      id: map['id'] as String,
      topicId: map['topic_id'] as String,
      misconceptionText: (map['misconception_text'] as String?) ?? '',
      misconceptionTextEn: map['misconception_text_en'] as String?,
      correctConcept: (map['correct_concept'] as String?) ?? '',
      correctConceptEn: map['correct_concept_en'] as String?,
      buddyIntro: (map['buddy_intro'] as String?) ?? '',
      buddyIntroEn: map['buddy_intro_en'] as String?,
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 1,
      criteria: criteria,
    );
  }
}

class TeacherTopic {
  const TeacherTopic({
    required this.id,
    this.courseId,
    required this.titleId,
    required this.titleEn,
    required this.descriptionId,
    required this.descriptionEn,
    required this.sortOrder,
    required this.isActive,
    required this.hasSessions,
    required this.misconceptions,
  });

  final String id;
  final String? courseId;
  final String titleId;
  final String titleEn;
  final String descriptionId;
  final String descriptionEn;
  final int sortOrder;
  final bool isActive;
  final bool hasSessions;
  final List<TeacherMisconception> misconceptions;

  bool get enReady =>
      misconceptions.isNotEmpty && misconceptions.every((m) => m.hasCompleteEn);

  factory TeacherTopic.fromMap(
    Map<String, dynamic> map,
    List<TeacherMisconception> misconceptions,
    bool hasSessions,
  ) {
    return TeacherTopic(
      id: map['id'] as String,
      courseId: map['course_id'] as String?,
      titleId: (map['title_id'] as String?) ?? '',
      titleEn: (map['title_en'] as String?) ?? '',
      descriptionId: (map['description_id'] as String?) ?? '',
      descriptionEn: (map['description_en'] as String?) ?? '',
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 1,
      isActive: (map['is_active'] as bool?) ?? true,
      hasSessions: hasSessions,
      misconceptions: misconceptions,
    );
  }
}

class TeacherStudentSummary {
  const TeacherStudentSummary({
    required this.studentId,
    required this.displayName,
    required this.email,
    required this.sessionCount,
    required this.lowestOrBestMeter,
    required this.latestMeter,
    this.avatarUrl,
  });

  final String studentId;
  final String displayName;
  final String email;
  final int sessionCount;
  final int lowestOrBestMeter;
  final int latestMeter;
  final String? avatarUrl;
}

class TeacherSessionCriterionItem {
  const TeacherSessionCriterionItem({
    required this.criterionId,
    required this.misconceptionTitle,
    required this.criterionText,
    required this.fulfilled,
    this.evidenceQuote,
  });

  final String criterionId;
  final String misconceptionTitle;
  final String criterionText;
  final bool fulfilled;
  final String? evidenceQuote;
}

class TeacherStudentSessionDetail {
  const TeacherStudentSessionDetail({
    required this.session,
    required this.criteriaItems,
  });

  final LearningSession session;
  final List<TeacherSessionCriterionItem> criteriaItems;
}

class Assignment {
  const Assignment({
    required this.id,
    required this.teacherId,
    this.courseId,
    this.topicId,
    required this.title,
    required this.description,
    required this.type,
    this.dueDate,
    required this.createdAt,
    this.isActive = true,
    this.teacherName,
    this.topicTitle,
  });

  final String id;
  final String teacherId;
  final String? courseId;
  final String? topicId;
  final String title;
  final String description;
  final String type; // 'assignment' | 'announcement' | 'praktikum'
  final DateTime? dueDate;
  final DateTime createdAt;
  final bool isActive;
  final String? teacherName;
  final String? topicTitle;

  factory Assignment.fromMap(Map<String, dynamic> map) {
    return Assignment(
      id: map['id'] as String,
      teacherId: (map['teacher_id'] as String?) ?? '',
      courseId: map['course_id'] as String?,
      topicId: map['topic_id'] as String?,
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      type: (map['type'] as String?) ?? 'assignment',
      dueDate: map['due_date'] != null ? DateTime.tryParse(map['due_date'] as String) : null,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : DateTime.now(),
      isActive: (map['is_active'] as bool?) ?? true,
      teacherName: (map['profiles'] as Map<String, dynamic>?)?['display_name'] as String?,
      topicTitle: (map['topics'] as Map<String, dynamic>?)?['title_id'] as String?,
    );
  }
}

class Question {
  const Question({
    required this.id,
    required this.topicId,
    required this.quizType,
    required this.questionText,
    this.codeSnippet,
    required this.options,
    required this.correctIndex,
    this.explanation,
    required this.sortOrder,
  });

  final String id;
  final String topicId;
  final String quizType; // 'pre_test' | 'post_test'
  final String questionText;
  final String? codeSnippet;
  final List<String> options;
  final int correctIndex;
  final String? explanation;
  final int sortOrder;

  factory Question.fromMap(Map<String, dynamic> map) {
    final rawOptions = map['options'];
    List<String> parsedOptions = [];
    if (rawOptions is List) {
      parsedOptions = rawOptions.map((e) => e.toString()).toList();
    }
    return Question(
      id: map['id'] as String,
      topicId: map['topic_id'] as String,
      quizType: (map['quiz_type'] as String?) ?? 'pre_test',
      questionText: (map['question_text'] as String?) ?? '',
      codeSnippet: map['code_snippet'] as String?,
      options: parsedOptions,
      correctIndex: (map['correct_index'] as num?)?.toInt() ?? 0,
      explanation: map['explanation'] as String?,
      sortOrder: (map['sort_order'] as num?)?.toInt() ?? 1,
    );
  }
}

class QuizAttempt {
  const QuizAttempt({
    required this.id,
    required this.studentId,
    required this.topicId,
    required this.quizType,
    required this.score,
    required this.totalQuestions,
    required this.answers,
    required this.createdAt,
  });

  final String id;
  final String studentId;
  final String topicId;
  final String quizType;
  final int score;
  final int totalQuestions;
  final Map<String, dynamic> answers;
  final DateTime createdAt;

  factory QuizAttempt.fromMap(Map<String, dynamic> map) {
    return QuizAttempt(
      id: map['id'] as String,
      studentId: map['student_id'] as String,
      topicId: map['topic_id'] as String,
      quizType: (map['quiz_type'] as String?) ?? 'pre_test',
      score: (map['score'] as num?)?.toInt() ?? 0,
      totalQuestions: (map['total_questions'] as num?)?.toInt() ?? 0,
      answers: (map['answers'] as Map<String, dynamic>?) ?? {},
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at'] as String) : DateTime.now(),
    );
  }
}
