import 'package:shared_preferences/shared_preferences.dart';

class ApiSettings {
  static Future<String?> getCurrencyUpdateDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('CURRENCY_UPDATE_DATE');
  }
}
