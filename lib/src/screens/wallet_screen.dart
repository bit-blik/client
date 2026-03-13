import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ndk_flutter/ndk_flutter.dart';
import '../../i18n/gen/strings.g.dart';
import '../providers/providers.dart';

const String kNwcWalletId = 'bitblik_nwc_wallet';

class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  static const routeName = '/wallet';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Translations.of(context);
    final ndk = ref.watch(ndkProvider);

    return Scaffold(
      appBar: AppBar(title: Text(t.wallet.title)),
      body:
          ndk == null
              ? const Center(child: CircularProgressIndicator())
              : NWallets(
                ndkFlutter: NdkFlutter(ndk: ndk),
                title: t.wallet.title,
                showWalletActions: false,
                walletCardsScrollDirection: Axis.vertical,
                showPendingTransactions: false,
                showRecentTransactions: false,
                albyGoConnectConfig: AlbyGoConnectConfig(
                  appName: 'BitBlik',
                  appIconUrl:
                      'https://bitblik.app/assets/assets/logo.png',
                  callback: 'bitblik://',
                ),
                onWalletSelected: (walletId) {
                  try {
                    ndk.wallets.setDefaultWallet(walletId);
                    ref.read(defaultWalletProvider.notifier).refresh();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to set default wallet: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
              ),
    );
  }
}
