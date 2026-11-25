import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/clay_widgets.dart';
import '../../../core/widgets/student_bottom_nav.dart';

class MateriPage extends ConsumerStatefulWidget {
  const MateriPage({super.key, required this.topicId});
  final String topicId;

  @override
  ConsumerState<MateriPage> createState() => _MateriPageState();
}

class _MateriPageState extends ConsumerState<MateriPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<TopicSummary?> _futureTopic;
  bool _isStartingSession = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTopic();
  }

  void _loadTopic() {
    final repo = ref.read(sessionRepositoryProvider);
    _futureTopic = repo.getTopicDetail(widget.topicId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _startSession(TopicSummary topic) async {
    setState(() => _isStartingSession = true);
    final appLang = ref.read(languageProvider).languageCode;
    final sessionLang = (appLang == 'en' && topic.enReady) ? 'en' : 'id';
    try {
      final repo = ref.read(sessionRepositoryProvider);
      final session = await repo.startSession(
        topicId: topic.id,
        language: sessionLang,
      );
      if (mounted) {
        context.push('/student/teach/${session.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.startSessionFailed(e.toString())),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isStartingSession = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = ref.watch(languageProvider).languageCode;
    final isEn = lang == 'en';

    return Scaffold(
      backgroundColor: AppTheme.clayCanvas,
      bottomNavigationBar: const StudentBottomNav(currentIndex: 1),
      appBar: AppBar(
        title: Text(
          l10n.studyModuleTitle,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.moduleLinkCopied)),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<TopicSummary?>(
        future: _futureTopic,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final topic = snapshot.data;
          if (topic == null) {
            return Center(
              child: Text(
                l10n.moduleNotFound,
                style: GoogleFonts.plusJakartaSans(
                  color: AppTheme.textSecondary,
                  fontSize: 15,
                ),
              ),
            );
          }

          return Column(
            children: [
              // Header Summary Card
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClayCard(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClayPill(
                            label: l10n.basicDataStructuresBadge,
                            color: AppTheme.primaryIndigoLight,
                            textColor: AppTheme.primaryIndigo,
                            icon: Icons.layers_rounded,
                          ),
                          const Spacer(),
                          ClayPill(
                            label: l10n.readingTimeMinutes(topic.readingTimeMinutes),
                            color: const Color(0xFFFEF3C7),
                            textColor: const Color(0xFFB45309),
                            icon: Icons.timer_outlined,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        topic.localizedTitle(lang),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        topic.localizedDesc(lang),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          color: AppTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Claymorphic Tab Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.clayBorder, width: 1.5),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppTheme.primaryIndigo,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryIndigo.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppTheme.textSecondary,
                    labelStyle: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                    tabs: [
                      Tab(text: l10n.tabBasicTheory),
                      Tab(text: l10n.tabRealAnalogy),
                      Tab(text: l10n.tabCodeExample),
                    ],
                  ),
                ),
              ),

              // Tab View Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Teori Dasar
                    _buildTheoryTab(topic, isEn),
                    // Tab 2: Analogi Riil
                    _buildAnalogyTab(topic, isEn),
                    // Tab 3: Contoh Kode
                    _buildCodeTab(topic, l10n.codeCopied),
                  ],
                ),
              ),

              // Bottom Action Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: AppTheme.clayBorder, width: 1.5),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ClayButton(
                        text: l10n.startTeachingBuddy,
                        icon: Icons.chat_bubble_rounded,
                        isLoading: _isStartingSession,
                        onPressed: () => _startSession(topic),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTheoryTab(TopicSummary topic, bool isEn) {
    final l10n = context.l10n;
    final defaultTheory = isEn
        ? 'A Stack is a linear data structure that follows the LIFO (Last In, First Out) principle. The element added most recently is the first one to be removed.'
        : 'Stack (Tumpukan) adalah struktur data linier yang mengikuti prinsip LIFO (Last In, First Out). Elemen yang paling terakhir ditambahkan akan menjadi elemen pertama yang dikeluarkan.';
    final theory = (!isEn && topic.theoryContent != null)
        ? topic.theoryContent!
        : defaultTheory;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ClayCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.menu_book_rounded, color: AppTheme.primaryIndigo, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    l10n.mainConceptTitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                theory,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ClayCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.checklist_rounded, color: AppTheme.successGreen, size: 22),
                  const SizedBox(width: 10),
                  Text(
                    l10n.coreOperationsTitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _buildOpItem(
                'PUSH(x)',
                isEn
                    ? 'Adds a new element to the top of the stack.'
                    : 'Menambahkan elemen baru ke posisi paling atas (top).',
                Icons.arrow_downward_rounded,
              ),
              const SizedBox(height: 10),
              _buildOpItem(
                'POP()',
                isEn
                    ? 'Removes and returns the element from the top of the stack.'
                    : 'Mengambil dan menghapus elemen dari posisi paling atas.',
                Icons.arrow_upward_rounded,
              ),
              const SizedBox(height: 10),
              _buildOpItem(
                'PEEK() / TOP()',
                isEn
                    ? 'Views the top element without removing it.'
                    : 'Melihat elemen teratas tanpa menghapusnya.',
                Icons.visibility_rounded,
              ),
              const SizedBox(height: 10),
              _buildOpItem(
                'isEmpty()',
                isEn
                    ? 'Checks whether the stack is currently empty.'
                    : 'Mengecek apakah tumpukan sedang kosong.',
                Icons.check_circle_outline_rounded,
              ),
              const SizedBox(height: 10),
              _buildOpItem(
                'isFull()',
                isEn
                    ? 'Checks whether the stack is full (capacity exceeded).'
                    : 'Mengecek kondisi tumpukan penuh (kapasitas terlampaui).',
                Icons.warning_amber_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOpItem(String title, String desc, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.clayCanvas,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.clayBorder, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.clayBorder, width: 1),
            ),
            child: Icon(icon, color: AppTheme.primaryIndigo, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: AppTheme.textSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalogyTab(TopicSummary topic, bool isEn) {
    final l10n = context.l10n;
    final defaultAnalogy = isEn
        ? 'Imagine a stack of clean plates at a cafeteria counter. The plate washed first and placed at the bottom will be the last one picked up (LIFO).'
        : 'Bayangkan tumpukan piring bersih di meja prasmanan kantin sekolah. Piring yang pertama kali dicuci dan ditaruh di bawah akan menjadi yang terakhir diambil (LIFO).';
    final analogy = (!isEn && topic.analogyContent != null)
        ? topic.analogyContent!
        : defaultAnalogy;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ClayCard(
          padding: const EdgeInsets.all(18),
          borderColor: const Color(0xFFFED7AA),
          color: const Color(0xFFFFF7ED),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.lightbulb_rounded, color: AppTheme.accentOrange, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    l10n.realWorldAnalogyTitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.accentOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                analogy,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ClayCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.realAppsExamplesTitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildOpItem(
                isEn ? 'Undo / Redo Feature (Ctrl+Z)' : 'Fitur Undo / Redo (Ctrl+Z)',
                isEn
                    ? 'Every keystroke is pushed to a Stack. Pressing Ctrl+Z pops the last operation.'
                    : 'Setiap ketikan disimpan ke Stack. Ketika Ctrl+Z ditekan, operasi terakhir di-POP.',
                Icons.undo_rounded,
              ),
              const SizedBox(height: 10),
              _buildOpItem(
                isEn ? 'Web Browser Back Button' : 'Tombol Back pada Web Browser',
                isEn
                    ? 'Visited URLs are stacked onto the browser navigation history.'
                    : 'Riwayat URL ditumpuk ke Stack history navigasi browser.',
                Icons.arrow_back_rounded,
              ),
              const SizedBox(height: 10),
              _buildOpItem(
                isEn ? 'Function Call Stack' : 'Call Stack Pemanggilan Fungsi',
                isEn
                    ? 'When a recursive function is called, memory addresses are stored in the system Call Stack.'
                    : 'Ketika fungsi rekursif dipanggil, alamat memori disimpan di Call Stack sistem.',
                Icons.call_split_rounded,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCodeTab(TopicSummary topic, String codeCopiedMsg) {
    final code = topic.codeSnippet ??
'''class Stack<T> {
  final List<T> _items = [];

  void push(T value) {
    _items.add(value);
  }

  T pop() {
    if (isEmpty) throw Exception("Stack Kosong (Underflow)!");
    return _items.removeLast();
  }

  T peek() {
    if (isEmpty) throw Exception("Stack Kosong!");
    return _items.last;
  }

  bool get isEmpty => _items.isEmpty;
  int get length => _items.length;
}''';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ClayCard(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF0F172A), // Dark code container for maximum syntax clarity
          borderColor: const Color(0xFF334155),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFFF59E0B), shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                      const SizedBox(width: 12),
                      Text(
                        'stack_implementation.dart',
                        style: GoogleFonts.jetBrainsMono(
                          color: const Color(0xFF94A3B8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, color: Color(0xFF94A3B8), size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(codeCopiedMsg)),
                      );
                    },
                  ),
                ],
              ),
              const Divider(color: Color(0xFF334155), height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Text(
                  code,
                  style: GoogleFonts.jetBrainsMono(
                    color: const Color(0xFFE2E8F0),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
