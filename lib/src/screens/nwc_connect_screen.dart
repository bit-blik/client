import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../i18n/gen/strings.g.dart';
import '../providers/providers.dart';

class NwcConnectScreen extends ConsumerStatefulWidget {
  const NwcConnectScreen({super.key});

  static const routeName = '/nwc-connect';

  @override
  ConsumerState<NwcConnectScreen> createState() => _NwcConnectScreenState();
}

class _NwcConnectScreenState extends ConsumerState<NwcConnectScreen> {
  MobileScannerController? _scannerController;
  bool _isProcessing = false;
  bool _hasScanned = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) {
      _scannerController = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
      );
    }
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    super.dispose();
  }

  Future<void> _handleNwcConnection(String connectionString) async {
    if (_isProcessing || _hasScanned) return;

    final trimmed = connectionString.trim();
    if (!trimmed.startsWith('nostr+walletconnect://')) {
      setState(() {
        _errorMessage = Translations.of(context).nwc.errors.invalid;
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _hasScanned = true;
      _errorMessage = null;
    });

    final t = Translations.of(context);
    final nwcServiceAsync = ref.read(nwcServiceProvider);

    await nwcServiceAsync.when(
      data: (nwcService) async {
        try {
          if (!mounted) return;

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(t.nwc.feedback.connecting)));

          await nwcService.connect(trimmed);

          if (!mounted) return;
          ref.read(nwcConnectionStatusProvider.notifier).state = true;

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(t.nwc.feedback.connected)));

          // Trigger balance and budget loading
          ref.read(nwcBalanceProvider.notifier).loadBalance();
          ref.read(nwcBudgetProvider.notifier).loadBudget();

          Navigator.of(context).pop(true);
        } catch (e) {
          if (!mounted) return;
          setState(() {
            _isProcessing = false;
            _hasScanned = false;
            _errorMessage = t.nwc.errors.connecting(details: e.toString());
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(t.nwc.errors.connecting(details: e.toString())),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      loading: () async {
        setState(() {
          _isProcessing = false;
          _hasScanned = false;
        });
      },
      error: (error, _) async {
        if (!mounted) return;
        setState(() {
          _isProcessing = false;
          _hasScanned = false;
          _errorMessage = error.toString();
        });
      },
    );
  }

  Future<void> _pasteFromClipboard() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    final text = clipboardData?.text;
    if (text != null && text.isNotEmpty) {
      await _handleNwcConnection(text);
    } else {
      if (!mounted) return;
      final t = Translations.of(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.nwc.errors.required)));
    }
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    if (_hasScanned || _isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      final rawValue = barcode.rawValue;
      if (rawValue != null && rawValue.startsWith('nostr+walletconnect://')) {
        _handleNwcConnection(rawValue);
        break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Translations.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(t.nwc.prompts.connect),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Stack(
        children: [
          // Camera preview (only on mobile)
          if (!kIsWeb && _scannerController != null)
            MobileScanner(
              controller: _scannerController!,
              onDetect: _onBarcodeDetected,
            )
          else
            // Web fallback - just show paste option
            Container(
              color: Colors.black,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.qr_code_scanner,
                        size: 100,
                        color: Colors.white54,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        t.nwc.prompts.pasteConnection,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Scanning overlay with cutout
          if (!kIsWeb)
            Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

          // Instructions overlay
          Positioned(
            top: 24,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                kIsWeb
                    ? t.nwc.prompts.pasteConnection
                    : t.nwc.labels.scanQrCode,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Error message
          if (_errorMessage != null)
            Positioned(
              top: 100,
              left: 24,
              right: 24,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          // Loading indicator
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.7),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 16),
                    Text(
                      t.nwc.feedback.connecting,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom paste button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 16,
                bottom: MediaQuery.of(context).padding.bottom + 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                    Colors.black,
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: ElevatedButton.icon(
                  onPressed: _isProcessing ? null : _pasteFromClipboard,
                  icon: const Icon(Icons.content_paste),
                  label: Text(t.nwc.prompts.pasteConnection),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
