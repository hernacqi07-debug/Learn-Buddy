import 'package:flutter/material.dart';
import '../models/models.dart';
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
    if (meter >= 80) return const Color(0xFF10B981); // Emerald
    if (meter >= 50) return const Color(0xFF38BDF8); // Electric Cyan
    if (meter >= 20) return const Color(0xFFF59E0B); // Amber
    return const Color(0xFFEF4444); // Coral/Red
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
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.6),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  moodText,
                  style: TextStyle(
                    fontSize: compact ? 12 : 13,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
            Text(
              '$m%',
              style: TextStyle(
                fontSize: compact ? 12 : 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
        SizedBox(height: compact ? 5 : 7),
        Container(
          height: compact ? 7 : 10,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(999),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final w = constraints.maxWidth * (m / 100.0);
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOut,
                    width: w,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          color.withValues(alpha: 0.7),
                          color,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
