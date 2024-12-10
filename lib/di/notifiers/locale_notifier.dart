import 'dart:ui';

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
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('localizedCategoriesUpdated', false);
    await _saveLocale(locale);
    notifyListeners();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();

    // Pobierz zapisany język, jeśli istnieje
    final localeCode = prefs.getString(_localeKey);

    if (localeCode == null) {
      final systemLocale = PlatformDispatcher.instance.locale;
      _locale = Locale(systemLocale.languageCode);
    } else {
      _locale = Locale(localeCode);
    }

    notifyListeners();
  }

  Future<void> _saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }
}
