import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_budget/data/repositories/currency_repository.dart';
import 'package:smart_budget/models/currency_rate.dart';

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

      if (lastUpdated != null &&
          currentTime.difference(lastUpdated).inHours < 24) {
        final cachedRates = await _getCachedCurrencyRates();
        if (cachedRates != null) {
          print('Currency rates loaded from cache: $cachedRates');

          emit(CurrencyRatesLoaded(cachedRates));
          return;
        }
      }

      final rates = await repository.fetchCurrencyRates();
      await _cacheCurrencyRates(rates);
      await _setLastUpdatedTimestamp(currentTime);
      print('Currency rates loaded from API: $rates');

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

  Future<List<CurrencyRate>?> _getCachedCurrencyRates() async {
    final prefs = await SharedPreferences.getInstance();
    final ratesJson = prefs.getString('cached_currency_rates');
    if (ratesJson != null) {
      final List<dynamic> decodedJson =
          jsonDecode(ratesJson); // Dekodowanie listy JSON
      return decodedJson.map((json) => CurrencyRate.fromJson(json)).toList();
    }
    return null;
  }

  Future<void> _cacheCurrencyRates(List<CurrencyRate> rates) async {
    final prefs = await SharedPreferences.getInstance();
    final ratesJson = jsonEncode(rates);
    await prefs.setString('cached_currency_rates', ratesJson);
  }
}
