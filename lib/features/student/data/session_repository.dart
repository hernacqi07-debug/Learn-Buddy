import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/models.dart';

class SessionRepository {
  SessionRepository(this._client);
  final SupabaseClient _client;

  Future<List<TopicSummary>> getTopicsSummary() async {
    final rows = await _client.rpc('get_student_topics_summary');
    return (rows as List)
        .map((e) => TopicSummary.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
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
}
