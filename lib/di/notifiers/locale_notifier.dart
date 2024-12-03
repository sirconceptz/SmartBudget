import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleNotifier extends ChangeNotifier {
  static const String _localeKey = 'selectedLocale';

  Locale _locale = const Locale('en');

  Locale get locale => _locale;

  LocaleNotifier() {
    _loadLocale();
  }

  void setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    await _saveLocale(locale);
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final localeCode = prefs.getString(_localeKey) ?? 'en';
    _locale = Locale(localeCode);
    notifyListeners();
  }

  Future<void> _saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }
}
