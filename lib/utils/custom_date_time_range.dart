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

  static String formatYearMonth(int year, int month) {
    final yy = year.toString().padLeft(4, '0');
    final mm = month.toString().padLeft(2, '0');
    return '$yy-$mm';
  }

  static DateTimeRange getExactOneMonthRange({
    int? selectedFirstDay,
    DateTime? minDate,
  }) {
    final now = DateTime.now();
    final referenceDate = minDate ?? now;

    if (selectedFirstDay != null) {
      final year = referenceDate.year;
      final month = referenceDate.month;

      final startDay =
          selectedFirstDay.clamp(1, DateTime(year, month + 1, 0).day);
      final startDate = DateTime(year, month, startDay);

      final nextMonth = DateTime(year, month + 1, 1);
      final endDay = selectedFirstDay.clamp(
          1, DateTime(nextMonth.year, nextMonth.month + 1, 0).day);
      final endDate = DateTime(nextMonth.year, nextMonth.month, endDay);

      return DateTimeRange(start: startDate, end: endDate);
    }

    final defaultStart = DateTime(
        referenceDate.year, referenceDate.month - 1, referenceDate.day);
    return DateTimeRange(start: defaultStart, end: referenceDate);
  }
}
