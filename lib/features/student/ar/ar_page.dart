import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/l10n/l10n_ext.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/clay_widgets.dart';

class ArPage extends ConsumerStatefulWidget {
  const ArPage({super.key});

  @override
  ConsumerState<ArPage> createState() => _ArPageState();
}

class _ArPageState extends ConsumerState<ArPage> with WidgetsBindingObserver {
  static const _checkChannel = MethodChannel('learn_buddy/ar_check');
  static const _channel = MethodChannel('learn_buddy/ar_channel');

  final _inputCtrl = TextEditingController(text: 'Data 1');

  bool _cameraGranted = false;
  bool _checkingPerms = true;
  bool _arSupported = false;
  bool _markerDetected = false;

  List<String> _items = [];
  final int _maxCapacity = 5;
  int _counter = 1;
  String? _feedbackText;
  bool _isAlert = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _channel.setMethodCallHandler(_onNativeCall);
    _initCameraAndAr();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _channel.setMethodCallHandler(null);
    _inputCtrl.dispose();
    if (Platform.isAndroid && _cameraGranted && _arSupported) {
      _channel.invokeMethod('pauseAr').catchError((_) {});
    }
    super.dispose();
  }

  Future<dynamic> _onNativeCall(MethodCall call) async {
    if (call.method == 'onMarkerStatus' && mounted) {
      final args = call.arguments as Map?;
      final detected = args?['detected'] == true;
      setState(() {
        _markerDetected = detected;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!Platform.isAndroid || !_cameraGranted || !_arSupported) return;
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _channel.invokeMethod('pauseAr').catchError((_) {});
    } else if (state == AppLifecycleState.resumed) {
      _channel.invokeMethod('resumeAr').catchError((_) {});
    }
  }

  Future<void> _initCameraAndAr() async {
    if (!Platform.isAndroid) {
      setState(() {
        _checkingPerms = false;
        _cameraGranted = false;
        _arSupported = false;
      });
      return;
    }

    final status = await Permission.camera.request();
    bool supported = false;
    try {
      String? avail;
      for (var i = 0; i < 10; i++) {
        avail = await _checkChannel.invokeMethod<String>('checkArAvailability');
        if (avail != 'UNKNOWN_CHECKING') break;
        await Future.delayed(const Duration(milliseconds: 150));
      }
      supported = avail != null && avail.startsWith('SUPPORTED');
    } catch (_) {
      supported = false;
    }

    if (!mounted) return;
    setState(() {
      _cameraGranted = status.isGranted;
      _arSupported = supported;
      _checkingPerms = false;
    });

    if (status.isGranted && supported) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _channel.invokeMethod('resumeAr').catchError((_) {});
        }
      });
    }
  }

  Future<void> _handlePush() async {
    if (!Platform.isAndroid || !_cameraGranted || !_arSupported) return;
    final val = _inputCtrl.text.trim();
    if (val.isEmpty) return;
    try {
      final res = await _channel.invokeMapMethod<String, dynamic>('push', {'label': val});
      if (res != null) _applyNativeResponse(res, val);
    } catch (_) {}
  }

  Future<void> _handlePop() async {
    if (!Platform.isAndroid || !_cameraGranted || !_arSupported) return;
    try {
      final res = await _channel.invokeMapMethod<String, dynamic>('pop');
      if (res != null) _applyNativeResponse(res, null);
    } catch (_) {}
  }

  Future<void> _handlePeek() async {
    if (!Platform.isAndroid || !_cameraGranted || !_arSupported) return;
    try {
      final res = await _channel.invokeMapMethod<String, dynamic>('peek');
      if (res != null) _applyNativeResponse(res, null);
    } catch (_) {}
  }

  Future<void> _handleReset() async {
    final l10n = context.l10n;
    if (!Platform.isAndroid || !_cameraGranted || !_arSupported) return;
    try {
      await _channel.invokeMethod('reset');
    } catch (_) {}
    setState(() {
      _items.clear();
      _counter = 1;
      _inputCtrl.text = 'Data 1';
      _isAlert = false;
      _feedbackText = l10n.arResetDone;
    });
  }

  void _applyNativeResponse(Map<String, dynamic> res, String? pushedVal) {
    final l10n = context.l10n;
    final event = res['event'] as String? ?? 'ok';
    final rawItems = (res['items'] as List?)?.map((e) => e.toString()).toList() ?? [];
    final affected = res['affectedItem'] as String? ?? pushedVal ?? '';

    setState(() {
      _items = rawItems;
      if (event == 'overflow') {
        _isAlert = true;
        _feedbackText = l10n.arOverflowAlert;
      } else if (event == 'underflow') {
        _isAlert = true;
        _feedbackText = l10n.arUnderflowAlert;
      } else if (event == 'peek') {
        _isAlert = false;
        _feedbackText = l10n.arPeekSuccess(affected);
      } else if (pushedVal != null) {
        _isAlert = false;
        _counter++;
        _inputCtrl.text = 'Data $_counter';
        _feedbackText = l10n.arPushSuccess(affected);
      } else {
        _isAlert = false;
        _feedbackText = l10n.arPopSuccess(affected);
      }
    });
  }

  void _showMarkerDialog() {
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          isEn ? 'Stack (LIFO) AR Marker' : 'Marker AR Stack (LIFO)',
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset('assets/ar/marker_stack.png', width: 220, height: 220),
            ),
            const SizedBox(height: 10),
            Text(
              isEn
                  ? 'Point the AR camera at this printed or screen marker to spawn the 3D Stack.'
                  : 'Arahkan kamera AR ke gambar marker ini (cetak atau layar laptop) untuk memunculkan Stack 3D.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              isEn ? 'Close' : 'Tutup',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final arActive = Platform.isAndroid && _cameraGranted && _arSupported;

    final statusLabel = !arActive
        ? l10n.arPageTitle
        : (_markerDetected
            ? (isEn ? 'Stack Marker Detected (3D Active)' : 'Marker Stack Terdeteksi (3D Aktif)')
            : (isEn ? 'Point camera at Stack Marker' : 'Arahkan kamera ke Marker Stack'));

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          // 1. Real ARCore Camera + 3D OpenGL Overlay
          if (arActive)
            const Positioned.fill(
              child: AndroidView(
                viewType: 'learn_buddy/ar_view',
                creationParamsCodec: StandardMessageCodec(),
              ),
            )
          else
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),

          // 2. Top Bar + Bottom Stack 3D Controls HUD
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: (arActive && _markerDetected)
                                      ? AppTheme.successGreen
                                      : AppTheme.accentOrange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  statusLabel,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (arActive) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _showMarkerDialog,
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.qr_code_2_rounded, color: AppTheme.primaryIndigo),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: _handleReset,
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.92),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.refresh_rounded, color: AppTheme.primaryIndigo),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                Expanded(
                  child: Center(
                    child: _checkingPerms
                        ? const CircularProgressIndicator(color: Colors.white)
                        : (Platform.isAndroid && !_cameraGranted)
                            ? Padding(
                                padding: const EdgeInsets.all(24),
                                child: ClayCard(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.videocam_off_rounded,
                                        size: 42,
                                        color: AppTheme.primaryIndigo,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        l10n.arCameraRequired,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 14),
                                      ClayButton(
                                        text: l10n.arGrantCameraBtn,
                                        height: 44,
                                        onPressed: _initCameraAndAr,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : (!_arSupported)
                                ? Padding(
                                    padding: const EdgeInsets.all(24),
                                    child: ClayCard(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.view_in_ar_rounded,
                                            size: 42,
                                            color: AppTheme.accentOrange,
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            l10n.arUnsupportedTitle,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            l10n.arUnsupportedDesc,
                                            textAlign: TextAlign.center,
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.textSecondary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox.shrink(),
                  ),
                ),

                if (arActive)
                  Container(
                    margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _isAlert ? AppTheme.dangerRed : AppTheme.clayBorder,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ClayPill(
                              label: 'Stack • ${l10n.arCapacityLabel(_items.length, _maxCapacity)}',
                              color: _items.length >= _maxCapacity
                                  ? const Color(0xFFFEF2F2)
                                  : AppTheme.primaryIndigoLight,
                              textColor: _items.length >= _maxCapacity
                                  ? AppTheme.dangerRed
                                  : AppTheme.primaryIndigo,
                            ),
                            Row(
                              children: ['Data A', '42', 'Buku 1'].map((preset) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 6),
                                  child: GestureDetector(
                                    onTap: () => _inputCtrl.text = preset,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppTheme.clayCanvas,
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppTheme.clayBorder),
                                      ),
                                      child: Text(
                                        preset,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                        if (_feedbackText != null) ...[
                          const SizedBox(height: 8),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: _isAlert
                                  ? AppTheme.dangerRedLight
                                  : AppTheme.primaryIndigoLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _feedbackText!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: _isAlert ? AppTheme.dangerRed : AppTheme.primaryIndigo,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        ClayTextField(
                          controller: _inputCtrl,
                          hintText: l10n.arValueHint,
                          prefixIcon: Icons.label_outline_rounded,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: ClayButton(
                                text: 'PUSH',
                                height: 44,
                                onPressed: _handlePush,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ClayButton(
                                text: 'POP',
                                isAccent: true,
                                height: 44,
                                onPressed: _handlePop,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ClayButton(
                                text: 'PEEK',
                                isPrimary: false,
                                height: 44,
                                onPressed: _handlePeek,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
