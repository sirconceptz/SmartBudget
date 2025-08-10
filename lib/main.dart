import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'package:smart_budget/screens/transaction/transactions_screen.dart';
import 'package:smart_budget/utils/recurring_transaction_manager.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;

import 'blocs/category/category_bloc.dart';
import 'blocs/category/category_event.dart';
import 'blocs/currency_conversion/currency_conversion_bloc.dart';
import 'blocs/transaction/transaction_bloc.dart';
import 'data/db/database_helper.dart';
import 'data/repositories/category_repository.dart';
import 'data/repositories/transaction_repository.dart';
import 'di/di.dart';
import 'di/notifiers/currency_notifier.dart';
import 'di/notifiers/finance_notifier.dart';
import 'di/notifiers/locale_notifier.dart';
import 'di/notifiers/theme_notifier.dart';
import 'l10n/app_localizations.dart';
import 'models/category.dart';
import 'models/transaction.dart';
import 'utils/app_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  await initializeDateFormatting('pl_PL', null);

  final dbHelper = DatabaseHelper(databaseFactory: databaseFactory);

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
          BlocProvider<CurrencyConversionBloc>(
            create: (_) => getIt<CurrencyConversionBloc>(),
          ),
          BlocProvider<CategoryBloc>(
            create: (context) => CategoryBloc(
              getIt<CategoryRepository>(),
              context.read<CurrencyConversionBloc>(),
              context.read<CurrencyNotifier>(),
              context.read<FinanceNotifier>(),
            ),
          ),
          BlocProvider<TransactionBloc>(
            create: (context) => TransactionBloc(
              getIt<TransactionRepository>(),
              getIt<RecurringTransactionRepository>(),
              context.read<CategoryBloc>(),
              getIt<CategoryRepository>(),
              context.read<CurrencyConversionBloc>(),
              context.read<CurrencyNotifier>(),
            ),
          ),
        ],
        child: Builder(
          builder: (context) {
            return MyApp(dbHelper: dbHelper);
          },
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final DatabaseHelper dbHelper;

  MyApp({required this.dbHelper, super.key});

  final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: primaryColor,
      onPrimary: Colors.white,
      secondary: accentColor,
      onSecondary: Colors.black,
      background: backgroundColor,
      onBackground: Colors.black,
      surface: surfaceColor,
      onSurface: Colors.black,
      error: Colors.red,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      titleTextStyle: GoogleFonts.inter(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.white,
        letterSpacing: 0.2,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 4,
      margin: EdgeInsets.all(8),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      backgroundColor: Colors.white,
      elevation: 12,
      type: BottomNavigationBarType.fixed,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentColor,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    textTheme: GoogleFonts.interTextTheme(),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: primaryColor,
      contentTextStyle: TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
  );

  final darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: darkPrimaryColor,
      onPrimary: Colors.white,
      secondary: darkAccentColor,
      onSecondary: Colors.black,
      background: darkBackgroundColor,
      onBackground: Colors.white,
      surface: darkSurfaceColor,
      onSurface: Colors.white,
      error: Colors.red,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: darkBackgroundColor,
    cardColor: darkCardColor,
    appBarTheme: AppBarTheme(
      backgroundColor: darkPrimaryColor,
      elevation: 0,
      titleTextStyle: GoogleFonts.inter(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: Colors.white,
        letterSpacing: 0.2,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardTheme: CardThemeData(
      color: darkCardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 4,
      margin: EdgeInsets.all(8),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkSurfaceColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      selectedItemColor: darkAccentColor,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      backgroundColor: darkCardColor,
      elevation: 12,
      type: BottomNavigationBarType.fixed,
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: darkAccentColor,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: darkPrimaryColor,
      contentTextStyle: TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      behavior: SnackBarBehavior.floating,
    ),
  );

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
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeNotifier.themeMode,
      routes: {
        '/': (context) => FutureBuilder<void>(
              future: _initializeRecurringTransactions(context),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return Scaffold(
                    body: Center(
                        child: Text('Błąd inicjalizacji: ${snapshot.error}')),
                  );
                } else {
                  final localizations = AppLocalizations.of(context);
                  if (localizations != null) {
                    updateLocalizedCategoriesIfNeeded(context, localizations);
                  }
                  return MainScreen();
                }
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
        '/transactions': (context) => TransactionsScreen(),
      },
    );
  }

  Future<void> _initializeRecurringTransactions(BuildContext context) async {
    final currencyBloc = context.read<CurrencyConversionBloc>();
    await RecurringTransactionManager()
        .addMissingRecurringTransactions(currencyBloc);
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
