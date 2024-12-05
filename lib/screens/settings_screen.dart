import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:smart_budget/blocs/category/category_bloc.dart';
import 'package:smart_budget/blocs/category/category_event.dart';
import 'package:smart_budget/utils/my_logger.dart';

import '../blocs/transaction/transaction_bloc.dart';
import '../blocs/transaction/transaction_event.dart';
import '../data/db/database_helper.dart';
import '../di/notifiers/currency_notifier.dart';
import '../di/notifiers/finance_notifier.dart';
import '../di/notifiers/locale_notifier.dart';
import '../di/notifiers/theme_notifier.dart';
import '../utils/enums/currency.dart';
import '../utils/toast.dart';
import '../widgets/setting_row.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final currencyNotifier = Provider.of<CurrencyNotifier>(context);
    final localeNotifier = Provider.of<LocaleNotifier>(context);
    final financeNotifier = Provider.of<FinanceNotifier>(context);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              AppLocalizations.of(context)!.appSection,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          SettingRow<Currency>(
            icon: Icons.attach_money,
            title: AppLocalizations.of(context)!.chooseCurrency,
            value: currencyNotifier.currency,
            items: Currency.values
                .map((currency) => DropdownMenuItem(
                      value: currency,
                      child: Text(currency
                          .localizedName(AppLocalizations.of(context)!)),
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
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              AppLocalizations.of(context)!.financeSection,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          SettingRow<int>(
            icon: Icons.calendar_today,
            title: AppLocalizations.of(context)!.firstDayOfMonth,
            value: financeNotifier.firstDayOfMonth,
            items: List.generate(
              28,
              (index) => DropdownMenuItem(
                value: index + 1,
                child: Text((index + 1).toString()),
              ),
            ),
            onChanged: (newDay) {
              if (newDay != null) {
                financeNotifier.setFirstDayOfMonth(newDay);
              }
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.backupSection,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16.0),
                InkWell(
                  child: Row(
                    children: [
                      Icon(Icons.download),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.exportBackup,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  onTap: () async {
                    try {
                      await DatabaseHelper().exportDatabase();
                      Toast.show(context,
                          AppLocalizations.of(context)!.exportBackupStatement);
                    } catch (E) {
                      MyLogger.write("BACKUP - EXPORT", E.toString());
                      Toast.show(context,
                          AppLocalizations.of(context)!.exportBackupError);
                    }
                  },
                ),
                const SizedBox(height: 16.0),
                InkWell(
                  child: Row(
                    children: [
                      Icon(Icons.upload),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.importBackup,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  onTap: () async {
                    try {
                      await DatabaseHelper().importDatabase();
                      context.read<TransactionBloc>().add(LoadTransactions());
                      context
                          .read<CategoryBloc>()
                          .add(LoadCategoriesWithSpentAmounts());
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(AppLocalizations.of(context)!
                                .importBackupStatement)),
                      );
                    } catch (E) {
                      MyLogger.write("BACKUP - IMPORT", E.toString());
                      Toast.show(context,
                          AppLocalizations.of(context)!.importBackupError);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
