import 'package:shared_preferences/shared_preferences.dart';

import 'shared_config_store.dart';

class SharedPreferencesConfigStore implements SharedConfigStore {
  @override
  Future<List<String>?> getStringList(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(key);
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, value);
  }
}

SharedConfigStore createSharedConfigStore() => SharedPreferencesConfigStore();
