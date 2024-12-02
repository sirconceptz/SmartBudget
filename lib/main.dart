import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'data/repositories/category_repository.dart';
import 'data/repositories/transaction_repository.dart';
import 'di/di.dart';
import 'di/notifiers/currency_notifier.dart';
import 'di/notifiers/theme_notifier.dart';
import 'models/category.dart';
import 'models/transaction.dart';

void main() async {
  setupDependencies();
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pl_PL', null);

  runApp(
    MultiProvider(
      providers: [
        BlocProvider(
          create: (context) => TransactionBloc(getIt<TransactionRepository>())
            ..add(LoadTransactions()),
        ),
        BlocProvider(
          create: (context) =>
              CategoryBloc(getIt<CategoryRepository>())..add(LoadCategories()),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeNotifier(),
        ),
        ChangeNotifierProvider(
          create: (_) => CurrencyNotifier(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'Smart Budget',
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
        '/': (context) => MainScreen(),
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
