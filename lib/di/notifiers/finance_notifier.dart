import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FinanceNotifier extends ChangeNotifier {
  static const String _firstDayKey = 'firstDayOfMonth';
  int _firstDayOfMonth = 1;

  int get firstDayOfMonth => _firstDayOfMonth;

  FinanceNotifier() {
    loadFirstDayOfMonth();
  }

  Future<void> loadFirstDayOfMonth() async {
    final prefs = await SharedPreferences.getInstance();
    _firstDayOfMonth = prefs.getInt(_firstDayKey) ?? 1;
    notifyListeners();
  }

  Future<void> setFirstDayOfMonth(int day) async {
    _firstDayOfMonth = day;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_firstDayKey, day);
    notifyListeners();
  }
}
