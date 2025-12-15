import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:android_intent_plus/android_intent.dart';
import '../../i18n/gen/strings.g.dart';
import '../screens/nwc_connect_screen.dart';

/// Shows a dialog to choose between Alby Go and NWC QR scanner
/// Returns true if a connection method was selected, false if cancelled
Future<bool?> showNwcConnectDialog(BuildContext context) async {
  final t = Translations.of(context);

  return showDialog<bool>(
    context: context,
    builder:
        (dialogContext) => Dialog(
          backgroundColor: const Color(0xFF1a1a2e),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  t.nwc.prompts.chooseMethod,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Grid of connection options
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  alignment: WrapAlignment.center,
                  children: [
                    // Alby Go button (only on Android, not web)
                    if (!kIsWeb && Platform.isAndroid)
                      _NwcOptionButton(
                        imagePath: 'assets/albygo.png',
                        label: 'Alby Go',
                        onTap: () async {
                          Navigator.of(dialogContext).pop(true);
                          await _connectAlbyGo();
                        },
                      ),
                    // NWC QR Scanner button
                    _NwcOptionButton(
                      imagePath: 'assets/nwc.png',
                      label: 'NWC',
                      onTap: () async {
                        Navigator.of(dialogContext).pop(true);
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const NwcConnectScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(
                    t.common.buttons.cancel,
                    style: const TextStyle(color: Colors.white54),
                  ),
                ),
              ],
            ),
          ),
        ),
  );
}

/// A styled button for NWC connection options
class _NwcOptionButton extends StatelessWidget {
  final String imagePath;
  final String label;
  final VoidCallback onTap;

  const _NwcOptionButton({
    required this.imagePath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Image.asset(
                imagePath,
                width: 56,
                height: 56,
                fit: BoxFit.contain,
                errorBuilder:
                    (context, error, stackTrace) =>
                        const Icon(Icons.wallet, size: 40, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Launches the Alby Go app via Android intent
Future<void> _connectAlbyGo() async {
  if (!kIsWeb && Platform.isAndroid) {
    final intent = AndroidIntent(
      action: 'action_view',
      data:
          "nostrnwc://bla?appname=BitBlik&appicon=https%3A%2F%2Fbitblik.app%2Fassets%2Fassets%2Flogo.png&callback=bitblik%3A%2F%2F",
    );
    await intent.launch();
  }
}
