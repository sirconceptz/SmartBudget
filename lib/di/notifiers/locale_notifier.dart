import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleNotifier extends ChangeNotifier {
  static const String _localeKey = 'selectedLocale';

  late Locale _locale;

  Locale get locale => _locale;

  LocaleNotifier() {
    final systemLocale = PlatformDispatcher.instance.locale;
    _locale = Locale(systemLocale.languageCode);

    _loadLocale();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('localizedCategoriesUpdated', false);

    await _saveLocale(locale);
    notifyListeners();
  }

  Future<void> _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();

    final localeCode = prefs.getString(_localeKey);

    if (localeCode != null) {
      _locale = Locale(localeCode);
    }

    notifyListeners();
  }

  Future<void> _saveLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }
}
