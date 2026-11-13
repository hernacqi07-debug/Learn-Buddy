import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/meter_paham_bar.dart';

class TeacherDashboardPage extends ConsumerStatefulWidget {
  const TeacherDashboardPage({super.key});

  @override
  ConsumerState<TeacherDashboardPage> createState() =>
      _TeacherDashboardPageState();
}

class _TeacherDashboardPageState extends ConsumerState<TeacherDashboardPage> {
  late Future<(List<TeacherStudentSummary>, List<TeacherTopic>)> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(List<TeacherStudentSummary>, List<TeacherTopic>)> _load() async {
    final repo = ref.read(teacherRepositoryProvider);
    final res = await Future.wait([
      repo.getStudentsProgress(),
      repo.getAllContent(),
    ]);
    return (
      res[0] as List<TeacherStudentSummary>,
      res[1] as List<TeacherTopic>,
    );
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = ref.watch(languageProvider).languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.teacherDashboardTitle),
        actions: [
          TextButton.icon(
            onPressed: () async {
              await context.push('/teacher/content');
              _reload();
            },
            icon: const Icon(Icons.edit_note_rounded),
            label: Text(l10n.manageContentButton),
          ),
          IconButton(
            tooltip: l10n.settingsTitle,
            icon: const Icon(Icons.settings_outlined),
            onPressed: () async {
              await context.push('/settings');
              _reload();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _reload(),
        child: FutureBuilder<(List<TeacherStudentSummary>, List<TeacherTopic>)>(
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
                      Text(snapshot.error.toString()),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _reload, child: Text(l10n.retry)),
                    ],
                  ),
                ),
              );
            }

            final students = snapshot.data?.$1 ?? const [];
            final topics = snapshot.data?.$2 ?? const [];

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  l10n.topicsSectionTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: topics.map((t) {
                    final title = lang == 'en' && t.titleEn.isNotEmpty
                        ? t.titleEn
                        : t.titleId;
                    return Chip(
                      label: Text(
                        '$title (${t.isActive ? l10n.activeLabel : l10n.inactiveLabel})',
                      ),
                      backgroundColor: t.isActive
                          ? AppTheme.primaryTeal.withValues(alpha: 0.1)
                          : const Color(0xFFE2E8F0),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                Text(
                  l10n.studentsProgressTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                if (students.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(l10n.noStudentsYet),
                    ),
                  )
                else
                  ...students.map(
                    (st) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () =>
                            context.push('/teacher/student/${st.studentId}'),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          st.displayName,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          st.email,
                                          style: const TextStyle(
                                            fontSize: 12.5,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    l10n.sessionsCountLabel(st.sessionCount),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.primaryTeal,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                              const SizedBox(height: 10),
                              MeterPahamBar(
                                meterPercent: st.lowestOrBestMeter,
                                compact: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
