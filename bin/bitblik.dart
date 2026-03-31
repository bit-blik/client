import 'dart:convert';
import 'dart:io';

import 'package:bitblik/src/services/api_service_nostr.dart';
import 'package:bitblik/src/services/key_service.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty || args.first == 'help' || args.first == '--help') {
    _printUsage();
    return;
  }

  final command = args.first;

  switch (command) {
    case 'list-coordinators':
      await _listCoordinators();
      return;
    default:
      stderr.writeln('Unknown command: $command');
      _printUsage();
      exitCode = 64;
  }
}

Future<void> _listCoordinators() async {
  final keyService = KeyService();
  final apiService = ApiServiceNostr(keyService);

  try {
    await apiService.init();

    final coordinators = await apiService.startCoordinatorDiscovery();

    for (final coordinator in coordinators) {
      await apiService.checkCoordinatorHealth(coordinator.pubkey);
    }

    final results = <Map<String, dynamic>>[];
    for (final coordinator in coordinators) {
      final info = apiService.getCoordinatorInfoByPubkey(coordinator.pubkey);

      final name = info?.name ?? coordinator.name;
      final minAmount = info?.minAmountSats ?? coordinator.minAmountSats;
      final maxAmount = info?.maxAmountSats ?? coordinator.maxAmountSats;
      final makerFee = info?.makerFee ?? coordinator.makerFee;
      final takerFee = info?.takerFee ?? coordinator.takerFee;

      results.add({
        'name': name,
        'pubkey': coordinator.pubkey,
        'responsive': coordinator.responsive == true,
        'amount_sats': {'min': minAmount, 'max': maxAmount},
        'fees': {'maker': makerFee, 'taker': takerFee},
        'currencies': coordinator.currencies,
        'version': coordinator.version,
        'terms': coordinator.termsOfUsageNaddr,
      });
    }

    final payload = {'count': results.length, 'coordinators': results};

    const encoder = JsonEncoder.withIndent('  ');
    stdout.writeln(encoder.convert(payload));
  } catch (e, st) {
    stderr.writeln('Failed to list coordinators: $e');
    stderr.writeln(st);
    exitCode = 1;
  } finally {
    await apiService.dispose();
  }
}

void _printUsage() {
  stdout.writeln('BitBlik CLI');
  stdout.writeln('');
  stdout.writeln('Usage:');
  stdout.writeln('  dart run bin/bitblik.dart <command>');
  stdout.writeln('');
  stdout.writeln('Commands:');
  stdout.writeln('  list-coordinators   Discover and print coordinator info');
}
