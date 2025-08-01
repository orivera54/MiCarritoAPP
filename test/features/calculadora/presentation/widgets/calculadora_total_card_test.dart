import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:supermercado_comparador/features/calculadora/presentation/widgets/calculadora_total_card.dart';

void main() {
  group('CalculadoraTotalCard', () {
    Widget createWidgetUnderTest({
      double total = 100.0,
      int itemCount = 5,
      VoidCallback? onGuardar,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: CalculadoraTotalCard(
            total: total,
            itemCount: itemCount,
            onGuardar: onGuardar ?? () {},
          ),
        ),
      );
    }

    testWidgets('should display total amount correctly', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest(total: 123.45));

      // assert
      expect(find.text('€123.45'), findsOneWidget);
    });

    testWidgets('should display item count correctly for multiple items', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest(itemCount: 5));

      // assert
      expect(find.text('5 productos'), findsOneWidget);
    });

    testWidgets('should display item count correctly for single item', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest(itemCount: 1));

      // assert
      expect(find.text('1 producto'), findsOneWidget);
    });

    testWidgets('should display summary title', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Resumen de compra'), findsOneWidget);
    });

    testWidgets('should display total label', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Total'), findsOneWidget);
    });

    testWidgets('should display save button', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Guardar lista'), findsOneWidget);
      expect(find.byIcon(Icons.save), findsOneWidget);
    });

    testWidgets('should call onGuardar when save button is tapped', (tester) async {
      // arrange
      bool onGuardarCalled = false;
      
      // act
      await tester.pumpWidget(createWidgetUnderTest(
        onGuardar: () => onGuardarCalled = true,
      ));
      
      await tester.tap(find.text('Guardar lista'));
      await tester.pump();

      // assert
      expect(onGuardarCalled, isTrue);
    });

    testWidgets('should disable save button when itemCount is 0', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest(itemCount: 0));

      // assert
      final saveButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Guardar lista'),
      );
      expect(saveButton.onPressed, isNull);
    });

    testWidgets('should enable save button when itemCount is greater than 0', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest(itemCount: 1));

      // assert
      final saveButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Guardar lista'),
      );
      expect(saveButton.onPressed, isNotNull);
    });

    testWidgets('should display zero total correctly', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest(total: 0.0));

      // assert
      expect(find.text('€0.00'), findsOneWidget);
    });

    testWidgets('should display zero items correctly', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest(itemCount: 0));

      // assert
      expect(find.text('0 productos'), findsOneWidget);
    });

    testWidgets('should have proper styling and layout', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(SafeArea), findsOneWidget);
      expect(find.byType(Column), findsAtLeastNWidgets(1));
      expect(find.byType(Row), findsOneWidget);
    });
  });
}