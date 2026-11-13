import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';

class TeacherStudentDetailPage extends ConsumerStatefulWidget {
  const TeacherStudentDetailPage({super.key, required this.studentId});

  final String studentId;

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
    final res = await Future.wait([
      repo.getStudentProfile(widget.studentId),
      repo.getStudentSessionsDetail(widget.studentId),
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
      appBar: AppBar(title: Text(l10n.studentDetailTitle)),
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
                child: Text(snapshot.error.toString()),
              ),
            );
          }

          final profile = snapshot.data?.$1;
          final details = snapshot.data?.$2 ?? const [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (profile != null) ...[
                Text(
                  profile.displayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  profile.email,
                  style: const TextStyle(color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 12),
              ],
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primaryTeal.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.lock_outline,
                      size: 18,
                      color: AppTheme.primaryTeal,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l10n.teacherPrivacyBanner,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF102A36),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (details.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(l10n.noHistoryYet),
                  ),
                )
              else
                ...details.map((d) {
                  final s = d.session;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      initiallyExpanded: details.first.session.id == s.id,
                      title: Text(
                        '${s.localizedTopicTitle(lang)} · ${s.meterPercent}%',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Text(
                        '${_statusLabel(context, s.status)} · ${s.studentInputs}/20 · ${s.language.toUpperCase()}',
                      ),
                      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                      children: d.criteriaItems.map((c) {
                        return Container(
                          margin: const EdgeInsets.only(top: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    c.fulfilled
                                        ? Icons.check_circle_rounded
                                        : Icons.cancel_outlined,
                                    size: 18,
                                    color: c.fulfilled
                                        ? AppTheme.successGreen
                                        : const Color(0xFF94A3B8),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      c.criterionText,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                c.misconceptionTitle,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                c.fulfilled &&
                                        (c.evidenceQuote ?? '').isNotEmpty
                                    ? '${l10n.evidenceLabel} "${c.evidenceQuote}"'
                                    : l10n.noEvidenceYet,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontStyle: c.fulfilled
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                  color: c.fulfilled
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  String _statusLabel(BuildContext context, SessionStatus status) {
    final l10n = context.l10n;
    return switch (status) {
      SessionStatus.completed => l10n.sessionStatusCompleted,
      SessionStatus.incomplete => l10n.sessionStatusIncomplete,
      SessionStatus.abandoned => l10n.sessionStatusAbandoned,
      SessionStatus.active => l10n.sessionStatusActive,
    };
  }
}
