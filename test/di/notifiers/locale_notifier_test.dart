import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_budget/di/notifiers/locale_notifier.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late LocaleNotifier localeNotifier;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  test('should initialize with system locale if no saved locale is found', () {
    final systemLocale = PlatformDispatcher.instance.locale;
    localeNotifier = LocaleNotifier();

    expect(localeNotifier.locale.languageCode, systemLocale.languageCode);
  });

  test('should load saved locale from SharedPreferences', () async {
    await prefs.setString('selectedLocale', 'es');

    localeNotifier = LocaleNotifier();
    await Future.delayed(Duration(milliseconds: 100));

    expect(localeNotifier.locale.languageCode, 'es');
  });

  test('should set and persist new locale', () async {
    localeNotifier = LocaleNotifier();

    await localeNotifier.setLocale(Locale('fr'));

    expect(localeNotifier.locale.languageCode, 'fr');

    final savedLocale = prefs.getString('selectedLocale');
    expect(savedLocale, 'fr');
  });
}
