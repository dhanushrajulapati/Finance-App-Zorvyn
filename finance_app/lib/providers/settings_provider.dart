import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  SharedPreferences? _prefs;

  ThemeMode _themeMode = ThemeMode.system;
  String _currencySymbol = '\$';
  bool _biometricEnabled = false;
  bool _notificationsEnabled = false;

  SettingsProvider() {
    _loadSettings();
  }

  ThemeMode get themeMode => _themeMode;
  String get currencySymbol => _currencySymbol;
  bool get biometricEnabled => _biometricEnabled;
  bool get notificationsEnabled => _notificationsEnabled;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    final themeIdx = _prefs?.getInt('theme_mode') ?? 0;
    _themeMode = ThemeMode.values[themeIdx];
    _currencySymbol = _prefs?.getString('currency_symbol') ?? '\$';
    _biometricEnabled = _prefs?.getBool('biometric_enabled') ?? false;
    _notificationsEnabled = _prefs?.getBool('notifications_enabled') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    await _prefs?.setInt('theme_mode', _themeMode.index);
    notifyListeners();
  }

  Future<void> setCurrency(String symbol) async {
    _currencySymbol = symbol;
    await _prefs?.setString('currency_symbol', symbol);
    notifyListeners();
  }

  Future<void> toggleBiometric(bool val) async {
    _biometricEnabled = val;
    await _prefs?.setBool('biometric_enabled', val);
    notifyListeners();
  }

  Future<void> toggleNotifications(bool val) async {
    _notificationsEnabled = val;
    await _prefs?.setBool('notifications_enabled', val);
    notifyListeners();
  }

  Future<void> exportDataMock() async {
    await Future.delayed(const Duration(seconds: 2));
  }
}
