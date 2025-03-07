import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_budget/di/notifiers/currency_notifier.dart';
import 'package:smart_budget/utils/enums/currency.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  late CurrencyNotifier currencyNotifier;

  setUp(() {
    SharedPreferences.setMockInitialValues({'selected_currency': 'usd'});
    currencyNotifier = CurrencyNotifier();
  });

  test('Initial currency should be USD', () {
    expect(currencyNotifier.currency, Currency.usd);
  });

  test('setCurrency should update currency and save to SharedPreferences', () async {
    final newCurrency = Currency.eur;

    currencyNotifier.setCurrency(newCurrency);

    expect(currencyNotifier.currency, newCurrency);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('selected_currency'), newCurrency.value);
  });

  test('loadCurrency should load saved currency from SharedPreferences', () async {
    SharedPreferences.setMockInitialValues({'selected_currency': 'eur'});

    final newNotifier = CurrencyNotifier();

    await Future.delayed(Duration(milliseconds: 100));

    expect(newNotifier.currency, Currency.eur);
  });

}
