import 'package:ndk/domain_layer/repositories/wallets_repo.dart';

import 'nostr_wallets_repo_factory_memory.dart'
    if (dart.library.ui) 'nostr_wallets_repo_factory_flutter.dart'
    as impl;

abstract class NostrWalletsRepoFactory {
  WalletsRepo create();
}

NostrWalletsRepoFactory createDefaultNostrWalletsRepoFactory() =>
    impl.createNostrWalletsRepoFactory();
