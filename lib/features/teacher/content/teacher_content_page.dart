import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';

class TeacherContentPage extends ConsumerStatefulWidget {
  const TeacherContentPage({super.key, this.initialCourseId});
  final String? initialCourseId;

  @override
  ConsumerState<TeacherContentPage> createState() => _TeacherContentPageState();
}

class _TeacherContentPageState extends ConsumerState<TeacherContentPage> {
  late Future<(List<Course>, List<TeacherTopic>)> _future;
  String? _selectedCourseId;
  String? _translatingMiscId;

  @override
  void initState() {
    super.initState();
    _selectedCourseId = widget.initialCourseId;
    _future = _load();
  }

  Future<(List<Course>, List<TeacherTopic>)> _load() async {
    final repo = ref.read(teacherRepositoryProvider);
    final myCourseId = ref.read(currentProfileProvider).value?.courseId;
    final courses = await repo.getCourses();
    if (myCourseId != null) {
      _selectedCourseId = myCourseId;
    } else if (_selectedCourseId == null && courses.isNotEmpty) {
      _selectedCourseId = courses.first.id;
    }
    final topics = await repo.getAllContent(courseId: _selectedCourseId);
    return (courses, topics);
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<void> _showTopicDialog({TeacherTopic? existing}) async {
    final l10n = context.l10n;
    final titleIdCtrl = TextEditingController(text: existing?.titleId ?? '');
    final titleEnCtrl = TextEditingController(text: existing?.titleEn ?? '');
    final descIdCtrl =
        TextEditingController(text: existing?.descriptionId ?? '');
    final descEnCtrl =
        TextEditingController(text: existing?.descriptionEn ?? '');
    final orderCtrl = TextEditingController(
      text: (existing?.sortOrder ?? 1).toString(),
    );
    bool isActive = existing?.isActive ?? true;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(existing == null ? l10n.addTopic : l10n.edit),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleIdCtrl,
                  decoration: InputDecoration(labelText: l10n.titleIdLabel),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: titleEnCtrl,
                  decoration: InputDecoration(labelText: l10n.titleEnLabel),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descIdCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(labelText: l10n.descIdLabel),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: descEnCtrl,
                  maxLines: 2,
                  decoration: InputDecoration(labelText: l10n.descEnLabel),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: orderCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: l10n.sortOrderLabel),
                ),
                SwitchListTile(
                  value: isActive,
                  title: Text(l10n.activeLabel),
                  onChanged: (v) => setDialogState(() => isActive = v),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleIdCtrl.text.trim().isEmpty ||
                    titleEnCtrl.text.trim().isEmpty) {
                  return;
                }
                await ref.read(teacherRepositoryProvider).saveTopic(
                      id: existing?.id,
                      courseId: existing?.courseId ?? _selectedCourseId,
                      titleId: titleIdCtrl.text,
                      titleEn: titleEnCtrl.text,
                      descriptionId: descIdCtrl.text,
                      descriptionEn: descEnCtrl.text,
                      sortOrder: int.tryParse(orderCtrl.text) ?? 1,
                      isActive: isActive,
                    );
                if (ctx.mounted) Navigator.pop(ctx, true);
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      ),
    );

    if (saved == true) _reload();
  }

  Future<void> _showMisconceptionDialog({
    required String topicId,
    TeacherMisconception? existing,
  }) async {
    final l10n = context.l10n;
    final miscCtrl =
        TextEditingController(text: existing?.misconceptionText ?? '');
    final correctCtrl =
        TextEditingController(text: existing?.correctConcept ?? '');
    final introCtrl = TextEditingController(text: existing?.buddyIntro ?? '');
    final orderCtrl =
        TextEditingController(text: (existing?.sortOrder ?? 1).toString());

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? l10n.addMisconception : l10n.edit),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: miscCtrl,
                maxLines: 2,
                decoration:
                    InputDecoration(labelText: l10n.misconceptionTextLabel),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: correctCtrl,
                maxLines: 2,
                decoration:
                    InputDecoration(labelText: l10n.correctConceptLabel),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: introCtrl,
                maxLines: 3,
                decoration: InputDecoration(labelText: l10n.buddyIntroLabel),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: orderCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.sortOrderLabel),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (miscCtrl.text.trim().isEmpty ||
                  correctCtrl.text.trim().isEmpty ||
                  introCtrl.text.trim().isEmpty) {
                return;
              }
              await ref.read(teacherRepositoryProvider).saveMisconception(
                    id: existing?.id,
                    topicId: topicId,
                    misconceptionText: miscCtrl.text,
                    correctConcept: correctCtrl.text,
                    buddyIntro: introCtrl.text,
                    sortOrder: int.tryParse(orderCtrl.text) ?? 1,
                  );
              if (ctx.mounted) Navigator.pop(ctx, true);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (saved == true) _reload();
  }

  Future<void> _showCriterionDialog({
    required String misconceptionId,
    TeacherCriterion? existing,
  }) async {
    final l10n = context.l10n;
    final textCtrl =
        TextEditingController(text: existing?.criterionText ?? '');
    final orderCtrl =
        TextEditingController(text: (existing?.sortOrder ?? 1).toString());

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(existing == null ? l10n.addCriterion : l10n.edit),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textCtrl,
              maxLines: 2,
              decoration: InputDecoration(labelText: l10n.criterionTextLabel),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: orderCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.sortOrderLabel),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              if (textCtrl.text.trim().isEmpty) return;
              await ref.read(teacherRepositoryProvider).saveCriterion(
                    id: existing?.id,
                    misconceptionId: misconceptionId,
                    criterionText: textCtrl.text,
                    sortOrder: int.tryParse(orderCtrl.text) ?? 1,
                  );
              if (ctx.mounted) Navigator.pop(ctx, true);
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );

    if (saved == true) _reload();
  }

  Future<void> _translateAndReview(TeacherMisconception misc) async {
    final l10n = context.l10n;
    setState(() => _translatingMiscId = misc.id);

    try {
      final data =
          await ref.read(teacherRepositoryProvider).translateMisconception(misc);
      if (!mounted) return;

      final miscEnCtrl = TextEditingController(
        text: (data['misconception_text_en'] as String?) ?? '',
      );
      final correctEnCtrl = TextEditingController(
        text: (data['correct_concept_en'] as String?) ?? '',
      );
      final introEnCtrl = TextEditingController(
        text: (data['buddy_intro_en'] as String?) ?? '',
      );

      final translatedCriteria = (data['criteria_en'] as List? ?? const []);
      final critCtrls = <String, TextEditingController>{};
      for (var i = 0; i < misc.criteria.length; i++) {
        final c = misc.criteria[i];
        String? found;
        for (final item in translatedCriteria) {
          if (item is Map && item['id'] == c.id) {
            found = item['criterion_text_en'] as String?;
            break;
          }
        }
        if (found == null && i < translatedCriteria.length) {
          final item = translatedCriteria[i];
          if (item is Map) found = item['criterion_text_en'] as String?;
        }
        critCtrls[c.id] = TextEditingController(text: found ?? '');
      }

      final saved = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.reviewTranslationTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: miscEnCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Misconception (EN)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: correctEnCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Correct Concept (EN)',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: introEnCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Buddy Opening Line (EN)',
                  ),
                ),
                const SizedBox(height: 12),
                ...misc.criteria.asMap().entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: TextField(
                      controller: critCtrls[entry.value.id],
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Criterion ${entry.key + 1} (EN)',
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                await ref.read(teacherRepositoryProvider).saveMisconceptionEn(
                      misconceptionId: misc.id,
                      misconceptionTextEn: miscEnCtrl.text,
                      correctConceptEn: correctEnCtrl.text,
                      buddyIntroEn: introEnCtrl.text,
                      criteriaEn: misc.criteria
                          .map((c) => (
                                id: c.id,
                                textEn: critCtrls[c.id]!.text,
                              ))
                          .toList(),
                    );
                if (ctx.mounted) Navigator.pop(ctx, true);
              },
              child: Text(l10n.save),
            ),
          ],
        ),
      );

      if (saved == true) _reload();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => _translatingMiscId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.contentManagementTitle),
        actions: [
          IconButton(
            tooltip: l10n.addTopic,
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => _showTopicDialog(),
          ),
        ],
      ),
      body: FutureBuilder<(List<Course>, List<TeacherTopic>)>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final courses = snapshot.data?.$1 ?? const [];
          final topics = snapshot.data?.$2 ?? const [];

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Assigned Course Banner (Locked to teacher's subject)
              if (courses.isNotEmpty) ...[
                Builder(builder: (context) {
                  final assigned = courses
                      .where((c) => c.id == _selectedCourseId)
                      .firstOrNull;
                  if (assigned == null) return const SizedBox.shrink();
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryIndigoLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.clayBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.menu_book_rounded,
                            color: AppTheme.primaryIndigo, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Mata Pelajaran: ${assigned.titleId}',
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),
              ],

              if (topics.isEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(
                            Icons.layers_clear_outlined,
                            size: 40,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Belum ada topik pada mata pelajaran ini.\nTekan tombol + di atas untuk menambahkan topik baru.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ...topics.map((topic) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ExpansionTile(
                      title: Text(
                        '${topic.sortOrder}. ${topic.titleId}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      subtitle: Row(
                    children: [
                      Text(
                        topic.isActive ? l10n.activeLabel : l10n.inactiveLabel,
                        style: TextStyle(
                          color: topic.isActive
                              ? AppTheme.successGreen
                              : const Color(0xFF64748B),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        topic.enReady
                            ? l10n.enReadyBadge
                            : l10n.enMissingBadge,
                        style: TextStyle(
                          color: topic.enReady
                              ? AppTheme.primaryTeal
                              : AppTheme.warningOrange,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: topic.isActive,
                        onChanged: (v) async {
                          await ref
                              .read(teacherRepositoryProvider)
                              .toggleTopicActive(topic.id, v);
                          _reload();
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showTopicDialog(existing: topic),
                      ),
                    ],
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                  children: [
                    if (topic.hasSessions)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          l10n.topicCannotDeleteNote,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      )
                    else
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () async {
                            await ref
                                .read(teacherRepositoryProvider)
                                .deleteTopicIfUnused(topic.id);
                            _reload();
                          },
                          icon: const Icon(
                            Icons.delete_outline,
                            color: AppTheme.dangerRed,
                          ),
                          label: Text(
                            l10n.delete,
                            style: const TextStyle(color: AppTheme.dangerRed),
                          ),
                        ),
                      ),
                    ...topic.misconceptions.map(
                      (m) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    '${m.sortOrder}. ${m.misconceptionText}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 19),
                                  onPressed: () => _showMisconceptionDialog(
                                    topicId: topic.id,
                                    existing: m,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 19,
                                    color: AppTheme.dangerRed,
                                  ),
                                  onPressed: () async {
                                    await ref
                                        .read(teacherRepositoryProvider)
                                        .deleteMisconception(m.id);
                                    _reload();
                                  },
                                ),
                              ],
                            ),
                            ...m.criteria.map(
                              (c) => Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.subdirectory_arrow_right,
                                      size: 16,
                                      color: Color(0xFF64748B),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        c.criterionText,
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 16),
                                      onPressed: () => _showCriterionDialog(
                                        misconceptionId: m.id,
                                        existing: c,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        size: 16,
                                        color: AppTheme.dangerRed,
                                      ),
                                      onPressed: () async {
                                        await ref
                                            .read(teacherRepositoryProvider)
                                            .deleteCriterion(c.id);
                                        _reload();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              children: [
                                OutlinedButton.icon(
                                  onPressed: () =>
                                      _showCriterionDialog(misconceptionId: m.id),
                                  icon: const Icon(Icons.add, size: 16),
                                  label: Text(l10n.addCriterion),
                                ),
                                ElevatedButton.icon(
                                  onPressed: _translatingMiscId == m.id
                                      ? null
                                      : () => _translateAndReview(m),
                                  icon: const Icon(Icons.translate, size: 16),
                                  label: Text(
                                    _translatingMiscId == m.id
                                        ? l10n.translating
                                        : l10n.translateToEnglish,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _showMisconceptionDialog(topicId: topic.id),
                        icon: const Icon(Icons.add),
                        label: Text(l10n.addMisconception),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final encodedTitle = Uri.encodeComponent(topic.titleId);
                          context.push(
                            '/teacher/content/${topic.id}/questions?title=$encodedTitle',
                          );
                        },
                        icon: const Icon(Icons.quiz_outlined),
                        label: const Text('Kelola Soal Pre/Post-Test'),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        );
      },
    ),
  );
}
}
