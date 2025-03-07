
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_budget/widgets/setting_row.dart';

void main() {
  testWidgets('SettingRow displays correct title and handles dropdown change', (WidgetTester tester) async {
    const icon = Icons.settings;
    const title = 'Select Option';
    const value = 1;
    final items = [
      DropdownMenuItem<int>(value: 1, child: Text('Option 1')),
      DropdownMenuItem<int>(value: 2, child: Text('Option 2')),
      DropdownMenuItem<int>(value: 3, child: Text('Option 3')),
    ];

    int? selectedValue;
    void onChanged(int? value) {
      selectedValue = value;
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SettingRow<int>(
            icon: icon,
            title: title,
            value: value,
            items: items,
            onChanged: onChanged,
          ),
        ),
      ),
    );

    expect(find.text(title), findsOneWidget);
    expect(find.byIcon(icon), findsOneWidget);

    await tester.tap(find.byType(DropdownButton<int>));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Option 2').last);
    await tester.pumpAndSettle();

    expect(selectedValue, 2);
  });
}
