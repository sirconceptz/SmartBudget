import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../utils/available_icons.dart';

class IconPickerDialog extends StatelessWidget {
  const IconPickerDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppLocalizations.of(context)!.chooseIcon),
      content: SizedBox(
        width: double.maxFinite,
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: availableIcons.length,
          itemBuilder: (context, index) {
            final icon = availableIcons[index];
            return IconButton(
              icon: Icon(icon),
              onPressed: () {
                Navigator.of(context).pop(index); // <- zwraca index
              },
            );
          },
        ),
      ),
    );
  }
}
