import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';

class TeacherQuestionsPage extends ConsumerStatefulWidget {
  const TeacherQuestionsPage({
    super.key,
    required this.topicId,
    this.topicTitle,
  });

  final String topicId;
  final String? topicTitle;

  @override
  ConsumerState<TeacherQuestionsPage> createState() =>
      _TeacherQuestionsPageState();
}

class _TeacherQuestionsPageState extends ConsumerState<TeacherQuestionsPage> {
  late Future<List<Question>> _future;
  String _selectedType = 'pre_test';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Question>> _load() {
    return ref.read(teacherRepositoryProvider).getTopicQuestions(widget.topicId);
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _showQuestionDialog({
    Question? existing,
    required int defaultSortOrder,
  }) async {
    String quizType = existing?.quizType ?? _selectedType;
    final questionCtrl =
        TextEditingController(text: existing?.questionText ?? '');
    final codeCtrl = TextEditingController(text: existing?.codeSnippet ?? '');
    final optACtrl = TextEditingController(
      text: existing != null && existing.options.isNotEmpty
          ? existing.options[0]
          : '',
    );
    final optBCtrl = TextEditingController(
      text: existing != null && existing.options.length > 1
          ? existing.options[1]
          : '',
    );
    final optCCtrl = TextEditingController(
      text: existing != null && existing.options.length > 2
          ? existing.options[2]
          : '',
    );
    final optDCtrl = TextEditingController(
      text: existing != null && existing.options.length > 3
          ? existing.options[3]
          : '',
    );
    final explanationCtrl =
        TextEditingController(text: existing?.explanation ?? '');
    final orderCtrl = TextEditingController(
      text: (existing?.sortOrder ?? defaultSortOrder).toString(),
    );
    int correctIndex = existing?.correctIndex ?? 0;
    bool isSaving = false;
    String? errorMsg;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? 'Tambah Soal' : 'Edit Soal'),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jenis Evaluasi',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(
                        value: 'pre_test',
                        label: Text('Pre-Test'),
                      ),
                      ButtonSegment(
                        value: 'post_test',
                        label: Text('Post-Test'),
                      ),
                    ],
                    selected: {quizType},
                    onSelectionChanged: isSaving
                        ? null
                        : (val) => setDialogState(() => quizType = val.first),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: questionCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Pertanyaan *',
                      hintText: 'Tulis pertanyaan pilihan ganda...',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: codeCtrl,
                    maxLines: 3,
                    style: GoogleFonts.jetBrainsMono(fontSize: 12.5),
                    decoration: const InputDecoration(
                      labelText: 'Potongan Kode (opsional)',
                      hintText: 'Contoh: stack.push(10)',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: optACtrl,
                    decoration: const InputDecoration(labelText: 'Pilihan A *'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: optBCtrl,
                    decoration: const InputDecoration(labelText: 'Pilihan B *'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: optCCtrl,
                    decoration: const InputDecoration(labelText: 'Pilihan C *'),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: optDCtrl,
                    decoration: const InputDecoration(labelText: 'Pilihan D *'),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Jawaban Benar',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    children: List.generate(4, (idx) {
                      final letter = ['A', 'B', 'C', 'D'][idx];
                      final selected = correctIndex == idx;
                      return ChoiceChip(
                        label: Text(
                          letter,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: selected ? Colors.white : AppTheme.textPrimary,
                          ),
                        ),
                        selected: selected,
                        selectedColor: AppTheme.successGreen,
                        onSelected: isSaving
                            ? null
                            : (_) => setDialogState(() => correctIndex = idx),
                      );
                    }),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: explanationCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Pembahasan (opsional)',
                      hintText: 'Penjelasan mengapa jawaban tersebut benar',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: orderCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Urutan Soal',
                    ),
                  ),
                  if (errorMsg != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      errorMsg!,
                      style: const TextStyle(
                        color: AppTheme.dangerRed,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(ctx, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: isSaving
                  ? null
                  : () async {
                      if (questionCtrl.text.trim().isEmpty ||
                          optACtrl.text.trim().isEmpty ||
                          optBCtrl.text.trim().isEmpty ||
                          optCCtrl.text.trim().isEmpty ||
                          optDCtrl.text.trim().isEmpty) {
                        setDialogState(() {
                          errorMsg =
                              'Pertanyaan dan seluruh pilihan A–D wajib diisi.';
                        });
                        return;
                      }
                      setDialogState(() {
                        isSaving = true;
                        errorMsg = null;
                      });
                      try {
                        final repo = ref.read(teacherRepositoryProvider);
                        final options = [
                          optACtrl.text,
                          optBCtrl.text,
                          optCCtrl.text,
                          optDCtrl.text,
                        ];
                        final sortOrder = int.tryParse(orderCtrl.text) ?? 1;

                        if (existing == null) {
                          await repo.createQuestion(
                            topicId: widget.topicId,
                            quizType: quizType,
                            questionText: questionCtrl.text,
                            codeSnippet: codeCtrl.text,
                            options: options,
                            correctIndex: correctIndex,
                            explanation: explanationCtrl.text,
                            sortOrder: sortOrder,
                          );
                        } else {
                          await repo.updateQuestion(
                            id: existing.id,
                            quizType: quizType,
                            questionText: questionCtrl.text,
                            codeSnippet: codeCtrl.text,
                            options: options,
                            correctIndex: correctIndex,
                            explanation: explanationCtrl.text,
                            sortOrder: sortOrder,
                          );
                        }
                        if (ctx.mounted) Navigator.pop(ctx, true);
                      } catch (e) {
                        setDialogState(() {
                          isSaving = false;
                          errorMsg = 'Gagal menyimpan soal: $e';
                        });
                      }
                    },
              child: Text(isSaving ? 'Menyimpan...' : 'Simpan'),
            ),
          ],
        ),
      ),
    );

    if (saved == true) {
      if (mounted) {
        setState(() => _selectedType = quizType);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              existing == null
                  ? 'Soal berhasil ditambahkan'
                  : 'Soal berhasil diperbarui',
            ),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
      _reload();
    }
  }

  Future<void> _confirmDelete(Question q) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Soal?'),
        content: Text(
          'Yakin ingin menghapus soal ini?\n\n"${q.questionText}"',
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    try {
      await ref.read(teacherRepositoryProvider).deleteQuestion(q.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Soal berhasil dihapus')),
        );
      }
      _reload();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus soal: $e'),
            backgroundColor: AppTheme.dangerRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kelola Soal Pre/Post-Test'),
            if (widget.topicTitle != null && widget.topicTitle!.isNotEmpty)
              Text(
                widget.topicTitle!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
          ],
        ),
      ),
      body: FutureBuilder<List<Question>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Gagal memuat soal: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.dangerRed),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _reload,
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final allQuestions = snapshot.data ?? const [];
          final preQuestions =
              allQuestions.where((q) => q.quizType == 'pre_test').toList();
          final postQuestions =
              allQuestions.where((q) => q.quizType == 'post_test').toList();
          final activeList =
              _selectedType == 'pre_test' ? preQuestions : postQuestions;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: _TypeTabButton(
                        label: 'Pre-Test (${preQuestions.length})',
                        selected: _selectedType == 'pre_test',
                        onTap: () => setState(() => _selectedType = 'pre_test'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _TypeTabButton(
                        label: 'Post-Test (${postQuestions.length})',
                        selected: _selectedType == 'post_test',
                        onTap: () => setState(() => _selectedType = 'post_test'),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: activeList.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.quiz_outlined,
                                size: 48,
                                color: AppTheme.textMuted,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _selectedType == 'pre_test'
                                    ? 'Belum ada soal Pre-Test untuk topik ini.'
                                    : 'Belum ada soal Post-Test untuk topik ini.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 14),
                              ElevatedButton.icon(
                                onPressed: () => _showQuestionDialog(
                                  defaultSortOrder: activeList.length + 1,
                                ),
                                icon: const Icon(Icons.add),
                                label: const Text('Tambah Soal Pertama'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                        itemCount: activeList.length,
                        itemBuilder: (context, index) {
                          final q = activeList[index];
                          return _QuestionCard(
                            question: q,
                            displayIndex: index + 1,
                            onEdit: () => _showQuestionDialog(
                              existing: q,
                              defaultSortOrder: q.sortOrder,
                            ),
                            onDelete: () => _confirmDelete(q),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FutureBuilder<List<Question>>(
        future: _future,
        builder: (context, snapshot) {
          final currentCount = (snapshot.data ?? const [])
              .where((q) => q.quizType == _selectedType)
              .length;
          return FloatingActionButton.extended(
            onPressed: () =>
                _showQuestionDialog(defaultSortOrder: currentCount + 1),
            backgroundColor: AppTheme.primaryIndigo,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text(
              'Tambah Soal',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          );
        },
      ),
    );
  }
}

class _TypeTabButton extends StatelessWidget {
  const _TypeTabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryIndigo : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppTheme.primaryIndigo : AppTheme.clayBorder,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: selected ? Colors.white : AppTheme.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.question,
    required this.displayIndex,
    required this.onEdit,
    required this.onDelete,
  });

  final Question question;
  final int displayIndex;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryIndigoLight,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Soal #$displayIndex (Urutan ${question.sortOrder})',
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryIndigo,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  tooltip: 'Edit soal',
                  onPressed: onEdit,
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: AppTheme.dangerRed,
                  ),
                  tooltip: 'Hapus soal',
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              question.questionText,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14.5,
                color: AppTheme.textPrimary,
              ),
            ),
            if (question.codeSnippet != null &&
                question.codeSnippet!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  question.codeSnippet!,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 12,
                    color: const Color(0xFFE2E8F0),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 10),
            ...List.generate(question.options.length, (idx) {
              final letter = ['A', 'B', 'C', 'D'][idx];
              final isCorrect = idx == question.correctIndex;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isCorrect
                      ? AppTheme.successGreenLight
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isCorrect
                        ? AppTheme.successGreen
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      '$letter.',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: isCorrect
                            ? AppTheme.successGreen
                            : AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        question.options[idx],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isCorrect ? FontWeight.w700 : FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    if (isCorrect)
                      const Icon(
                        Icons.check_circle,
                        size: 16,
                        color: AppTheme.successGreen,
                      ),
                  ],
                ),
              );
            }),
            if (question.explanation != null &&
                question.explanation!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryIndigoLight.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Pembahasan: ${question.explanation!}',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
