import 'package:flutter/material.dart';
import 'package:khaanado/constants/color_constants.dart';
import 'package:khaanado/services/local_storage.dart';

class ThemeController extends ChangeNotifier {
  ThemeController(this._storage);

  final LocalStorage _storage;
  bool _dark = true;

  bool get isDark => _dark;

  ThemeMode get mode => _dark ? ThemeMode.dark : ThemeMode.light;

  void hydrate() {
    _dark = _storage.readDarkTheme();
    ColorConstants.applyDark(_dark);
    notifyListeners();
  }

  Future<void> setDark(bool value) async {
    if (_dark == value) return;
    _dark = value;
    ColorConstants.applyDark(_dark);
    notifyListeners();
    await _storage.saveDarkTheme(_dark);
  }

  Future<void> toggle() => setDark(!_dark);
}
