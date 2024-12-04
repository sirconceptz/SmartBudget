import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_budget/config.dart';

class CurrencyRepository {
  final String _baseUrl = AppConfig.apiUrl;
  final String _apiKey = AppConfig.apiKey;

  Future<Map<String, double>> fetchCurrencyRates(String baseCurrency) async {
    final response = await http.get(
        Uri.parse("$_baseUrl?apikey=$_apiKey&base_currency=${baseCurrency.toUpperCase()}"));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final rates = (data['data'] as Map<String, dynamic>).map((key, value) {
        final rateValue = (value as Map<String, dynamic>)['value'];

        // Obsługa przypadku, gdy wartość jest int lub double
        double parsedRate;
        if (rateValue is int) {
          parsedRate = rateValue.toDouble(); // Konwersja int -> double
        } else if (rateValue is double) {
          parsedRate = rateValue;
        } else {
          throw Exception('Unexpected rate value type: $rateValue');
        }

        return MapEntry(key, parsedRate);
      });
      return rates;
    } else {
      throw Exception('Failed to fetch currency rates');
    }
  }

  Future<bool> shouldRefreshRates() async {
    final prefs = await SharedPreferences.getInstance();
    final lastUpdate = prefs.getString('last_currency_update');
    if (lastUpdate == null) {
      return true;
    }
    final lastUpdateDate = DateTime.parse(lastUpdate);
    final now = DateTime.now();
    return now.difference(lastUpdateDate).inHours >= 24;
  }

  Future<void> saveLastUpdateDate() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('last_currency_update', DateTime.now().toIso8601String());
  }
}
