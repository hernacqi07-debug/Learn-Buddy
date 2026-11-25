import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/clay_widgets.dart';
import '../../../core/widgets/student_bottom_nav.dart';

class AnnouncementsPage extends ConsumerStatefulWidget {
  const AnnouncementsPage({super.key});

  @override
  ConsumerState<AnnouncementsPage> createState() => _AnnouncementsPageState();
}

class _AnnouncementsPageState extends ConsumerState<AnnouncementsPage> {
  late Future<List<Assignment>> _futureAssignments;

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  void _fetch() {
    setState(() {
      _futureAssignments = ref.read(sessionRepositoryProvider).getAssignments();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppTheme.clayCanvas,
      bottomNavigationBar: const StudentBottomNav(currentIndex: 1),
      appBar: AppBar(
        title: Text(
          l10n.announcementsTitle,
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
      body: FutureBuilder<List<Assignment>>(
        future: _futureAssignments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                l10n.failedToLoad(snapshot.error.toString()),
                style: GoogleFonts.plusJakartaSans(color: AppTheme.dangerRed),
              ),
            );
          }

          final list = snapshot.data ?? [];
          if (list.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.campaign_outlined, size: 52, color: AppTheme.textMuted),
                    const SizedBox(height: 12),
                    Text(
                      l10n.noAnnouncementsYet,
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
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, index) {
              final item = list[index];
              return _buildAssignmentCard(item);
            },
          );
        },
      ),
    );
  }

  Widget _buildAssignmentCard(Assignment item) {
    final l10n = context.l10n;
    Color badgeBg;
    Color badgeText;
    IconData icon;
    String typeLabel;

    switch (item.type) {
      case 'praktikum':
        badgeBg = const Color(0xFFEEF2FF);
        badgeText = AppTheme.primaryIndigo;
        icon = Icons.terminal_rounded;
        typeLabel = l10n.typePracticum;
        break;
      case 'announcement':
        badgeBg = const Color(0xFFFEF3C7);
        badgeText = const Color(0xFFB45309);
        icon = Icons.campaign_rounded;
        typeLabel = l10n.typeAnnouncement;
        break;
      default:
        badgeBg = const Color(0xFFECFDF5);
        badgeText = const Color(0xFF047857);
        icon = Icons.assignment_rounded;
        typeLabel = l10n.typeIndividual;
    }

    return ClayCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClayPill(
                label: typeLabel,
                color: badgeBg,
                textColor: badgeText,
                icon: icon,
              ),
              const Spacer(),
              if (item.dueDate != null)
                Row(
                  children: [
                    const Icon(Icons.alarm_rounded, size: 14, color: AppTheme.accentOrange),
                    const SizedBox(width: 4),
                    Text(
                      '${item.dueDate!.day}/${item.dueDate!.month}/${item.dueDate!.year}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.accentOrange,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.description,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              color: AppTheme.textSecondary,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppTheme.primaryIndigo.withValues(alpha: 0.15),
                    child: Text(
                      (item.teacherName ?? 'G')[0],
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryIndigo,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.teacherName ?? l10n.defaultTeacherName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMuted,
                    ),
                  ),
                ],
              ),
              if (item.topicId != null)
                GestureDetector(
                  onTap: () {
                    context.push('/student/materi/${item.topicId}');
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.clayCanvas,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.clayBorder, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.openModuleBtn,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryIndigo,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded, size: 14, color: AppTheme.primaryIndigo),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
