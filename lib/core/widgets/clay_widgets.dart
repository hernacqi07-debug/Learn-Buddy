import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Tactile Claymorphic Card with double-depth soft shadow and inner highlight bevel
class ClayCard extends StatelessWidget {
  const ClayCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.borderRadius = 24.0,
    this.color = Colors.white,
    this.borderColor,
    this.borderWidth = 2.0,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color color;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor ?? AppTheme.clayBorder,
          width: borderWidth,
        ),
        boxShadow: [
          // Soft ambient outer drop shadow
          BoxShadow(
            color: const Color(0xFF1E1B4B).withValues(alpha: 0.07),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: const Color(0xFF1E1B4B).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: padding,
          child: child,
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: card,
      );
    }
    return card;
  }
}

/// Chunky Tactile Extruded Clay Button
class ClayButton extends StatefulWidget {
  const ClayButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isPrimary = true,
    this.isAccent = false,
    this.isDanger = false,
    this.height = 52.0,
    this.borderRadius = 16.0,
    this.isLoading = false,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isPrimary;
  final bool isAccent;
  final bool isDanger;
  final double height;
  final double borderRadius;
  final bool isLoading;

  @override
  State<ClayButton> createState() => _ClayButtonState();
}

class _ClayButtonState extends State<ClayButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color border;
    Color textCol;

    if (widget.isDanger) {
      bg = const Color(0xFFEF4444);
      border = const Color(0xFFDC2626);
      textCol = Colors.white;
    } else if (widget.isAccent) {
      bg = AppTheme.accentOrange;
      border = const Color(0xFFC2410C);
      textCol = Colors.white;
    } else if (widget.isPrimary) {
      bg = AppTheme.primaryIndigo;
      border = const Color(0xFF3730A3);
      textCol = Colors.white;
    } else {
      bg = Colors.white;
      border = AppTheme.clayBorder;
      textCol = AppTheme.textPrimary;
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.isLoading ? null : widget.onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.translationValues(0, _isPressed ? 2 : 0, 0),
        height: widget.height,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(color: border, width: 2),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: bg.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  )
                ]
              : [
                  BoxShadow(
                    color: bg.withValues(alpha: 0.32),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Center(
          child: widget.isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: textCol,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: textCol, size: 20),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.text,
                      style: GoogleFonts.plusJakartaSans(
                        color: textCol,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Fully Rounded Pill Tag / Badge (Claymorphic)
class ClayPill extends StatelessWidget {
  const ClayPill({
    super.key,
    required this.label,
    this.icon,
    this.isSelected = false,
    Color? backgroundColor,
    Color? color,
    this.textColor,
    this.onTap,
  }) : backgroundColor = backgroundColor ?? color;

  final String label;
  final IconData? icon;
  final bool isSelected;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bg = isSelected
        ? AppTheme.primaryIndigo
        : (backgroundColor ?? Colors.white);
    final text = isSelected
        ? Colors.white
        : (textColor ?? AppTheme.textPrimary);
    final border = isSelected
        ? const Color(0xFF3730A3)
        : AppTheme.clayBorder;

    Widget pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E1B4B).withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 15, color: text),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              color: text,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: pill);
    }
    return pill;
  }
}

/// Recessed Inset Clay Input Field
class ClayTextField extends StatelessWidget {
  const ClayTextField({
    super.key,
    this.controller,
    String? hintText,
    String? hint,
    String? label,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
  })  : hintText = hintText ?? hint ?? label ?? '',
        labelText = label;

  final TextEditingController? controller;
  final String hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null && labelText!.isNotEmpty) ...[
          Text(
            labelText!,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9).withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.clayBorder, width: 1.5),
          ),
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            maxLines: maxLines,
            onChanged: onChanged,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 14,
                color: const Color(0xFF94A3B8),
              ),
              prefixIcon: prefixIcon != null
                  ? Icon(prefixIcon, color: const Color(0xFF64748B), size: 20)
                  : null,
              suffixIcon: suffixIcon,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

/// Recessed Clay Progress Bar for SMK Mastery
class ClayProgressBar extends StatelessWidget {
  const ClayProgressBar({
    super.key,
    double? percentage,
    double? progress,
    this.height = 10.0,
    this.barColor,
  }) : percentage = percentage ?? ((progress ?? 0.0) * 100.0);

  final double percentage; // 0.0 to 100.0
  final double height;
  final Color? barColor;

  @override
  Widget build(BuildContext context) {
    final clamped = (percentage / 100.0).clamp(0.0, 1.0);
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: AppTheme.clayBorder, width: 1.0),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: clamped,
        child: Container(
          decoration: BoxDecoration(
            color: barColor ?? AppTheme.primaryIndigo,
            borderRadius: BorderRadius.circular(9999),
            boxShadow: [
              BoxShadow(
                color: (barColor ?? AppTheme.primaryIndigo).withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
