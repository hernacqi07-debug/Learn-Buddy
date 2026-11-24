import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/models/models.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/clay_widgets.dart';
import '../../../core/widgets/student_bottom_nav.dart';

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
    (List<Course>, List<TopicSummary>, List<LearningSession>, List<Assignment>)
  >
  _loadFuture;
  String? _selectedCourseId;

  @override
  void initState() {
    super.initState();
    _loadFuture = _fetchData();
  }

  Future<
    (List<Course>, List<TopicSummary>, List<LearningSession>, List<Assignment>)
  >
  _fetchData() async {
    final repo = ref.read(sessionRepositoryProvider);
    final results = await Future.wait([
      repo.getCourses(),
      repo.getTopicsSummary(),
      repo.getMySessions(),
      repo.getAssignments(),
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
    );
  }

  void _reload() {
    setState(() {
      _loadFuture = _fetchData();
    });
  }

  Future<void> _startNewSessionDialog(TopicSummary topic) async {
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

  String _initials(String name) {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'S';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  void _showTopicsDialog(List<TopicSummary> topics) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppTheme.clayBorder, width: 2),
        ),
        title: Text(
          'Topik Struktur Data',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppTheme.textPrimary,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: topics.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (ctx, i) {
              final topic = topics[i];
              return Row(
                children: [
                  Expanded(
                    child: Text(
                      topic.titleId,
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: topic.bestMeterPercent >= 80
                          ? AppTheme.successGreenLight
                          : AppTheme.primaryIndigoLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${topic.bestMeterPercent}%',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                        color: topic.bestMeterPercent >= 80
                            ? AppTheme.successGreen
                            : AppTheme.primaryIndigo,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          ClayButton(
            text: 'Tutup',
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
    final displayName = (profile?.displayName ?? '').trim();
    final firstName = displayName.isEmpty
        ? 'Siswa'
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
                            'Gagal memuat data: ${snapshot.error}',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              color: AppTheme.dangerRed,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ClayButton(text: 'Coba Lagi', onPressed: _reload),
                        ],
                      ),
                    ),
                  );
                }

                final topics = snapshot.data!.$2;
            final sessions = snapshot.data!.$3;
                final currentTopic = topics.isNotEmpty
                    ? topics.first
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
                                  'Halo, $firstName! 👋',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  displayName.isEmpty
                                      ? 'Siswa Learn Buddy'
                                      : displayName,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.primaryIndigo,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Siap eksplorasi keahlian coding hari ini?',
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
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppTheme.primaryIndigo,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  _initials(displayName),
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
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
                              'Ringkasan Progres',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Minggu Ini',
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
                            'Sesi Selesai',
                            AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            '$avgMeter%',
                            'Rata-rata Meter',
                            AppTheme.primaryIndigo,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCardRich(topicsDone, topics.length),
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
                              '✨ Fitur Unggulan 3D',
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
                                  'Eksplorasi AR 3D',
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
                              text: 'Buka Mode AR 3D',
                              icon: Icons.view_in_ar_rounded,
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Mode AR 3D segera hadir — masih tahap pengembangan.',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: AppTheme.primaryIndigo,
                                  ),
                                );
                              },
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
                              'Fitur Belajar',
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
                            '8 Menu',
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
                          onTap: () => _startNewSessionDialog(currentTopic),
                        ),
                        _buildFeatureTile(
                          label: 'Materi',
                          icon: Icons.menu_book_rounded,
                          iconBg: const Color(0xFFFFF7ED),
                          onTap: () => context.push(
                            '/student/materi/${currentTopic.id}',
                          ),
                        ),
                        _buildFeatureTile(
                          label: 'Latihan Soal',
                          icon: Icons.assignment_turned_in_rounded,
                          iconBg: const Color(0xFFFEF9C3),
                          onTap: () => context.push(
                            '/student/quiz/${currentTopic.id}?type=pre_test',
                          ),
                        ),
                        _buildFeatureTile(
                          label: 'Rekap',
                          icon: Icons.analytics_rounded,
                          iconBg: const Color(0xFFDCFCE7),
                          onTap: () => context.push('/student/history'),
                        ),
                        _buildFeatureTile(
                          label: 'Topik',
                          icon: Icons.layers_rounded,
                          iconBg: const Color(0xFFE0F2FE),
                          onTap: () => _showTopicsDialog(topics),
                        ),
                        _buildFeatureTile(
                          label: 'Riwayat',
                          icon: Icons.history_rounded,
                          iconBg: const Color(0xFFF3E8FF),
                          onTap: () => context.push('/student/history'),
                        ),
                        _buildFeatureTile(
                          label: 'Pengumuman',
                          icon: Icons.campaign_rounded,
                          iconBg: const Color(0xFFFCE7F3),
                          onTap: () => context.push('/student/announcements'),
                        ),
                        _buildFeatureTile(
                          label: 'AR 3D',
                          icon: Icons.view_in_ar_rounded,
                          iconBg: const Color(0xFFEEF2FF),
                          iconColor: AppTheme.accentOrange,
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Mode AR 3D segera hadir — masih tahap pengembangan.',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                  ),
                                ),
                                backgroundColor: AppTheme.primaryIndigo,
                              ),
                            );
                          },
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
                              'Latihan Soal',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryIndigoLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Topik: ${currentTopic.titleId}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryIndigo,
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
                            onTap: () => context.push(
                              '/student/quiz/${currentTopic.id}?type=pre_test',
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryIndigoLight,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.play_lesson_rounded,
                                    color: AppTheme.primaryIndigo,
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
                                        '5 soal • Sebelum belajar',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12.5,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ClayButton(
                                  text: 'Mulai',
                                  height: 40,
                                  onPressed: () => context.push(
                                    '/student/quiz/${currentTopic.id}?type=pre_test',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 28, color: AppTheme.clayBorder),
                          InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => context.push(
                              '/student/quiz/${currentTopic.id}?type=post_test',
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.task_alt_rounded,
                                    color: AppTheme.textSecondary,
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
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '5 soal • Setelah belajar',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12.5,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                                        'Selesaikan Pre-Test dulu',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
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
                                      'Topik Aktif: ${currentTopic.titleId}',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Struktur Data',
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
                                  '$bestMeter% Paham',
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
                                  ? 'Lanjutkan Mengajar'
                                  : 'Mulai Mengajar Buddy',
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

  Widget _buildStatCardRich(int done, int total) {
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
            'Topik Tuntas',
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
