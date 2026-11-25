import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/register_page.dart';
import '../../features/settings/presentation/change_password_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/student/announcements/announcements_page.dart';
import '../../features/student/ar/ar_page.dart';
import '../../features/student/chat_hub/student_chat_hub_page.dart';
import '../../features/student/history/history_page.dart';
import '../../features/student/home/student_home_page.dart';
import '../../features/student/materi/materi_page.dart';
import '../../features/student/quiz/quiz_page.dart';
import '../../features/student/teach/chat_page.dart';
import '../../features/student/teach/recap_page.dart';
import '../../features/teacher/content/teacher_content_page.dart';
import '../../features/teacher/dashboard/teacher_dashboard_page.dart';
import '../../features/teacher/dashboard/teacher_student_detail_page.dart';
import '../models/models.dart';
import '../providers/app_providers.dart';

class _RouterRefreshNotifier extends ChangeNotifier {
  _RouterRefreshNotifier(Ref ref) {
    ref.listen<AsyncValue<UserProfile?>>(
      currentProfileProvider,
      (_, _) => notifyListeners(),
    );
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = _RouterRefreshNotifier(ref);
  ref.onDispose(refreshListenable.dispose);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final profileAsync = ref.read(currentProfileProvider);
      if (profileAsync.isLoading) return null;

      final profile = profileAsync.value;
      final path = state.matchedLocation;
      final isAuthRoute = path == '/login' || path == '/register';

      if (profile == null) {
        return isAuthRoute ? null : '/login';
      }

      final homeRoute =
          profile.role == UserRole.teacher ? '/teacher' : '/student';

      if (isAuthRoute) {
        return homeRoute;
      }

      if (profile.role == UserRole.student && path.startsWith('/teacher')) {
        return '/student';
      }
      if (profile.role == UserRole.teacher && path.startsWith('/student')) {
        return '/teacher';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: '/student',
        builder: (context, state) => const StudentHomePage(),
      ),
      GoRoute(
        path: '/student/chat',
        builder: (context, state) => const StudentChatHubPage(),
      ),
      GoRoute(
        path: '/student/ar',
        builder: (context, state) => const ArPage(),
      ),
      GoRoute(
        path: '/student/materi/:topicId',
        builder: (context, state) => MateriPage(
          topicId: state.pathParameters['topicId']!,
        ),
      ),
      GoRoute(
        path: '/student/quiz/:topicId',
        builder: (context, state) => QuizPage(
          topicId: state.pathParameters['topicId']!,
          initialQuizType: state.uri.queryParameters['type'] ?? 'pre_test',
        ),
      ),
      GoRoute(
        path: '/student/announcements',
        builder: (context, state) => const AnnouncementsPage(),
      ),
      GoRoute(
        path: '/student/history',
        builder: (context, state) => const HistoryPage(),
      ),
      GoRoute(
        path: '/student/teach/:sessionId',
        builder: (context, state) => ChatPage(
          sessionId: state.pathParameters['sessionId']!,
        ),
      ),
      GoRoute(
        path: '/student/recap/:sessionId',
        builder: (context, state) => RecapPage(
          sessionId: state.pathParameters['sessionId']!,
        ),
      ),
      GoRoute(
        path: '/teacher',
        builder: (context, state) => const TeacherDashboardPage(),
      ),
      GoRoute(
        path: '/teacher/content',
        builder: (context, state) => TeacherContentPage(
          initialCourseId: state.uri.queryParameters['courseId'],
        ),
      ),
      GoRoute(
        path: '/teacher/student/:studentId',
        builder: (context, state) => TeacherStudentDetailPage(
          studentId: state.pathParameters['studentId']!,
        ),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/settings/change-password',
        builder: (context, state) => const ChangePasswordPage(),
      ),
    ],
  );
});
