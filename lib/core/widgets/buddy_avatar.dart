import 'package:flutter/material.dart';
import '../models/models.dart';
import '../l10n/l10n_ext.dart';

class BuddyAvatar extends StatelessWidget {
  const BuddyAvatar({
    super.key,
    int? meterPercent,
    this.mood,
    this.size = 56,
    this.showBorder = true,
    this.showGlow = true,
  }) : meterPercent = meterPercent ?? 0;

  final int meterPercent;
  final BuddyMood? mood;
  final double size;
  final bool showBorder;
  final bool showGlow;

  static String moodLabel(BuildContext context, BuddyMood mood) {
    final l10n = context.l10n;
    return switch (mood) {
      BuddyMood.confused => l10n.moodConfused,
      BuddyMood.thinking => l10n.moodThinking,
      BuddyMood.doubtful => l10n.moodDoubtful,
      BuddyMood.starting => l10n.moodStarting,
      BuddyMood.understands => l10n.moodUnderstands,
      BuddyMood.happy => l10n.moodHappy,
    };
  }

  Color _moodAuraColor(BuddyMood mood) {
    return switch (mood) {
      BuddyMood.confused => const Color(0xFFEF4444),
      BuddyMood.thinking => const Color(0xFFF59E0B),
      BuddyMood.doubtful => const Color(0xFFFB923C),
      BuddyMood.starting => const Color(0xFF38BDF8),
      BuddyMood.understands => const Color(0xFF10B981),
      BuddyMood.happy => const Color(0xFF34D399),
    };
  }

  @override
  Widget build(BuildContext context) {
    final effectiveMood = mood ?? BuddyMood.fromMeter(meterPercent);
    final auraColor = _moodAuraColor(effectiveMood);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: auraColor.withValues(alpha: 0.8),
                width: 2.2,
              )
            : null,
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: auraColor.withValues(alpha: 0.4),
                  blurRadius: 14,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(size * 0.08),
        child: Image.asset(
          effectiveMood.assetPath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.face_rounded,
            size: size * 0.6,
            color: auraColor,
          ),
        ),
      ),
    );
  }
}
