import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_budget/di/notifiers/theme_notifier.dart';

void main() {
  late ThemeNotifier themeNotifier;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  test('should initialize with system theme mode', () {
    themeNotifier = ThemeNotifier();

    expect(themeNotifier.themeMode, ThemeMode.system);
  });

  test('should load saved theme mode from SharedPreferences', () async {
    await prefs.setString('theme_mode', ThemeMode.dark.toString());

    themeNotifier = ThemeNotifier();
    await Future.delayed(Duration(milliseconds: 100));

    expect(themeNotifier.themeMode, ThemeMode.dark);
  });

  test('should set and persist new theme mode', () async {
    themeNotifier = ThemeNotifier();

    themeNotifier.setTheme(ThemeMode.light);

    await Future.delayed(Duration(milliseconds: 100));
    expect(themeNotifier.themeMode, ThemeMode.light);

    final savedTheme = prefs.getString('theme_mode');
    expect(savedTheme, ThemeMode.light.toString());
  });
}
