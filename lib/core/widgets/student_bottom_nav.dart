import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/l10n_ext.dart';
import '../models/models.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import 'clay_widgets.dart';

/// Menu bawah siswa — mengikuti tab bar di layar Stitch
/// (Chat – Beranda – Pengaturan). Item aktif tampil sebagai pill indigo,
/// item lain abu-abu. Dipakai semua halaman siswa; halaman Chat (mengajar)
/// sengaja tidak memakainya supaya kolom ketik tidak terganggu keyboard.
/// Untuk guru widget ini tidak menampilkan apa-apa.
class StudentBottomNav extends ConsumerWidget {
  const StudentBottomNav({
    super.key,
    required this.currentIndex,
    this.onReturnFromChat,
  });

  /// 0 = Chat, 1 = Beranda, 2 = Pengaturan.
  final int currentIndex;

  /// Dipanggil setelah halaman Chat ditutup (mis. Beranda me-refresh data).
  final VoidCallback? onReturnFromChat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider).value;
    if (profile != null && profile.role != UserRole.student) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppTheme.clayBorder, width: 2),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.chat_bubble_rounded,
                label: 'Chat',
                active: currentIndex == 0,
                onTap: () => _onChatTap(context, ref),
              ),
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Beranda',
                active: currentIndex == 1,
                onTap: () {
                  if (currentIndex != 1) context.go('/student');
                },
              ),
              _NavItem(
                icon: Icons.settings_rounded,
                label: 'Pengaturan',
                active: currentIndex == 2,
                onTap: () {
                  if (currentIndex != 2) context.go('/settings');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onChatTap(BuildContext context, WidgetRef ref) async {
    await startTeachingSession(context, ref);
    onReturnFromChat?.call();
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? Colors.white : AppTheme.textSecondary;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        constraints: const BoxConstraints(minWidth: 72),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryIndigo : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: content,
      ),
    );
  }
}

/// Alur mulai/lanjutkan sesi mengajar dari tab Chat:
/// pilih topik (lanjutkan sesi aktif bila ada) → pilih bahasa → mulai sesi.
Future<void> startTeachingSession(
  BuildContext context,
  WidgetRef ref,
) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  List<TopicSummary> topics;
  try {
    topics = await ref.read(sessionRepositoryProvider).getTopicsSummary();
  } catch (e) {
    if (!context.mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal memuat topik: $e')),
    );
    return;
  }
  if (!context.mounted) return;
  Navigator.pop(context);

  if (topics.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Belum ada topik aktif')),
    );
    return;
  }

  final appLang = ref.read(languageProvider).languageCode;
  final chosen = await showDialog<TopicSummary>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: AppTheme.clayBorder, width: 2),
      ),
      title: Text(
        'Pilih Topik',
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.w800,
          fontSize: 18,
          color: AppTheme.textPrimary,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: topics.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (ctx, i) {
            final topic = topics[i];
            final title =
                appLang == 'en' ? topic.titleEn : topic.titleId;
            return InkWell(
              onTap: () => Navigator.pop(ctx, topic),
              borderRadius: BorderRadius.circular(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        if (topic.activeSessionId != null)
                          Text(
                            'Lanjutkan sesi',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              color: AppTheme.accentOrange,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: topic.bestMeterPercent >= 80
                          ? AppTheme.successGreenLight
                          : AppTheme.primaryIndigoLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${topic.bestMeterPercent}%',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w800,
                        fontSize: 12.5,
                        color: topic.bestMeterPercent >= 80
                            ? AppTheme.successGreen
                            : AppTheme.primaryIndigo,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      actions: [
        ClayButton(
          text: 'Tutup',
          height: 44,
          onPressed: () => Navigator.pop(ctx),
        ),
      ],
    ),
  );

  if (chosen == null || !context.mounted) return;

  if (chosen.activeSessionId != null) {
    await context.push('/student/teach/${chosen.activeSessionId}');
    return;
  }

  final language = await showSessionLanguageDialog(context, ref, chosen);
  if (language == null || !context.mounted) return;

  try {
    final session = await ref
        .read(sessionRepositoryProvider)
        .startSession(topicId: chosen.id, language: language);
    if (!context.mounted) return;
    await context.push('/student/teach/${session.id}');
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Gagal memulai sesi: $e')),
    );
  }
}

/// Dialog pilih bahasa sesi (dipakai Beranda dan tab Chat).
Future<String?> showSessionLanguageDialog(
  BuildContext context,
  WidgetRef ref,
  TopicSummary topic,
) {
  final l10n = context.l10n;
  final appLang = ref.read(languageProvider).languageCode;
  String selectedLang = (appLang == 'en' && topic.enReady) ? 'en' : 'id';

  return showDialog<String>(
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
            text: 'Mulai Sesi',
            height: 44,
            onPressed: () => Navigator.pop(ctx, selectedLang),
          ),
        ],
      ),
    ),
  );
}
