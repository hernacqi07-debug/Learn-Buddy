import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/clay_widgets.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  late Future<List<LearningSession>> _futureSessions;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() {
    setState(() {
      _futureSessions = ref.read(sessionRepositoryProvider).getMySessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.clayCanvas,
      appBar: AppBar(
        title: Text(
          'Riwayat Sesi Belajar',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _fetch,
          ),
        ],
      ),
      body: FutureBuilder<List<LearningSession>>(
        future: _futureSessions,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi kesalahan: ${snapshot.error}',
                style: GoogleFonts.plusJakartaSans(color: AppTheme.dangerRed),
              ),
            );
          }

          final sessions = snapshot.data ?? [];
          if (sessions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.history_toggle_off_rounded, size: 52, color: AppTheme.textMuted),
                    const SizedBox(height: 12),
                    Text(
                      'Belum ada riwayat sesi mengajar Buddy.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final session = sessions[index];
              return _buildSessionCard(session);
            },
          );
        },
      ),
    );
  }

  Widget _buildSessionCard(LearningSession session) {
    final bool isCompleted = session.status == SessionStatus.completed;
    final bool isActive = session.status == SessionStatus.active;

    Color badgeBg;
    Color badgeText;
    String statusText;

    if (isCompleted) {
      badgeBg = const Color(0xFFECFDF5);
      badgeText = const Color(0xFF047857);
      statusText = 'Selesai Paham';
    } else if (isActive) {
      badgeBg = const Color(0xFFEEF2FF);
      badgeText = AppTheme.primaryIndigo;
      statusText = 'Sedang Berjalan';
    } else {
      badgeBg = const Color(0xFFFFF7ED);
      badgeText = const Color(0xFFC2410C);
      statusText = 'Belum Tuntas';
    }

    final formattedDate =
        '${session.startedAt.day}/${session.startedAt.month}/${session.startedAt.year} · ${session.startedAt.hour.toString().padLeft(2, '0')}:${session.startedAt.minute.toString().padLeft(2, '0')} WIB';

    return ClayCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClayPill(
                label: statusText,
                color: badgeBg,
                textColor: badgeText,
              ),
              const Spacer(),
              Text(
                formattedDate,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: AppTheme.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meter Circular / Badge
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppTheme.successGreen.withValues(alpha: 0.12)
                      : AppTheme.primaryIndigo.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCompleted ? AppTheme.successGreen : AppTheme.primaryIndigo,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${session.meterPercent}%',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: isCompleted ? AppTheme.successGreen : AppTheme.primaryIndigo,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.localizedTopicTitle('id'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${session.studentInputs} Giliran Mengajar Buddy · Bahasa: ${session.language.toUpperCase()}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (isActive)
                ClayButton(
                  text: 'Lanjutkan Sesi',
                  height: 40,
                  onPressed: () {
                    context.push('/student/teach/${session.id}');
                  },
                )
              else
                ClayButton(
                  text: 'Lihat Evaluasi & Rekap',
                  isPrimary: false,
                  height: 40,
                  onPressed: () {
                    context.push('/student/recap/${session.id}');
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
