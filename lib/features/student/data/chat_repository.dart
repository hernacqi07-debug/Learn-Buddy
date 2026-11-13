import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/models.dart';

class ChatRepository {
  ChatRepository(this._client);
  final SupabaseClient _client;

  Future<TeachTurnResult> sendTurn({
    required String sessionId,
    required String studentMessage,
  }) async {
    final response = await _client.functions
        .invoke(
          'teach-turn',
          body: {
            'session_id': sessionId,
            'student_message': studentMessage,
          },
        )
        .timeout(const Duration(seconds: 50));

    if (response.status != 200 || response.data is! Map) {
      final errMsg = (response.data is Map)
          ? (response.data['error'] as String?) ?? 'Error ${response.status}'
          : 'Error ${response.status}';
      throw Exception(errMsg);
    }

    return TeachTurnResult.fromMap(
      Map<String, dynamic>.from(response.data as Map),
    );
  }
}
