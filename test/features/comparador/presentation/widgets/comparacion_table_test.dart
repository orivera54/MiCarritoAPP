import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:supermercado_comparador/features/comparador/presentation/widgets/comparacion_table.dart';
import 'package:supermercado_comparador/features/comparador/domain/entities/producto_comparacion.dart';
import 'package:supermercado_comparador/features/productos/domain/entities/producto.dart';
import 'package:supermercado_comparador/features/almacenes/domain/entities/almacen.dart';

void main() {
  group('ComparacionTable', () {
    late List<ProductoComparacion> productos;
    late Almacen almacen1;
    late Almacen almacen2;
    late Producto producto1;
    late Producto producto2;

    setUp(() {
      almacen1 = Almacen(
        id: 1,
        nombre: 'Almacén 1',
        direccion: 'Calle 1, 123',
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
      );

      almacen2 = Almacen(
        id: 2,
        nombre: 'Almacén 2',
        direccion: 'Calle 2, 456',
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
      );

      producto1 = Producto(
        id: 1,
        nombre: 'Leche Entera',
        precio: 1.50,
        tamano: '1L',
        peso: 1.0,
        codigoQR: '1234567890',
        categoriaId: 1,
        almacenId: 1,
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
      );

      producto2 = Producto(
        id: 2,
        nombre: 'Leche Entera',
        precio: 1.20,
        tamano: '1L',
        peso: 1.0,
        codigoQR: '0987654321',
        categoriaId: 1,
        almacenId: 2,
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
      );

      productos = [
        ProductoComparacion(
          producto: producto1,
          almacen: almacen1,
          esMejorPrecio: false,
        ),
        ProductoComparacion(
          producto: producto2,
          almacen: almacen2,
          esMejorPrecio: true,
        ),
      ];
    });

    Widget createWidgetUnderTest(List<ProductoComparacion> productos) {
      return MaterialApp(
        home: Scaffold(
          body: ComparacionTable(productos: productos),
        ),
      );
    }

    testWidgets('should display empty message when no products', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest([]));

      // Assert
      expect(find.text('No hay productos para comparar'), findsOneWidget);
    });

    testWidgets('should display table header correctly', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest(productos));

      // Assert
      expect(find.text('Producto'), findsOneWidget);
      expect(find.text('Almacén'), findsOneWidget);
      expect(find.text('Precio'), findsOneWidget);
    });

    testWidgets('should display product information correctly', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest(productos));

      // Assert
      expect(find.text('Leche Entera'), findsNWidgets(2));
      expect(find.text('1L'), findsNWidgets(2));
      expect(find.text('Almacén 1'), findsOneWidget);
      expect(find.text('Almacén 2'), findsOneWidget);
      // Check for formatted prices (the exact format may vary by locale)
      expect(find.textContaining('1,50'), findsOneWidget);
      expect(find.textContaining('1,20'), findsOneWidget);
    });

    testWidgets('should highlight best price with star icon', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest(productos));

      // Assert
      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('should show product details dialog when product is tapped', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest(productos));
      await tester.tap(find.text('Leche Entera').first);
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Leche Entera'), findsWidgets); // Title and in table (may be more than 2)
      expect(find.text('Almacén:'), findsOneWidget);
      expect(find.text('Precio:'), findsOneWidget);
      expect(find.text('Tamaño:'), findsOneWidget);
      expect(find.text('Peso:'), findsOneWidget);
      expect(find.text('Código QR:'), findsOneWidget);
      expect(find.text('Dirección:'), findsOneWidget);
    });

    testWidgets('should show best price indicator in product details dialog', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest(productos));
      await tester.tap(find.text('Leche Entera').last); // Second product (best price)
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Mejor precio disponible'), findsOneWidget);
      expect(find.byIcon(Icons.star), findsNWidgets(2)); // One in table, one in dialog
    });

    testWidgets('should not show best price indicator for non-best price products', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest(productos));
      await tester.tap(find.text('Leche Entera').first); // First product (not best price)
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Mejor precio disponible'), findsNothing);
    });

    testWidgets('should close product details dialog when close button is pressed', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest(productos));
      await tester.tap(find.text('Leche Entera').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cerrar'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('should handle products without optional fields', (tester) async {
      // Arrange
      final productoSinOpcionales = Producto(
        id: 3,
        nombre: 'Producto Simple',
        precio: 2.00,
        categoriaId: 1,
        almacenId: 1,
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
      );

      final almacenSinDireccion = Almacen(
        id: 3,
        nombre: 'Almacén Simple',
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
      );

      final productosSimples = [
        ProductoComparacion(
          producto: productoSinOpcionales,
          almacen: almacenSinDireccion,
          esMejorPrecio: true,
        ),
      ];

      // Act
      await tester.pumpWidget(createWidgetUnderTest(productosSimples));
      await tester.tap(find.text('Producto Simple'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Tamaño:'), findsNothing);
      expect(find.text('Peso:'), findsNothing);
      expect(find.text('Código QR:'), findsNothing);
      expect(find.text('Dirección:'), findsNothing);
    });

    testWidgets('should apply correct styling to best price row', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest(productos));

      // Assert
      // Find containers with green background (best price styling)
      final containers = find.byType(Container);
      bool foundGreenContainer = false;
      
      for (final containerFinder in containers.evaluate()) {
        final container = containerFinder.widget as Container;
        if (container.decoration is BoxDecoration) {
          final decoration = container.decoration as BoxDecoration;
          if (decoration.color == Colors.green.shade50) {
            foundGreenContainer = true;
            expect(decoration.border, isA<Border>());
            break;
          }
        }
      }
      
      expect(foundGreenContainer, isTrue, reason: 'Should find a container with green background for best price');
    });

    testWidgets('should truncate long product names', (tester) async {
      // Arrange
      final productoNombreLargo = Producto(
        id: 4,
        nombre: 'Este es un nombre de producto muy largo que debería ser truncado en la tabla',
        precio: 3.00,
        categoriaId: 1,
        almacenId: 1,
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
      );

      final productosNombreLargo = [
        ProductoComparacion(
          producto: productoNombreLargo,
          almacen: almacen1,
          esMejorPrecio: true,
        ),
      ];

      // Act
      await tester.pumpWidget(createWidgetUnderTest(productosNombreLargo));

      // Assert
      final textWidget = tester.widget<Text>(
        find.text('Este es un nombre de producto muy largo que debería ser truncado en la tabla'),
      );
      expect(textWidget.maxLines, equals(2));
      expect(textWidget.overflow, equals(TextOverflow.ellipsis));
    });
  });
}