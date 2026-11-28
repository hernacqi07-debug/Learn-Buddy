import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/clay_widgets.dart';
import '../../../core/widgets/user_avatar.dart';
import '../data/admin_repository.dart';

class AdminDashboardPage extends ConsumerStatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  ConsumerState<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends ConsumerState<AdminDashboardPage> {
  int _tabIndex = 0; // 0: Overview, 1: Users, 2: Content
  bool _loading = true;
  String? _error;

  AdminOverviewStats? _stats;
  List<UserProfile> _users = [];
  List<AdminCourseItem> _courses = [];
  List<AdminTopicItem> _topics = [];
  List<AdminInviteCode> _inviteCodes = [];

  final _searchCtrl = TextEditingController();
  String _roleFilter = 'all'; // 'all' | 'student' | 'teacher' | 'admin'

  AdminRepository get _repo => AdminRepository(ref.read(supabaseClientProvider));

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _repo.fetchOverviewStats(),
        _repo.fetchAllProfiles(),
        _repo.fetchCoursesAndTopics(),
        _repo.fetchInviteCodes(),
      ]);
      if (!mounted) return;
      final content = results[2] as (List<AdminCourseItem>, List<AdminTopicItem>);
      setState(() {
        _stats = results[0] as AdminOverviewStats;
        _users = results[1] as List<UserProfile>;
        _courses = content.$1;
        _topics = content.$2;
        _inviteCodes = results[3] as List<AdminInviteCode>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.plusJakartaSans(color: Colors.white)),
        backgroundColor: isError ? AppTheme.dangerRed : AppTheme.primaryIndigo,
      ),
    );
  }

  Future<void> _openCreateUserDialog(bool isEn) async {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final schoolCtrl = TextEditingController();
    final classCtrl = TextEditingController();
    UserRole selectedRole = UserRole.student;
    bool submitting = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: Text(
              isEn ? 'Create New Account' : 'Buat Akun Baru',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClayTextField(
                    controller: nameCtrl,
                    hintText: isEn ? 'Full Name' : 'Nama Lengkap',
                    prefixIcon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 10),
                  ClayTextField(
                    controller: emailCtrl,
                    hintText: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 10),
                  ClayTextField(
                    controller: passCtrl,
                    hintText: isEn ? 'Password (min. 6 chars)' : 'Password (min. 6 karakter)',
                    obscureText: true,
                    prefixIcon: Icons.lock_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isEn ? 'Account Role' : 'Peran Akun',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _roleChoiceChip(
                        label: isEn ? 'Student' : 'Siswa',
                        selected: selectedRole == UserRole.student,
                        onTap: () => setDialogState(() => selectedRole = UserRole.student),
                      ),
                      const SizedBox(width: 6),
                      _roleChoiceChip(
                        label: isEn ? 'Teacher' : 'Guru',
                        selected: selectedRole == UserRole.teacher,
                        onTap: () => setDialogState(() => selectedRole = UserRole.teacher),
                      ),
                      const SizedBox(width: 6),
                      _roleChoiceChip(
                        label: 'Admin',
                        selected: selectedRole == UserRole.admin,
                        onTap: () => setDialogState(() => selectedRole = UserRole.admin),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClayTextField(
                    controller: schoolCtrl,
                    hintText: isEn ? 'School (optional)' : 'Sekolah (opsional)',
                    prefixIcon: Icons.school_outlined,
                  ),
                  const SizedBox(height: 10),
                  ClayTextField(
                    controller: classCtrl,
                    hintText: isEn ? 'Class (optional)' : 'Kelas (opsional)',
                    prefixIcon: Icons.class_outlined,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: submitting ? null : () => Navigator.of(ctx).pop(),
                child: Text(isEn ? 'Cancel' : 'Batal'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryIndigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: submitting
                    ? null
                    : () async {
                        if (nameCtrl.text.trim().isEmpty ||
                            emailCtrl.text.trim().isEmpty ||
                            passCtrl.text.length < 6) {
                          _showSnack(
                            isEn
                                ? 'Please fill name, email, and password (min 6 chars).'
                                : 'Nama, email, dan password (min. 6 karakter) wajib diisi.',
                            isError: true,
                          );
                          return;
                        }
                        setDialogState(() => submitting = true);
                        try {
                          await _repo.createUser(
                            email: emailCtrl.text,
                            password: passCtrl.text,
                            displayName: nameCtrl.text,
                            role: selectedRole,
                            schoolName: schoolCtrl.text,
                            className: classCtrl.text,
                          );
                          if (ctx.mounted) Navigator.of(ctx).pop();
                          _showSnack(isEn ? 'Account created!' : 'Akun berhasil dibuat!');
                          await _loadAll();
                        } catch (e) {
                          setDialogState(() => submitting = false);
                          _showSnack(
                            e.toString().replaceFirst('Exception: ', ''),
                            isError: true,
                          );
                        }
                      },
                child: submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(isEn ? 'Create' : 'Buat Akun'),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _openChangeRoleDialog(UserProfile user, bool isEn) async {
    UserRole picked = user.role;
    bool saving = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(
            isEn ? 'Change Role' : 'Ubah Peran Pengguna',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 17),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${user.displayName}\n${user.email}',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _roleChoiceChip(
                    label: isEn ? 'Student' : 'Siswa',
                    selected: picked == UserRole.student,
                    onTap: () => setDialogState(() => picked = UserRole.student),
                  ),
                  const SizedBox(width: 6),
                  _roleChoiceChip(
                    label: isEn ? 'Teacher' : 'Guru',
                    selected: picked == UserRole.teacher,
                    onTap: () => setDialogState(() => picked = UserRole.teacher),
                  ),
                  const SizedBox(width: 6),
                  _roleChoiceChip(
                    label: 'Admin',
                    selected: picked == UserRole.admin,
                    onTap: () => setDialogState(() => picked = UserRole.admin),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.of(ctx).pop(),
              child: Text(isEn ? 'Cancel' : 'Batal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryIndigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: saving
                  ? null
                  : () async {
                      if (picked == user.role) {
                        Navigator.of(ctx).pop();
                        return;
                      }
                      setDialogState(() => saving = true);
                      try {
                        await _repo.updateUserRole(userId: user.id, role: picked);
                        if (ctx.mounted) Navigator.of(ctx).pop();
                        _showSnack(isEn ? 'Role updated!' : 'Peran berhasil diperbarui!');
                        await _loadAll();
                      } catch (e) {
                        setDialogState(() => saving = false);
                        _showSnack(
                          e.toString().replaceFirst('Exception: ', ''),
                          isError: true,
                        );
                      }
                    },
              child: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(isEn ? 'Save' : 'Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeleteUser(UserProfile user, bool isEn) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          isEn ? 'Delete Account?' : 'Hapus Akun?',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, color: AppTheme.dangerRed),
        ),
        content: Text(
          isEn
              ? 'Account "${user.displayName}" (${user.email}) and all its data will be permanently deleted.'
              : 'Akun "${user.displayName}" (${user.email}) beserta datanya akan dihapus permanen.',
          style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(isEn ? 'Cancel' : 'Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.dangerRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(isEn ? 'Delete' : 'Hapus'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    try {
      await _repo.deleteUser(user.id);
      _showSnack(isEn ? 'Account deleted.' : 'Akun berhasil dihapus.');
      await _loadAll();
    } catch (e) {
      _showSnack(e.toString().replaceFirst('Exception: ', ''), isError: true);
    }
  }

  Widget _roleChoiceChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primaryIndigo : AppTheme.clayCanvas,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppTheme.primaryIndigo : AppTheme.clayBorder,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final currentUser = ref.watch(currentProfileProvider).value;

    return Scaffold(
      backgroundColor: AppTheme.clayCanvas,
      floatingActionButton: _tabIndex == 1
          ? FloatingActionButton.extended(
              backgroundColor: AppTheme.primaryIndigo,
              foregroundColor: Colors.white,
              onPressed: () => _openCreateUserDialog(isEn),
              icon: const Icon(Icons.person_add_rounded),
              label: Text(
                isEn ? 'Add Account' : 'Buat Akun',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
              ),
            )
          : null,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  UserAvatar(
                    displayName: currentUser?.displayName ?? 'Admin',
                    avatarUrl: currentUser?.avatarUrl,
                    size: 44,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEn ? 'Admin Console' : 'Panel Admin',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 19,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          currentUser?.email ?? 'admin@learnbuddy.id',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _loadAll,
                    icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryIndigo),
                    tooltip: isEn ? 'Refresh' : 'Muat Ulang',
                  ),
                  IconButton(
                    onPressed: () => context.push('/settings'),
                    icon: const Icon(Icons.settings_rounded, color: AppTheme.textPrimary),
                    tooltip: isEn ? 'Settings' : 'Pengaturan',
                  ),
                ],
              ),
            ),

            // 3-Tab Segmented Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppTheme.clayBorder, width: 1.5),
                ),
                child: Row(
                  children: [
                    _tabButton(0, isEn ? 'Overview' : 'Ringkasan', Icons.dashboard_rounded),
                    _tabButton(1, isEn ? 'Users' : 'Pengguna', Icons.people_alt_rounded),
                    _tabButton(2, isEn ? 'Content' : 'Konten', Icons.tune_rounded),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Body
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: ClayCard(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.error_outline_rounded,
                                      size: 40, color: AppTheme.dangerRed),
                                  const SizedBox(height: 10),
                                  Text(_error!, textAlign: TextAlign.center),
                                  const SizedBox(height: 12),
                                  ClayButton(
                                    text: isEn ? 'Retry' : 'Coba Lagi',
                                    height: 42,
                                    onPressed: _loadAll,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadAll,
                          child: _tabIndex == 0
                              ? _buildOverviewTab(isEn)
                              : _tabIndex == 1
                                  ? _buildUsersTab(isEn, currentUser?.id)
                                  : _buildContentTab(isEn),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(int index, String label, IconData icon) {
    final active = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppTheme.primaryIndigo : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: active ? Colors.white : AppTheme.textSecondary),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: active ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab(bool isEn) {
    final s = _stats;
    if (s == null) return const SizedBox.shrink();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.45,
          children: [
            _statCard(
              title: isEn ? 'Total Users' : 'Total Pengguna',
              value: '${s.totalUsers}',
              subtitle: isEn
                  ? '${s.totalStudents} Students • ${s.totalTeachers} Teachers'
                  : '${s.totalStudents} Siswa • ${s.totalTeachers} Guru',
              icon: Icons.groups_rounded,
              color: AppTheme.primaryIndigo,
            ),
            _statCard(
              title: isEn ? 'Admin Accounts' : 'Akun Admin',
              value: '${s.totalAdmins}',
              subtitle: isEn ? 'Role-based access' : 'Akses kontrol penuh',
              icon: Icons.admin_panel_settings_rounded,
              color: const Color(0xFF7C3AED),
            ),
            _statCard(
              title: isEn ? 'Courses' : 'Kursus',
              value: '${s.activeCourses}/${s.totalCourses}',
              subtitle: isEn ? 'Active courses' : 'Kursus aktif',
              icon: Icons.menu_book_rounded,
              color: AppTheme.successGreen,
            ),
            _statCard(
              title: isEn ? 'Topics' : 'Topik',
              value: '${s.activeTopics}/${s.totalTopics}',
              subtitle: isEn ? 'Active topics' : 'Topik aktif',
              icon: Icons.layers_rounded,
              color: AppTheme.accentOrange,
            ),
            _statCard(
              title: isEn ? 'Learning Sessions' : 'Sesi Belajar',
              value: '${s.totalSessions}',
              subtitle: isEn
                  ? 'Avg Meter: ${s.avgMeterPercent}%'
                  : 'Rata-rata Meter: ${s.avgMeterPercent}%',
              icon: Icons.psychology_rounded,
              color: const Color(0xFF0284C7),
            ),
            _statCard(
              title: isEn ? 'AI Interactions' : 'Log Interaksi AI',
              value: '${s.totalTurnLogs}',
              subtitle: isEn ? 'Evaluated turns' : 'Putaran dievaluasi',
              icon: Icons.auto_awesome_rounded,
              color: const Color(0xFFDB2777),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ClayCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.vpn_key_rounded,
                        size: 20, color: AppTheme.accentOrange),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEn ? 'Teacher Invite Code' : 'Kode Undangan Guru',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          isEn
                              ? 'Used when registering a new teacher account'
                              : 'Digunakan saat mendaftar akun guru baru',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_inviteCodes.isEmpty)
                Text(
                  isEn ? 'No active invite code.' : 'Belum ada kode undangan.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    color: AppTheme.textSecondary,
                  ),
                )
              else
                ..._inviteCodes.map((ic) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.clayCanvas,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.clayBorder),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: SelectableText(
                            ic.code,
                            style: GoogleFonts.jetBrainsMono(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        ClayPill(
                          label: ic.isActive
                              ? (isEn ? 'Active' : 'Aktif')
                              : (isEn ? 'Inactive' : 'Nonaktif'),
                          color: ic.isActive
                              ? AppTheme.successGreen.withValues(alpha: 0.14)
                              : AppTheme.dangerRedLight,
                          textColor:
                              ic.isActive ? AppTheme.successGreen : AppTheme.dangerRed,
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: ic.code));
                            _showSnack(isEn
                                ? 'Invite code copied: ${ic.code}'
                                : 'Kode disalin: ${ic.code}');
                          },
                          icon: const Icon(Icons.copy_rounded,
                              size: 18, color: AppTheme.primaryIndigo),
                          tooltip: isEn ? 'Copy' : 'Salin',
                        ),
                      ],
                    ),
                  );
                }),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ClayCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryIndigoLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.shield_outlined, color: AppTheme.primaryIndigo),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isEn
                      ? 'Student chat messages remain private and are not exposed in the Admin Console.'
                      : 'Privasi terjaga: isi percakapan pribadi siswa dengan Buddy tidak ditampilkan di Panel Admin.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return ClayCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              Icon(icon, size: 18, color: color),
            ],
          ),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
            ),
          ),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTab(bool isEn, String? currentAdminId) {
    final query = _searchCtrl.text.trim().toLowerCase();
    final filtered = _users.where((u) {
      final matchesRole = _roleFilter == 'all' || u.role.name == _roleFilter;
      final matchesQuery = query.isEmpty ||
          u.displayName.toLowerCase().contains(query) ||
          u.email.toLowerCase().contains(query);
      return matchesRole && matchesQuery;
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 88),
      children: [
        ClayTextField(
          controller: _searchCtrl,
          hintText: isEn ? 'Search name or email...' : 'Cari nama atau email...',
          prefixIcon: Icons.search_rounded,
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filterChip('all', isEn ? 'All' : 'Semua'),
              const SizedBox(width: 6),
              _filterChip('student', isEn ? 'Student' : 'Siswa'),
              const SizedBox(width: 6),
              _filterChip('teacher', isEn ? 'Teacher' : 'Guru'),
              const SizedBox(width: 6),
              _filterChip('admin', 'Admin'),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                isEn ? 'No matching accounts.' : 'Tidak ada akun yang cocok.',
                style: GoogleFonts.plusJakartaSans(color: AppTheme.textSecondary),
              ),
            ),
          )
        else
          ...filtered.map((user) {
            final isSelf = user.id == currentAdminId;
            final roleColor = switch (user.role) {
              UserRole.admin => const Color(0xFF7C3AED),
              UserRole.teacher => AppTheme.accentOrange,
              UserRole.student => AppTheme.primaryIndigo,
            };
            final roleLabel = switch (user.role) {
              UserRole.admin => 'Admin',
              UserRole.teacher => isEn ? 'Teacher' : 'Guru',
              UserRole.student => isEn ? 'Student' : 'Siswa',
            };

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ClayCard(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        UserAvatar(
                          displayName: user.displayName,
                          avatarUrl: user.avatarUrl,
                          size: 40,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              Text(
                                user.email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ClayPill(
                          label: roleLabel,
                          color: roleColor.withValues(alpha: 0.14),
                          textColor: roleColor,
                        ),
                      ],
                    ),
                    if ((user.schoolName ?? '').isNotEmpty || (user.className ?? '').isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        [user.schoolName, user.className]
                            .where((e) => e != null && e.isNotEmpty)
                            .join(' • '),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                    if (!isSelf) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _openChangeRoleDialog(user, isEn),
                              icon: const Icon(Icons.manage_accounts_rounded, size: 16),
                              label: Text(isEn ? 'Change Role' : 'Ubah Role'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryIndigo,
                                side: const BorderSide(color: AppTheme.clayBorder),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () => _confirmDeleteUser(user, isEn),
                            icon: const Icon(Icons.delete_outline_rounded, size: 16),
                            label: Text(isEn ? 'Delete' : 'Hapus'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.dangerRed,
                              side: BorderSide(color: AppTheme.dangerRed.withValues(alpha: 0.4)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          }),
      ],
    );
  }

  Widget _filterChip(String value, String label) {
    final active = _roleFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _roleFilter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryIndigo : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active ? AppTheme.primaryIndigo : AppTheme.clayBorder,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: active ? Colors.white : AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildContentTab(bool isEn) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
      children: [
        Text(
          isEn ? 'Courses (Active / Inactive)' : 'Kursus (Aktif / Nonaktif)',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ..._courses.map((c) {
          final title = isEn && c.titleEn.isNotEmpty ? c.titleEn : c.titleId;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ClayCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          c.code,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: c.isActive,
                    activeTrackColor: AppTheme.successGreen,
                    onChanged: (val) async {
                      try {
                        await _repo.toggleCourseActive(c.id, val);
                        await _loadAll();
                      } catch (e) {
                        _showSnack(e.toString(), isError: true);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        Text(
          isEn ? 'Topics (Active / Inactive)' : 'Topik Materi (Aktif / Nonaktif)',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        ..._topics.map((t) {
          final title = isEn && t.titleEn.isNotEmpty ? t.titleEn : t.titleId;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ClayCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  Switch.adaptive(
                    value: t.isActive,
                    activeTrackColor: AppTheme.successGreen,
                    onChanged: (val) async {
                      try {
                        await _repo.toggleTopicActive(t.id, val);
                        await _loadAll();
                      } catch (e) {
                        _showSnack(e.toString(), isError: true);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
