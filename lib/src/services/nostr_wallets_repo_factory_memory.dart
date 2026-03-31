import 'package:ndk/data_layer/repositories/wallets/mem_wallets_repo.dart';
import 'package:ndk/domain_layer/repositories/wallets_repo.dart';

import 'nostr_wallets_repo_factory.dart';

NostrWalletsRepoFactory createNostrWalletsRepoFactory() =>
    const InMemoryNostrWalletsRepoFactory();

class InMemoryNostrWalletsRepoFactory implements NostrWalletsRepoFactory {
  const InMemoryNostrWalletsRepoFactory();

  @override
  WalletsRepo create() => MemWalletsRepo();
}
