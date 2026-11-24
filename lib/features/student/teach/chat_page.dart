import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/buddy_avatar.dart';
import '../../../core/widgets/chat_bubble.dart';
import '../../../core/widgets/clay_widgets.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  static const int _maxChars = 800;

  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  LearningSession? _session;
  List<ChatMessage> _messages = [];
  bool _loading = true;
  bool _sending = false;
  String? _loadError;
  String? _sendError;

  // Quick prompt chips
  final List<String> _quickPrompts = [
    'Bayangkan piring kotor yang terakhir dicuci ditaruh paling atas, piring mana yang diambil duluan?',
    'Kalau tumpukannya kosong tapi kita paksa ambil data, itu namanya apa Bud?',
    'Betul! Coba analogikan juga dengan tombol Back di browser internet!',
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final repo = ref.read(sessionRepositoryProvider);
      final results = await Future.wait([
        repo.getSession(widget.sessionId),
        repo.getMessages(widget.sessionId),
      ]);
      if (!mounted) return;
      setState(() {
        _session = results[0] as LearningSession;
        _messages = results[1] as List<ChatMessage>;
        _loading = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _loading = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage([String? quickText]) async {
    final text = quickText ?? _inputCtrl.text.trim();
    final session = _session;
    if (text.isEmpty ||
        session == null ||
        _sending ||
        session.status != SessionStatus.active) {
      return;
    }

    setState(() {
      _sending = true;
      _sendError = null;
    });

    try {
      final result = await ref.read(chatRepositoryProvider).sendTurn(
            sessionId: widget.sessionId,
            studentMessage: text,
          );
      if (!mounted) return;

      _inputCtrl.clear();
      final now = DateTime.now();
      final updated = [
        ..._messages,
        ChatMessage(
          id: 'local-s-${now.microsecondsSinceEpoch}',
          sessionId: widget.sessionId,
          role: 'student',
          content: text,
          createdAt: now,
        ),
        ChatMessage(
          id: 'local-b-${now.microsecondsSinceEpoch}',
          sessionId: widget.sessionId,
          role: 'buddy',
          content: result.buddyReply,
          createdAt: now,
        ),
        if (result.nextBuddyIntro != null && result.nextBuddyIntro!.isNotEmpty)
          ChatMessage(
            id: 'local-n-${now.microsecondsSinceEpoch}',
            sessionId: widget.sessionId,
            role: 'buddy',
            content: result.nextBuddyIntro!,
            createdAt: now,
          ),
      ];

      setState(() {
        _messages = updated;
        _session = LearningSession(
          id: session.id,
          studentId: session.studentId,
          topicId: session.topicId,
          activeMisconceptionId: result.activeMisconceptionId,
          language: session.language,
          status: result.sessionStatus,
          meterPercent: result.meterPercent,
          studentInputs: result.inputsUsed,
          startedAt: session.startedAt,
          endedAt: result.sessionStatus == SessionStatus.active ? null : now,
          topicTitleId: session.topicTitleId,
          topicTitleEn: session.topicTitleEn,
        );
        _sending = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _sendError = 'Gagal menghubungi Buddy. Coba lagi dalam beberapa saat.';
      });
    }
  }

  Future<void> _confirmEndSession() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: AppTheme.clayBorder, width: 2),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryIndigoLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.assignment_turned_in_rounded, color: AppTheme.primaryIndigo),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Akhiri Sesi Belajar?',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Apakah Anda yakin ingin menyelesaikan sesi mengajar ini?',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sistem akan menyusun Rekap Capaian & Evaluasi Pemahaman berdasarkan konsep yang telah Anda ajarkan kepada Buddy.',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppTheme.textSecondary,
                height: 1.45,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Lanjutkan Belajar',
              style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          ClayButton(
            text: 'Akhiri & Lihat Rekap',
            height: 44,
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    await ref.read(sessionRepositoryProvider).endSession(widget.sessionId);
    if (!mounted) return;
    context.pushReplacement('/student/recap/${widget.sessionId}');
  }

  void _showRubricCriteriaModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.checklist_rounded, color: AppTheme.primaryIndigo, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      'Rubrik Penilaian AI Buddy',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Ajarkan dan jelaskan poin-poin berikut agar Buddy paham sepenuhnya:',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            _buildRubricItem('Prinsip LIFO (Last In, First Out)'),
            _buildRubricItem('Operasi PUSH (Menambahkan data ke posisi Top)'),
            _buildRubricItem('Operasi POP (Mengambil data dari posisi Top)'),
            _buildRubricItem('Operasi PEEK / TOP (Melihat elemen puncak)'),
            _buildRubricItem('Kondisi Stack Underflow & Overflow'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRubricItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: AppTheme.primaryIndigo, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppTheme.clayCanvas,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null || _session == null) {
      return Scaffold(
        backgroundColor: AppTheme.clayCanvas,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _loadError ?? 'Sesi belajar tidak ditemukan',
                  style: GoogleFonts.plusJakartaSans(color: AppTheme.dangerRed),
                ),
                const SizedBox(height: 12),
                ClayButton(text: 'Coba Lagi', onPressed: _load),
              ],
            ),
          ),
        ),
      );
    }

    final session = _session!;
    final isActive = session.status == SessionStatus.active;
    final int meter = session.meterPercent;

    return Scaffold(
      backgroundColor: AppTheme.clayCanvas,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Row(
          children: [
            BuddyAvatar(mood: BuddyMood.fromMeter(meter), size: 36),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Buddy (Murid AI)',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    '${session.localizedTopicTitle('id')} · $meter% Paham',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: meter >= 80 ? AppTheme.successGreen : AppTheme.primaryIndigo,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.checklist_rounded, color: AppTheme.primaryIndigo),
            tooltip: 'Lihat Kriteria Penilaian',
            onPressed: _showRubricCriteriaModal,
          ),
          if (isActive)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton(
                onPressed: _confirmEndSession,
                child: Text(
                  'Selesai',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    color: AppTheme.accentOrange,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Meter progress bar pinned under AppBar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tingkat Pemahaman Buddy',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    Text(
                      '$meter%',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: meter >= 80 ? AppTheme.successGreen : AppTheme.primaryIndigo,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClayProgressBar(
                  progress: meter / 100.0,
                  height: 6,
                  barColor: meter >= 80 ? AppTheme.successGreen : AppTheme.primaryIndigo,
                ),
              ],
            ),
          ),

          // Message history list
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return ChatBubble(message: msg);
              },
            ),
          ),

          // Sending Indicator
          if (_sending)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2)),
                  const SizedBox(width: 8),
                  Text(
                    'Buddy sedang mengetik & mencerna penjelasanmu...',
                    style: GoogleFonts.plusJakartaSans(fontSize: 12, color: AppTheme.textMuted),
                  ),
                ],
              ),
            ),

          if (_sendError != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: AppTheme.dangerRedLight,
              child: Text(
                _sendError!,
                style: GoogleFonts.plusJakartaSans(color: AppTheme.dangerRed, fontSize: 12),
              ),
            ),

          // Quick prompt chips
          if (isActive && !_sending)
            Container(
              height: 40,
              margin: const EdgeInsets.only(bottom: 6),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _quickPrompts.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final prompt = _quickPrompts[idx];
                  return GestureDetector(
                    onTap: () => _sendMessage(prompt),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.clayBorder, width: 1.2),
                      ),
                      child: Text(
                        prompt,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryIndigo,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

          // Chat Input Area
          if (isActive)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppTheme.clayBorder, width: 1.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.clayCanvas,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppTheme.clayBorder, width: 1.5),
                      ),
                      child: TextField(
                        controller: _inputCtrl,
                        maxLength: _maxChars,
                        decoration: const InputDecoration(
                          hintText: 'Jelaskan konsep kepada Buddy...',
                          border: InputOrigin.none,
                          enabledBorder: InputOrigin.none,
                          focusedBorder: InputOrigin.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                          counterText: '',
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: _sending ? null : () => _sendMessage(),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryIndigo,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryIndigo.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: ClayButton(
                text: 'Lihat Rekap Sesi Ini',
                onPressed: () => context.pushReplacement('/student/recap/${widget.sessionId}'),
              ),
            ),
        ],
      ),
    );
  }
}

class InputOrigin {
  static const none = InputBorder.none;
}
