import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/models.dart';

class AuthRepository {
  AuthRepository(this._client);
  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  static String localAvatarKey(String uid) => 'local_avatar_path_$uid';

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

  Future<List<Course>> fetchActiveCoursesForRegistration() async {
    final rows = await _client
        .from('courses')
        .select('id, code, title_id, title_en, description_id, description_en, icon, accent_color, sort_order, is_active')
        .eq('is_active', true)
        .order('sort_order', ascending: true);
    return (rows as List)
        .map((e) => Course.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<UserProfile> signUp({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
    String? inviteCode,
    String? courseId,
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
          'p_course_id': role == UserRole.teacher ? courseId : null,
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

  /// Saves selected gallery photo locally AND uploads to Supabase Storage 'avatars' bucket.
  /// Returns `(cloudUrl, localPath)`.
  Future<(String? cloudUrl, String localPath)> uploadAvatar(XFile file) async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) throw Exception('User not authenticated');

    final bytes = await file.readAsBytes();
    final appDir = await getApplicationDocumentsDirectory();
    final ext = file.path.split('.').last.toLowerCase();
    final safeExt = (ext == 'png' || ext == 'webp') ? ext : 'jpg';
    final localFile = File('${appDir.path}/avatar_$uid.$safeExt');
    await localFile.writeAsBytes(bytes, flush: true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(localAvatarKey(uid), localFile.path);

    String? publicUrl;
    try {
      final storagePath =
          '$uid/avatar_${DateTime.now().millisecondsSinceEpoch}.$safeExt';
      await _client.storage.from('avatars').uploadBinary(
            storagePath,
            bytes,
            fileOptions: FileOptions(
              contentType: safeExt == 'png'
                  ? 'image/png'
                  : (safeExt == 'webp' ? 'image/webp' : 'image/jpeg'),
              upsert: true,
            ),
          );
      publicUrl = _client.storage.from('avatars').getPublicUrl(storagePath);
      await _client
          .from('profiles')
          .update({'avatar_url': publicUrl})
          .eq('id', uid);
    } catch (_) {
      // Cloud bucket/column might not be migrated yet; local file path still persists cleanly.
    }

    return (publicUrl, localFile.path);
  }

  Future<void> removeAvatar() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return;

    final prefs = await SharedPreferences.getInstance();
    final existingPath = prefs.getString(localAvatarKey(uid));
    if (existingPath != null) {
      final f = File(existingPath);
      if (await f.exists()) {
        await f.delete();
      }
      await prefs.remove(localAvatarKey(uid));
    }

    try {
      await _client
          .from('profiles')
          .update({'avatar_url': null})
          .eq('id', uid);
    } catch (_) {
      // Ignore if column not yet migrated.
    }
  }

  Future<String?> getLocalAvatarPath() async {
    final uid = _client.auth.currentUser?.id;
    if (uid == null) return null;
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString(localAvatarKey(uid));
    if (path != null && await File(path).exists()) {
      return path;
    }
    return null;
  }

  Future<void> signOut() => _client.auth.signOut();
}
