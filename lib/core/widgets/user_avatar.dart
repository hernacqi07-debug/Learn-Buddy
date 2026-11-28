import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// Avatar pengguna yang mendukung:
/// 1. Foto lokal dari galeri (`localPath`)
/// 2. Foto cloud dari Supabase Storage (`avatarUrl`)
/// 3. Emoji avatar (`emoji`)
/// 4. Inisial nama (`displayName`) sebagai fallback
class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.localPath,
    this.avatarUrl,
    this.emoji,
    this.displayName = '',
    this.size = 48,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.borderWidth = 0,
  });

  final String? localPath;
  final String? avatarUrl;
  final String? emoji;
  final String displayName;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double borderWidth;

  String _initials(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'LB';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Widget _buildFallback() {
    if (emoji != null && emoji!.isNotEmpty) {
      return Text(
        emoji!,
        style: TextStyle(fontSize: size * 0.5),
      );
    }
    return Text(
      _initials(displayName),
      style: GoogleFonts.plusJakartaSans(
        fontSize: size * 0.38,
        fontWeight: FontWeight.w800,
        color: textColor ?? Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppTheme.primaryIndigo;
    final hasLocal = localPath != null && localPath!.isNotEmpty && File(localPath!).existsSync();
    final hasUrl = avatarUrl != null && avatarUrl!.isNotEmpty;

    Widget content;
    if (hasLocal) {
      content = Image.file(
        File(localPath!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Center(child: _buildFallback()),
      );
    } else if (hasUrl) {
      content = Image.network(
        avatarUrl!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => Center(child: _buildFallback()),
      );
    } else {
      content = Center(child: _buildFallback());
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: borderWidth > 0 && borderColor != null
            ? Border.all(color: borderColor!, width: borderWidth)
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: content,
    );
  }
}
