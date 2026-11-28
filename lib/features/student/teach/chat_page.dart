import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/l10n/l10n_ext.dart';
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

  List<String> _promptsForTopic(bool isEn) {
    final t = (_session?.topicTitleId ?? '').toLowerCase();
    if (t.contains('stack')) {
      return isEn
          ? const [
              'Imagine dirty plates washed last are placed on top — which plate gets picked first?',
              'If the stack is empty and we force taking data out, what is that called, Bud?',
              'Right! Now think of the Back button in an internet browser too!',
            ]
          : const [
              'Bayangkan piring kotor yang terakhir dicuci ditaruh paling atas, piring mana yang diambil duluan?',
              'Kalau tumpukannya kosong tapi kita paksa ambil data, itu namanya apa Bud?',
              'Betul! Coba analogikan juga dengan tombol Back di browser internet!',
            ];
    }
    if (t.contains('queue')) {
      return isEn
          ? const [
              'Queue follows FIFO: whoever arrives first at the front gets served first.',
              'Enqueue adds data at the rear, while dequeue removes data from the front.',
              'Think of a ticket counter line — can the last person leave first?',
            ]
          : const [
              'Queue memakai prinsip FIFO: siapa yang datang duluan di depan akan dilayani duluan.',
              'Enqueue menambah data di belakang (REAR), sedangkan dequeue mengambil data dari depan (FRONT).',
              'Bayangkan antrean kasir, apakah orang paling belakang bisa langsung dilayani duluan?',
            ];
    }
    if (t.contains('linked')) {
      return isEn
          ? const [
              'Each node in a Linked List stores data and a next pointer to the following node.',
              'HEAD points to the first node, and the last node points to null.',
              'Inserting at the front only updates pointers without shifting other elements!',
            ]
          : const [
              'Setiap node di Linked List menyimpan data dan pointer next ke node berikutnya.',
              'HEAD menunjuk node pertama, sedangkan node terakhir menunjuk ke null.',
              'Menyisipkan data di awal cukup mengubah pointer tanpa menggeser elemen lain!',
            ];
    }
    if (t.contains('class')) {
      return isEn
          ? const [
              'A Class is a blueprint, while an Object is a real instance created with new.',
              'One Class can create many Objects with different attribute values.',
              'Think of a house blueprint vs actual houses built from it!',
            ]
          : const [
              'Class itu cetak biru (blueprint), sedangkan Object adalah wujud nyata yang dibuat dengan new.',
              'Dari satu Class kita bisa membuat banyak Object dengan nilai atribut berbeda.',
              'Ibarat cetakan kue (Class) dan kue-kue nyata yang dihasilkan (Object)!',
            ];
    }
    if (t.contains('enkapsulasi')) {
      return isEn
          ? const [
              'Encapsulation hides internal fields with private so outside code cannot corrupt them.',
              'We use public Getter and Setter methods to validate changes safely.',
              'Just like an ATM: you cannot grab cash directly without PIN and balance checks!',
            ]
          : const [
              'Enkapsulasi menyembunyikan atribut pakai private agar tidak diubah sembarangan dari luar.',
              'Akses data dilakukan lewat Getter dan Setter public yang bisa diberi validasi.',
              'Seperti mesin ATM, saldo tidak bisa langsung diubah tanpa verifikasi aturan!',
            ];
    }
    if (t.contains('pewarisan')) {
      return isEn
          ? const [
              'Inheritance lets a subclass reuse attributes and methods from a superclass via extends.',
              'With @Override, a subclass can customize behavior inherited from its parent.',
              'Think of Vehicle as parent and Car/Motorcycle as children with their own traits!',
            ]
          : const [
              'Pewarisan (extends) membuat subclass mewarisi atribut dan method dari superclass.',
              'Dengan @Override, subclass bisa menyesuaikan perilaku method warisan induknya.',
              'Ibarat Hewan sebagai induk, lalu Kucing dan Anjing mewarisi dan punya suara masing-masing!',
            ];
    }
    if (t.contains('list') && t.contains('tuple')) {
      return isEn
          ? const [
              'List is mutable (can be modified/appended), while Tuple is immutable (fixed once created).',
              'Trying to modify a Tuple element raises a TypeError in Python.',
              'Use Tuple for constant data like GPS coordinates or fixed config!',
            ]
          : const [
              'List bersifat mutable (bisa diubah/ditambah), sedangkan Tuple immutable (tetap setelah dibuat).',
              'Jika kita mencoba mengubah elemen Tuple, Python akan memunculkan TypeError.',
              'Tuple cocok untuk data tetap seperti koordinat GPS atau konstanta konfigurasi!',
            ];
    }
    if (t.contains('dictionary')) {
      return isEn
          ? const [
              'Dictionary stores key-value pairs where every key must be unique.',
              'Looking up a value by key is super fast using hashing, unlike searching a list.',
              'Use .get(key, default) to avoid KeyError when a key does not exist!',
            ]
          : const [
              'Dictionary menyimpan pasangan key-value dan setiap key harus unik.',
              'Mencari nilai berdasarkan key sangat cepat tanpa perlu memeriksa indeks satu per satu.',
              'Gunakan .get(key, default) supaya aman dan tidak terkena KeyError!',
            ];
    }
    if (t.contains('perulangan')) {
      return isEn
          ? const [
              'Use for loops for known ranges/collections and while loops for condition-based repetition.',
              'A function (def) uses return to send a value back, whereas print only displays text.',
              'Make sure a while loop updates its condition so it does not loop forever!',
            ]
          : const [
              'Loop for dipakai untuk rentang/koleksi tertentu, sedangkan while berjalan selama kondisi True.',
              'Fungsi (def) memakai return untuk mengembalikan nilai, beda dengan print yang cuma menampilkan teks.',
              'Pastikan kondisi di while berubah agar tidak terjadi infinite loop!',
            ];
    }
    return isEn
        ? const [
            'Let me explain the core concept step by step!',
            'Here is a real-world analogy to make it easier to understand.',
            'Can you try summarizing what you learned so far, Buddy?',
          ]
        : const [
            'Aku jelaskan konsep utamanya pelan-pelan ya, Buddy!',
            'Bayangkan analogi di dunia nyata supaya lebih mudah dipahami.',
            'Coba ulangi dengan bahasamu sendiri, bagian mana yang masih bikin bingung?',
          ];
  }

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
        _sendError = context.l10n.buddyTimeoutError;
      });
    }
  }

  Future<void> _confirmEndSession() async {
    final l10n = context.l10n;
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
                l10n.endSessionModalTitle,
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
              l10n.endSessionModalQuestion,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.endSessionModalDesc,
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
              l10n.continueLearningBtn,
              style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
            ),
          ),
          ClayButton(
            text: l10n.endAndViewRecapBtn,
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
    final l10n = context.l10n;
    final recapFuture =
        ref.read(sessionRepositoryProvider).getSessionRecap(widget.sessionId);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: FutureBuilder<List<RecapMisconception>>(
            future: recapFuture,
            builder: (ctx, snap) {
              final items = snap.data ?? const <RecapMisconception>[];
              final isEn = ref.read(languageProvider).languageCode == 'en';

              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(
                              Icons.checklist_rounded,
                              color: AppTheme.primaryIndigo,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.rubricModalTitle,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AppTheme.textMuted,
                        ),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.rubricModalDesc,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (snap.connectionState == ConnectionState.waiting)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        isEn
                            ? 'No rubric criteria found for this session.'
                            : 'Belum ada kriteria penilaian untuk sesi ini.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(ctx).size.height * 0.45,
                      ),
                      child: ListView(
                        shrinkWrap: true,
                        children: items
                            .map(
                              (m) => _buildRubricItem(
                                '${isEn && m.titleEn != null && m.titleEn!.isNotEmpty ? m.titleEn! : m.titleId} (${m.fulfilledCriteria}/${m.totalCriteria})',
                                fulfilled: m.isResolved,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  const SizedBox(height: 12),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRubricItem(String text, {bool fulfilled = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            fulfilled
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: fulfilled ? AppTheme.successGreen : AppTheme.primaryIndigo,
            size: 18,
          ),
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
    final l10n = context.l10n;
    final lang = ref.watch(languageProvider).languageCode;
    final isEn = lang == 'en';

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
                  _loadError ?? l10n.sessionNotFound,
                  style: GoogleFonts.plusJakartaSans(color: AppTheme.dangerRed),
                ),
                const SizedBox(height: 12),
                ClayButton(text: l10n.retry, onPressed: _load),
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
                    l10n.buddyAiLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    '${session.localizedTopicTitle(lang)} · ${l10n.understoodBadge(meter)}',
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
            tooltip: l10n.viewCriteriaTooltip,
            onPressed: _showRubricCriteriaModal,
          ),
          if (isActive)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: TextButton(
                onPressed: _confirmEndSession,
                child: Text(
                  l10n.finishBtn,
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
                      l10n.buddyUnderstandingLabel,
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
                    l10n.buddyTypingHint,
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
            Builder(
              builder: (context) {
                final prompts = _promptsForTopic(isEn);
                return Container(
                  height: 40,
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: prompts.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final prompt = prompts[idx];
                      return GestureDetector(
                        onTap: () => _sendMessage(prompt),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppTheme.clayBorder,
                              width: 1.2,
                            ),
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
                );
              },
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
                        decoration: InputDecoration(
                          hintText: l10n.messageHint,
                          border: InputOrigin.none,
                          enabledBorder: InputOrigin.none,
                          focusedBorder: InputOrigin.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
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
                text: l10n.viewThisRecapBtn,
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
