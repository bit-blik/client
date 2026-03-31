import 'dart:convert';
import 'dart:io';

import 'secure_key_value_store.dart';

class FileSecureKeyValueStore implements SecureKeyValueStore {
  FileSecureKeyValueStore({String? filePath})
    : _filePath = filePath ?? _defaultFilePath();

  final String _filePath;

  @override
  Future<String?> read({required String key}) async {
    final values = await _readAll();
    return values[key];
  }

  @override
  Future<void> write({required String key, String? value}) async {
    final values = await _readAll();
    if (value == null) {
      values.remove(key);
    } else {
      values[key] = value;
    }
    await _writeAll(values);
  }

  @override
  Future<void> delete({required String key}) async {
    final values = await _readAll();
    values.remove(key);
    await _writeAll(values);
  }

  Future<Map<String, String>> _readAll() async {
    final file = File(_filePath);
    if (!await file.exists()) {
      return <String, String>{};
    }

    final raw = await file.readAsString();
    if (raw.trim().isEmpty) {
      return <String, String>{};
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return <String, String>{};
    }

    return decoded.map((key, value) => MapEntry(key, value?.toString() ?? ''));
  }

  Future<void> _writeAll(Map<String, String> values) async {
    final file = File(_filePath);
    await file.parent.create(recursive: true);
    await file.writeAsString(jsonEncode(values));
  }

  static String _defaultFilePath() {
    final env = Platform.environment;
    final xdgConfigHome = env['XDG_CONFIG_HOME'];
    if (xdgConfigHome != null && xdgConfigHome.isNotEmpty) {
      return '$xdgConfigHome/bitblik/secure_store.json';
    }

    final home = env['HOME'];
    if (home != null && home.isNotEmpty) {
      return '$home/.config/bitblik/secure_store.json';
    }

    return '.bitblik_secure_store.json';
  }
}

SecureKeyValueStore createSecureKeyValueStore() => FileSecureKeyValueStore();
