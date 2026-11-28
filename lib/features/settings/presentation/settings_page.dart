import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/clay_widgets.dart';
import '../../../core/widgets/student_bottom_nav.dart';
import '../../../core/widgets/user_avatar.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _nameCtrl = TextEditingController();
  String _selectedAvatar = '👨‍🎓';
  bool _saving = false;
  bool _uploadingAvatar = false;
  bool _seeded = false;

  final List<String> _availableAvatars = ['👨‍🎓', '👩‍🎓', '🧑‍💻', '👩‍💻', '🤖', '🦊', '🚀', '💡'];

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    final av = prefs.getString('student_avatar');
    if (av != null && mounted) {
      setState(() => _selectedAvatar = av);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('student_avatar', _selectedAvatar);

      await ref.read(authRepositoryProvider).updateDisplayName(name);
      await ref.read(currentProfileProvider.notifier).refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.profileUpdatedMsg),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.profileUpdateError(e.toString())),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _uploadXFile(XFile picked) async {
    final l10n = context.l10n;
    setState(() => _uploadingAvatar = true);
    try {
      final (_, localPath) =
          await ref.read(authRepositoryProvider).uploadAvatar(picked);
      ref.read(localAvatarPathProvider.notifier).setPath(localPath);
      await ref.read(currentProfileProvider.notifier).refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.photoUpdatedMsg),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.photoUploadError(e.toString())),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  Future<void> _pickFromGallery() async {
    final l10n = context.l10n;
    // Request Photos / Storage permission explicitly so Android grants access to Vivo Gallery
    var status = await Permission.photos.request();
    if (status.isDenied) {
      status = await Permission.storage.request();
    }
    if (status.isPermanentlyDenied) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.permissionDeniedMsg),
          backgroundColor: AppTheme.accentOrange,
          action: SnackBarAction(
            label: 'Settings',
            textColor: Colors.white,
            onPressed: openAppSettings,
          ),
        ),
      );
      return;
    }

    // Use FilePicker (opens full Vivo File Manager / Gallery browser, avoiding empty Google Photo Picker)
    final files = await FilePicker.pickFiles(
      type: FileType.image,
      compressionQuality: 80,
    );
    if (files.isNotEmpty && files.first.path != null && mounted) {
      await _uploadXFile(XFile(files.first.path!));
      return;
    }
  }

  Future<void> _pickFromCamera() async {
    final l10n = context.l10n;
    final status = await Permission.camera.request();
    if (status.isPermanentlyDenied || status.isDenied) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.permissionDeniedMsg),
          backgroundColor: AppTheme.accentOrange,
          action: SnackBarAction(
            label: 'Settings',
            textColor: Colors.white,
            onPressed: openAppSettings,
          ),
        ),
      );
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    if (picked == null || !mounted) return;
    await _uploadXFile(picked);
  }

  Future<void> _removePhoto() async {
    final l10n = context.l10n;
    setState(() => _uploadingAvatar = true);
    try {
      await ref.read(authRepositoryProvider).removeAvatar();
      ref.read(localAvatarPathProvider.notifier).setPath(null);
      await ref.read(currentProfileProvider.notifier).refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.photoRemovedMsg),
          backgroundColor: AppTheme.primaryIndigo,
        ),
      );
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  void _showAvatarPicker() {
    final l10n = context.l10n;
    final profile = ref.read(currentProfileProvider).value;
    final localPath = ref.read(localAvatarPathProvider).value;
    final hasCustomPhoto =
        (localPath != null && localPath.isNotEmpty) ||
        (profile?.avatarUrl != null && profile!.avatarUrl!.isNotEmpty);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
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
                Text(
                  l10n.chooseAvatarTitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppTheme.textMuted),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClayButton(
              text: l10n.chooseFromFilesGalleryBtn,
              icon: Icons.photo_library_rounded,
              onPressed: () {
                Navigator.pop(ctx);
                _pickFromGallery();
              },
            ),
            const SizedBox(height: 10),
            ClayButton(
              text: l10n.chooseFromCameraBtn,
              icon: Icons.camera_alt_rounded,
              isAccent: true,
              onPressed: () {
                Navigator.pop(ctx);
                _pickFromCamera();
              },
            ),
            if (hasCustomPhoto) ...[
              const SizedBox(height: 10),
              ClayButton(
                text: l10n.removeProfilePhotoBtn,
                icon: Icons.delete_outline_rounded,
                isPrimary: false,
                onPressed: () {
                  Navigator.pop(ctx);
                  _removePhoto();
                },
              ),
            ],
            const SizedBox(height: 18),
            Text(
              l10n.orChooseEmojiLabel,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: _availableAvatars.map((avatar) {
                final isSelected = avatar == _selectedAvatar;
                return InkWell(
                  onTap: () async {
                    setState(() => _selectedAvatar = avatar);
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.setString('student_avatar', avatar);
                    if (ctx.mounted) Navigator.pop(ctx);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primaryIndigoLight : AppTheme.clayCanvas,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppTheme.primaryIndigo : AppTheme.clayBorder,
                        width: isSelected ? 2.0 : 1.2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(avatar, style: const TextStyle(fontSize: 28)),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteAllHistory() async {
    final l10n = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppTheme.dangerRed, width: 2),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: AppTheme.dangerRed),
            const SizedBox(width: 8),
            Text(
              l10n.clearChatConfirmTitle,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          l10n.clearChatConfirmBody,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              l10n.cancel,
              style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
            ),
          ),
          ClayButton(
            text: l10n.yesDeleteAllBtn,
            isDanger: true,
            height: 42,
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    try {
      await ref.read(sessionRepositoryProvider).deleteAllMySessions();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.clearChatSuccess),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.clearChatError(e.toString())),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEn = ref.watch(languageProvider).languageCode == 'en';
    final profile = ref.watch(currentProfileProvider).value;

    if (profile != null && !_seeded) {
      _nameCtrl.text = profile.displayName;
      _seeded = true;
    }

    final isStudent = profile?.role == UserRole.student;

    return Scaffold(
      backgroundColor: AppTheme.clayCanvas,
      bottomNavigationBar: const StudentBottomNav(currentIndex: 2),
      appBar: AppBar(
        title: Text(
          l10n.accountSettingsTitle,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              final homeRoute = switch (profile?.role) {
                UserRole.admin => '/admin',
                UserRole.teacher => '/teacher',
                _ => '/student',
              };
              context.go(homeRoute);
            }
          },
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1. Profile Avatar & Name
          ClayCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                GestureDetector(
                  onTap: _uploadingAvatar ? null : _showAvatarPicker,
                  child: Stack(
                    children: [
                      UserAvatar(
                        localPath: ref.watch(localAvatarPathProvider).value,
                        avatarUrl: profile?.avatarUrl,
                        emoji: _selectedAvatar,
                        displayName: profile?.displayName ?? '',
                        size: 84,
                        backgroundColor: AppTheme.primaryIndigoLight,
                        textColor: AppTheme.primaryIndigo,
                        borderColor: AppTheme.primaryIndigo,
                        borderWidth: 2.2,
                      ),
                      if (_uploadingAvatar)
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: SizedBox(
                              width: 26,
                              height: 26,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: AppTheme.primaryIndigo,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  profile?.displayName ?? (isEn ? 'User' : 'Pengguna'),
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profile?.email ?? '',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 10),
                ClayPill(
                  label: switch (profile?.role) {
                    UserRole.admin => 'Administrator',
                    UserRole.teacher =>
                      isEn ? 'Instructor / Teacher' : 'Guru Pengajar',
                    _ => (profile?.className != null &&
                            profile!.className!.trim().isNotEmpty)
                        ? '${isEn ? 'Student' : 'Siswa'} • ${profile.className!.trim()}'
                        : (isEn ? 'Student' : 'Siswa'),
                  },
                  color: switch (profile?.role) {
                    UserRole.admin => AppTheme.dangerRedLight,
                    UserRole.teacher => const Color(0xFFFEF3C7),
                    _ => AppTheme.primaryIndigoLight,
                  },
                  textColor: switch (profile?.role) {
                    UserRole.admin => AppTheme.dangerRed,
                    UserRole.teacher => const Color(0xFFB45309),
                    _ => AppTheme.primaryIndigo,
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 2. Edit Profile Form
          ClayCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.accountInfoSection,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                ClayTextField(
                  controller: _nameCtrl,
                  label: l10n.displayNameLabel,
                  hint: l10n.enterYourNameHint,
                  prefixIcon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 14),
                ClayButton(
                  text: l10n.saveChangesBtn,
                  isLoading: _saving,
                  onPressed: _saveProfile,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 3. Language Selection Card
          ClayCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryIndigoLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.translate_rounded,
                        color: AppTheme.primaryIndigo,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.appLanguageLabel,
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          Text(
                            l10n.appLanguageSub,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Consumer(
                  builder: (context, ref, _) {
                    final currentCode = ref.watch(languageProvider).languageCode;
                    return Row(
                      children: [
                        Expanded(
                          child: _buildLanguageOption(
                            title: 'Indonesia',
                            code: 'id',
                            flag: '🇮🇩',
                            isSelected: currentCode == 'id',
                            onTap: () {
                              ref.read(languageProvider.notifier).setLanguage('id');
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildLanguageOption(
                            title: 'English',
                            code: 'en',
                            flag: '🇬🇧',
                            isSelected: currentCode == 'en',
                            onTap: () {
                              ref.read(languageProvider.notifier).setLanguage('en');
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 4. Security & Account Settings
          ClayCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.securityDataSection,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                _buildSettingsTile(
                  icon: Icons.lock_outline_rounded,
                  iconBg: AppTheme.primaryIndigoLight,
                  iconColor: AppTheme.primaryIndigo,
                  title: l10n.changePasswordTitle,
                  subtitle: l10n.changePasswordSub,
                  onTap: () => context.push('/settings/change-password'),
                ),
                if (isStudent) ...[
                  const Divider(height: 24, color: AppTheme.clayBorder),
                  _buildSettingsTile(
                    icon: Icons.delete_sweep_rounded,
                    iconBg: AppTheme.dangerRedLight,
                    iconColor: AppTheme.dangerRed,
                    title: l10n.clearChatHistoryTitle,
                    subtitle: l10n.clearChatHistorySub,
                    onTap: _deleteAllHistory,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4. Logout Button
          ClayButton(
            text: l10n.logoutFullBtn,
            isDanger: true,
            icon: Icons.logout_rounded,
            onPressed: () async {
              final router = GoRouter.of(context);
              await ref.read(authRepositoryProvider).signOut();
              if (mounted) router.go('/login');
            },
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.textMuted),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required String title,
    required String code,
    required String flag,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryIndigoLight : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryIndigo : AppTheme.clayBorder,
            width: isSelected ? 2.0 : 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryIndigo.withValues(alpha: 0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(flag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                fontSize: 13.5,
                color: isSelected ? AppTheme.primaryIndigo : AppTheme.textPrimary,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 6),
              const Icon(
                Icons.check_circle_rounded,
                color: AppTheme.primaryIndigo,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
