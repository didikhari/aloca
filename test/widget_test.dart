import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Aloca app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Aloca'),
          ),
        ),
      ),
    );

    expect(find.text('Aloca'), findsOneWidget);
  });
}
