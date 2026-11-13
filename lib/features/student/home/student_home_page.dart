import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/meter_paham_bar.dart';

class StudentHomePage extends ConsumerStatefulWidget {
  const StudentHomePage({super.key});

  @override
  ConsumerState<StudentHomePage> createState() => _StudentHomePageState();
}

class _StudentHomePageState extends ConsumerState<StudentHomePage> {
  late Future<(List<TopicSummary>, List<LearningSession>)> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _fetchData();
  }

  Future<(List<TopicSummary>, List<LearningSession>)> _fetchData() async {
    final repo = ref.read(sessionRepositoryProvider);
    final results = await Future.wait([
      repo.getTopicsSummary(),
      repo.getMySessions(),
    ]);
    return (
      results[0] as List<TopicSummary>,
      results[1] as List<LearningSession>,
    );
  }

  void _reload() {
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
          title: Text(l10n.chooseSessionLanguage),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RadioGroup<String>(
                groupValue: selectedLang,
                onChanged: (v) {
                  if (v == 'en' && !topic.enReady) return;
                  if (v != null) setDialogState(() => selectedLang = v);
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RadioListTile<String>(
                      value: 'id',
                      title: Text(l10n.indonesianLabel),
                    ),
                    RadioListTile<String>(
                      value: 'en',
                      enabled: topic.enReady,
                      title: Text(l10n.englishLabel),
                      subtitle: !topic.enReady
                          ? Text(
                              l10n.enLockedNote,
                              style: const TextStyle(fontSize: 12),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.sessionLanguageNote,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, selectedLang),
              child: Text(l10n.confirm),
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
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> _deleteSession(LearningSession session) async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteSessionTitle),
        content: Text(l10n.deleteSessionBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await ref.read(sessionRepositoryProvider).deleteSession(session.id);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = ref.watch(languageProvider).languageCode;
    final profile = ref.watch(currentProfileProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.studentHomeTitle),
        actions: [
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
        child: FutureBuilder<(List<TopicSummary>, List<LearningSession>)>(
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
                      Text(snapshot.error.toString(), textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: _reload, child: Text(l10n.retry)),
                    ],
                  ),
                ),
              );
            }

            final topics = snapshot.data?.$1 ?? const [];
            final sessions = snapshot.data?.$2 ?? const [];

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (profile != null) ...[
                  Text(
                    l10n.welcomeUser(profile.displayName),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF102A36),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.appTagline,
                    style: const TextStyle(color: Color(0xFF475569)),
                  ),
                  const SizedBox(height: 18),
                ],
                Text(
                  l10n.topicsSectionTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                if (topics.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(l10n.noTopicsAvailable),
                    ),
                  )
                else
                  ...topics.map((t) => _TopicCard(
                        topic: t,
                        lang: lang,
                        onContinue: t.activeSessionId == null
                            ? null
                            : () async {
                                await context.push(
                                  '/student/teach/${t.activeSessionId}',
                                );
                                _reload();
                              },
                        onStartNew: () => _startNewSessionDialog(t),
                      )),
                const SizedBox(height: 22),
                Text(
                  l10n.historySectionTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                if (sessions.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(l10n.noHistoryYet),
                    ),
                  )
                else
                  ...sessions.map(
                    (s) => Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        title: Text(
                          s.localizedTopicTitle(lang),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Text(
                          '${_statusLabel(context, s.status)} · ${s.meterPercent}% · '
                          '${s.language.toUpperCase()}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppTheme.dangerRed,
                              ),
                              onPressed: () => _deleteSession(s),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: () async {
                          if (s.status == SessionStatus.active) {
                            await context.push('/student/teach/${s.id}');
                          } else {
                            await context.push('/student/recap/${s.id}');
                          }
                          _reload();
                        },
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

class _TopicCard extends StatelessWidget {
  const _TopicCard({
    required this.topic,
    required this.lang,
    required this.onStartNew,
    this.onContinue,
  });

  final TopicSummary topic;
  final String lang;
  final VoidCallback onStartNew;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final String statusText;
    final Color statusColor;
    if (topic.hasCompleted80) {
      statusText = l10n.statusTargetReached;
      statusColor = AppTheme.successGreen;
    } else if (topic.activeSessionId != null || topic.bestMeterPercent > 0) {
      statusText = l10n.statusInProgress;
      statusColor = AppTheme.secondaryAmber;
    } else {
      statusText = l10n.statusNotStarted;
      statusColor = const Color(0xFF64748B);
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    topic.localizedTitle(lang),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            if (topic.localizedDesc(lang).isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                topic.localizedDesc(lang),
                style: const TextStyle(color: Color(0xFF475569), fontSize: 13.5),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              l10n.bestMeterLabel(topic.bestMeterPercent),
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            MeterPahamBar(meterPercent: topic.bestMeterPercent, compact: true),
            const SizedBox(height: 14),
            Row(
              children: [
                if (onContinue != null) ...[
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onContinue,
                      child: Text(l10n.continueSession),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: onContinue != null
                      ? OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: onStartNew,
                          child: Text(l10n.startNewSession),
                        )
                      : ElevatedButton(
                          onPressed: onStartNew,
                          child: Text(l10n.startNewSession),
                        ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
