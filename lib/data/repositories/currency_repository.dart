import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_budget/models/currency_rate.dart';
import 'package:smart_budget/utils/my_logger.dart';

class CurrencyRepository {
  final String _sharedKey = 'CURRENCY_UPDATE_DATE';
  final http.Client httpClient;
  final SharedPreferences sharedPreferences;

  CurrencyRepository({http.Client? client, required this.sharedPreferences})
      : httpClient = client ?? http.Client();

  Future<List<CurrencyRate>> fetchCurrencyRates() async {
    try {
      final response = await httpClient.get(
        Uri.parse("http://57.128.225.173:3100/api/rates"),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is! Map<String, dynamic>) {
          throw Exception('Invalid data format received from API');
        }

        final date = data['date'];
        if (date is String) {
          final prefs = sharedPreferences;
          await prefs.setString(_sharedKey, date);
          MyLogger.write("Currency - FETCH", "Saved update date: $date");
        } else {
          throw Exception('Invalid "date" field format');
        }

        final ratesData = data['rates'];
        if (ratesData is! Map<String, dynamic>) {
          throw Exception('Invalid "rates" field format');
        }

        final rates = ratesData.entries.map((entry) {
          final code = entry.key;
          final value = entry.value;

          final parsedRate = value is num
              ? value.toDouble()
              : throw Exception('Unexpected rate value type: $value');

          return CurrencyRate(name: code, code: code, rate: parsedRate);
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
      final prefs = sharedPreferences;
      final lastUpdate = prefs.getString(_sharedKey);
      if (lastUpdate == null) {
        return true;
      }
      final lastUpdateDate = DateTime.parse(lastUpdate);
      final now = DateTime.now();
      return now.difference(lastUpdateDate).inHours >= 24;
    } catch (e) {
      MyLogger.write("Error checking last update date", e.toString());
      return true;
    }
  }

  Future<void> saveLastUpdateDate() async {
    try {
      final prefs = sharedPreferences;
      await prefs.setString(_sharedKey, DateTime.now().toIso8601String());
    } catch (e) {
      throw Exception('Error saving last update date: $e');
    }
  }
}
