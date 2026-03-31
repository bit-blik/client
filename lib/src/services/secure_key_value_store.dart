import 'secure_key_value_store_stub.dart'
    if (dart.library.io) 'secure_key_value_store_io.dart'
    if (dart.library.ui) 'flutter_secure_key_value_store.dart'
    as impl;

abstract class SecureKeyValueStore {
  Future<String?> read({required String key});
  Future<void> write({required String key, String? value});
  Future<void> delete({required String key});
}

SecureKeyValueStore createDefaultSecureKeyValueStore() =>
    impl.createSecureKeyValueStore();
