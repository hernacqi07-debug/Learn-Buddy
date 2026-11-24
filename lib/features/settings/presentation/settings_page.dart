import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/clay_widgets.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _nameCtrl = TextEditingController();
  String _selectedAvatar = '👨‍🎓';
  bool _saving = false;
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
        const SnackBar(
          content: Text('Profil berhasil diperbarui!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan profil: $e'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showAvatarPicker() {
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
                Text(
                  'Pilih Avatar Akun',
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
            const SizedBox(height: 14),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: _availableAvatars.map((avatar) {
                final isSelected = avatar == _selectedAvatar;
                return InkWell(
                  onTap: () {
                    setState(() => _selectedAvatar = avatar);
                    Navigator.pop(ctx);
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
              'Hapus Riwayat Chat?',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
        content: Text(
          'Semua riwayat percakapan dan sesi bimbingan bersama AI Buddy akan dihapus permanen. Tindakan ini tidak dapat dibatalkan.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13.5,
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
            ),
          ),
          ClayButton(
            text: 'Ya, Hapus Semua',
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
        const SnackBar(
          content: Text('Semua riwayat sesi berhasil dibersihkan.'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus riwayat: $e'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider).value;

    if (profile != null && !_seeded) {
      _nameCtrl.text = profile.displayName;
      _seeded = true;
    }

    final isStudent = profile?.role == UserRole.student;

    return Scaffold(
      backgroundColor: AppTheme.clayCanvas,
      appBar: AppBar(
        title: Text(
          'Pengaturan Akun',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
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
                  onTap: _showAvatarPicker,
                  child: Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryIndigoLight,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.primaryIndigo, width: 2),
                        ),
                        alignment: Alignment.center,
                        child: Text(_selectedAvatar, style: const TextStyle(fontSize: 40)),
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
                          child: const Icon(Icons.edit_rounded, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  profile?.displayName ?? 'Pengguna',
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
                  label: isStudent ? 'Siswa SMK Kelas XI' : 'Guru Pengajar',
                  color: isStudent ? AppTheme.primaryIndigoLight : const Color(0xFFFEF3C7),
                  textColor: isStudent ? AppTheme.primaryIndigo : const Color(0xFFB45309),
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
                  'Informasi Akun',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 14),
                ClayTextField(
                  controller: _nameCtrl,
                  label: 'Nama Lengkap',
                  hint: 'Masukkan nama Anda',
                  prefixIcon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 14),
                ClayButton(
                  text: 'Simpan Perubahan',
                  isLoading: _saving,
                  onPressed: _saveProfile,
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 3. Security & Account Settings
          ClayCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Keamanan & Data',
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
                  title: 'Ubah Kata Sandi',
                  subtitle: 'Ganti kata sandi akun secara berkala',
                  onTap: () => context.push('/settings/change-password'),
                ),
                const Divider(height: 24, color: AppTheme.clayBorder),
                _buildSettingsTile(
                  icon: Icons.delete_sweep_rounded,
                  iconBg: AppTheme.dangerRedLight,
                  iconColor: AppTheme.dangerRed,
                  title: 'Bersihkan Riwayat Chat',
                  subtitle: 'Hapus seluruh percakapan dengan Buddy',
                  onTap: _deleteAllHistory,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4. Logout Button
          ClayButton(
            text: 'Keluar dari Akun (Logout)',
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
}
