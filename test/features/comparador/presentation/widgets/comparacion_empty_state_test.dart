import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:supermercado_comparador/features/comparador/presentation/widgets/comparacion_empty_state.dart';

void main() {
  group('ComparacionEmptyState', () {
    const terminoBusqueda = 'producto inexistente';

    Widget createWidgetUnderTest() {
      return const MaterialApp(
        home: Scaffold(
          body: ComparacionEmptyState(
            terminoBusqueda: terminoBusqueda,
          ),
        ),
      );
    }

    testWidgets('should display empty state message correctly', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('No se encontraron productos'), findsOneWidget);
      expect(find.text('No hay productos que coincidan con "$terminoBusqueda"'), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets('should display suggestions card', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Sugerencias:'), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('should display all suggestion items', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('• Verifica la ortografía del producto\n'
          '• Intenta con términos más generales\n'
          '• Asegúrate de haber agregado productos\n'
          '• Prueba escaneando un código QR'), findsOneWidget);
    });

    testWidgets('should center content properly', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      final centerWidgets = find.byType(Center);
      expect(centerWidgets, findsWidgets);
      
      // Find the main center widget that contains our content
      final mainCenter = tester.widget<Center>(centerWidgets.first);
      final scrollView = mainCenter.child as SingleChildScrollView;
      final column = scrollView.child as Column;
      
      expect(column.mainAxisAlignment, equals(MainAxisAlignment.center));
    });

    testWidgets('should use correct icon colors', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      final searchOffIcon = tester.widget<Icon>(find.byIcon(Icons.search_off));
      expect(searchOffIcon.color, equals(Colors.grey[400]));

      final lightbulbIcon = tester.widget<Icon>(find.byIcon(Icons.lightbulb_outline));
      expect(lightbulbIcon.color, equals(Colors.amber[700]));
    });

    testWidgets('should apply correct text styles', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      final titleText = tester.widget<Text>(find.text('No se encontraron productos'));
      expect(titleText.style?.color, equals(Colors.grey[600]));

      final subtitleText = tester.widget<Text>(
        find.text('No hay productos que coincidan con "$terminoBusqueda"')
      );
      expect(subtitleText.style?.fontSize, equals(16));
      expect(subtitleText.style?.color, equals(Colors.grey));
      expect(subtitleText.textAlign, equals(TextAlign.center));

      final suggestionsTitle = tester.widget<Text>(find.text('Sugerencias:'));
      expect(suggestionsTitle.style?.fontWeight, equals(FontWeight.bold));
      expect(suggestionsTitle.style?.fontSize, equals(16));
    });

    testWidgets('should have proper spacing between elements', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      final sizedBoxes = find.byType(SizedBox);
      expect(sizedBoxes, findsWidgets); // Should have multiple SizedBox widgets for spacing
      
      // Verify that there are at least some spacing elements
      expect(sizedBoxes.evaluate().length, greaterThan(3));
    });

    testWidgets('should display with different search terms', (tester) async {
      // Arrange
      const differentTerm = 'otro producto';
      const widget = MaterialApp(
        home: Scaffold(
          body: ComparacionEmptyState(
            terminoBusqueda: differentTerm,
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.text('No hay productos que coincidan con "$differentTerm"'), findsOneWidget);
    });

    testWidgets('should handle empty search term', (tester) async {
      // Arrange
      const emptyTerm = '';
      const widget = MaterialApp(
        home: Scaffold(
          body: ComparacionEmptyState(
            terminoBusqueda: emptyTerm,
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.text('No hay productos que coincidan con ""'), findsOneWidget);
    });

    testWidgets('should handle special characters in search term', (tester) async {
      // Arrange
      const specialTerm = 'café & té (orgánico)';
      const widget = MaterialApp(
        home: Scaffold(
          body: ComparacionEmptyState(
            terminoBusqueda: specialTerm,
          ),
        ),
      );

      // Act
      await tester.pumpWidget(widget);

      // Assert
      expect(find.text('No hay productos que coincidan con "$specialTerm"'), findsOneWidget);
    });
  });
}