import 'package:flutter/material.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String content;
  final String cancelText;
  final String confirmText;
  final VoidCallback? onConfirm;

  const ConfirmDialog({
    Key? key,
    required this.title,
    required this.content,
    required this.cancelText,
    required this.confirmText,
    this.onConfirm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, true);
            if (onConfirm != null) {
              onConfirm!();
            }
          },
          child: Text(confirmText),
        ),
      ],
    );
  }
}
