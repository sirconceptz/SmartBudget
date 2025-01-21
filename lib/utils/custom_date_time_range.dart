import 'package:flutter/material.dart';

class CustomDateTimeRange {
  static DateTimeRange getCustomMonthRange(
      DateTime selectedMonth, int firstDayOfMonth) {
    final start = DateTime(
      selectedMonth.year,
      selectedMonth.month,
      firstDayOfMonth,
      0,
      0,
      0,
    );

    final nextMonth = DateTime(
      selectedMonth.year,
      selectedMonth.month + 1,
      firstDayOfMonth,
      0,
      0,
      0,
    );

    final end = nextMonth.subtract(const Duration(seconds: 1));

    return DateTimeRange(start: start, end: end);
  }
}
