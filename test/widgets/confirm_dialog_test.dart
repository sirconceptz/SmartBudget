import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_budget/widgets/confirm_dialog.dart';

void main() {
  testWidgets('should display the correct title and content', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ConfirmDialog(
            title: 'Confirm Action',
            content: 'Are you sure?',
            cancelText: 'Cancel',
            confirmText: 'OK',
          ),
        ),
      ),
    );

    expect(find.text('Confirm Action'), findsOneWidget);
    expect(find.text('Are you sure?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('OK'), findsOneWidget);
  });

  testWidgets('should return false when cancel is pressed', (WidgetTester tester) async {
    bool? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showDialog<bool>(
                context: context,
                builder: (context) => ConfirmDialog(
                  title: 'Delete Item',
                  content: 'Are you sure?',
                  cancelText: 'No',
                  confirmText: 'Yes',
                ),
              );
            },
            child: Text('Open Dialog'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle(); // Czekamy, aż dialog się otworzy

    await tester.tap(find.text('No')); // Klikamy "No"
    await tester.pumpAndSettle(); // Czekamy na zamknięcie

    expect(result, isFalse);
  });

  testWidgets('should return true and call onConfirm when confirm is pressed', (WidgetTester tester) async {
    bool? result;
    bool confirmCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              result = await showDialog<bool>(
                context: context,
                builder: (context) => ConfirmDialog(
                  title: 'Delete Item',
                  content: 'Are you sure?',
                  cancelText: 'No',
                  confirmText: 'Yes',
                  onConfirm: () => confirmCalled = true,
                ),
              );
            },
            child: Text('Open Dialog'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Yes'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(confirmCalled, isTrue);
  });
}
