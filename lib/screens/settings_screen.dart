import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Ekran ustawień',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
