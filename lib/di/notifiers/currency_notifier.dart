import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/enums/currency.dart';

class CurrencyNotifier extends ChangeNotifier {
  Currency _currency = Currency.usd; // Default currency

  CurrencyNotifier() {
    _loadCurrency();
  }

  Currency get currency => _currency;

  void setCurrency(Currency currency) async {
    _currency = currency;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_currency', currency.value);
  }

  void _loadCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCurrency = prefs.getString('selected_currency');
    if (savedCurrency != null) {
      _currency = CurrencyExtension.fromString(savedCurrency);
      notifyListeners();
    } else {
      _currency = Currency.usd;
      notifyListeners();
    }
  }
}
