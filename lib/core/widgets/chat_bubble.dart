import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.message,
  });

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isStudent = message.isStudent;

    return Align(
      alignment: isStudent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.82,
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isStudent ? AppTheme.primaryIndigo : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(20),
              topRight: const Radius.circular(20),
              bottomLeft: Radius.circular(isStudent ? 20 : 6),
              bottomRight: Radius.circular(isStudent ? 6 : 20),
            ),
            border: Border.all(
              color: isStudent ? const Color(0xFF3730A3) : AppTheme.clayBorder,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isStudent
                    ? AppTheme.primaryIndigo.withValues(alpha: 0.25)
                    : const Color(0xFF1E1B4B).withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: isStudent
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              // Role Badge
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isStudent) ...[
                    const Text('🤖 ', style: TextStyle(fontSize: 12)),
                  ],
                  Text(
                    isStudent ? 'KAMU (PENGAJAR)' : 'BUDDY (MURID AI)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: isStudent
                          ? const Color(0xFFC7D2FE)
                          : AppTheme.primaryIndigo,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                message.content,
                style: GoogleFonts.plusJakartaSans(
                  color: isStudent ? Colors.white : AppTheme.textPrimary,
                  fontSize: 14,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
