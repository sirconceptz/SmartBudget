import 'package:flutter_test/flutter_test.dart';
import 'package:smart_budget/utils/custom_date_time_range.dart';

void main() {
  group('CustomDateTimeRange', () {
    test('should return correct date range for first day of the month', () {
      final selectedMonth = DateTime(2024, 3, 15);
      final firstDayOfMonth = 5;

      final range = CustomDateTimeRange.getCustomMonthRange(selectedMonth, firstDayOfMonth);

      expect(range.start, DateTime(2024, 3, 5, 0, 0, 0));
      expect(range.end, DateTime(2024, 4, 4, 23, 59, 59, 000));
    });

    test('should return correct date range when firstDayOfMonth is 1', () {
      final selectedMonth = DateTime(2024, 3, 20);
      final firstDayOfMonth = 1;

      final range = CustomDateTimeRange.getCustomMonthRange(selectedMonth, firstDayOfMonth);

      expect(range.start, DateTime(2024, 3, 1, 0, 0, 0));
      expect(range.end, DateTime(2024, 3, 31, 23, 59, 59, 000));
    });

    test('should format year and month correctly', () {
      expect(CustomDateTimeRange.formatYearMonth(2024, 3), '2024-03');
      expect(CustomDateTimeRange.formatYearMonth(1999, 12), '1999-12');
      expect(CustomDateTimeRange.formatYearMonth(5, 5), '0005-05');
    });
  });
}
