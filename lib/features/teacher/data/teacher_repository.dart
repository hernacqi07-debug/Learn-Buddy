import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/models.dart';

class TeacherRepository {
  TeacherRepository(this._client);
  final SupabaseClient _client;

  Future<List<Course>> getCourses() async {
    try {
      final rows = await _client
          .from('courses')
          .select('*, profiles(display_name), topics(id)')
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

  Future<void> assignTeacherToCourse({
    required String courseId,
    required String? teacherId,
  }) async {
    await _client
        .from('courses')
        .update({'teacher_id': teacherId})
        .eq('id', courseId);
  }

  /// Reads students and their session meters (NEVER accesses messages table).
  /// Sorted ascending by lowest/best meter so struggling students appear first.
  Future<List<TeacherStudentSummary>> getStudentsProgress({
    String? courseId,
  }) async {
    final studentsRaw = await _client
        .from('profiles')
        .select('id, display_name, email')
        .eq('role', 'student')
        .order('display_name', ascending: true);

    final sessionsRaw = await _client
        .from('sessions')
        .select('student_id, topic_id, meter_percent, started_at, topics(course_id)')
        .order('started_at', ascending: false);

    final sessionsByStudent = <String, List<Map<String, dynamic>>>{};
    for (final s in (sessionsRaw as List)) {
      final map = Map<String, dynamic>.from(s as Map);
      if (courseId != null) {
        final topicCourseId =
            (map['topics'] as Map<String, dynamic>?)?['course_id'] as String?;
        if (topicCourseId != courseId) continue;
      }
      final sid = map['student_id'] as String;
      sessionsByStudent.putIfAbsent(sid, () => []).add(map);
    }

    final result = <TeacherStudentSummary>[];
    for (final st in (studentsRaw as List)) {
      final m = Map<String, dynamic>.from(st as Map);
      final id = m['id'] as String;
      final list = sessionsByStudent[id] ?? const [];
      int best = 0;
      int latest = 0;
      if (list.isNotEmpty) {
        latest = (list.first['meter_percent'] as num?)?.toInt() ?? 0;
        for (final item in list) {
          final val = (item['meter_percent'] as num?)?.toInt() ?? 0;
          if (val > best) best = val;
        }
      }
      result.add(
        TeacherStudentSummary(
          studentId: id,
          displayName: (m['display_name'] as String?) ?? '',
          email: (m['email'] as String?) ?? '',
          sessionCount: list.length,
          lowestOrBestMeter: list.isEmpty ? 0 : best,
          latestMeter: latest,
        ),
      );
    }

    result.sort((a, b) {
      final cmp = a.lowestOrBestMeter.compareTo(b.lowestOrBestMeter);
      if (cmp != 0) return cmp;
      return a.displayName.compareTo(b.displayName);
    });
    return result;
  }

  Future<UserProfile?> getStudentProfile(String studentId) async {
    final row = await _client
        .from('profiles')
        .select()
        .eq('id', studentId)
        .maybeSingle();
    if (row == null) return null;
    return UserProfile.fromMap(row);
  }

  Future<List<TeacherStudentSessionDetail>> getStudentSessionsDetail(
    String studentId,
  ) async {
    final sessionsRaw = await _client
        .from('sessions')
        .select('*, topics(title_id, title_en)')
        .eq('student_id', studentId)
        .order('started_at', ascending: false);

    final sessions = (sessionsRaw as List)
        .map((e) => LearningSession.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
    if (sessions.isEmpty) return [];

    final sessionIds = sessions.map((s) => s.id).toList();
    final scRaw = await _client
        .from('session_criteria')
        .select('session_id, criterion_id, criterion_text_snapshot, fulfilled, evidence_quote')
        .inFilter('session_id', sessionIds);

    final criteriaRaw = await _client
        .from('criteria')
        .select('id, misconception_id, sort_order, misconceptions(misconception_text, sort_order)')
        .order('sort_order', ascending: true);

    final criterionMeta = <String, Map<String, dynamic>>{};
    for (final c in (criteriaRaw as List)) {
      final map = Map<String, dynamic>.from(c as Map);
      criterionMeta[map['id'] as String] = map;
    }

    final bySession = <String, List<TeacherSessionCriterionItem>>{};
    for (final row in (scRaw as List)) {
      final map = Map<String, dynamic>.from(row as Map);
      final sid = map['session_id'] as String;
      final cid = map['criterion_id'] as String;
      final meta = criterionMeta[cid];
      final misc = meta?['misconceptions'] as Map<String, dynamic>?;

      bySession.putIfAbsent(sid, () => []).add(
        TeacherSessionCriterionItem(
          criterionId: cid,
          misconceptionTitle: (misc?['misconception_text'] as String?) ?? '-',
          criterionText: (map['criterion_text_snapshot'] as String?) ?? '',
          fulfilled: (map['fulfilled'] as bool?) ?? false,
          evidenceQuote: map['evidence_quote'] as String?,
        ),
      );
    }

    return sessions
        .map(
          (s) => TeacherStudentSessionDetail(
            session: s,
            criteriaItems: bySession[s.id] ?? const [],
          ),
        )
        .toList();
  }

  Future<List<TeacherTopic>> getAllContent({String? courseId}) async {
    final topicQuery = courseId != null
        ? _client
            .from('topics')
            .select()
            .eq('course_id', courseId)
            .order('sort_order', ascending: true)
        : _client.from('topics').select().order('sort_order', ascending: true);

    final [topicsRaw, miscRaw, criteriaRaw, sessionTopicsRaw] =
        await Future.wait([
      topicQuery,
      _client
          .from('misconceptions')
          .select()
          .order('sort_order', ascending: true),
      _client.from('criteria').select().order('sort_order', ascending: true),
      _client.from('sessions').select('topic_id'),
    ]);

    final topicsWithSessions = <String>{};
    for (final row in (sessionTopicsRaw as List)) {
      final tid = (row as Map)['topic_id'] as String?;
      if (tid != null) topicsWithSessions.add(tid);
    }

    final criteriaByMisc = <String, List<TeacherCriterion>>{};
    for (final row in (criteriaRaw as List)) {
      final c = TeacherCriterion.fromMap(Map<String, dynamic>.from(row as Map));
      criteriaByMisc.putIfAbsent(c.misconceptionId, () => []).add(c);
    }

    final miscByTopic = <String, List<TeacherMisconception>>{};
    for (final row in (miscRaw as List)) {
      final map = Map<String, dynamic>.from(row as Map);
      final id = map['id'] as String;
      final m = TeacherMisconception.fromMap(map, criteriaByMisc[id] ?? const []);
      miscByTopic.putIfAbsent(m.topicId, () => []).add(m);
    }

    return (topicsRaw as List).map((row) {
      final map = Map<String, dynamic>.from(row as Map);
      final id = map['id'] as String;
      return TeacherTopic.fromMap(
        map,
        miscByTopic[id] ?? const [],
        topicsWithSessions.contains(id),
      );
    }).toList();
  }

  Future<void> saveTopic({
    String? id,
    String? courseId,
    required String titleId,
    required String titleEn,
    required String descriptionId,
    required String descriptionEn,
    required int sortOrder,
    required bool isActive,
  }) async {
    final payload = <String, dynamic>{
      'title_id': titleId.trim(),
      'title_en': titleEn.trim(),
      'description_id': descriptionId.trim(),
      'description_en': descriptionEn.trim(),
      'sort_order': sortOrder,
      'is_active': isActive,
    };
    if (courseId != null) {
      payload['course_id'] = courseId;
    }
    if (id == null) {
      final uid = _client.auth.currentUser?.id;
      await _client.from('topics').insert({...payload, 'created_by': uid});
    } else {
      await _client.from('topics').update(payload).eq('id', id);
    }
  }

  Future<void> toggleTopicActive(String topicId, bool isActive) async {
    await _client
        .from('topics')
        .update({'is_active': isActive})
        .eq('id', topicId);
  }

  Future<void> deleteTopicIfUnused(String topicId) async {
    await _client.from('topics').delete().eq('id', topicId);
  }

  Future<void> saveMisconception({
    String? id,
    required String topicId,
    required String misconceptionText,
    required String correctConcept,
    required String buddyIntro,
    required int sortOrder,
  }) async {
    final payload = {
      'topic_id': topicId,
      'misconception_text': misconceptionText.trim(),
      'correct_concept': correctConcept.trim(),
      'buddy_intro': buddyIntro.trim(),
      'sort_order': sortOrder,
    };
    if (id == null) {
      await _client.from('misconceptions').insert(payload);
    } else {
      await _client.from('misconceptions').update(payload).eq('id', id);
    }
  }

  Future<void> saveMisconceptionEn({
    required String misconceptionId,
    required String misconceptionTextEn,
    required String correctConceptEn,
    required String buddyIntroEn,
    required List<({String id, String textEn})> criteriaEn,
  }) async {
    await _client
        .from('misconceptions')
        .update({
          'misconception_text_en': misconceptionTextEn.trim(),
          'correct_concept_en': correctConceptEn.trim(),
          'buddy_intro_en': buddyIntroEn.trim(),
        })
        .eq('id', misconceptionId);

    for (final c in criteriaEn) {
      await _client
          .from('criteria')
          .update({'criterion_text_en': c.textEn.trim()})
          .eq('id', c.id);
    }
  }

  Future<void> deleteMisconception(String id) async {
    await _client.from('misconceptions').delete().eq('id', id);
  }

  Future<void> saveCriterion({
    String? id,
    required String misconceptionId,
    required String criterionText,
    required int sortOrder,
  }) async {
    final payload = {
      'misconception_id': misconceptionId,
      'criterion_text': criterionText.trim(),
      'sort_order': sortOrder,
    };
    if (id == null) {
      await _client.from('criteria').insert(payload);
    } else {
      await _client.from('criteria').update(payload).eq('id', id);
    }
  }

  Future<void> deleteCriterion(String id) async {
    await _client.from('criteria').delete().eq('id', id);
  }

  Future<Map<String, dynamic>> translateMisconception(
    TeacherMisconception misc,
  ) async {
    final res = await _client.functions.invoke(
      'translate-content',
      body: {
        'misconception_text': misc.misconceptionText,
        'correct_concept': misc.correctConcept,
        'buddy_intro': misc.buddyIntro,
        'criteria': misc.criteria
            .map((c) => {'id': c.id, 'criterion_text': c.criterionText})
            .toList(),
      },
    );
    if (res.status != 200 || res.data is! Map) {
      throw Exception('Translation failed (${res.status})');
    }
    return Map<String, dynamic>.from(res.data as Map);
  }

  // --- Real Data: Tugas & Pengumuman Guru ---
  Future<List<Assignment>> getTeacherAssignments() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return [];
    try {
      final rows = await _client
          .from('assignments')
          .select('*, profiles(display_name), topics(title_id)')
          .eq('teacher_id', uid)
          .order('created_at', ascending: false);
      return (rows as List)
          .map((e) => Assignment.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> createAssignment({
    required String title,
    required String description,
    required String type,
    String? courseId,
    String? topicId,
    DateTime? dueDate,
  }) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw Exception('Guru belum login');
    await _client.from('assignments').insert({
      'teacher_id': uid,
      'course_id': courseId,
      'topic_id': topicId,
      'title': title.trim(),
      'description': description.trim(),
      'type': type,
      'due_date': dueDate?.toIso8601String(),
      'is_active': true,
    });
  }

  Future<void> deleteAssignment(String assignmentId) async {
    await _client.from('assignments').delete().eq('id', assignmentId);
  }

  // --- Real Data: Bank Soal & Evaluasi ---
  Future<List<Question>> getTopicQuestions(String topicId) async {
    try {
      final rows = await _client
          .from('questions')
          .select()
          .eq('topic_id', topicId)
          .order('sort_order', ascending: true);
      return (rows as List)
          .map((e) => Question.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> createQuestion({
    required String topicId,
    required String quizType,
    required String questionText,
    String? codeSnippet,
    required List<String> options,
    required int correctIndex,
    String? explanation,
  }) async {
    await _client.from('questions').insert({
      'topic_id': topicId,
      'quiz_type': quizType,
      'question_text': questionText.trim(),
      'code_snippet': codeSnippet?.trim(),
      'options': options,
      'correct_index': correctIndex,
      'explanation': explanation?.trim(),
      'sort_order': 1,
    });
  }

  Future<void> deleteQuestion(String questionId) async {
    await _client.from('questions').delete().eq('id', questionId);
  }
}
