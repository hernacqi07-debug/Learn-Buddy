import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/student/data/chat_repository.dart';
import '../../features/student/data/session_repository.dart';
import '../../features/teacher/data/teacher_repository.dart';
import '../models/models.dart';

const _langPrefKey = 'learn_buddy_language_pref';

final supabaseClientProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(supabaseClientProvider)),
);

final sessionRepositoryProvider = Provider<SessionRepository>(
  (ref) => SessionRepository(ref.watch(supabaseClientProvider)),
);

final chatRepositoryProvider = Provider<ChatRepository>(
  (ref) => ChatRepository(ref.watch(supabaseClientProvider)),
);

final teacherRepositoryProvider = Provider<TeacherRepository>(
  (ref) => TeacherRepository(ref.watch(supabaseClientProvider)),
);

class LanguageNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    _loadCached();
    return const Locale('id');
  }

  Future<void> _loadCached() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_langPrefKey);
    if (code == 'en' || code == 'id') {
      state = Locale(code!);
    }
  }

  Future<void> setLocaleLocalOnly(String code) async {
    if (code != 'id' && code != 'en') return;
    state = Locale(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_langPrefKey, code);
  }

  Future<void> setLanguage(String code) async {
    if (code != 'id' && code != 'en') return;
    await setLocaleLocalOnly(code);
    final repo = ref.read(authRepositoryProvider);
    if (repo.currentUser != null) {
      try {
        await repo.updateLanguagePref(code);
      } catch (_) {
        // Keep local preference even if remote sync fails momentarily.
      }
    }
  }
}

final languageProvider = NotifierProvider<LanguageNotifier, Locale>(
  LanguageNotifier.new,
);

class CurrentProfileNotifier extends AsyncNotifier<UserProfile?> {
  @override
  Future<UserProfile?> build() async {
    final repo = ref.watch(authRepositoryProvider);
    final sub = repo.authStateChanges.listen((event) async {
      if (event.event == AuthChangeEvent.signedIn ||
          event.event == AuthChangeEvent.signedOut ||
          event.event == AuthChangeEvent.userUpdated) {
        final p = await repo.fetchCurrentProfile();
        setProfile(p);
      }
    });
    ref.onDispose(sub.cancel);

    final profile = await repo.fetchCurrentProfile();
    if (profile != null) {
      await ref
          .read(languageProvider.notifier)
          .setLocaleLocalOnly(profile.languagePref);
    }
    return profile;
  }

  void setProfile(UserProfile? profile) {
    if (profile != null) {
      ref
          .read(languageProvider.notifier)
          .setLocaleLocalOnly(profile.languagePref);
    }
    state = AsyncData(profile);
  }

  Future<UserProfile?> reload([String? explicitUid]) async {
    state = const AsyncLoading();
    final repo = ref.read(authRepositoryProvider);
    final profile = await repo.fetchCurrentProfile(explicitUid);
    setProfile(profile);
    return profile;
  }

  Future<UserProfile?> refresh() => reload();
}

final currentProfileProvider =
    AsyncNotifierProvider<CurrentProfileNotifier, UserProfile?>(
      CurrentProfileNotifier.new,
    );
