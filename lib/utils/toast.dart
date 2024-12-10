import 'package:flutter/material.dart';

class Toast {
  static void show(BuildContext context, String massage) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(massage)),
    );
  }
}
