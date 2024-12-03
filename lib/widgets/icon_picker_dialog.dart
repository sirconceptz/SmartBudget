import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class IconPickerDialog extends StatelessWidget {
  final List<IconData> availableIcons = [
    Icons.shopping_cart,
    Icons.fastfood,
    Icons.house,
    Icons.car_rental,
    Icons.health_and_safety,
    Icons.fitness_center,
    Icons.flight,
    Icons.music_note,
    Icons.movie,
    Icons.school,
    Icons.attach_money,
  ];

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
                Navigator.of(context).pop(icon);
              },
            );
          },
        ),
      ),
    );
  }
}
