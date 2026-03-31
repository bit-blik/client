import 'secure_key_value_store.dart';

SecureKeyValueStore createSecureKeyValueStore() =>
    throw UnsupportedError(
      'No secure key store available for this platform runtime.',
    );
