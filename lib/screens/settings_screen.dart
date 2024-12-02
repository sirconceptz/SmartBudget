import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../di/notifiers/currency_notifier.dart';
import '../di/notifiers/locale_notifier.dart';
import '../di/notifiers/theme_notifier.dart';
import '../utils/enums/currency.dart';
import '../widgets/setting_row.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final currencyNotifier = Provider.of<CurrencyNotifier>(context);
    final localeNotifier = Provider.of<LocaleNotifier>(context);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SettingRow<Currency>(
            icon: Icons.attach_money,
            title: AppLocalizations.of(context)!.chooseCurrency,
            value: currencyNotifier.currency,
            items: Currency.values
                .map((currency) => DropdownMenuItem(
                      value: currency,
                      child: Text(currency.name.toUpperCase()),
                    ))
                .toList(),
            onChanged: (newCurrency) {
              if (newCurrency != null) {
                currencyNotifier.setCurrency(newCurrency);
              }
            },
          ),
          const SizedBox(height: 16.0),
          SettingRow<ThemeMode>(
            icon: Icons.color_lens_outlined,
            title: AppLocalizations.of(context)!.chooseTheme,
            value: themeNotifier.themeMode,
            items: [
              DropdownMenuItem(
                value: ThemeMode.system,
                child: Text(AppLocalizations.of(context)!.automatic),
              ),
              DropdownMenuItem(
                value: ThemeMode.light,
                child: Text(AppLocalizations.of(context)!.light),
              ),
              DropdownMenuItem(
                value: ThemeMode.dark,
                child: Text(AppLocalizations.of(context)!.dark),
              ),
            ],
            onChanged: (newMode) {
              if (newMode != null) {
                themeNotifier.setTheme(newMode);
              }
            },
          ),
          const SizedBox(height: 16.0),
          SettingRow<Locale>(
            icon: Icons.language,
            title: AppLocalizations.of(context)!.chooseLanguage,
            value: localeNotifier.locale,
            items: const [
              DropdownMenuItem(
                value: Locale('en'),
                child: Text('English'),
              ),
              DropdownMenuItem(
                value: Locale('pl'),
                child: Text('Polski'),
              ),
            ],
            onChanged: (newLocale) {
              if (newLocale != null) {
                localeNotifier.setLocale(newLocale);
              }
            },
          ),
        ],
      ),
    );
  }
}
