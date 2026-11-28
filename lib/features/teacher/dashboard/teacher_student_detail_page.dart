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

class TeacherStudentDetailPage extends ConsumerStatefulWidget {
  const TeacherStudentDetailPage({
    super.key,
    required this.studentId,
    this.courseId,
  });

  final String studentId;
  final String? courseId;

  @override
  ConsumerState<TeacherStudentDetailPage> createState() =>
      _TeacherStudentDetailPageState();
}

class _TeacherStudentDetailPageState
    extends ConsumerState<TeacherStudentDetailPage> {
  late Future<(UserProfile?, List<TeacherStudentSessionDetail>)> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(UserProfile?, List<TeacherStudentSessionDetail>)> _load() async {
    final repo = ref.read(teacherRepositoryProvider);
    final teacherCourseId =
        widget.courseId ?? ref.read(currentProfileProvider).value?.courseId;
    final res = await Future.wait([
      repo.getStudentProfile(widget.studentId),
      repo.getStudentSessionsDetail(
        widget.studentId,
        courseId: teacherCourseId,
      ),
    ]);
    return (
      res[0] as UserProfile?,
      res[1] as List<TeacherStudentSessionDetail>,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = ref.watch(languageProvider).languageCode;

    return Scaffold(
      backgroundColor: AppTheme.clayCanvas,
      appBar: AppBar(
        title: Text(
          l10n.transcriptDetailTitle,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: FutureBuilder<(UserProfile?, List<TeacherStudentSessionDetail>)>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n.failedToLoad(snapshot.error.toString()),
                  style: GoogleFonts.plusJakartaSans(color: AppTheme.dangerRed),
                ),
              ),
            );
          }

          final profile = snapshot.data?.$1;
          final details = snapshot.data?.$2 ?? const [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Student Header Card
              if (profile != null)
                ClayCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      UserAvatar(
                        avatarUrl: profile.avatarUrl,
                        displayName: profile.displayName,
                        size: 56,
                        backgroundColor: AppTheme.primaryIndigoLight,
                        textColor: AppTheme.primaryIndigo,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              profile.displayName,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              profile.email,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: AppTheme.textMuted,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ClayPill(
                              label: '${profile.className ?? 'XI RPL'} · ${profile.schoolName ?? 'SMK'}',
                              color: AppTheme.primaryIndigoLight,
                              textColor: AppTheme.primaryIndigo,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 14),

              // Pedagogical Privacy Statement
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.security_rounded, size: 20, color: AppTheme.successGreen),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.teacherPrivacyDesc,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF065F46),
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text(
                l10n.sessionHistoryRubricTitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 10),

              if (details.isEmpty)
                ClayCard(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      l10n.noStudentSessions,
                      style: GoogleFonts.plusJakartaSans(
                        color: AppTheme.textSecondary,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                )
              else
                ...details.map((d) {
                  final s = d.session;
                  final isCompleted = s.meterPercent >= 80;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14.0),
                    child: ClayCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  s.localizedTopicTitle(lang),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ClayPill(
                                label: l10n.understoodBadge(s.meterPercent),
                                color: isCompleted ? AppTheme.successGreenLight : const Color(0xFFFFF7ED),
                                textColor: isCompleted ? AppTheme.successGreen : AppTheme.accentOrange,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClayProgressBar(
                            progress: s.meterPercent / 100.0,
                            height: 6,
                            barColor: isCompleted ? AppTheme.successGreen : AppTheme.accentOrange,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${l10n.teachingTurnsGiven(s.studentInputs)} · ${s.startedAt.day}/${s.startedAt.month}/${s.startedAt.year}',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          if (d.criteriaItems.isNotEmpty) ...[
                            const Divider(height: 24, color: AppTheme.clayBorder),
                            Text(
                              l10n.criteriaAchievementTitle,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            ...d.criteriaItems.map((c) => Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: c.fulfilled ? const Color(0xFFECFDF5) : AppTheme.clayCanvas,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: c.fulfilled ? const Color(0xFFA7F3D0) : AppTheme.clayBorder,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            c.fulfilled ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                                            size: 16,
                                            color: c.fulfilled ? AppTheme.successGreen : AppTheme.textMuted,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              c.criterionText,
                                              style: GoogleFonts.plusJakartaSans(
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w700,
                                                color: c.fulfilled ? const Color(0xFF065F46) : AppTheme.textPrimary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (c.evidenceQuote != null && c.evidenceQuote!.isNotEmpty) ...[
                                        const SizedBox(height: 6),
                                        Text(
                                          l10n.studentEvidenceQuote(c.evidenceQuote!),
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11.5,
                                            fontStyle: FontStyle.italic,
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                )),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
