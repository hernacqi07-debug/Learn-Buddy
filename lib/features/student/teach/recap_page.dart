import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/buddy_avatar.dart';
import '../../../core/widgets/meter_paham_bar.dart';

class RecapPage extends ConsumerStatefulWidget {
  const RecapPage({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<RecapPage> createState() => _RecapPageState();
}

class _RecapPageState extends ConsumerState<RecapPage> {
  late Future<(LearningSession, List<RecapMisconception>)> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(LearningSession, List<RecapMisconception>)> _load() async {
    final repo = ref.read(sessionRepositoryProvider);
    final res = await Future.wait([
      repo.getSession(widget.sessionId),
      repo.getSessionRecap(widget.sessionId),
    ]);
    return (
      res[0] as LearningSession,
      res[1] as List<RecapMisconception>,
    );
  }

  Future<void> _retryTopic(LearningSession session) async {
    final newSession = await ref.read(sessionRepositoryProvider).startSession(
          topicId: session.topicId,
          language: session.language,
        );
    if (!mounted) return;
    context.pushReplacement('/student/teach/${newSession.id}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = ref.watch(languageProvider).languageCode;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.recapTitle)),
      body: FutureBuilder<(LearningSession, List<RecapMisconception>)>(
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

          final session = snapshot.data!.$1;
          final items = snapshot.data!.$2;
          final resolved = items.where((m) => m.isResolved).toList();
          final unresolved = items.where((m) => !m.isResolved).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      BuddyAvatar(meterPercent: session.meterPercent, size: 84),
                      const SizedBox(height: 12),
                      Text(
                        session.localizedTopicTitle(lang),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _statusChip(context, session.status),
                      const SizedBox(height: 14),
                      MeterPahamBar(meterPercent: session.meterPercent),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              if (resolved.isNotEmpty) ...[
                Text(
                  l10n.resolvedTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.successGreen,
                  ),
                ),
                const SizedBox(height: 8),
                ...resolved.map(
                  (m) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.successGreen,
                      ),
                      title: Text(m.localizedTitle(session.language)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (unresolved.isNotEmpty) ...[
                Text(
                  l10n.unresolvedTitle,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.warningOrange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.unresolvedNoHintNote,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 8),
                ...unresolved.map(
                  (m) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const Icon(
                        Icons.radio_button_unchecked_rounded,
                        color: AppTheme.warningOrange,
                      ),
                      // Title only, NO hints or answer keys!
                      title: Text(m.localizedTitle(session.language)),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => context.push('/student/teach/${session.id}'),
                icon: const Icon(Icons.chat_bubble_outline),
                label: Text(l10n.historySectionTitle),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _retryTopic(session),
                child: Text(l10n.tryAgainTopic),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: () => context.go('/student'),
                child: Text(l10n.chooseOtherTopic),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _statusChip(BuildContext context, SessionStatus status) {
    final l10n = context.l10n;
    final (label, color) = switch (status) {
      SessionStatus.completed => (
          l10n.sessionStatusCompleted,
          AppTheme.successGreen,
        ),
      SessionStatus.incomplete => (
          l10n.sessionStatusIncomplete,
          AppTheme.warningOrange,
        ),
      SessionStatus.abandoned => (
          l10n.sessionStatusAbandoned,
          const Color(0xFF64748B),
        ),
      SessionStatus.active => (
          l10n.sessionStatusActive,
          AppTheme.primaryTeal,
        ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12),
      ),
    );
  }
}
