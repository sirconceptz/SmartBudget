import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:smart_budget/screens/add_category_screen.dart';
import 'package:smart_budget/screens/add_transaction_screen.dart';
import 'package:smart_budget/screens/edit_category_screen.dart';
import 'package:smart_budget/screens/edit_transaction_screen.dart';
import 'package:smart_budget/screens/main_screen.dart';
import 'package:smart_budget/screens/settings_screen.dart';

import 'blocs/category/category_bloc.dart';
import 'blocs/category/category_event.dart';
import 'blocs/transaction/transaction_bloc.dart';
import 'blocs/transaction/transaction_event.dart';
import 'data/db/database_helper.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/currency_repository.dart';
import 'data/repositories/transaction_repository.dart';
import 'di/di.dart';
import 'di/notifiers/currency_notifier.dart';
import 'di/notifiers/finance_notifier.dart';
import 'di/notifiers/locale_notifier.dart';
import 'di/notifiers/theme_notifier.dart';
import 'models/category.dart';
import 'models/transaction.dart';

void main() async {
  setupDependencies();
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pl_PL', null);

  final dbHelper = DatabaseHelper();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeNotifier(),
        ),
        ChangeNotifierProvider(
          create: (_) => CurrencyNotifier(),
        ),
        ChangeNotifierProvider(
          create: (_) => LocaleNotifier(),
        ),
        ChangeNotifierProvider(
          create: (_) => FinanceNotifier(),
        ),
        BlocProvider(
          create: (context) => TransactionBloc(
            getIt<TransactionRepository>(),
            getIt<CurrencyRepository>(),
            context.read<CurrencyNotifier>().currency,
          )..add(LoadTransactions()),
        ),
        BlocProvider(
          create: (context) =>
          CategoryBloc(getIt<CategoryRepository>())..add(LoadCategories()),
        ),
      ],
      child: MyApp(
        dbHelper: dbHelper,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final DatabaseHelper dbHelper;

  const MyApp({required this.dbHelper, super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final localeNotifier = Provider.of<LocaleNotifier>(context);

    return MaterialApp(
      title: 'Smart Budget',
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: localeNotifier.locale,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green, brightness: Brightness.light),
        useMaterial3: true,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green, brightness: Brightness.dark),
        useMaterial3: true,
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
        ),
      ),
      themeMode: themeNotifier.themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => Builder(
              builder: (context) {
                final localizations = AppLocalizations.of(context);
                if (localizations != null) {
                  context
                      .read<CategoryBloc>()
                      .add(UpdateLocalizedCategories(localizations));
                }
                return MainScreen();
              },
            ),
        '/addTransaction': (context) => AddTransactionScreen(),
        '/addCategory': (context) => AddCategoryScreen(),
        '/editTransaction': (context) => EditTransactionScreen(
              transaction:
                  ModalRoute.of(context)!.settings.arguments as Transaction,
            ),
        '/editCategory': (context) => EditCategoryScreen(
              category: ModalRoute.of(context)!.settings.arguments as Category,
            ),
        '/settings': (context) => SettingsScreen(),
      },
    );
  }
}
