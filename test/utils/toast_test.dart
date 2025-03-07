import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_budget/utils/toast.dart';

void main() {
  testWidgets('should show a SnackBar with the correct message', (WidgetTester tester) async {
    const testMessage = 'Test message';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () => Toast.show(context, testMessage),
                child: Text('Show Toast'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    expect(find.text(testMessage), findsOneWidget);
  });
}
