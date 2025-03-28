import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_budget/data/repositories/recurring_transactions_repository.dart';
import 'package:smart_budget/screens/category/add_category_screen.dart';
import 'package:smart_budget/screens/category/edit_category_screen.dart';
import 'package:smart_budget/screens/main_screen.dart';
import 'package:smart_budget/screens/settings_screen.dart';
import 'package:smart_budget/screens/transaction/add_transaction_screen.dart';
import 'package:smart_budget/screens/transaction/edit_transaction_screen.dart';
import 'package:smart_budget/utils/recurring_transaction_worker.dart';

import 'blocs/category/category_bloc.dart';
import 'blocs/category/category_event.dart';
import 'blocs/currency_conversion/currency_conversion_bloc.dart';
import 'blocs/currency_conversion/currency_conversion_event.dart';
import 'blocs/transaction/transaction_bloc.dart';
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
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencies();
  await initializeDateFormatting('pl_PL', null);

  final dbHelper = DatabaseHelper();

  RecurringTransactionWorker.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => CurrencyNotifier()),
        ChangeNotifierProvider(create: (_) => LocaleNotifier()),
        ChangeNotifierProvider(create: (_) => FinanceNotifier()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) {
              final bloc = CurrencyConversionBloc(
                getIt<CurrencyRepository>(),
              );
              WidgetsBinding.instance.addPostFrameCallback((_) {
                bloc.add(LoadCurrencyRates());
              });
              return bloc;
            },
          ),
          BlocProvider(
            create: (context) => CategoryBloc(
              getIt<CategoryRepository>(),
              context.read<CurrencyConversionBloc>(),
              context.read<CurrencyNotifier>(),
              context.read<FinanceNotifier>(),
            ),
          ),
          BlocProvider(
            create: (context) => TransactionBloc(
              getIt<TransactionRepository>(),
              getIt<RecurringTransactionRepository>(),
              BlocProvider.of<CategoryBloc>(context),
              getIt<CategoryRepository>(),
              context.read<CurrencyConversionBloc>(),
              context.read<CurrencyNotifier>(),
            ),
          ),
        ],
        child: MyApp(dbHelper: dbHelper),
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
      debugShowCheckedModeBanner: false,
      locale: localeNotifier.locale,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green.shade800, brightness: Brightness.light),
        useMaterial3: true,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.green.shade800,
          unselectedItemColor: Colors.grey,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green.shade800, brightness: Brightness.dark),
        useMaterial3: true,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.green.shade800,
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
                  updateLocalizedCategoriesIfNeeded(context, localizations);
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

  Future<void> updateLocalizedCategoriesIfNeeded(
      BuildContext context, AppLocalizations localizations) async {
    final prefs = await SharedPreferences.getInstance();
    final isUpdated = prefs.getBool('localizedCategoriesUpdated') ?? false;

    if (!isUpdated) {
      context
          .read<CategoryBloc>()
          .add(UpdateLocalizedCategories(localizations));
      await prefs.setBool('localizedCategoriesUpdated', true);
    }
  }
}
