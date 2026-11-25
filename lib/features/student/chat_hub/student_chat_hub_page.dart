import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/buddy_avatar.dart';
import '../../../core/widgets/clay_widgets.dart';
import '../../../core/widgets/student_bottom_nav.dart';
import '../../../core/widgets/user_avatar.dart';

/// Halaman Tab "Chat" siswa — mengikuti layar Stitch "Learn Buddy - Beranda Siswa"
/// (31dc183a4e9c473186b30ed72aa2d51e) dengan 100% Data Real Supabase & dukungan ID/EN.
class StudentChatHubPage extends ConsumerStatefulWidget {
  const StudentChatHubPage({super.key});

  @override
  ConsumerState<StudentChatHubPage> createState() => _StudentChatHubPageState();
}

class _StudentChatHubPageState extends ConsumerState<StudentChatHubPage> {
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

  Future<void> _openTopicSession(TopicSummary topic) async {
    if (topic.activeSessionId != null) {
      await context.push('/student/teach/${topic.activeSessionId}');
      if (mounted) _reload();
      return;
    }

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
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: AppTheme.textMuted,
                        ),
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
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ClayButton(
              text: l10n.startSessionBtn,
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
      if (mounted) _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.startSessionFailed(e.toString())),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
    }
  }

  IconData _topicIcon(TopicSummary topic) {
    final lower = topic.titleId.toLowerCase();
    if (lower.contains('linked')) return Icons.link_rounded;
    if (lower.contains('queue') || lower.contains('antri')) return Icons.format_list_numbered_rounded;
    if (lower.contains('tree') || lower.contains('pohon')) return Icons.account_tree_rounded;
    return Icons.layers_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = ref.watch(languageProvider).languageCode;
    final isEn = lang == 'en';
    final profile = ref.watch(currentProfileProvider).value;
    final displayName = (profile?.displayName ?? '').trim();
    final firstName = displayName.isEmpty
        ? l10n.roleStudent
        : displayName.split(RegExp(r'\s+')).first;

    return Scaffold(
      backgroundColor: AppTheme.clayCanvas,
      bottomNavigationBar: StudentBottomNav(
        currentIndex: 0,
        onReturnFromChat: _reload,
      ),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Text(
              'Learn ',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            Text(
              'Buddy',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryIndigo,
              ),
            ),
          ],
        ),
        actions: [
          // Quick Language Switcher Pill
          GestureDetector(
            onTap: () {
              final next = isEn ? 'id' : 'en';
              ref.read(languageProvider.notifier).setLanguage(next);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    next == 'en' ? l10n.switchedToEn : l10n.switchedToId,
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
                  Text(isEn ? '🇬🇧' : '🇮🇩', style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    isEn ? 'EN' : 'ID',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      color: AppTheme.primaryIndigo,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Profile Icon Button
          Padding(
            padding: const EdgeInsets.only(right: 12.0, left: 4.0),
            child: GestureDetector(
              onTap: () => context.go('/settings'),
              child: UserAvatar(
                localPath: ref.watch(localAvatarPathProvider).value,
                avatarUrl: profile?.avatarUrl,
                displayName: displayName,
                size: 38,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryIndigo,
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
                      Text(
                        l10n.failedToLoad(snapshot.error.toString()),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.plusJakartaSans(color: AppTheme.dangerRed),
                      ),
                      const SizedBox(height: 12),
                      ClayButton(text: l10n.retry, onPressed: _reload),
                    ],
                  ),
                ),
              );
            }

            final (topics, sessions) = snapshot.data!;
            final activeSession = sessions.where((s) => s.status == SessionStatus.active).firstOrNull;
            final primaryTopic = topics.isNotEmpty ? topics.first : null;

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              children: [
                // 1. Hero Card (RPL Kelas XI + Halo + Lanjutkan Sesi -> + Buddy Mascot)
                ClayCard(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: const Color(0xFFFED7AA), width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.accentOrange,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    profile?.className ?? 'RPL Kelas XI',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.accentOrange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.welcomeUser(firstName),
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isEn
                                  ? 'Ready to continue teaching Buddy today?'
                                  : 'Mau lanjut mengajar Buddy hari ini?',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                color: AppTheme.textSecondary,
                                height: 1.35,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ClayButton(
                              text: activeSession != null
                                  ? '${l10n.continueSession} →'
                                  : '${l10n.startTeachingBuddy} →',
                              isAccent: true,
                              height: 44,
                              onPressed: () {
                                if (activeSession != null) {
                                  context.push('/student/teach/${activeSession.id}').then((_) {
                                    if (mounted) _reload();
                                  });
                                } else if (primaryTopic != null) {
                                  _openTopicSession(primaryTopic);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      BuddyAvatar(
                        meterPercent: activeSession?.meterPercent ?? primaryTopic?.bestMeterPercent ?? 85,
                        size: 92,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Topik Struktur Data Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.menu_book_rounded, size: 20, color: AppTheme.primaryIndigo),
                        const SizedBox(width: 8),
                        Text(
                          l10n.topicsSectionTitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        if (primaryTopic != null) {
                          context.push('/student/materi/${primaryTopic.id}');
                        }
                      },
                      child: Row(
                        children: [
                          Text(
                            l10n.seeAll,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryIndigo,
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, size: 18, color: AppTheme.primaryIndigo),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Topics Cards List
                if (topics.isEmpty)
                  ClayCard(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        l10n.noTopicsAvailable,
                        style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
                      ),
                    ),
                  )
                else
                  ...topics.map((topic) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildTopicCard(topic, lang, isEn, l10n),
                      )),

                const SizedBox(height: 14),

                // 3. Riwayat Sesi Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.history_edu_rounded, size: 20, color: AppTheme.primaryIndigo),
                        const SizedBox(width: 8),
                        Text(
                          l10n.historySectionTitle,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => context.push('/student/history'),
                      child: Text(
                        isEn ? 'Latest' : 'Terbaru',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                if (sessions.isEmpty)
                  ClayCard(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        l10n.noHistoryYet,
                        style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
                      ),
                    ),
                  )
                else
                  ...sessions.take(3).map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: _buildRecentSessionTile(s, lang, isEn, l10n),
                      )),

                const SizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopicCard(TopicSummary topic, String lang, bool isEn, dynamic l10n) {
    final bool isDone = topic.bestMeterPercent >= 80 || topic.hasCompleted80;
    final bool isInProgress = !isDone && (topic.bestMeterPercent > 0 || topic.activeSessionId != null);

    Color badgeBg;
    Color badgeText;
    IconData badgeIcon;
    String badgeLabel;

    if (isDone) {
      badgeBg = const Color(0xFFFFF7ED);
      badgeText = AppTheme.accentOrange;
      badgeIcon = Icons.check_circle_outline_rounded;
      badgeLabel = isEn ? 'Completed' : 'Tuntas';
    } else if (isInProgress) {
      badgeBg = AppTheme.primaryIndigoLight;
      badgeText = AppTheme.primaryIndigo;
      badgeIcon = Icons.timelapse_rounded;
      badgeLabel = l10n.statusInProgress;
    } else {
      badgeBg = const Color(0xFFF1F5F9);
      badgeText = AppTheme.textSecondary;
      badgeIcon = Icons.access_time_rounded;
      badgeLabel = l10n.statusNotStarted;
    }

    return ClayCard(
      padding: const EdgeInsets.all(16),
      onTap: () => _openTopicSession(topic),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.primaryIndigoLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _topicIcon(topic),
                  color: AppTheme.primaryIndigo,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      topic.localizedTitle(lang),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      topic.localizedDesc(lang),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ClayPill(
                label: badgeLabel,
                color: badgeBg,
                textColor: badgeText,
                icon: badgeIcon,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isEn ? 'Mastery Meter' : 'Meter Paham',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              Text(
                '${topic.bestMeterPercent}%',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: topic.bestMeterPercent > 0 ? AppTheme.primaryIndigo : AppTheme.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClayProgressBar(
            progress: topic.bestMeterPercent / 100.0,
            height: 8,
            barColor: topic.bestMeterPercent >= 80 ? AppTheme.primaryIndigo : AppTheme.primaryIndigo,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSessionTile(LearningSession session, String lang, bool isEn, dynamic l10n) {
    final bool isDone = session.status == SessionStatus.completed;
    final dateStr = '${session.startedAt.day}/${session.startedAt.month}';

    return ClayCard(
      padding: const EdgeInsets.all(14),
      onTap: () {
        if (session.status == SessionStatus.active) {
          context.push('/student/teach/${session.id}').then((_) {
            if (mounted) _reload();
          });
        } else {
          context.push('/student/recap/${session.id}');
        }
      },
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.primaryIndigoLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.event_note_rounded,
              color: AppTheme.primaryIndigo,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${session.localizedTopicTitle(lang)} — $dateStr',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isDone
                      ? (isEn ? 'Finished teaching Buddy' : 'Selesai diajarkan ke Buddy')
                      : l10n.teachingTurnsGiven(session.studentInputs),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primaryIndigoLight,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${session.meterPercent}%',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.primaryIndigo,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.verified_outlined,
                  size: 15,
                  color: isDone ? AppTheme.accentOrange : AppTheme.primaryIndigo,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
