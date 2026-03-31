import 'shared_config_store.dart';

class InMemorySharedConfigStore implements SharedConfigStore {
  final Map<String, List<String>> _values = <String, List<String>>{};

  @override
  Future<List<String>?> getStringList(String key) async {
    final value = _values[key];
    if (value == null) {
      return null;
    }
    return List<String>.from(value);
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    _values[key] = List<String>.from(value);
  }
}

SharedConfigStore createSharedConfigStore() => InMemorySharedConfigStore();
