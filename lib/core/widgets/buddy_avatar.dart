import 'package:flutter/material.dart';
import '../models/models.dart';
import '../l10n/l10n_ext.dart';

class BuddyAvatar extends StatelessWidget {
  const BuddyAvatar({
    super.key,
    required this.meterPercent,
    this.size = 56,
    this.showBorder = true,
  });

  final int meterPercent;
  final double size;
  final bool showBorder;

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

  @override
  Widget build(BuildContext context) {
    final mood = BuddyMood.fromMeter(meterPercent);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFE7F4F8),
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(color: const Color(0xFF1F7A94).withValues(alpha: 0.3), width: 2)
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.all(size * 0.06),
        child: Image.asset(
          mood.assetPath,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.face_rounded,
            size: size * 0.6,
            color: const Color(0xFF1F7A94),
          ),
        ),
      ),
    );
  }
}
