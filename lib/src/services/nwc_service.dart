import 'package:ndk/ndk.dart';
import 'package:ndk/shared/logger/logger.dart';

import 'key_service.dart';

/// Service for managing Nostr Wallet Connect (NWC) connections
class NwcService {
  final KeyService _keyService;
  final Ndk _ndk;
  NwcConnection? _nwcConnection;
  bool _isConnected = false;

  NwcService(this._keyService, this._ndk);

  /// Get the current NWC connection instance
  NwcConnection? get connection => _nwcConnection;

  /// Check if NWC is currently connected
  bool get isConnected => _isConnected;

  /// Get the relay URLs used by the NWC connection
  List<String> get relayUrls => _nwcConnection?.relays ?? [];

  /// Initialize and connect to NWC if a connection string is saved
  Future<void> initAndConnect() async {
    try {
      final connectionString = await _keyService.getNwcConnectionString();
      if (connectionString != null && connectionString.isNotEmpty) {
        Logger.log.i(
          '🔗 Found saved NWC connection string, attempting to connect...',
        );
        await connect(connectionString);
      } else {
        Logger.log.i('🔗 No saved NWC connection string found.');
      }
    } catch (e) {
      Logger.log.e('❌ Error initializing NWC connection: $e');
    }
  }

  /// Connect to NWC using the provided connection URI
  Future<void> connect(String nwcUri) async {
    try {
      Logger.log.i('🔗 Connecting to NWC...');
      _nwcConnection = await _ndk.nwc.connect(nwcUri, doGetInfoMethod: true);
      _isConnected = true;

      // Save the connection string
      await _keyService.saveNwcConnectionString(nwcUri);

      Logger.log.i('✅ NWC connected successfully!');
    } catch (e) {
      _isConnected = false;
      _nwcConnection = null;
      Logger.log.e('❌ Failed to connect to NWC: $e');
      rethrow;
    }
  }

  /// Get wallet balance in satoshis
  Future<int?> getBalance() async {
    if (!_isConnected || _nwcConnection == null) {
      Logger.log.w('⚠️ NWC not connected, cannot get balance');
      return null;
    }

    try {
      Logger.log.d('💰 Getting NWC wallet balance...');
      final balanceResponse = await _ndk.nwc.getBalance(_nwcConnection!);
      Logger.log.i('💰 NWC balance: ${balanceResponse.balanceSats} sats');
      return balanceResponse.balanceSats;
    } catch (e) {
      Logger.log.e('❌ Failed to get NWC balance: $e');
      return null;
    }
  }

  /// Get wallet budget information
  Future<Map<String, dynamic>?> getBudget() async {
    if (!_isConnected || _nwcConnection == null) {
      Logger.log.w('⚠️ NWC not connected, cannot get budget');
      return null;
    }

    try {
      Logger.log.d('📊 Getting NWC wallet budget...');
      final budgetResponse = await _ndk.nwc.getBudget(_nwcConnection!);

      // Format budget information
      final budgetInfo = <String, dynamic>{
        'usedBudgetSats': budgetResponse.userBudgetSats,
        'totalBudgetSats': budgetResponse.totalBudgetSats,
        'renewsAt': budgetResponse.renewsAt,
        'renewalPeriod': budgetResponse.renewalPeriod?.plaintext,
      };

      Logger.log.i(
        '📊 NWC budget - Used: ${budgetResponse.userBudgetSats} sats, Total: ${budgetResponse.totalBudgetSats} sats',
      );
      return budgetInfo;
    } catch (e) {
      Logger.log.e('❌ Failed to get NWC budget: $e');
      return null;
    }
  }

  /// Pay a Lightning invoice using NWC
  Future<void> payInvoice(String invoice) async {
    if (!_isConnected || _nwcConnection == null) {
      Logger.log.w('⚠️ NWC not connected, cannot pay invoice');
      throw Exception('NWC not connected');
    }

    try {
      Logger.log.i('💸 Paying invoice via NWC...');
      final paymentResponse = await _ndk.nwc.payInvoice(
        _nwcConnection!,
        invoice: invoice,
      );
      Logger.log.i(
        '✅ Invoice paid successfully! Preimage: ${paymentResponse.preimage}',
      );
    } catch (e) {
      // Logger.log.e('❌ Failed to pay invoice via NWC: $e');
      rethrow;
    }
  }

  /// Disconnect from NWC and clear saved connection string
  Future<void> disconnect() async {
    try {
      Logger.log.i('🔗 Disconnecting NWC...');

      // Clear the connection
      _nwcConnection = null;
      _isConnected = false;

      // Delete the saved connection string
      await _keyService.deleteNwcConnectionString();

      Logger.log.i('✅ NWC disconnected successfully!');
    } catch (e) {
      Logger.log.e('❌ Error disconnecting NWC: $e');
      rethrow;
    }
  }

  /// Dispose resources
  void dispose() {
    _nwcConnection = null;
    _isConnected = false;
  }
}
