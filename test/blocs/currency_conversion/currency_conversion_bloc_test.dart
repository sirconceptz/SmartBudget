import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_budget/blocs/currency_conversion/currency_conversion_bloc.dart';
import 'package:smart_budget/blocs/currency_conversion/currency_conversion_event.dart';
import 'package:smart_budget/blocs/currency_conversion/currency_conversion_state.dart';
import 'package:smart_budget/data/repositories/currency_repository.dart';
import 'package:smart_budget/models/currency_rate.dart';

class MockCurrencyRepository extends Mock implements CurrencyRepository {}

void main() {
  late CurrencyConversionBloc bloc;
  late MockCurrencyRepository mockRepository;

  final testRates = [
    CurrencyRate(code: 'USD', name: 'US Dollar', rate: 1.0),
    CurrencyRate(code: 'EUR', name: 'Euro', rate: 0.85),
    CurrencyRate(code: 'GBP', name: 'British Pound', rate: 0.75),
  ];

  setUp(() {
    mockRepository = MockCurrencyRepository();
    bloc = CurrencyConversionBloc(mockRepository);

    SharedPreferences.setMockInitialValues({});
  });

  group('CurrencyConversionBloc', () {
    blocTest<CurrencyConversionBloc, CurrencyConversionState>(
      'emits [CurrencyRatesLoading, CurrencyRatesLoaded] when fetching fresh currency rates',
      build: () {
        when(() => mockRepository.fetchCurrencyRates()).thenAnswer((_) async => testRates);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadCurrencyRates()),
      expect: () => [
        CurrencyRatesLoading(),
        CurrencyRatesLoaded(testRates),
      ],
      verify: (_) {
        verify(() => mockRepository.fetchCurrencyRates()).called(1);
      },
    );

    blocTest<CurrencyConversionBloc, CurrencyConversionState>(
      'emits [CurrencyRatesLoading, CurrencyRatesLoaded] when loading cached rates',
      build: () {
        final lastUpdated = DateTime.now().millisecondsSinceEpoch;
        final cachedRatesJson = jsonEncode(testRates.map((e) => e.toJson()).toList());

        SharedPreferences.setMockInitialValues({
          'currency_rates_last_updated': lastUpdated,
          'cached_currency_rates': cachedRatesJson,
        });

        return bloc;
      },
      act: (bloc) => bloc.add(LoadCurrencyRates()),
      expect: () => [
        CurrencyRatesLoading(),
        CurrencyRatesLoaded(testRates),
      ],
    );

    blocTest<CurrencyConversionBloc, CurrencyConversionState>(
      'emits [CurrencyRatesLoading, CurrencyRatesError] when fetching rates fails',
      build: () {
        when(() => mockRepository.fetchCurrencyRates()).thenThrow(Exception('Network error'));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadCurrencyRates()),
      expect: () => [
        CurrencyRatesLoading(),
        CurrencyRatesError('Exception: Network error'),
      ],
    );

    test('triggers callbacks after loading rates', () async {
      when(() => mockRepository.fetchCurrencyRates()).thenAnswer((_) async => testRates);

      bool callbackCalled = false;
      void testCallback() => callbackCalled = true;

      bloc.registerOnCurrencyRatesLoadedCallback(testCallback);
      bloc.add(LoadCurrencyRates());

      await Future.delayed(Duration(milliseconds: 100)); // Poczekaj na async eventy

      expect(callbackCalled, isTrue);
    });
  });
}