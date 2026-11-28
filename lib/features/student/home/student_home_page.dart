import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/l10n/l10n_ext.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/clay_widgets.dart';
import '../../../core/widgets/student_bottom_nav.dart';
import '../../../core/widgets/user_avatar.dart';

/// Beranda siswa — mengikuti layar "Beranda Dashboard (Blank)" di Stitch
/// (Learn Buddy Claymorphic): kartu identitas besar, Ringkasan Progres,
/// kartu AR 3D, grid Fitur Belajar 8 tile, kartu Latihan Soal Pre/Post-Test,
/// dan kartu Topik Aktif. Angka-angka dihitung dari data asli Supabase,
/// bukan angka contoh di mockup.
class StudentHomePage extends ConsumerStatefulWidget {
  const StudentHomePage({super.key});

  @override
  ConsumerState<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends ConsumerState<StudentHomePage> {
  late Future<
    (
      List<Course>,
      List<TopicSummary>,
      List<LearningSession>,
      List<Assignment>,
      List<QuizAttempt>,
      Map<String, ({int preCount, int postCount})>,
    )
  >
  _loadFuture;
  String? _selectedCourseId;
  String? _selectedTopicId;

  @override
  void initState() {
    super.initState();
    _loadFuture = _fetchData();
  }

  Future<
    (
      List<Course>,
      List<TopicSummary>,
      List<LearningSession>,
      List<Assignment>,
      List<QuizAttempt>,
      Map<String, ({int preCount, int postCount})>,
    )
  >
  _fetchData() async {
    final repo = ref.read(sessionRepositoryProvider);
    final results = await Future.wait([
      repo.getCourses(),
      repo.getTopicsSummary(),
      repo.getMySessions(),
      repo.getAssignments(),
      repo.getAllMyQuizAttempts(),
      repo.getQuestionCountsByTopic(),
    ]);

    final courses = results[0] as List<Course>;
    if (_selectedCourseId == null && courses.isNotEmpty) {
      _selectedCourseId = courses.first.id;
    }

    return (
      courses,
      results[1] as List<TopicSummary>,
      results[2] as List<LearningSession>,
      results[3] as List<Assignment>,
      results[4] as List<QuizAttempt>,
      results[5] as Map<String, ({int preCount, int postCount})>,
    );
  }

  void _reload() {
    setState(() {
      _loadFuture = _fetchData();
    });
  }

  Future<void> _startNewSessionDialog(TopicSummary topic) async {
    if (topic.activeSessionId != null && topic.activeSessionId!.isNotEmpty) {
      await context.push('/student/teach/${topic.activeSessionId}');
      if (mounted) _reload();
      return;
    }

    final chosen = await showSessionLanguageDialog(context, ref, topic);
    if (chosen == null || !mounted) return;

    try {
      final session = await ref
          .read(sessionRepositoryProvider)
          .startSession(topicId: topic.id, language: chosen);
      if (!mounted) return;
      await context.push('/student/teach/${session.id}');
      _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memulai sesi: $e'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
    }
  }

  void _showTopicsDialog(
    List<Course> courses,
    List<TopicSummary> topics, {
    String? title,
    void Function(TopicSummary topic)? onTopicSelected,
  }) {
    final lang = ref.read(languageProvider).languageCode;
    final isEn = lang == 'en';
    final l10n = context.l10n;

    final grouped = <String, List<TopicSummary>>{};
    for (final t in topics) {
      final cid = t.courseId ?? '__other__';
      grouped.putIfAbsent(cid, () => []).add(t);
    }

    final sections = <(String, List<TopicSummary>)>[];
    for (final c in courses) {
      final list = grouped.remove(c.id);
      if (list != null && list.isNotEmpty) {
        sections.add((c.localizedTitle(lang), list));
      }
    }
    if (grouped.isNotEmpty) {
      final rest = grouped.values.expand((e) => e).toList();
      sections.add((isEn ? 'Other Topics' : 'Topik Lainnya', rest));
    }

    final activeId =
        _selectedTopicId ?? (topics.isNotEmpty ? topics.first.id : null);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppTheme.clayBorder, width: 2),
        ),
        title: Text(
          title ?? (isEn ? 'Topics by Subject' : 'Topik per Mata Pelajaran'),
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppTheme.textPrimary,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int sIdx = 0; sIdx < sections.length; sIdx++) ...[
                  if (sIdx > 0) const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(
                        Icons.menu_book_rounded,
                        size: 16,
                        color: AppTheme.primaryIndigo,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          sections[sIdx].$1,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                            color: AppTheme.primaryIndigo,
                          ),
                        ),
                      ),
                      Text(
                        '${sections[sIdx].$2.length} ${isEn ? 'Topics' : 'Topik'}',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...sections[sIdx].$2.map((topic) {
                    final isSelected = topic.id == activeId;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () {
                          setState(() {
                            _selectedTopicId = topic.id;
                            _selectedCourseId = topic.courseId;
                          });
                          Navigator.pop(ctx);
                          onTopicSelected?.call(topic);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppTheme.primaryIndigoLight
                                : const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? AppTheme.primaryIndigo
                                  : AppTheme.clayBorder,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              if (isSelected) ...[
                                const Icon(
                                  Icons.check_circle_rounded,
                                  size: 16,
                                  color: AppTheme.primaryIndigo,
                                ),
                                const SizedBox(width: 6),
                              ],
                              Expanded(
                                child: Text(
                                  topic.localizedTitle(lang),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13.5,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: topic.bestMeterPercent >= 80
                                      ? AppTheme.successGreenLight
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${topic.bestMeterPercent}%',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 12,
                                    color: topic.bestMeterPercent >= 80
                                        ? AppTheme.successGreen
                                        : AppTheme.primaryIndigo,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
        actions: [
          ClayButton(
            text: l10n.close,
            height: 44,
            onPressed: () => Navigator.pop(ctx),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider).value;
    final lang = ref.watch(languageProvider).languageCode;
    final isEn = lang == 'en';
    final l10n = context.l10n;
    final displayName = (profile?.displayName ?? '').trim();
    final firstName = displayName.isEmpty
        ? l10n.roleStudent
        : displayName.split(RegExp(r'\s+')).first;

    return Scaffold(
      backgroundColor: AppTheme.clayCanvas,
      bottomNavigationBar: StudentBottomNav(
        currentIndex: 1,
        onReturnFromChat: _reload,
      ),
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryIndigo,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.school_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Learn',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              'Buddy',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryIndigo,
              ),
            ),
          ],
        ),
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final currentLocale = ref.watch(languageProvider);
              final isId = currentLocale.languageCode == 'id';
              return GestureDetector(
                onTap: () {
                  final next = isId ? 'en' : 'id';
                  ref.read(languageProvider.notifier).setLanguage(next);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        next == 'en'
                            ? 'Beralih ke Bahasa Inggris (English)'
                            : 'Beralih ke Bahasa Indonesia',
                      ),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryIndigoLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.clayBorder, width: 1.2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(isId ? '🇮🇩' : '🇬🇧', style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        isId ? 'ID' : 'EN',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          color: AppTheme.primaryIndigo,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppTheme.textPrimary,
            ),
            onPressed: () => context.push('/student/announcements'),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryIndigo,
        onRefresh: () async => _reload(),
        child:
            FutureBuilder<
              (
                List<Course>,
                List<TopicSummary>,
                List<LearningSession>,
                List<Assignment>,
                List<QuizAttempt>,
                Map<String, ({int preCount, int postCount})>,
              )
            >(
              future: _loadFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.failedToLoad(snapshot.error.toString()),
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              color: AppTheme.dangerRed,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ClayButton(text: l10n.retry, onPressed: _reload),
                        ],
                      ),
                    ),
                  );
                }

                final courses = snapshot.data!.$1;
                final topics = snapshot.data!.$2;
                final sessions = snapshot.data!.$3;
                final quizAttempts = snapshot.data!.$5;
                final questionCounts = snapshot.data!.$6;
                final currentTopic = topics.isNotEmpty
                    ? topics.firstWhere(
                        (t) => t.id == _selectedTopicId,
                        orElse: () => topics.first,
                      )
                    : const TopicSummary(
                        id: 'stack-default',
                        titleId: 'Stack (Tumpukan)',
                        titleEn: 'Stack',
                        descriptionId:
                            'Struktur data LIFO untuk operasi Push dan Pop.',
                        descriptionEn:
                            'LIFO data structure for push and pop operations.',
                        sortOrder: 1,
                        enReady: true,
                        bestMeterPercent: 0,
                        hasCompleted80: false,
                      );
                final currentCourseTitle = courses
                        .where((c) => c.id == currentTopic.courseId)
                        .map((c) => c.localizedTitle(lang))
                        .firstOrNull ??
                    (isEn ? 'Data Structures' : 'Struktur Data');
                final preAttempts = quizAttempts
                    .where(
                      (a) =>
                          a.topicId == currentTopic.id &&
                          a.quizType == 'pre_test',
                    )
                    .toList();
                final postAttempts = quizAttempts
                    .where(
                      (a) =>
                          a.topicId == currentTopic.id &&
                          a.quizType == 'post_test',
                    )
                    .toList();
                final hasDonePreTest = preAttempts.isNotEmpty;
                final hasDonePostTest = postAttempts.isNotEmpty;
                final bestPreScore = preAttempts.isEmpty
                    ? 0
                    : preAttempts
                        .map((a) => a.score)
                        .reduce((a, b) => a > b ? a : b);
                final bestPostScore = postAttempts.isEmpty
                    ? 0
                    : postAttempts
                        .map((a) => a.score)
                        .reduce((a, b) => a > b ? a : b);
                final topicCounts =
                    questionCounts[currentTopic.id] ?? (preCount: 0, postCount: 0);

                // Ringkasan Progres dari data asli.
                final completedSessions = sessions
                    .where((s) => s.status == SessionStatus.completed)
                    .length;
                final avgMeter = topics.isEmpty
                    ? 0
                    : (topics.fold<int>(
                                0,
                                (sum, t) => sum + t.bestMeterPercent,
                              ) /
                              topics.length)
                          .round();
                final topicsDone = topics.where((t) => t.hasCompleted80).length;
                final bestMeter = currentTopic.bestMeterPercent;

                return ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  children: [
                    // 1. Kartu identitas (diperbesar, seperti di Stitch).
                    ClayCard(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.welcomeUser(firstName),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  displayName.isEmpty
                                      ? (isEn ? 'Learn Buddy Student' : 'Siswa Learn Buddy')
                                      : displayName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryIndigo,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  isEn
                                      ? 'Ready to explore coding skills today?'
                                      : 'Siap eksplorasi keahlian coding hari ini?',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 14,
                                    height: 1.35,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () => context.go('/settings'),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                UserAvatar(
                                  localPath: ref.watch(localAvatarPathProvider).value,
                                  avatarUrl: profile?.avatarUrl,
                                  displayName: displayName,
                                  size: 72,
                                ),
                                Positioned(
                                  right: -2,
                                  bottom: -2,
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppTheme.accentOrange,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.local_fire_department_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 2. Ringkasan Progres.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.insights_rounded,
                              size: 20,
                              color: AppTheme.primaryIndigo,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isEn ? 'Progress Summary' : 'Ringkasan Progres',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          isEn ? 'This Week' : 'Minggu Ini',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            '$completedSessions',
                            isEn ? 'Completed Sessions' : 'Sesi Selesai',
                            AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            '$avgMeter%',
                            isEn ? 'Average Meter' : 'Rata-rata Meter',
                            AppTheme.primaryIndigo,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCardRich(
                            topicsDone,
                            topics.length,
                            isEn ? 'Mastered Topics' : 'Topik Tuntas',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 3. Kartu AR 3D (tombol menampilkan "segera hadir" — AR belum diimplementasi).
                    ClayCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryIndigoLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isEn ? '✨ 3D Featured Mode' : '✨ Fitur Unggulan 3D',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryIndigo,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  isEn ? 'Explore 3D AR' : 'Eksplorasi AR 3D',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryIndigo,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.view_in_ar_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            width: double.infinity,
                            child: ClayButton(
                              text: isEn ? 'Open 3D AR Mode' : 'Buka Mode AR 3D',
                              icon: Icons.view_in_ar_rounded,
                              onPressed: () => context.push('/student/ar'),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 4. Fitur Belajar — grid 8 tile.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.apps_rounded,
                              size: 20,
                              color: AppTheme.primaryIndigo,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.studentFeaturesTitle,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryIndigoLight,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isEn ? '8 Menus' : '8 Menu',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryIndigo,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.78,
                      children: [
                        _buildFeatureTile(
                          label: 'Chat Buddy',
                          icon: Icons.chat_bubble_rounded,
                          iconBg: const Color(0xFFEEF2FF),
                          onTap: () => _showTopicsDialog(
                            courses,
                            topics,
                            title: isEn
                                ? 'Select Topic for Buddy'
                                : 'Pilih Topik Chat Buddy',
                            onTopicSelected: _startNewSessionDialog,
                          ),
                        ),
                        _buildFeatureTile(
                          label: isEn ? 'Modules' : 'Materi',
                          icon: Icons.menu_book_rounded,
                          iconBg: const Color(0xFFFFF7ED),
                          onTap: () => _showTopicsDialog(
                            courses,
                            topics,
                            title: isEn
                                ? 'Select Module by Subject'
                                : 'Pilih Materi per Mata Pelajaran',
                            onTopicSelected: (t) => context.push(
                              '/student/materi/${t.id}',
                            ),
                          ),
                        ),
                        _buildFeatureTile(
                          label: isEn ? 'Practice' : 'Latihan Soal',
                          icon: Icons.assignment_turned_in_rounded,
                          iconBg: const Color(0xFFFEF9C3),
                          onTap: () => _showTopicsDialog(
                            courses,
                            topics,
                            title: isEn
                                ? 'Select Quiz by Subject'
                                : 'Pilih Latihan Soal per Mapel',
                            onTopicSelected: (t) async {
                              await context.push(
                                '/student/quiz/${t.id}?type=pre_test',
                              );
                              if (mounted) _reload();
                            },
                          ),
                        ),
                        _buildFeatureTile(
                          label: isEn ? 'Recap' : 'Rekap',
                          icon: Icons.analytics_rounded,
                          iconBg: const Color(0xFFDCFCE7),
                          onTap: () => context.push('/student/history'),
                        ),
                        _buildFeatureTile(
                          label: isEn ? 'Topics' : 'Topik',
                          icon: Icons.layers_rounded,
                          iconBg: const Color(0xFFE0F2FE),
                          onTap: () => _showTopicsDialog(courses, topics),
                        ),
                        _buildFeatureTile(
                          label: isEn ? 'History' : 'Riwayat',
                          icon: Icons.history_rounded,
                          iconBg: const Color(0xFFF3E8FF),
                          onTap: () => context.push('/student/history'),
                        ),
                        _buildFeatureTile(
                          label: isEn ? 'Notices' : 'Pengumuman',
                          icon: Icons.campaign_rounded,
                          iconBg: const Color(0xFFFCE7F3),
                          onTap: () => context.push('/student/announcements'),
                        ),
                        _buildFeatureTile(
                          label: 'AR 3D',
                          icon: Icons.view_in_ar_rounded,
                          iconBg: const Color(0xFFEEF2FF),
                          iconColor: AppTheme.accentOrange,
                          onTap: () => context.push('/student/ar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // 5. Latihan Soal — Pre-Test & Post-Test.
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.quiz_rounded,
                              size: 20,
                              color: AppTheme.primaryIndigo,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isEn ? 'Practice Quizzes' : 'Latihan Soal',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Flexible(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _showTopicsDialog(
                              courses,
                              topics,
                              title: isEn
                                  ? 'Switch Quiz Topic'
                                  : 'Ganti Topik Latihan Soal',
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryIndigoLight,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Flexible(
                                    child: Text(
                                      isEn
                                          ? 'Topic: ${currentTopic.localizedTitle(lang)}'
                                          : 'Topik: ${currentTopic.localizedTitle(lang)}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.primaryIndigo,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 15,
                                    color: AppTheme.primaryIndigo,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClayCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              await context.push(
                                '/student/quiz/${currentTopic.id}?type=pre_test',
                              );
                              if (mounted) _reload();
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: hasDonePreTest
                                        ? AppTheme.successGreenLight
                                        : AppTheme.primaryIndigoLight,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    hasDonePreTest
                                        ? Icons.check_circle_rounded
                                        : Icons.play_lesson_rounded,
                                    color: hasDonePreTest
                                        ? AppTheme.successGreen
                                        : AppTheme.primaryIndigo,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Pre-Test',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w800,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        isEn
                                            ? '${topicCounts.preCount} questions • Before learning'
                                            : '${topicCounts.preCount} soal • Sebelum belajar',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12.5,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (hasDonePreTest)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.successGreenLight,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppTheme.successGreen,
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Text(
                                      isEn
                                          ? 'Done • $bestPreScore'
                                          : 'Selesai • $bestPreScore',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.successGreen,
                                      ),
                                    ),
                                  )
                                else
                                  ClayButton(
                                    text: isEn ? 'Start' : 'Mulai',
                                    height: 40,
                                    onPressed: () async {
                                      await context.push(
                                        '/student/quiz/${currentTopic.id}?type=pre_test',
                                      );
                                      if (mounted) _reload();
                                    },
                                  ),
                              ],
                            ),
                          ),
                          const Divider(height: 28, color: AppTheme.clayBorder),
                          InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              if (!hasDonePreTest) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isEn
                                          ? 'Please complete the Pre-Test first to unlock Post-Test.'
                                          : 'Selesaikan Pre-Test terlebih dahulu untuk membuka Post-Test.',
                                    ),
                                    backgroundColor: AppTheme.accentOrange,
                                  ),
                                );
                                return;
                              }
                              await context.push(
                                '/student/quiz/${currentTopic.id}?type=post_test',
                              );
                              if (mounted) _reload();
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: !hasDonePreTest
                                        ? const Color(0xFFF1F5F9)
                                        : hasDonePostTest
                                            ? AppTheme.successGreenLight
                                            : AppTheme.primaryIndigoLight,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    !hasDonePreTest
                                        ? Icons.lock_outline_rounded
                                        : hasDonePostTest
                                            ? Icons.check_circle_rounded
                                            : Icons.task_alt_rounded,
                                    color: !hasDonePreTest
                                        ? AppTheme.textSecondary
                                        : hasDonePostTest
                                            ? AppTheme.successGreen
                                            : AppTheme.primaryIndigo,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Post-Test',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w800,
                                          color: hasDonePreTest
                                              ? AppTheme.textPrimary
                                              : AppTheme.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        isEn
                                            ? '${topicCounts.postCount} questions • After learning'
                                            : '${topicCounts.postCount} soal • Setelah belajar',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12.5,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (!hasDonePreTest)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.lock_rounded,
                                          size: 13,
                                          color: AppTheme.textSecondary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          isEn
                                              ? 'Complete Pre-Test first'
                                              : 'Selesaikan Pre-Test dulu',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else if (hasDonePostTest)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 7,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.successGreenLight,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppTheme.successGreen,
                                        width: 1.2,
                                      ),
                                    ),
                                    child: Text(
                                      isEn
                                          ? 'Done • $bestPostScore'
                                          : 'Selesai • $bestPostScore',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.successGreen,
                                      ),
                                    ),
                                  )
                                else
                                  ClayButton(
                                    text: isEn ? 'Start' : 'Mulai',
                                    height: 40,
                                    onPressed: () async {
                                      await context.push(
                                        '/student/quiz/${currentTopic.id}?type=post_test',
                                      );
                                      if (mounted) _reload();
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 6. Topik Aktif — meter + lanjutkan/mulai mengajar Buddy.
                    ClayCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      l10n.activeTopicLabel(
                                        currentTopic.localizedTitle(lang),
                                      ),
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      currentCourseTitle,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: bestMeter >= 80
                                      ? AppTheme.successGreenLight
                                      : AppTheme.primaryIndigoLight,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: bestMeter >= 80
                                        ? AppTheme.successGreen
                                        : AppTheme.primaryIndigo,
                                    width: 1.2,
                                  ),
                                ),
                                child: Text(
                                  l10n.understoodBadge(bestMeter),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                    color: bestMeter >= 80
                                        ? AppTheme.successGreen
                                        : AppTheme.primaryIndigo,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ClayProgressBar(
                            progress: bestMeter / 100.0,
                            height: 10,
                            barColor: bestMeter >= 80
                                ? AppTheme.successGreen
                                : AppTheme.primaryIndigo,
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ClayButton(
                              text: bestMeter > 0
                                  ? l10n.continueTeaching
                                  : l10n.startTeachingBuddy,
                              icon: Icons.chat_bubble_rounded,
                              onPressed: () =>
                                  _startNewSessionDialog(currentTopic),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, Color valueColor) {
    return ClayCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      borderRadius: 20,
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCardRich(int done, int total, String label) {
    return ClayCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      borderRadius: 20,
      child: Column(
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$done',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.accentOrange,
                  ),
                ),
                TextSpan(
                  text: '/$total',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTile({
    required String label,
    required IconData icon,
    required Color iconBg,
    Color iconColor = AppTheme.primaryIndigo,
    required VoidCallback onTap,
  }) {
    return ClayCard(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      borderRadius: 20,
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
