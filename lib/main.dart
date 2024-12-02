import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_budget/screens/add_category_screen.dart';
import 'package:smart_budget/screens/add_transaction_screen.dart';
import 'package:smart_budget/screens/edit_category_screen.dart';
import 'package:smart_budget/screens/edit_transaction_screen.dart';
import 'package:smart_budget/screens/main_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'blocs/transaction_block/transaction_event.dart';
import 'blocs/transaction_type/transaction_type_bloc.dart';
import 'blocs/transaction_type/transaction_type_event.dart';
import 'di/di.dart';
import 'blocs/transaction_block/transaction_bloc.dart';
import 'data/repositories/transaction_repository.dart';
import 'models/transaction_model.dart';
import 'models/transaction_type_model.dart';

void main() async {
  setupDependencies();
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pl_PL', null);
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => TransactionBloc(getIt<TransactionRepository>())
            ..add(LoadTransactions()),
        ),
        BlocProvider(
          create: (context) => TransactionTypeBloc(getIt<TransactionRepository>())
            ..add(LoadTransactionTypes()),
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
    return MaterialApp(
      title: 'Smart Budget',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Colors.green,
          unselectedItemColor: Colors.grey,
        ),
      ),

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
             category:
                  ModalRoute.of(context)!.settings.arguments as TransactionType,
            ),
      },
    );
  }
}
