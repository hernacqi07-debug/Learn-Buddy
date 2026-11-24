import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/models/models.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _inviteCtrl = TextEditingController();

  UserRole _role = UserRole.student;
  bool _isLoading = false;
  bool _isSuccess = false;
  bool _obscure = true;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _inviteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _isSuccess = false;
      _error = null;
    });

    try {
      final lang = ref.read(languageProvider).languageCode;
      final newProfile = await ref.read(authRepositoryProvider).signUp(
            email: _emailCtrl.text,
            password: _passwordCtrl.text,
            displayName: _nameCtrl.text,
            role: _role,
            inviteCode: _role == UserRole.teacher ? _inviteCtrl.text : null,
            languagePref: lang,
          );

      if (mounted) {
        setState(() => _isSuccess = true);
        ref.read(currentProfileProvider.notifier).setProfile(newProfile);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.celebration_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Akun berhasil dibuat! Selamat datang, ${_nameCtrl.text.trim()} 🎉',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );

        final destination =
            newProfile.role == UserRole.teacher ? '/teacher' : '/student';
        context.go(destination);
      }
    } on PostgrestException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSuccess = false;
          _error = e.message.contains('INVALID_INVITE_CODE')
              ? context.l10n.inviteCodeInvalid
              : e.message;
        });
      }
    } on AuthException catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSuccess = false;
          final msg = e.message.toLowerCase();
          if (msg.contains('already registered') ||
              msg.contains('already in use')) {
            _error = 'Email ini sudah terdaftar. Silakan login langsung.';
          } else {
            _error = e.message;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSuccess = false;
          _error = e.toString();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.registerTitle)),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.displayNameLabel,
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (v) {
                        if ((v ?? '').trim().isEmpty) return l10n.nameRequired;
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: l10n.emailLabel,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      validator: (v) {
                        final val = (v ?? '').trim();
                        if (val.isEmpty || !val.contains('@')) {
                          return l10n.invalidEmail;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: l10n.passwordLabel,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      validator: (v) {
                        if ((v ?? '').length < 8) {
                          return l10n.passwordTooShort;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.roleLabel,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<UserRole>(
                      segments: [
                        ButtonSegment(
                          value: UserRole.student,
                          label: Text(l10n.roleStudent),
                          icon: const Icon(Icons.school_outlined),
                        ),
                        ButtonSegment(
                          value: UserRole.teacher,
                          label: Text(l10n.roleTeacher),
                          icon: const Icon(Icons.co_present_outlined),
                        ),
                      ],
                      selected: {_role},
                      onSelectionChanged: (val) =>
                          setState(() => _role = val.first),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.roleLockedHint,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    if (_role == UserRole.teacher) ...[
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _inviteCtrl,
                        decoration: InputDecoration(
                          labelText: l10n.inviteCodeLabel,
                          prefixIcon: const Icon(Icons.vpn_key_outlined),
                        ),
                      ),
                    ],
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.dangerRed.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: AppTheme.dangerRed,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: (_isLoading || _isSuccess) ? null : _submit,
                      style: _isSuccess
                          ? ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF10B981),
                              foregroundColor: Colors.white,
                            )
                          : null,
                      child: _isSuccess
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_rounded,
                                    color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Pendaftaran Berhasil!',
                                  style: TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ],
                            )
                          : _isLoading
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text('Mendaftarkan akun...'),
                                  ],
                                )
                              : Text(l10n.registerButton),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _isLoading ? null : () => context.go('/login'),
                      child: Text(l10n.hasAccountPrompt),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
