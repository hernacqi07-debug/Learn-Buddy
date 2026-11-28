import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/models/models.dart';

class AdminOverviewStats {
  const AdminOverviewStats({
    required this.totalUsers,
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalAdmins,
    required this.totalCourses,
    required this.activeCourses,
    required this.totalTopics,
    required this.activeTopics,
    required this.totalSessions,
    required this.avgMeterPercent,
    required this.totalTurnLogs,
  });

  final int totalUsers;
  final int totalStudents;
  final int totalTeachers;
  final int totalAdmins;
  final int totalCourses;
  final int activeCourses;
  final int totalTopics;
  final int activeTopics;
  final int totalSessions;
  final int avgMeterPercent;
  final int totalTurnLogs;
}

class AdminCourseItem {
  const AdminCourseItem({
    required this.id,
    required this.code,
    required this.titleId,
    required this.titleEn,
    required this.isActive,
  });

  final String id;
  final String code;
  final String titleId;
  final String titleEn;
  final bool isActive;
}

class AdminTopicItem {
  const AdminTopicItem({
    required this.id,
    required this.courseId,
    required this.titleId,
    required this.titleEn,
    required this.isActive,
  });

  final String id;
  final String? courseId;
  final String titleId;
  final String titleEn;
  final bool isActive;
}

class AdminInviteCode {
  const AdminInviteCode({
    required this.code,
    required this.isActive,
  });

  final String code;
  final bool isActive;
}

class AdminRepository {
  AdminRepository(this._client);
  final SupabaseClient _client;

  Future<AdminOverviewStats> fetchOverviewStats() async {
    final results = await Future.wait([
      _client.from('profiles').select('id, role'),
      _client.from('courses').select('id, is_active'),
      _client.from('topics').select('id, is_active'),
      _client.from('sessions').select('id, meter_percent'),
      _client.from('turn_logs').select('id'),
    ]);

    final profiles = (results[0] as List).cast<Map<String, dynamic>>();
    final courses = (results[1] as List).cast<Map<String, dynamic>>();
    final topics = (results[2] as List).cast<Map<String, dynamic>>();
    final sessions = (results[3] as List).cast<Map<String, dynamic>>();
    final turnLogs = (results[4] as List).cast<Map<String, dynamic>>();

    int students = 0, teachers = 0, admins = 0;
    for (final p in profiles) {
      final r = (p['role'] as String?) ?? 'student';
      if (r == 'admin') {
        admins++;
      } else if (r == 'teacher') {
        teachers++;
      } else {
        students++;
      }
    }

    final activeCourses = courses.where((c) => c['is_active'] == true).length;
    final activeTopics = topics.where((t) => t['is_active'] == true).length;

    int avgMeter = 0;
    if (sessions.isNotEmpty) {
      final sum = sessions.fold<int>(
        0,
        (acc, s) => acc + ((s['meter_percent'] as num?)?.toInt() ?? 0),
      );
      avgMeter = (sum / sessions.length).round();
    }

    return AdminOverviewStats(
      totalUsers: profiles.length,
      totalStudents: students,
      totalTeachers: teachers,
      totalAdmins: admins,
      totalCourses: courses.length,
      activeCourses: activeCourses,
      totalTopics: topics.length,
      activeTopics: activeTopics,
      totalSessions: sessions.length,
      avgMeterPercent: avgMeter,
      totalTurnLogs: turnLogs.length,
    );
  }

  Future<List<UserProfile>> fetchAllProfiles() async {
    final rows = await _client
        .from('profiles')
        .select()
        .order('created_at', ascending: false);
    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map(UserProfile.fromMap)
        .toList();
  }

  Future<void> createUser({
    required String email,
    required String password,
    required String displayName,
    required UserRole role,
    String? schoolName,
    String? className,
  }) async {
    final res = await _client.functions.invoke(
      'admin-users',
      body: {
        'action': 'create_user',
        'email': email.trim(),
        'password': password,
        'display_name': displayName.trim(),
        'role': role.name,
        'school_name': schoolName?.trim().isEmpty == true ? null : schoolName?.trim(),
        'class_name': className?.trim().isEmpty == true ? null : className?.trim(),
      },
    );
    if (res.status >= 400) {
      final data = res.data;
      final errMsg = data is Map ? data['error']?.toString() : data?.toString();
      throw Exception(errMsg ?? 'Gagal membuat akun.');
    }
  }

  Future<void> updateUserRole({
    required String userId,
    required UserRole role,
  }) async {
    final res = await _client.functions.invoke(
      'admin-users',
      body: {
        'action': 'update_role',
        'user_id': userId,
        'role': role.name,
      },
    );
    if (res.status >= 400) {
      final data = res.data;
      final errMsg = data is Map ? data['error']?.toString() : data?.toString();
      throw Exception(errMsg ?? 'Gagal mengubah role.');
    }
  }

  Future<void> deleteUser(String userId) async {
    final res = await _client.functions.invoke(
      'admin-users',
      body: {
        'action': 'delete_user',
        'user_id': userId,
      },
    );
    if (res.status >= 400) {
      final data = res.data;
      final errMsg = data is Map ? data['error']?.toString() : data?.toString();
      throw Exception(errMsg ?? 'Gagal menghapus akun.');
    }
  }

  Future<(List<AdminCourseItem>, List<AdminTopicItem>)> fetchCoursesAndTopics() async {
    final results = await Future.wait([
      _client.from('courses').select('id, code, title_id, title_en, is_active').order('sort_order'),
      _client.from('topics').select('id, course_id, title_id, title_en, is_active').order('sort_order'),
    ]);

    final courses = (results[0] as List).cast<Map<String, dynamic>>().map((c) {
      return AdminCourseItem(
        id: c['id'] as String,
        code: (c['code'] as String?) ?? '',
        titleId: (c['title_id'] as String?) ?? '',
        titleEn: (c['title_en'] as String?) ?? '',
        isActive: c['is_active'] == true,
      );
    }).toList();

    final topics = (results[1] as List).cast<Map<String, dynamic>>().map((t) {
      return AdminTopicItem(
        id: t['id'] as String,
        courseId: t['course_id'] as String?,
        titleId: (t['title_id'] as String?) ?? '',
        titleEn: (t['title_en'] as String?) ?? '',
        isActive: t['is_active'] == true,
      );
    }).toList();

    return (courses, topics);
  }

  Future<void> toggleCourseActive(String courseId, bool isActive) async {
    await _client.from('courses').update({'is_active': isActive}).eq('id', courseId);
  }

  Future<void> toggleTopicActive(String topicId, bool isActive) async {
    await _client.from('topics').update({'is_active': isActive}).eq('id', topicId);
  }

  Future<List<AdminInviteCode>> fetchInviteCodes() async {
    final rows = await _client
        .from('teacher_invite_codes')
        .select('code, is_active')
        .order('created_at', ascending: false);
    return (rows as List).cast<Map<String, dynamic>>().map((r) {
      return AdminInviteCode(
        code: (r['code'] as String?) ?? '',
        isActive: r['is_active'] == true,
      );
    }).toList();
  }
}
