import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:supermercado_comparador/features/calculadora/presentation/widgets/calculadora_item_card.dart';
import 'package:supermercado_comparador/features/calculadora/domain/entities/item_calculadora.dart';
import 'package:supermercado_comparador/features/productos/domain/entities/producto.dart';

void main() {
  group('CalculadoraItemCard', () {
    late Producto testProducto;
    late ItemCalculadora testItem;

    setUp(() {
      testProducto = Producto(
        id: 1,
        nombre: 'Test Product',
        precio: 10.0,
        peso: 0.5,
        tamano: 'Medium',
        categoriaId: 1,
        almacenId: 1,
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
      );

      testItem = ItemCalculadora(
        id: 1,
        productoId: 1,
        producto: testProducto,
        cantidad: 2,
        subtotal: 20.0,
      );
    });

    Widget createWidgetUnderTest({
      ItemCalculadora? item,
      Function(int)? onCantidadChanged,
      VoidCallback? onEliminar,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: CalculadoraItemCard(
            item: item ?? testItem,
            onCantidadChanged: onCantidadChanged ?? (cantidad) {},
            onEliminar: onEliminar ?? () {},
          ),
        ),
      );
    }

    testWidgets('should display product information correctly', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('Precio unitario: €10.00'), findsOneWidget);
      expect(find.text('Peso: 500g'), findsOneWidget);
      expect(find.text('Tamaño: Medium'), findsOneWidget);
      expect(find.text('€20.00'), findsOneWidget); // subtotal
    });

    testWidgets('should display cantidad controls', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byIcon(Icons.remove), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.text('2'), findsOneWidget); // cantidad in text field
    });

    testWidgets('should display delete button', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('should call onEliminar when delete button is tapped', (tester) async {
      // arrange
      bool onEliminarCalled = false;
      
      // act
      await tester.pumpWidget(createWidgetUnderTest(
        onEliminar: () => onEliminarCalled = true,
      ));
      
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pump();

      // assert
      expect(onEliminarCalled, isTrue);
    });

    testWidgets('should call onCantidadChanged when add button is tapped', (tester) async {
      // arrange
      int? newCantidad;
      
      // act
      await tester.pumpWidget(createWidgetUnderTest(
        onCantidadChanged: (cantidad) => newCantidad = cantidad,
      ));
      
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();

      // assert
      expect(newCantidad, equals(3));
    });

    testWidgets('should call onCantidadChanged when remove button is tapped', (tester) async {
      // arrange
      int? newCantidad;
      
      // act
      await tester.pumpWidget(createWidgetUnderTest(
        onCantidadChanged: (cantidad) => newCantidad = cantidad,
      ));
      
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();

      // assert
      expect(newCantidad, equals(1));
    });

    testWidgets('should disable remove button when cantidad is 1', (tester) async {
      // arrange
      final itemWithCantidad1 = testItem.copyWith(cantidad: 1, subtotal: 10.0);
      
      // act
      await tester.pumpWidget(createWidgetUnderTest(item: itemWithCantidad1));

      // assert
      final removeButton = tester.widget<IconButton>(
        find.byIcon(Icons.remove),
      );
      expect(removeButton.onPressed, isNull);
    });

    testWidgets('should handle item without producto', (tester) async {
      // arrange
      const itemWithoutProducto = ItemCalculadora(
        id: 1,
        productoId: 999,
        producto: null,
        cantidad: 1,
        subtotal: 0.0,
      );
      
      // act
      await tester.pumpWidget(createWidgetUnderTest(item: itemWithoutProducto));

      // assert
      expect(find.text('Producto no encontrado'), findsOneWidget);
      expect(find.text('ID: 999'), findsOneWidget);
    });

    testWidgets('should update cantidad when text field is edited', (tester) async {
      // arrange
      int? newCantidad;
      
      // act
      await tester.pumpWidget(createWidgetUnderTest(
        onCantidadChanged: (cantidad) => newCantidad = cantidad,
      ));
      
      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), '5');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // assert
      expect(newCantidad, equals(5));
    });

    testWidgets('should not display peso if producto has no peso', (tester) async {
      // arrange
      final productoSinPeso = testProducto.copyWith(peso: null);
      final itemSinPeso = testItem.copyWith(producto: productoSinPeso);
      
      // act
      await tester.pumpWidget(createWidgetUnderTest(item: itemSinPeso));

      // assert
      expect(find.textContaining('Peso:'), findsNothing);
    });

    testWidgets('should not display tamano if producto has no tamano', (tester) async {
      // arrange
      final productoSinTamano = testProducto.copyWith(tamano: null);
      final itemSinTamano = testItem.copyWith(producto: productoSinTamano);
      
      // act
      await tester.pumpWidget(createWidgetUnderTest(item: itemSinTamano));

      // assert
      expect(find.textContaining('Tamaño:'), findsNothing);
    });
  });
}