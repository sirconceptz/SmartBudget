import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_budget/data/repositories/currency_repository.dart';

import 'currency_conversion_event.dart';
import 'currency_conversion_state.dart';

class CurrencyConversionBloc
    extends Bloc<CurrencyConversionEvent, CurrencyConversionState> {
  final CurrencyRepository repository;

  CurrencyConversionBloc(this.repository) : super(CurrencyRatesLoading()) {
    on<LoadCurrencyRates>(_onLoadCurrencyRates);
  }

  Future<void> _onLoadCurrencyRates(
    LoadCurrencyRates event,
    Emitter<CurrencyConversionState> emit,
  ) async {
    try {
      emit(CurrencyRatesLoading());

      final lastUpdated = await _getLastUpdatedTimestamp();
      final currentTime = DateTime.now();

      // Check if rates were updated within the last 24 hours
      if (lastUpdated != null &&
          currentTime.difference(lastUpdated).inHours < 24) {
        final cachedRates = await _getCachedCurrencyRates();
        if (cachedRates != null) {
          emit(CurrencyRatesLoaded(cachedRates));
          return;
        }
      }

      final rates = await repository.fetchCurrencyRates(event.baseCurrency);
      await _cacheCurrencyRates(rates);
      await _setLastUpdatedTimestamp(currentTime);

      emit(CurrencyRatesLoaded(rates));
    } catch (error) {
      emit(CurrencyRatesError(error.toString()));
    }
  }

  Future<DateTime?> _getLastUpdatedTimestamp() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('currency_rates_last_updated');
    if (timestamp != null) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return null;
  }

  Future<void> _setLastUpdatedTimestamp(DateTime timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        'currency_rates_last_updated', timestamp.millisecondsSinceEpoch);
  }

  Future<Map<String, double>?> _getCachedCurrencyRates() async {
    final prefs = await SharedPreferences.getInstance();
    final ratesJson = prefs.getString('cached_currency_rates');
    if (ratesJson != null) {
      final Map<String, dynamic> decodedJson = json.decode(ratesJson);
      return decodedJson.map((key, value) => MapEntry(key, value.toDouble()));
    }
    return null;
  }

  Future<void> _cacheCurrencyRates(Map<String, double> rates) async {
    final prefs = await SharedPreferences.getInstance();
    final ratesJson = Uri.encodeComponent(rates.toString());
    await prefs.setString('cached_currency_rates', ratesJson);
  }
}
