import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:smart_budget/blocs/category/category_bloc.dart';
import 'package:smart_budget/blocs/category/category_event.dart';
import 'package:smart_budget/utils/my_logger.dart';
import 'package:sqflite/sqflite.dart';

import '../blocs/transaction/transaction_bloc.dart';
import '../blocs/transaction/transaction_event.dart';
import '../data/db/database_helper.dart';
import '../di/notifiers/currency_notifier.dart';
import '../di/notifiers/finance_notifier.dart';
import '../di/notifiers/locale_notifier.dart';
import '../di/notifiers/theme_notifier.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_settings.dart';
import '../utils/enums/currency.dart';
import '../utils/enums/supported_language.dart';
import '../utils/toast.dart';
import '../widgets/setting_row.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  String? updateDate;
  bool isLoading = true;

  Future<void> loadUpdateDate() async {
    final date = await ApiSettings.getCurrencyUpdateDate();
    if (mounted) {
      setState(() {
        updateDate = date;
        isLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadUpdateDate();
  }

  @override
  void dispose() {
    super.dispose();
  }

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
            items: SupportedLanguage.values.map((language) {
              return DropdownMenuItem(
                value: language.locale,
                child: Text(language.displayName),
              );
            }).toList(),
            onChanged: (Locale? newLocale) {
              if (newLocale != null && newLocale != localeNotifier.locale) {
                localeNotifier.setLocale(newLocale);
              }
            },
          ),
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.sendApplicationLog,
              softWrap: true,
              maxLines: 3,
              textAlign: TextAlign.start,
            ),
            onTap: () async {
              String? uri = await MyLogger().getFileUri();
              if (uri != null) {
                sendLogs(context, uri);
              } else {
                if (context.mounted) {
                  Toast.show(
                      context, AppLocalizations.of(context)!.noDataToSend);
                }
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
          FutureBuilder<String?>(
            future: ApiSettings.getCurrencyUpdateDate(),
            builder: (context, snapshot) {
              final loc = AppLocalizations.of(context)!;

              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text(
                  loc.currencyUpdateDateLoading,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                );
              } else if (snapshot.hasError) {
                return Text(
                  loc.currencyUpdateDateError,
                  style: const TextStyle(fontSize: 12, color: Colors.red),
                  textAlign: TextAlign.center,
                );
              } else if (snapshot.hasData && snapshot.data != null) {
                final dateFormatted =
                    DateFormat.yMd(Localizations.localeOf(context).toString())
                        .format(DateTime.parse(snapshot.data!));
                return Text(
                  loc.currencyUpdateDateValue(dateFormatted),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                );
              } else {
                return Text(
                  loc.currencyUpdateDateNone,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                );
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
                      String filePath = await DatabaseHelper(databaseFactory: databaseFactory).exportDatabase();

                      await Share.shareXFiles(
                        [XFile(filePath)],
                        subject:
                            AppLocalizations.of(context)!.backup_file_title,
                        text: AppLocalizations.of(context)!.backup_file_text,
                      );

                      Toast.show(context,
                          AppLocalizations.of(context)!.exportBackupStatement);
                    } catch (e) {
                      MyLogger.write("BACKUP - EXPORT", e.toString());
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
                      await DatabaseHelper(databaseFactory: databaseFactory).importDatabase();
                      context.read<TransactionBloc>().add(LoadTransactions());

                      final dateRange = DateTimeRange(
                        start: DateTime.now().subtract(Duration(days: 30)),
                        end: DateTime.now(),
                      );
                      context
                          .read<CategoryBloc>()
                          .add(LoadCategoriesWithSpentAmounts(dateRange));
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

  void sendLogs(BuildContext context, String path) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String model = "";
    String systemVersion = "";
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      model = "${androidInfo.brand} - ${androidInfo.model}";
      systemVersion = "SDK ${androidInfo.version.sdkInt}";
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      model = "Apple ${iosInfo.utsname.machine}";
      systemVersion = iosInfo.systemVersion;
    }
    final String version = packageInfo.version;
    final Email message = Email(
        body:
            'Błąd w aplikacji Smart Budget $version\nModel $model\nWersja systemu: $systemVersion\n',
        subject: 'Błąd w Smart Budget - wersja $version',
        recipients: ['mateusz.hermanowicz@icloud.com'],
        attachmentPaths: [path]);

    try {
      await FlutterEmailSender.send(message);
    } catch (e) {
      MyLogger.write("Wysyłanie logów", e.toString());
      Toast.show(context, "Problem z wysłaniem logów");
    }
  }
}
