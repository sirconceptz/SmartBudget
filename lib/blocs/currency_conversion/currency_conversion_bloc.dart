import 'dart:convert';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_budget/data/repositories/currency_repository.dart';
import 'package:smart_budget/models/currency_rate.dart';

import 'currency_conversion_event.dart';
import 'currency_conversion_state.dart';

class CurrencyConversionBloc
    extends Bloc<CurrencyConversionEvent, CurrencyConversionState> {
  final CurrencyRepository repository;
  final List<VoidCallback> _onCurrencyRatesLoadedCallbacks = [];

  static const _kRatesKey = 'cached_currency_rates';
  static const _kRatesDateKey = 'cached_currency_rates_date';
  static const _kLastUpdatedKey = 'currency_rates_last_updated';

  CurrencyConversionBloc(this.repository) : super(CurrencyRatesLoading()) {
    on<LoadCurrencyRates>(_onLoadCurrencyRates);
    on<BackgroundRefreshCurrencyRates>(_onBackgroundRefreshCurrencyRates);
  }

  void registerOnCurrencyRatesLoadedCallback(VoidCallback callback) {
    _onCurrencyRatesLoadedCallbacks.add(callback);
  }

  void unregisterOnCurrencyRatesLoadedCallback(VoidCallback callback) {
    _onCurrencyRatesLoadedCallbacks.remove(callback);
  }

  Future<void> _onLoadCurrencyRates(
      LoadCurrencyRates event,
      Emitter<CurrencyConversionState> emit,
      ) async {
    try {
      emit(CurrencyRatesLoading());
      final prefs = await SharedPreferences.getInstance();
      final today = _formatDate(DateTime.now());

      final cachedToday = await _getCachedCurrencyRatesForDate(today, prefs);
      if (cachedToday != null && cachedToday.isNotEmpty) {
        emit(CurrencyRatesLoaded(cachedToday, fromCache: true, isStale: false));
        _triggerCallbacks();

        add(BackgroundRefreshCurrencyRates(attempts: 2));
        return;
      }

      try {
        final fresh = await _fetchWithRetry(maxAttempts: 2);
        await _cacheCurrencyRates(fresh, dateYMD: today, prefs: prefs);
        emit(CurrencyRatesLoaded(fresh, fromCache: false, isStale: false));
        _triggerCallbacks();
        return;
      } catch (_) {
        final fallback = _fallbackRates();
        await _cacheCurrencyRates(fallback, dateYMD: today, prefs: prefs);
        emit(CurrencyRatesLoaded(fallback, fromCache: false, isStale: false));
        _triggerCallbacks();
        return;
      }
    } catch (error) {
      emit(CurrencyRatesError(error.toString()));
    }
  }

  Future<void> _onBackgroundRefreshCurrencyRates(
      BackgroundRefreshCurrencyRates event,
      Emitter<CurrencyConversionState> emit,
      ) async {
    try {
      final rates = await _fetchWithRetry(maxAttempts: event.attempts);
      final prefs = await SharedPreferences.getInstance();
      final today = _formatDate(DateTime.now());
      await _cacheCurrencyRates(rates, dateYMD: today, prefs: prefs);

      emit(CurrencyRatesLoaded(rates, fromCache: false, isStale: false));
      _triggerCallbacks();
    } catch (_) {
    }
  }

  Future<List<CurrencyRate>> _fetchWithRetry({
    int maxAttempts = 2,
    Duration initialDelay = const Duration(seconds: 2),
    Duration perAttemptTimeout = const Duration(seconds: 5),
  }) async {
    assert(maxAttempts > 0);
    var attempt = 0;
    var delay = initialDelay;

    while (true) {
      attempt++;
      try {
        final data =
        await repository.fetchCurrencyRates().timeout(perAttemptTimeout);
        return data;
      } catch (e) {
        if (attempt >= maxAttempts) rethrow;
        await Future.delayed(delay);
        delay *= 2;
      }
    }
  }

  void _triggerCallbacks() {
    for (final callback in _onCurrencyRatesLoadedCallbacks) {
      callback();
    }
  }

  Future<List<CurrencyRate>?> _getCachedCurrencyRatesForDate(
      String dateYMD, SharedPreferences prefs) async {
    final cachedDate = prefs.getString(_kRatesDateKey);
    if (cachedDate == dateYMD) {
      final ratesJson = prefs.getString(_kRatesKey);
      if (ratesJson != null) {
        final List<dynamic> decodedJson = jsonDecode(ratesJson);
        return decodedJson
            .map((json) => CurrencyRate.fromJson(json))
            .toList();
      }
    }
    return null;
  }

  Future<void> _cacheCurrencyRates(
      List<CurrencyRate> rates, {
        required String dateYMD,
        SharedPreferences? prefs,
      }) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    final ratesJson = jsonEncode(rates);
    await p.setString(_kRatesKey, ratesJson);
    await p.setString(_kRatesDateKey, dateYMD);
    await p.setInt(_kLastUpdatedKey, DateTime.now().millisecondsSinceEpoch);
  }

  Future<List<CurrencyRate>> ensureLatestCurrencyRates() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = _formatDate(DateTime.now());

      final cachedToday = await _getCachedCurrencyRatesForDate(today, prefs);
      if (cachedToday != null && cachedToday.isNotEmpty) {
        return cachedToday;
      }

      try {
        final rates = await repository.fetchCurrencyRates();
        await _cacheCurrencyRates(rates, dateYMD: today, prefs: prefs);
        return rates;
      } catch (_) {
        final fallback = _fallbackRates();
        await _cacheCurrencyRates(fallback, dateYMD: today, prefs: prefs);
        return fallback;
      }
    } catch (error) {
      throw Exception('Failed to resolve currency rates: $error');
    }
  }

  List<CurrencyRate> _fallbackRates() {
    const hardcoded = '''
    {
      "date":"2025-10-15",
      "rates":{
        "AUD":1.5401,"CAD":1.4045,"CHF":0.8016,"CNY":7.1384,"EUR":0.8619,
        "GBP":0.7507,"HKD":7.7742,"JPY":151.75,"NZD":1.7503,"PLN":3.6729
      }
    }
    ''';
    print("Fallback currency rates used.");
    final decoded = jsonDecode(hardcoded) as Map<String, dynamic>;
    final Map<String, dynamic> ratesMap =
    (decoded['rates'] as Map).map((k, v) => MapEntry(k.toString(), v));

    return ratesMap.entries.map((e) {
      return CurrencyRate(
        code: e.key,
        name: e.key,
        rate: (e.value is num)
            ? (e.value as num).toDouble()
            : double.parse(e.value.toString()),
      );
    }).toList();
  }

  String _formatDate(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
