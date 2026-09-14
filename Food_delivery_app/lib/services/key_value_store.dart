import 'package:shared_preferences/shared_preferences.dart';

abstract class KeyValueStore {
  Future<void> setString(String key, String value);

  String? getString(String key);

  Future<void> remove(String key);

  Future<void> clear();
}

class MemoryStore implements KeyValueStore {
  MemoryStore([Map<String, String>? seed]) : _data = {...?seed};

  final Map<String, String> _data;

  @override
  Future<void> setString(String key, String value) async {
    _data[key] = value;
  }

  @override
  String? getString(String key) => _data[key];

  @override
  Future<void> remove(String key) async {
    _data.remove(key);
  }

  @override
  Future<void> clear() async {
    _data.clear();
  }
}

class SharedPrefsStore implements KeyValueStore {
  SharedPrefsStore(this._prefs);

  final SharedPreferences _prefs;

  @override
  Future<void> setString(String key, String value) => _prefs.setString(key, value);

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<void> remove(String key) => _prefs.remove(key);

  @override
  Future<void> clear() => _prefs.clear();
}
