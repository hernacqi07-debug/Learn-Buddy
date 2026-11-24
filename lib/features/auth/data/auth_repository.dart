import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/models.dart';

class AuthRepository {
  AuthRepository(this._client);
  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    final res = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    return res.user;
  }

  Future<UserProfile> signUp({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
    String? inviteCode,
    String languagePref = 'id',
  }) async {
    final res = await _client.auth.signUp(
      email: email.trim(),
      password: password,
    );
    if (res.user == null || res.session == null) {
      throw const AuthException(
        'Registrasi gagal atau Confirm email masih aktif di Supabase.',
      );
    }

    try {
      final data = await _client.rpc(
        'register_user_profile',
        params: {
          'p_display_name': displayName.trim(),
          'p_role': role.name,
          'p_invite_code': inviteCode?.trim(),
          'p_language_pref': languagePref,
        },
      );
      return UserProfile.fromMap(Map<String, dynamic>.from(data as Map));
    } catch (e) {
      await _client.auth.signOut();
      rethrow;
    }
  }

  Future<UserProfile?> fetchCurrentProfile([String? explicitUid]) async {
    final uid = explicitUid ??
        _client.auth.currentUser?.id ??
        _client.auth.currentSession?.user.id;
    if (uid == null) return null;
    final row = await _client
        .from('profiles')
        .select()
        .eq('id', uid)
        .maybeSingle();
    if (row == null) return null;
    return UserProfile.fromMap(row);
  }

  Future<void> updateDisplayName(String displayName) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;
    await _client
        .from('profiles')
        .update({'display_name': displayName.trim()})
        .eq('id', uid);
  }

  Future<void> updateLanguagePref(String languagePref) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;
    await _client
        .from('profiles')
        .update({'language_pref': languagePref})
        .eq('id', uid);
  }

  Future<void> signOut() => _client.auth.signOut();
}
