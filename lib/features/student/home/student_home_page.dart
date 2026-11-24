import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/clay_widgets.dart';

class StudentHomePage extends ConsumerStatefulWidget {
  const StudentHomePage({super.key});

  @override
  ConsumerState<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends ConsumerState<StudentHomePage> {
  String _studentAvatar = '👨‍🎓';

  late Future<(List<Course>, List<TopicSummary>, List<LearningSession>, List<Assignment>)>
      _loadFuture;
  String? _selectedCourseId;

  @override
  void initState() {
    super.initState();
    _loadFuture = _fetchData();
    _loadStudentAvatar();
  }

  Future<void> _loadStudentAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final av = prefs.getString('student_avatar');
    if (av != null && mounted) {
      setState(() => _studentAvatar = av);
    }
  }

  Future<(List<Course>, List<TopicSummary>, List<LearningSession>, List<Assignment>)>
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
    _loadStudentAvatar();
    setState(() {
      _loadFuture = _fetchData();
    });
  }

  Future<void> _startNewSessionDialog(TopicSummary topic) async {
    final l10n = context.l10n;
    final appLang = ref.read(languageProvider).languageCode;
    String selectedLang = (appLang == 'en' && topic.enReady) ? 'en' : 'id';

    final chosen = await showDialog<String>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppTheme.clayBorder, width: 2),
          ),
          title: Text(
            l10n.chooseSessionLanguage,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: AppTheme.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RadioListTile<String>(
                value: 'id',
                groupValue: selectedLang,
                title: Text(
                  l10n.indonesianLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                activeColor: AppTheme.primaryIndigo,
                onChanged: (v) {
                  if (v != null) setDialogState(() => selectedLang = v);
                },
              ),
              RadioListTile<String>(
                value: 'en',
                groupValue: selectedLang,
                enabled: topic.enReady,
                activeColor: AppTheme.primaryIndigo,
                title: Text(
                  l10n.englishLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                subtitle: !topic.enReady
                    ? Text(
                        l10n.enLockedNote,
                        style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted),
                      )
                    : null,
                onChanged: (v) {
                  if (v != null && topic.enReady) {
                    setDialogState(() => selectedLang = v);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                l10n.cancel,
                style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
              ),
            ),
            ClayButton(
              text: 'Mulai Sesi',
              height: 44,
              onPressed: () => Navigator.pop(ctx, selectedLang),
            ),
          ],
        ),
      ),
    );

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

  void _showProtegeGuideDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppTheme.clayBorder, width: 2),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryIndigoLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.psychology_rounded, color: AppTheme.primaryIndigo),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Metode Protégé Effect',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apa itu Protégé Effect?',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Protégé Effect adalah fenomena psikologi pendidikan di mana seseorang memahami suatu materi secara jauh lebih mendalam ketika ia mengajarkannya kepada orang lain.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Peran Anda di Learn Buddy:',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Buddy adalah murid AI Anda yang sedang bingung dengan konsep Struktur Data. Jelaskan prinsip-prinsipnya dengan bahasa Anda sendiri, gunakan analogi riil, dan koreksi kekeliruan Buddy hingga meter pemahamannya mencapai 100%!',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.45,
              ),
            ),
          ],
        ),
        actions: [
          ClayButton(
            text: 'Saya Paham, Siap Mengajar!',
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

    return Scaffold(
      backgroundColor: AppTheme.clayCanvas,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryIndigoLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.clayBorder, width: 1.5),
              ),
              child: Center(
                child: Text(_studentAvatar, style: const TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, ${profile?.displayName ?? 'Siswa'}! 👋',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    '${profile?.className ?? 'XI RPL'} · ${profile?.schoolName ?? 'SMK Negeri'}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppTheme.textPrimary),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryIndigo,
        onRefresh: () async => _reload(),
        child: FutureBuilder<(List<Course>, List<TopicSummary>, List<LearningSession>, List<Assignment>)>(
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
                        style: GoogleFonts.plusJakartaSans(color: AppTheme.dangerRed),
                      ),
                      const SizedBox(height: 12),
                      ClayButton(
                        text: 'Coba Lagi',
                        onPressed: _reload,
                      ),
                    ],
                  ),
                ),
              );
            }

            final (courses, topics, sessions, assignments) = snapshot.data!;
            final currentTopic = topics.isNotEmpty
                ? topics.first
                : const TopicSummary(
                    id: 'stack-default',
                    titleId: 'Stack (Tumpukan)',
                    titleEn: 'Stack',
                    descriptionId: 'Struktur data LIFO untuk operasi Push dan Pop.',
                    descriptionEn: 'LIFO data structure for push and pop operations.',
                    sortOrder: 1,
                    enReady: true,
                    bestMeterPercent: 0,
                    hasCompleted80: false,
                  );

            // Compute overall understanding progress
            final int bestMeter = currentTopic.bestMeterPercent;

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // 1. Progres Belajar Card (Tactile Claymorphic)
                ClayCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Progres Belajar: Struktur Data',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Topik Aktif: ${currentTopic.titleId}',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: bestMeter >= 80 ? AppTheme.successGreenLight : AppTheme.primaryIndigoLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: bestMeter >= 80 ? AppTheme.successGreen : AppTheme.primaryIndigo,
                                width: 1.2,
                              ),
                            ),
                            child: Text(
                              '$bestMeter% Paham',
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: bestMeter >= 80 ? AppTheme.successGreen : AppTheme.primaryIndigo,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClayProgressBar(
                        progress: bestMeter / 100.0,
                        height: 10,
                        barColor: bestMeter >= 80 ? AppTheme.successGreen : AppTheme.primaryIndigo,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ClayButton(
                              text: bestMeter > 0 ? 'Lanjutkan Mengajar' : 'Mulai Mengajar Buddy',
                              icon: Icons.chat_bubble_rounded,
                              onPressed: () => _startNewSessionDialog(currentTopic),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Section Header: 8 Fitur Belajar
                Text(
                  'Fitur Pembelajaran Siswa',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),

                // 8 Fitur Belajar Clay Buttons Grid (2 columns)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.45,
                  children: [
                    _buildFeatureCard(
                      title: 'Modul Materi',
                      subtitle: 'Teori & analogi LIFO',
                      icon: Icons.menu_book_rounded,
                      iconBg: const Color(0xFFEEF2FF),
                      iconColor: AppTheme.primaryIndigo,
                      onTap: () => context.push('/student/materi/${currentTopic.id}'),
                    ),
                    _buildFeatureCard(
                      title: 'Kuis Pemahaman',
                      subtitle: 'Evaluasi konsep Stack',
                      icon: Icons.quiz_rounded,
                      iconBg: const Color(0xFFFEF3C7),
                      iconColor: const Color(0xFFB45309),
                      onTap: () => context.push('/student/quiz/${currentTopic.id}?type=post_test'),
                    ),
                    _buildFeatureCard(
                      title: 'Riwayat Sesi',
                      subtitle: '${sessions.length} sesi mengajar',
                      icon: Icons.history_rounded,
                      iconBg: const Color(0xFFECFDF5),
                      iconColor: const Color(0xFF047857),
                      onTap: () => context.push('/student/history'),
                    ),
                    _buildFeatureCard(
                      title: 'Papan Tugas',
                      subtitle: '${assignments.length} tugas aktif',
                      icon: Icons.campaign_rounded,
                      iconBg: const Color(0xFFFFF7ED),
                      iconColor: AppTheme.accentOrange,
                      onTap: () => context.push('/student/announcements'),
                    ),
                    _buildFeatureCard(
                      title: 'Ruang AI Buddy',
                      subtitle: 'Bimbing murid AI',
                      icon: Icons.smart_toy_rounded,
                      iconBg: const Color(0xFFF3E8FF),
                      iconColor: const Color(0xFF7E22CE),
                      onTap: () => _startNewSessionDialog(currentTopic),
                    ),
                    _buildFeatureCard(
                      title: 'Panduan Protégé',
                      subtitle: 'Belajar lewat mengajar',
                      icon: Icons.psychology_rounded,
                      iconBg: const Color(0xFFE0F2FE),
                      iconColor: const Color(0xFF0369A1),
                      onTap: _showProtegeGuideDialog,
                    ),
                    _buildFeatureCard(
                      title: 'Pre-Test Awal',
                      subtitle: 'Uji pemahaman dasar',
                      icon: Icons.assignment_turned_in_rounded,
                      iconBg: const Color(0xFFFCE7F3),
                      iconColor: const Color(0xFFBE185D),
                      onTap: () => context.push('/student/quiz/${currentTopic.id}?type=pre_test'),
                    ),
                    _buildFeatureCard(
                      title: 'Pengaturan Akun',
                      subtitle: 'Profil & sandi akun',
                      icon: Icons.tune_rounded,
                      iconBg: const Color(0xFFF1F5F9),
                      iconColor: const Color(0xFF475569),
                      onTap: () => context.push('/settings'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. Tugas Terbaru dari Guru (Real Data)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tugas & Pengumuman Guru',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/student/announcements'),
                      child: Text(
                        'Lihat Semua',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppTheme.primaryIndigo,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                if (assignments.isEmpty)
                  ClayCard(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        'Belum ada tugas baru yang diberikan.',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.textSecondary,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                  )
                else
                  ...assignments.take(2).map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: ClayCard(
                          padding: const EdgeInsets.all(16),
                          onTap: () => context.push('/student/announcements'),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryIndigoLight,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.assignment_rounded, color: AppTheme.primaryIndigo),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w800,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      item.teacherName ?? 'Pak Hendra, S.Kom',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12.5,
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
                            ],
                          ),
                        ),
                      )),

                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return ClayCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}
