import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_budget/di/notifiers/finance_notifier.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late FinanceNotifier financeNotifier;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() async {
    mockSharedPreferences = MockSharedPreferences();

    SharedPreferences.setMockInitialValues({'firstDayOfMonth': 5});

    financeNotifier = FinanceNotifier();

    when(() => mockSharedPreferences.getInt(any())).thenReturn(5);
    when(() => mockSharedPreferences.setInt(any(), any()))
        .thenAnswer((_) async => true);
  });

  test('should load the first day of the month from SharedPreferences', () async {
    await financeNotifier.loadFirstDayOfMonth();

    expect(financeNotifier.firstDayOfMonth, 5);
  });


  test('should set the first day of the month in SharedPreferences', () async {
    financeNotifier = FinanceNotifier();

    await financeNotifier.setFirstDayOfMonth(10);

    expect(financeNotifier.firstDayOfMonth, 10);

    verify(() => mockSharedPreferences.setInt('firstDayOfMonth', 10)).called(1);
  });
}
