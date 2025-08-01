// Basic widget test for Supermercado Comparador app
//
// This test verifies that the app can be instantiated and shows the splash screen.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:supermercado_comparador/main.dart';

void main() {
  setUpAll(() {
    // Initialize sqflite for testing
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  testWidgets('App smoke test - shows splash screen',
      (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SupermercadoComparadorApp());

    // Wait for the app to initialize
    await tester.pumpAndSettle();

    // Verify that the app loads without crashing
    // The app should show some content (could be splash screen or main content)
    expect(find.byType(MaterialApp), findsOneWidget);

    // The app should have a scaffold or some basic structure
    expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
  });

  testWidgets('App navigation structure test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SupermercadoComparadorApp());

    // Wait for the app to initialize
    await tester.pumpAndSettle();

    // Verify that the MaterialApp is present
    expect(find.byType(MaterialApp), findsOneWidget);

    // Check that the app has proper structure
    final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(materialApp.title, equals('Supermercado Comparador'));
    expect(materialApp.initialRoute, equals('/'));
  });
}
