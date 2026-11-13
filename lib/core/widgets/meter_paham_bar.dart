import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'buddy_avatar.dart';

class MeterPahamBar extends StatelessWidget {
  const MeterPahamBar({
    super.key,
    required this.meterPercent,
    this.compact = false,
  });

  final int meterPercent;
  final bool compact;

  Color _barColor(int meter) {
    if (meter >= 80) return AppTheme.successGreen;
    if (meter >= 50) return AppTheme.primaryTeal;
    if (meter >= 20) return AppTheme.secondaryAmber;
    return AppTheme.warningOrange;
  }

  @override
  Widget build(BuildContext context) {
    final m = meterPercent.clamp(0, 100);
    final mood = BuddyMood.fromMeter(m);
    final moodText = BuddyAvatar.moodLabel(context, mood);
    final color = _barColor(m);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              moodText,
              style: TextStyle(
                fontSize: compact ? 12 : 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              '$m%',
              style: TextStyle(
                fontSize: compact ? 12 : 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF102A36),
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? 4 : 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: m / 100.0),
            duration: const Duration(milliseconds: 350),
            builder: (context, value, _) {
              return LinearProgressIndicator(
                value: value,
                minHeight: compact ? 7 : 10,
                backgroundColor: const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              );
            },
          ),
        ),
      ],
    );
  }
}
