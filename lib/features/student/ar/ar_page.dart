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

class _ArMenuSpec {
  const _ArMenuSpec({
    required this.badgeTitle,
    required this.presets,
    required this.defaultInput,
    required this.primaryLabel,
    required this.primaryAction,
    required this.accentLabel,
    required this.accentAction,
    required this.secondaryLabel,
    required this.secondaryAction,
    this.showInput = true,
  });

  final String badgeTitle;
  final List<String> presets;
  final String defaultInput;
  final String primaryLabel;
  final String primaryAction;
  final String accentLabel;
  final String accentAction;
  final String secondaryLabel;
  final String secondaryAction;
  final bool showInput;
}

class ArPage extends ConsumerStatefulWidget {
  const ArPage({super.key});

  @override
  ConsumerState<ArPage> createState() => _ArPageState();
}

class _ArPageState extends ConsumerState<ArPage> with WidgetsBindingObserver {
  static const _checkChannel = MethodChannel('learn_buddy/ar_check');
  static const _channel = MethodChannel('learn_buddy/ar_channel');

  final _inputCtrl = TextEditingController(text: 'Data 2');

  bool _cameraGranted = false;
  bool _checkingPerms = true;
  bool _arSupported = false;
  bool _markerDetected = false;
  String? _activeObjectType;
  String? _nativeStatus;

  List<String> _items = [];
  String? _feedbackText;
  bool _isAlert = false;

  static const Map<String, _ArMenuSpec> _menuSpecs = {
    'stack': _ArMenuSpec(
      badgeTitle: 'Stack (LIFO)',
      presets: ['Data A', '42', 'Buku 1'],
      defaultInput: 'Data 2',
      primaryLabel: 'PUSH',
      primaryAction: 'push',
      accentLabel: 'POP',
      accentAction: 'pop',
      secondaryLabel: 'PEEK',
      secondaryAction: 'peek',
    ),
    'queue': _ArMenuSpec(
      badgeTitle: 'Queue (FIFO)',
      presets: ['Antre A', 'Antre B', 'VIP'],
      defaultInput: 'Antre 3',
      primaryLabel: 'ENQUEUE',
      primaryAction: 'enqueue',
      accentLabel: 'DEQUEUE',
      accentAction: 'dequeue',
      secondaryLabel: 'PEEK',
      secondaryAction: 'peek',
    ),
    'linked_list': _ArMenuSpec(
      badgeTitle: 'Linked List',
      presets: ['N:30', 'N:40', 'N:99'],
      defaultInput: 'N:30',
      primaryLabel: 'INS HEAD',
      primaryAction: 'insert_head',
      accentLabel: 'INS TAIL',
      accentAction: 'insert_tail',
      secondaryLabel: 'DEL HEAD',
      secondaryAction: 'delete_head',
    ),
    'java_class': _ArMenuSpec(
      badgeTitle: 'Java: Class & Object',
      presets: ['Sedan', 'SUV', 'Truk'],
      defaultInput: 'Mobil 2',
      primaryLabel: 'NEW OBJ',
      primaryAction: 'new_object',
      accentLabel: 'UBAH OBJ',
      accentAction: 'mutate_obj',
      secondaryLabel: 'INFO',
      secondaryAction: 'inspect',
    ),
    'java_encap': _ArMenuSpec(
      badgeTitle: 'Java: Encapsulation',
      presets: ['250', '500', '999'],
      defaultInput: '250',
      primaryLabel: 'SETTER',
      primaryAction: 'setter',
      accentLabel: 'GETTER',
      accentAction: 'getter',
      secondaryLabel: 'HACK!',
      secondaryAction: 'direct_hack',
    ),
    'java_inherit': _ArMenuSpec(
      badgeTitle: 'Java: Inheritance',
      presets: ['Ikan', 'Kelinci', 'Elang'],
      defaultInput: 'Ikan',
      primaryLabel: '+ CHILD',
      primaryAction: 'add_child',
      accentLabel: 'OVERRIDE',
      accentAction: 'override_method',
      secondaryLabel: 'INFO',
      secondaryAction: 'inspect',
    ),
    'py_list_tuple': _ArMenuSpec(
      badgeTitle: 'Python: List vs Tuple',
      presets: ['Apel', 'Jeruk', '99'],
      defaultInput: 'Apel',
      primaryLabel: 'APPEND',
      primaryAction: 'list_append',
      accentLabel: 'POP LIST',
      accentAction: 'list_pop',
      secondaryLabel: 'EDIT TUPLE',
      secondaryAction: 'try_edit_tuple',
    ),
    'py_dict': _ArMenuSpec(
      badgeTitle: 'Python: Dictionary',
      presets: ['umur:17', 'nilai:95', 'nama:Ani'],
      defaultInput: 'nilai:95',
      primaryLabel: 'SET KEY',
      primaryAction: 'set_pair',
      accentLabel: 'LOOKUP',
      accentAction: 'lookup',
      secondaryLabel: 'DEL KEY',
      secondaryAction: 'del_pair',
    ),
    'py_loop': _ArMenuSpec(
      badgeTitle: 'Python: Loop & Def',
      presets: [],
      defaultInput: '',
      primaryLabel: 'NEXT ITER',
      primaryAction: 'next_iter',
      accentLabel: 'CALL DEF',
      accentAction: 'call_func',
      secondaryLabel: 'RESET',
      secondaryAction: 'reset',
      showInput: false,
    ),
  };

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
      final objectType = args?['objectType'] as String?;
      final status = args?['status'] as String?;
      final rawItems = (args?['items'] as List?)?.map((e) => e.toString()).toList();
      final switchedTopic = detected && objectType != null && objectType != _activeObjectType;

      setState(() {
        _markerDetected = detected;
        _activeObjectType = detected ? objectType : null;
        if (status != null && status.isNotEmpty) {
          _nativeStatus = status;
        }
        if (rawItems != null) {
          _items = rawItems;
        }
        if (switchedTopic) {
          final spec = _menuSpecs[objectType];
          _feedbackText = null;
          _isAlert = false;
          if (spec != null) {
            _inputCtrl.text = spec.defaultInput;
          }
        }
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

  Future<void> _sendAction(String action) async {
    if (!Platform.isAndroid || !_cameraGranted || !_arSupported) return;
    if (action == 'reset') {
      await _handleReset();
      return;
    }
    try {
      final res = await _channel.invokeMapMethod<String, dynamic>('action', {
        'action': action,
        'label': _inputCtrl.text.trim(),
      });
      if (res != null && mounted) {
        final event = res['event'] as String? ?? 'ok';
        final rawItems = (res['items'] as List?)?.map((e) => e.toString()).toList() ?? [];
        final message = res['message'] as String?;
        setState(() {
          _items = rawItems;
          _isAlert = event == 'overflow' || event == 'underflow';
          if (message != null && message.isNotEmpty) {
            _feedbackText = message;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _handleReset() async {
    if (!Platform.isAndroid || !_cameraGranted || !_arSupported) return;
    try {
      final res = await _channel.invokeMapMethod<String, dynamic>('reset');
      if (res != null && mounted) {
        final rawItems = (res['items'] as List?)?.map((e) => e.toString()).toList() ?? [];
        setState(() {
          _items = rawItems;
          _isAlert = false;
          _feedbackText = context.l10n.arResetDone;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final isEn = Localizations.localeOf(context).languageCode == 'en';
    final arActive = Platform.isAndroid && _cameraGranted && _arSupported;

    final statusLabel = !arActive
        ? l10n.arPageTitle
        : (_nativeStatus ??
            (_markerDetected
                ? (isEn ? '3D Object Active' : 'Objek 3D Aktif')
                : (isEn ? 'Point camera at AR Marker' : 'Arahkan kamera ke Marker AR')));

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
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
                      if (arActive && _markerDetected && _activeObjectType != null) ...[
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

                // Context-Aware Simulation Menu: hidden until a 3D object appears
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: (arActive && _markerDetected && _activeObjectType != null)
                      ? _buildDynamicSimulationMenu(_activeObjectType!)
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicSimulationMenu(String objectType) {
    final spec = _menuSpecs[objectType];
    if (spec == null) return const SizedBox.shrink();

    return Container(
      key: ValueKey('ar_menu_$objectType'),
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
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ClayPill(
                label: '${spec.badgeTitle} • ${_items.length}',
                color: AppTheme.primaryIndigoLight,
                textColor: AppTheme.primaryIndigo,
              ),
              if (spec.presets.isNotEmpty)
                Wrap(
                  spacing: 5,
                  runSpacing: 4,
                  children: spec.presets.map((preset) {
                    return GestureDetector(
                      onTap: () => _inputCtrl.text = preset,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.clayCanvas,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.clayBorder),
                        ),
                        child: Text(
                          preset,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textSecondary,
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
          if (spec.showInput) ...[
            const SizedBox(height: 8),
            ClayTextField(
              controller: _inputCtrl,
              hintText: context.l10n.arValueHint,
              prefixIcon: Icons.label_outline_rounded,
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClayButton(
                  text: spec.primaryLabel,
                  height: 44,
                  onPressed: () => _sendAction(spec.primaryAction),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClayButton(
                  text: spec.accentLabel,
                  isAccent: true,
                  height: 44,
                  onPressed: () => _sendAction(spec.accentAction),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ClayButton(
                  text: spec.secondaryLabel,
                  isPrimary: false,
                  height: 44,
                  onPressed: () => _sendAction(spec.secondaryAction),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
