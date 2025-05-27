import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_budget/data/repositories/currency_repository.dart';
import 'package:smart_budget/models/currency_rate.dart';
import 'package:smart_budget/utils/my_logger.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockSharedPreferences extends Mock implements SharedPreferences {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CurrencyRepository currencyRepository;
  late MockHttpClient mockHttpClient;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockHttpClient = MockHttpClient();
    mockSharedPreferences = MockSharedPreferences();
    MyLogger.isTestMode = true;
    currencyRepository = CurrencyRepository(
      client: mockHttpClient,
      sharedPreferences: mockSharedPreferences,
    );
    SharedPreferences.setMockInitialValues({});
    when(() => mockSharedPreferences.setString(any(), any()))
        .thenAnswer((_) async => true);
  });

  group('CurrencyRepository', () {
    final testRates = [
      CurrencyRate(name: "AUD", code: "AUD", rate: 0.9),
      CurrencyRate(name: "CAD", code: "CAD", rate: 110.0),
    ];

    final testData = {
      'date': DateTime.now().toIso8601String(),
      'rates': {
        'AUD': 0.9,
        'CAD': 110.0,
      }
    };

    final testDataJson = json.encode(testData);
    final testUrl =
        "https://storage.googleapis.com/my-currency-data/rates.json";
    test('fetchCurrencyRates returns a list of CurrencyRate on successful API call', () async {
      when(() => mockHttpClient.get(Uri.parse(testUrl))).thenAnswer(
              (_) async => http.Response(testDataJson, 200));

      final result = await currencyRepository.fetchCurrencyRates();

      expect(result.length, 2);
      expect(result[0].name, testRates[0].name);
      expect(result[0].code, testRates[0].code);
      expect(result[1].name, testRates[1].name);
      expect(result[1].code, testRates[1].code);
    });

    test('shouldRefreshRates returns true when last update is null', () async {
      when(() => mockSharedPreferences.getString(any())).thenReturn(null);
      SharedPreferences.setMockInitialValues({});
      final result = await currencyRepository.shouldRefreshRates();

      expect(result, true);
    });

    test('shouldRefreshRates returns true when last update is older than 24 hours', () async {
      final lastUpdate = DateTime.now().subtract(const Duration(hours: 25)).toIso8601String();
      when(() => mockSharedPreferences.getString(any())).thenReturn(lastUpdate);
      SharedPreferences.setMockInitialValues({'CURRENCY_UPDATE_DATE': lastUpdate});

      final result = await currencyRepository.shouldRefreshRates();

      expect(result, true);
    });

    test('shouldRefreshRates returns false when last update is within 24 hours', () async {
      final lastUpdate = DateTime.now().subtract(const Duration(hours: 23)).toIso8601String();
      when(() => mockSharedPreferences.getString(any())).thenReturn(lastUpdate);
      SharedPreferences.setMockInitialValues({'CURRENCY_UPDATE_DATE': lastUpdate});

      final result = await currencyRepository.shouldRefreshRates();

      expect(result, false);
    });

    test('saveLastUpdateDate saves the current date to SharedPreferences', () async {
      when(() => mockSharedPreferences.setString(any(), any()))
          .thenAnswer((_) async => true);

      await currencyRepository.saveLastUpdateDate();

      verify(() => mockSharedPreferences.setString(
        'CURRENCY_UPDATE_DATE',
        any(that: isA<String>()),
      )).called(1);
    });
  });
}