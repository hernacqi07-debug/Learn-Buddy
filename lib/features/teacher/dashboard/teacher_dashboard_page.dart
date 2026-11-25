import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/clay_widgets.dart';
import '../../../core/widgets/user_avatar.dart';

class TeacherDashboardPage extends ConsumerStatefulWidget {
  const TeacherDashboardPage({super.key});

  @override
  ConsumerState<TeacherDashboardPage> createState() => _TeacherDashboardPageState();
}

class _TeacherDashboardPageState extends ConsumerState<TeacherDashboardPage> {
  late Future<(List<Course>, List<TeacherStudentSummary>, List<TeacherTopic>)> _future;
  String? _selectedCourseId;
  String _filter = 'all'; // 'all' | 'struggling' | 'completed'

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(List<Course>, List<TeacherStudentSummary>, List<TeacherTopic>)> _load() async {
    final repo = ref.read(teacherRepositoryProvider);
    final myProfile = ref.read(currentProfileProvider).value;

    final courses = await repo.getCourses();

    if (_selectedCourseId == null && courses.isNotEmpty) {
      final myCourse = courses.firstWhere(
        (c) => c.teacherId == myProfile?.id,
        orElse: () => courses.first,
      );
      _selectedCourseId = myCourse.id;
    }

    final res = await Future.wait([
      repo.getStudentsProgress(courseId: _selectedCourseId),
      repo.getAllContent(courseId: _selectedCourseId),
    ]);

    return (
      courses,
      res[0] as List<TeacherStudentSummary>,
      res[1] as List<TeacherTopic>,
    );
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  void _showCreateAssignmentDialog(List<TeacherTopic> topics) {
    final l10n = context.l10n;
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String selectedType = 'praktikum';
    String? selectedTopicId = topics.isNotEmpty ? topics.first.id : null;
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: AppTheme.clayBorder, width: 2),
          ),
          title: Text(
            l10n.createTaskModalTitle,
            style: GoogleFonts.plusJakartaSans(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: AppTheme.textPrimary,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClayTextField(
                  controller: titleCtrl,
                  label: l10n.taskTitleLabel,
                  hint: l10n.taskTitleHint,
                ),
                const SizedBox(height: 14),
                ClayTextField(
                  controller: descCtrl,
                  label: l10n.taskDescLabel,
                  hint: l10n.taskDescHint,
                  maxLines: 3,
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.categoryLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    ChoiceChip(
                      label: Text(l10n.typePracticum),
                      selected: selectedType == 'praktikum',
                      onSelected: (_) => setDialogState(() => selectedType = 'praktikum'),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: Text(l10n.typeAnnouncement),
                      selected: selectedType == 'announcement',
                      onSelected: (_) => setDialogState(() => selectedType = 'announcement'),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  l10n.dueDateLabel('${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                l10n.cancel,
                style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
              ),
            ),
            ClayButton(
              text: l10n.publishTaskBtn,
              isLoading: isSaving,
              height: 44,
              onPressed: () async {
                final t = titleCtrl.text.trim();
                final d = descCtrl.text.trim();
                if (t.isEmpty || d.isEmpty) return;

                setDialogState(() => isSaving = true);
                try {
                  final repo = ref.read(teacherRepositoryProvider);
                  await repo.createAssignment(
                    title: t,
                    description: d,
                    type: selectedType,
                    courseId: _selectedCourseId,
                    topicId: selectedTopicId,
                    dueDate: selectedDate,
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.taskPublishedMsg),
                        backgroundColor: AppTheme.successGreen,
                      ),
                    );
                    _reload();
                  }
                } catch (e) {
                  if (ctx.mounted) {
                    setDialogState(() => isSaving = false);
                    ScaffoldMessenger.of(ctx).showSnackBar(
                      SnackBar(content: Text('$e'), backgroundColor: AppTheme.dangerRed),
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final myProfile = ref.watch(currentProfileProvider).value;

    return Scaffold(
      backgroundColor: AppTheme.clayCanvas,
      appBar: AppBar(
        title: Row(
          children: [
            UserAvatar(
              localPath: ref.watch(localAvatarPathProvider).value,
              avatarUrl: myProfile?.avatarUrl,
              emoji: '👨‍🏫',
              displayName: myProfile?.displayName ?? 'G',
              size: 38,
              backgroundColor: const Color(0xFFFEF3C7),
              borderColor: const Color(0xFFFDE68A),
              borderWidth: 1.5,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    myProfile?.displayName ?? 'Pak Hendra, S.Kom',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    l10n.teacherPanelSub,
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
            icon: const Icon(Icons.settings_outlined, color: AppTheme.textPrimary),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryIndigo,
        onRefresh: () async => _reload(),
        child: FutureBuilder<(List<Course>, List<TeacherStudentSummary>, List<TeacherTopic>)>(
          future: _future,
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
                        'Terjadi kesalahan: ${snapshot.error}',
                        style: GoogleFonts.plusJakartaSans(color: AppTheme.dangerRed),
                      ),
                      const SizedBox(height: 12),
                      ClayButton(text: 'Coba Lagi', onPressed: _reload),
                    ],
                  ),
                ),
              );
            }

            final (courses, students, topics) = snapshot.data!;

            // Calculate analytics KPIs
            final totalStudents = students.length;
            final strugglingCount = students.where((s) => s.lowestOrBestMeter < 60).length;
            final completedCount = students.where((s) => s.lowestOrBestMeter >= 80).length;
            final double avgMeter = students.isEmpty
                ? 0.0
                : students.map((s) => s.lowestOrBestMeter).reduce((a, b) => a + b) / students.length;

            // Filter students
            final filteredStudents = students.where((s) {
              if (_filter == 'struggling') return s.lowestOrBestMeter < 60;
              if (_filter == 'completed') return s.lowestOrBestMeter >= 80;
              return true;
            }).toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. KPI Stats Grid (4 Tactile Clay Cards)
                Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard(
                        title: l10n.totalStudentsKpi,
                        value: '$totalStudents',
                        icon: Icons.people_alt_rounded,
                        color: AppTheme.primaryIndigo,
                        bgColor: AppTheme.primaryIndigoLight,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildKpiCard(
                        title: l10n.classAverageKpi,
                        value: '${avgMeter.round()}%',
                        icon: Icons.analytics_rounded,
                        color: const Color(0xFF0284C7),
                        bgColor: const Color(0xFFE0F2FE),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildKpiCard(
                        title: l10n.needsGuidanceKpi,
                        value: '$strugglingCount',
                        icon: Icons.warning_amber_rounded,
                        color: AppTheme.accentOrange,
                        bgColor: const Color(0xFFFFF7ED),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildKpiCard(
                        title: l10n.masteredKpi,
                        value: '$completedCount',
                        icon: Icons.verified_rounded,
                        color: AppTheme.successGreen,
                        bgColor: const Color(0xFFECFDF5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 2. Quick Management Actions
                Text(
                  l10n.teacherActionsTitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ClayButton(
                        text: l10n.manageModulesRubricBtn,
                        icon: Icons.edit_note_rounded,
                        isPrimary: true,
                        height: 48,
                        onPressed: () {
                          final query = _selectedCourseId != null ? '?courseId=$_selectedCourseId' : '';
                          context.push('/teacher/content$query');
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: ClayButton(
                        text: l10n.createPracticumTaskBtn,
                        icon: Icons.add_task_rounded,
                        isAccent: true,
                        height: 48,
                        onPressed: () => _showCreateAssignmentDialog(topics),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. Monitoring Siswa & Transkrip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.monitoringListTitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Filter Chips
                Row(
                  children: [
                    _buildFilterChip(l10n.filterAll(totalStudents), 'all'),
                    const SizedBox(width: 8),
                    _buildFilterChip(l10n.filterRemedial(strugglingCount), 'struggling'),
                    const SizedBox(width: 8),
                    _buildFilterChip(l10n.filterMastered(completedCount), 'completed'),
                  ],
                ),
                const SizedBox(height: 14),

                if (filteredStudents.isEmpty)
                  ClayCard(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        l10n.noStudentsInCategory,
                        style: GoogleFonts.plusJakartaSans(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                else
                  ...filteredStudents.map((student) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: ClayCard(
                          padding: const EdgeInsets.all(16),
                          onTap: () {
                            context.push('/teacher/student/${student.studentId}');
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  UserAvatar(
                                    avatarUrl: student.avatarUrl,
                                    displayName: student.displayName,
                                    size: 36,
                                    backgroundColor: AppTheme.primaryIndigoLight,
                                    textColor: AppTheme.primaryIndigo,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          student.displayName,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          student.email,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 12,
                                            color: AppTheme.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ClayPill(
                                    label: '${student.lowestOrBestMeter}%',
                                    color: student.lowestOrBestMeter >= 80
                                        ? AppTheme.successGreenLight
                                        : (student.lowestOrBestMeter < 60
                                            ? const Color(0xFFFFF7ED)
                                            : AppTheme.primaryIndigoLight),
                                    textColor: student.lowestOrBestMeter >= 80
                                        ? AppTheme.successGreen
                                        : (student.lowestOrBestMeter < 60
                                            ? AppTheme.accentOrange
                                            : AppTheme.primaryIndigo),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              ClayProgressBar(
                                progress: student.lowestOrBestMeter / 100.0,
                                height: 6,
                                barColor: student.lowestOrBestMeter >= 80
                                    ? AppTheme.successGreen
                                    : (student.lowestOrBestMeter < 60
                                        ? AppTheme.accentOrange
                                        : AppTheme.primaryIndigo),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    l10n.sessionsWithBuddy(student.sessionCount),
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 12,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        l10n.viewTranscriptBtn,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.primaryIndigo,
                                        ),
                                      ),
                                      const Icon(Icons.chevron_right_rounded, size: 16, color: AppTheme.primaryIndigo),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      )),
                const SizedBox(height: 30),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return ClayCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 18),
              ),
              const Spacer(),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryIndigo : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.primaryIndigo : AppTheme.clayBorder,
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppTheme.textPrimary,
          ),
        ),
      ),
    );
  }
}
