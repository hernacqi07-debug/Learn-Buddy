import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/buddy_avatar.dart';
import '../../../core/widgets/chat_bubble.dart';
import '../../../core/widgets/meter_paham_bar.dart';

class ChatPage extends ConsumerStatefulWidget {
  const ChatPage({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  static const int _maxChars = 800;
  static const int _maxInputs = 20;

  final _inputCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  LearningSession? _session;
  List<ChatMessage> _messages = [];
  bool _loading = true;
  bool _sending = false;
  String? _loadError;
  String? _sendError;

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

  Future<void> _sendMessage() async {
    final text = _inputCtrl.text.trim();
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
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _sending = false;
        _sendError = context.l10n.buddyTimeoutError;
      });
    }
  }

  Future<void> _confirmEndSession() async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.endSessionConfirmTitle),
        content: Text(l10n.endSessionConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    await ref.read(sessionRepositoryProvider).endSession(widget.sessionId);
    if (!mounted) return;
    context.pushReplacement('/student/recap/${widget.sessionId}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final appLang = ref.watch(languageProvider).languageCode;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.appTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null || _session == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.appTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_loadError ?? 'Session not found'),
                const SizedBox(height: 12),
                ElevatedButton(onPressed: _load, child: Text(l10n.retry)),
              ],
            ),
          ),
        ),
      );
    }

    final session = _session!;
    final isActive = session.status == SessionStatus.active;

    return Scaffold(
      appBar: AppBar(
        title: Text(session.localizedTopicTitle(appLang)),
        actions: [
          if (isActive)
            TextButton(
              onPressed: _sending ? null : _confirmEndSession,
              child: Text(l10n.endSessionButton),
            )
          else
            TextButton(
              onPressed: () =>
                  context.pushReplacement('/student/recap/${session.id}'),
              child: Text(l10n.viewRecap),
            ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Row(
              children: [
                BuddyAvatar(meterPercent: session.meterPercent, size: 54),
                const SizedBox(width: 12),
                Expanded(
                  child: MeterPahamBar(meterPercent: session.meterPercent),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              itemCount: _messages.length + (_sending ? 1 : 0),
              itemBuilder: (context, index) {
                if (_sending && index == _messages.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFD7E5EC)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.buddyThinking,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return ChatBubble(message: _messages[index]);
              },
            ),
          ),
          if (_sendError != null)
            Container(
              width: double.infinity,
              color: AppTheme.warningOrange.withValues(alpha: 0.12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                _sendError!,
                style: const TextStyle(
                  color: AppTheme.warningOrange,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (!isActive)
            SafeArea(
              top: false,
              child: Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.sessionCompletedBanner,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () =>
                            context.pushReplacement('/student/recap/${session.id}'),
                        child: Text(l10n.viewRecap),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SafeArea(
              top: false,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.inputCounter(session.studentInputs, _maxInputs),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF475569),
                          ),
                        ),
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _inputCtrl,
                          builder: (context, val, _) => Text(
                            '${val.text.length}/$_maxChars',
                            style: TextStyle(
                              fontSize: 12,
                              color: val.text.length >= _maxChars
                                  ? AppTheme.dangerRed
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _inputCtrl,
                            enabled: !_sending,
                            maxLength: _maxChars,
                            minLines: 1,
                            maxLines: 4,
                            decoration: InputDecoration(
                              hintText: l10n.messageHint,
                              counterText: '',
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _sending ? null : _sendMessage,
                          style: IconButton.styleFrom(
                            backgroundColor: AppTheme.primaryTeal,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(48, 48),
                          ),
                          icon: const Icon(Icons.send_rounded),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
