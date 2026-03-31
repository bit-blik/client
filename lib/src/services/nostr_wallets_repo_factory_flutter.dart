import 'package:ndk/domain_layer/repositories/wallets_repo.dart';
import 'package:ndk_flutter/ndk_flutter.dart';

import 'nostr_wallets_repo_factory.dart';

NostrWalletsRepoFactory createNostrWalletsRepoFactory() =>
    const DefaultNostrWalletsRepoFactory();

class DefaultNostrWalletsRepoFactory implements NostrWalletsRepoFactory {
  const DefaultNostrWalletsRepoFactory();

  @override
  WalletsRepo create() => FlutterSecureStorageWalletsRepo();
}
