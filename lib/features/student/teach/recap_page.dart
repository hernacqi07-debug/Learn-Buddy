import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/buddy_avatar.dart';
import '../../../core/widgets/clay_widgets.dart';
import '../../../core/widgets/student_bottom_nav.dart';

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
    return Scaffold(
      backgroundColor: AppTheme.clayCanvas,
      bottomNavigationBar: const StudentBottomNav(currentIndex: 1),
      appBar: AppBar(
        title: Text(
          'Rekap Capaian Belajar',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.go('/student'),
        ),
      ),
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
                child: Text(
                  snapshot.error.toString(),
                  style: GoogleFonts.plusJakartaSans(color: AppTheme.dangerRed),
                ),
              ),
            );
          }

          final session = snapshot.data!.$1;
          final items = snapshot.data!.$2;
          final resolved = items.where((m) => m.isResolved).toList();
          final unresolved = items.where((m) => !m.isResolved).toList();
          final isCompleted = session.meterPercent >= 80;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Main Summary Card
              ClayCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    BuddyAvatar(
                      mood: BuddyMood.fromMeter(session.meterPercent),
                      size: 80,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      session.localizedTopicTitle('id'),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ClayPill(
                      label: isCompleted ? 'Tuntas Paham (>=80%)' : 'Perlu Diperkuat',
                      color: isCompleted ? AppTheme.successGreenLight : const Color(0xFFFEF3C7),
                      textColor: isCompleted ? AppTheme.successGreen : const Color(0xFFB45309),
                      icon: isCompleted ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Tingkat Pemahaman Buddy:',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          '${session.meterPercent}%',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: isCompleted ? AppTheme.successGreen : AppTheme.primaryIndigo,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClayProgressBar(
                      progress: session.meterPercent / 100.0,
                      height: 10,
                      barColor: isCompleted ? AppTheme.successGreen : AppTheme.primaryIndigo,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '${session.studentInputs} Giliran Mengajar Diberikan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        color: AppTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Resolved Misconceptions
              if (resolved.isNotEmpty) ...[
                Text(
                  'Konsep yang Berhasil Diluruskan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.successGreen,
                  ),
                ),
                const SizedBox(height: 8),
                ...resolved.map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ClayCard(
                      padding: const EdgeInsets.all(14),
                      borderColor: const Color(0xFFA7F3D0),
                      color: const Color(0xFFECFDF5),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppTheme.successGreen, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              m.localizedTitle('id'),
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF065F46),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Unresolved Misconceptions
              if (unresolved.isNotEmpty) ...[
                Text(
                  'Konsep yang Masih Perlu Diperkuat',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.accentOrange,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Buddy masih bingung di butir-butir ini. Coba ajari lagi dengan analogi baru.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                ...unresolved.map(
                  (m) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: ClayCard(
                      padding: const EdgeInsets.all(14),
                      borderColor: const Color(0xFFFED7AA),
                      color: const Color(0xFFFFF7ED),
                      child: Row(
                        children: [
                          const Icon(Icons.help_outline_rounded, color: AppTheme.accentOrange, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              m.localizedTitle('id'),
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF9A3412),
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Actions
              ClayButton(
                text: 'Baca Ulang Riwayat Chat',
                isPrimary: false,
                icon: Icons.chat_bubble_outline_rounded,
                onPressed: () => context.push('/student/teach/${session.id}'),
              ),
              const SizedBox(height: 12),

              ClayButton(
                text: 'Coba Ajari Lagi (Sesi Baru)',
                icon: Icons.replay_rounded,
                onPressed: () => _retryTopic(session),
              ),
              const SizedBox(height: 12),

              Center(
                child: TextButton(
                  onPressed: () => context.go('/student'),
                  child: Text(
                    'Kembali ke Beranda Utama',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          );
        },
      ),
    );
  }
}
