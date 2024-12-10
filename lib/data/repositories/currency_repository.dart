import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_budget/config.dart';
import 'package:smart_budget/models/currency_rate.dart';
import 'package:smart_budget/utils/my_logger.dart';

class CurrencyRepository {
  final String _baseUrl = AppConfig.apiUrl;
  final String _apiKey = AppConfig.apiKey;
  final String _sharedKey = 'last_currency_update';

  Future<List<CurrencyRate>> fetchCurrencyRates() async {
    try {
      final response = await http.get(
        Uri.parse(
            "$_baseUrl?apikey=$_apiKey&base_currency=USD&currencies=EUR,JPY,GBP,AUD,CAD,CHF,CNY,HKD,NZD,PLN"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['data'] == null || data['data'] is! Map<String, dynamic>) {
          throw Exception('Invalid data format received from API');
        }

        final rates =
            (data['data'] as Map<String, dynamic>).entries.map((entry) {
          final key = entry.key;
          final value = entry.value;

          if (value is Map<String, dynamic> && value['value'] != null) {
            final rateValue = value['value'];
            final parsedRate = rateValue is num
                ? rateValue.toDouble()
                : throw Exception('Unexpected rate value type: $rateValue');

            return CurrencyRate(name: key, code: key, rate: parsedRate);
          } else {
            throw Exception('Unexpected data structure for currency rate');
          }
        }).toList();

        return rates;
      } else {
        MyLogger.write("Currency - FETCH",
            'Failed to fetch currency rates: ${response.reasonPhrase}');
        throw Exception(
            'Failed to fetch currency rates: ${response.reasonPhrase}');
      }
    } catch (e) {
      MyLogger.write("Currency - FETCH", 'Error fetching currency rates: $e');
      throw Exception('Error fetching currency rates: $e');
    }
  }

  Future<bool> shouldRefreshRates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdate = prefs.getString(_sharedKey);
      if (lastUpdate == null) {
        return true;
      }
      final lastUpdateDate = DateTime.parse(lastUpdate);
      final now = DateTime.now();
      return now.difference(lastUpdateDate).inHours >= 24;
    } catch (e) {
      throw Exception('Error checking last update date: $e');
    }
  }

  Future<void> saveLastUpdateDate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sharedKey, DateTime.now().toIso8601String());
    } catch (e) {
      throw Exception('Error saving last update date: $e');
    }
  }
}
