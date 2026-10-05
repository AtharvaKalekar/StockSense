import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stocksense/main.dart';

void main() {
  testWidgets('App renders splash screen initially', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: StockSenseApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });
}
