import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/models.dart';

class SessionRepository {
  SessionRepository(this._client);
  final SupabaseClient _client;

  Future<List<Course>> getCourses() async {
    try {
      final rows = await _client
          .from('courses')
          .select('*, profiles!courses_teacher_id_fkey(display_name), topics(id)')
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      return (rows as List).map((e) {
        final map = Map<String, dynamic>.from(e as Map);
        final topics = map['topics'] as List? ?? [];
        final teacherName =
            (map['profiles'] as Map<String, dynamic>?)?['display_name']
                as String?;
        return Course.fromMap(
          map,
          topicCount: topics.length,
          teacherName: teacherName,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<TopicSummary>> getTopicsSummary({String? courseId}) async {
    try {
      final rows = await _client.rpc(
        'get_student_topics_by_course',
        params: courseId != null ? {'p_course_id': courseId} : {},
      );
      return (rows as List)
          .map((e) => TopicSummary.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      final rows = await _client.rpc('get_student_topics_summary');
      final list = (rows as List)
          .map((e) => TopicSummary.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
      if (courseId != null) {
        return list.where((t) => t.courseId == courseId).toList();
      }
      return list;
    }
  }

  Future<List<LearningSession>> getMySessions() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return [];
    final rows = await _client
        .from('sessions')
        .select('*, topics(title_id, title_en)')
        .eq('student_id', uid)
        .order('started_at', ascending: false);
    return (rows as List)
        .map((e) => LearningSession.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<LearningSession> getSession(String sessionId) async {
    final row = await _client
        .from('sessions')
        .select('*, topics(title_id, title_en)')
        .eq('id', sessionId)
        .single();
    return LearningSession.fromMap(row);
  }

  Future<List<ChatMessage>> getMessages(String sessionId) async {
    final rows = await _client
        .from('messages')
        .select()
        .eq('session_id', sessionId)
        .order('created_at', ascending: true);
    return (rows as List)
        .map((e) => ChatMessage.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<LearningSession> startSession({
    required String topicId,
    required String language,
  }) async {
    final row = await _client.rpc(
      'start_learning_session',
      params: {
        'p_topic_id': topicId,
        'p_language': language,
      },
    );
    return LearningSession.fromMap(Map<String, dynamic>.from(row as Map));
  }

  Future<LearningSession> endSession(String sessionId) async {
    final row = await _client.rpc(
      'end_learning_session',
      params: {'p_session_id': sessionId},
    );
    return LearningSession.fromMap(Map<String, dynamic>.from(row as Map));
  }

  Future<void> deleteSession(String sessionId) async {
    await _client.from('sessions').delete().eq('id', sessionId);
  }

  Future<void> deleteAllMySessions() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;
    await _client.from('sessions').delete().eq('student_id', uid);
  }

  Future<List<RecapMisconception>> getSessionRecap(String sessionId) async {
    final rows = await _client.rpc(
      'get_session_recap',
      params: {'p_session_id': sessionId},
    );
    return (rows as List)
        .map(
          (e) => RecapMisconception.fromMap(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  // --- Real Data: Assignments & Announcements ---
  Future<List<Assignment>> getAssignments() async {
    try {
      final rows = await _client
          .from('assignments')
          .select('*, profiles(display_name), topics(title_id)')
          .order('created_at', ascending: false);
      return (rows as List)
          .map((e) => Assignment.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  // --- Real Data: Topic Detail & Content ---
  Future<TopicSummary?> getTopicDetail(String topicId) async {
    try {
      final row = await _client
          .from('topics')
          .select()
          .eq('id', topicId)
          .maybeSingle();
      if (row == null) return null;
      return TopicSummary.fromMap(Map<String, dynamic>.from(row as Map));
    } catch (_) {
      return null;
    }
  }

  // --- Real Data: Questions & Quizzes ---
  Future<List<Question>> getQuestions(String topicId, {String? quizType}) async {
    try {
      var query = _client.from('questions').select().eq('topic_id', topicId);
      if (quizType != null) {
        query = query.eq('type', quizType);
      }
      final rows = await query.order('sort_order', ascending: true);
      return (rows as List)
          .map((e) => Question.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<QuizAttempt> submitQuizAttempt({
    required String topicId,
    required String quizType,
    required int score,
    required int totalQuestions,
    int? correctAnswers,
    required Map<String, dynamic> answers,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw Exception('User not logged in');

    final resolvedCorrectAnswers = correctAnswers ??
        answers.values.where((v) => v is Map && v['is_correct'] == true).length;

    final data = {
      'student_id': uid,
      'topic_id': topicId,
      'quiz_type': quizType,
      'score': score,
      'total_questions': totalQuestions,
      'correct_answers': resolvedCorrectAnswers,
      'answers': answers,
    };

    final row = await _client
        .from('quiz_attempts')
        .insert(data)
        .select()
        .single();
    return QuizAttempt.fromMap(Map<String, dynamic>.from(row as Map));
  }

  Future<List<QuizAttempt>> getQuizAttempts(String topicId) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return [];
    try {
      final rows = await _client
          .from('quiz_attempts')
          .select()
          .eq('student_id', uid)
          .eq('topic_id', topicId)
          .order('created_at', ascending: false);
      return (rows as List)
          .map((e) => QuizAttempt.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<QuizAttempt>> getAllMyQuizAttempts() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return [];
    try {
      final rows = await _client
          .from('quiz_attempts')
          .select()
          .eq('student_id', uid)
          .order('created_at', ascending: false);
      return (rows as List)
          .map((e) => QuizAttempt.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, ({int preCount, int postCount})>>
      getQuestionCountsByTopic() async {
    try {
      final rows = await _client.from('questions').select('topic_id, type');
      final counts = <String, ({int preCount, int postCount})>{};
      for (final r in (rows as List)) {
        final m = Map<String, dynamic>.from(r as Map);
        final tid = m['topic_id'] as String?;
        final type = (m['type'] as String?) ?? 'pre_test';
        if (tid == null) continue;
        final prev = counts[tid] ?? (preCount: 0, postCount: 0);
        counts[tid] = type == 'post_test'
            ? (preCount: prev.preCount, postCount: prev.postCount + 1)
            : (preCount: prev.preCount + 1, postCount: prev.postCount);
      }
      return counts;
    } catch (_) {
      return {};
    }
  }

  // --- Real Data: User Account Security ---
  Future<void> changePassword(String newPassword) async {
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }
}
