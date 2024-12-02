import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../di/notifiers/currency_notifier.dart';
import '../di/notifiers/theme_notifier.dart';
import '../utils/enums/currency.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final currencyNotifier = Provider.of<CurrencyNotifier>(context);

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text('Wybierz walutę:', style: TextStyle(fontSize: 18)),
            DropdownButton<Currency>(
              value: currencyNotifier.currency,
              items: Currency.values.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Text(currency.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (Currency? newCurrency) {
                if (newCurrency != null) {
                  currencyNotifier.setCurrency(newCurrency);
                }
              },
            ),
          ]),
          SizedBox(height: 16.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Wybierz motyw:', style: TextStyle(fontSize: 18)),
              DropdownButton<ThemeMode>(
                value: themeNotifier.themeMode,
                items: [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('Automatyczny'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('Jasny'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('Ciemny'),
                  ),
                ],
                onChanged: (ThemeMode? newMode) {
                  if (newMode != null) {
                    themeNotifier.setTheme(newMode);
                  }
                },
              )
            ],
          ),
          SizedBox(height: 16.0),
          Divider(),
          ListTile(
            leading: Icon(Icons.language),
            title: Text('Język'),
            subtitle: Text('Wybierz język aplikacji'),
            onTap: null,
          ),
          ListTile(
            leading: Icon(Icons.cloud_upload),
            title: Text('Kopia zapasowa'),
            subtitle: Text('Utwórz kopię zapasową danych'),
            onTap: null,
          ),
          ListTile(
            leading: Icon(Icons.info),
            title: Text('O aplikacji'),
            subtitle: Text('Informacje o aplikacji i deweloperze'),
            onTap: null,
          ),
        ],
      ),
    );
  }
}
