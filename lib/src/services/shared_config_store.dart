import 'shared_config_store_memory.dart'
    if (dart.library.ui) 'shared_config_store_flutter.dart'
    as impl;

abstract class SharedConfigStore {
  Future<List<String>?> getStringList(String key);
  Future<void> setStringList(String key, List<String> value);
}

SharedConfigStore createDefaultSharedConfigStore() =>
    impl.createSharedConfigStore();
