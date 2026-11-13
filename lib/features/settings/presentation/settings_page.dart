import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _nameCtrl = TextEditingController();
  bool _savingName = false;
  bool _seeded = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveName() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _savingName = true);
    try {
      await ref.read(authRepositoryProvider).updateDisplayName(name);
      await ref.read(currentProfileProvider.notifier).refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.updateNameSuccess)),
      );
    } finally {
      if (mounted) setState(() => _savingName = false);
    }
  }

  Future<void> _deleteAllHistory() async {
    final l10n = context.l10n;
    final firstOk = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAllConfirm1Title),
        content: Text(l10n.deleteAllConfirm1Body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (firstOk != true || !mounted) return;

    final secondOk = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteAllConfirm2Title),
        content: Text(l10n.deleteAllConfirm2Body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (secondOk != true || !mounted) return;

    await ref.read(sessionRepositoryProvider).deleteAllMySessions();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.deleteAllSuccess)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = ref.watch(languageProvider);
    final profile = ref.watch(currentProfileProvider).value;

    if (profile != null && !_seeded) {
      _nameCtrl.text = profile.displayName;
      _seeded = true;
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appLanguageLabel,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SegmentedButton<String>(
                    segments: [
                      ButtonSegment(
                        value: 'id',
                        label: Text(l10n.indonesianLabel),
                      ),
                      ButtonSegment(
                        value: 'en',
                        label: Text(l10n.englishLabel),
                      ),
                    ],
                    selected: {locale.languageCode},
                    onSelectionChanged: (val) {
                      ref
                          .read(languageProvider.notifier)
                          .setLanguage(val.first);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (profile != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.profileSectionTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        labelText: l10n.displayNameLabel,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '${l10n.emailLabel}: ${profile.email}',
                      style: const TextStyle(color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.roleLabel}: ${profile.role == UserRole.teacher ? l10n.roleTeacher : l10n.roleStudent}',
                      style: const TextStyle(color: Color(0xFF475569)),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _savingName ? null : _saveName,
                      child: Text(l10n.save),
                    ),
                  ],
                ),
              ),
            ),
          if (profile?.role == UserRole.student) ...[
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.delete_forever_outlined,
                  color: AppTheme.dangerRed,
                ),
                title: Text(
                  l10n.deleteAllHistoryButton,
                  style: const TextStyle(
                    color: AppTheme.dangerRed,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                onTap: _deleteAllHistory,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.aboutTitle,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    l10n.aboutBody,
                    style: const TextStyle(color: Color(0xFF475569)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.privacyNotice,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 48),
              foregroundColor: AppTheme.dangerRed,
              side: const BorderSide(color: AppTheme.dangerRed),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
            icon: const Icon(Icons.logout),
            label: Text(l10n.logoutButton),
          ),
        ],
      ),
    );
  }
}
