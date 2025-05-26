import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smart_budget/screens/transaction/transactions_screen.dart';

import './settings_screen.dart';
import 'category/category_list_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final GlobalKey<SettingsScreenState> _settingsKey = GlobalKey<SettingsScreenState>();
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();

    _screens = [
      HomeScreen(),
      TransactionsScreen(),
      CategoryListScreen(),
      SettingsScreen(key: _settingsKey),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.appTitle),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 3) {
            _settingsKey.currentState?.loadUpdateDate();
          }
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: AppLocalizations.of(context)!.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: AppLocalizations.of(context)!.transactions,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: AppLocalizations.of(context)!.categories,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: AppLocalizations.of(context)!.settings,
          ),
        ],
      ),
    );
  }
}
