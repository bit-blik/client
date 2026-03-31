import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'secure_key_value_store.dart';

SecureKeyValueStore createSecureKeyValueStore() =>
    const FlutterSecureKeyValueStore();

class FlutterSecureKeyValueStore implements SecureKeyValueStore {
  const FlutterSecureKeyValueStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read({required String key}) => _storage.read(key: key);

  @override
  Future<void> write({required String key, String? value}) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete({required String key}) => _storage.delete(key: key);
}
