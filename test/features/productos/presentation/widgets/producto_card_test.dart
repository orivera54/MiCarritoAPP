import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supermercado_comparador/features/productos/domain/entities/producto.dart';
import 'package:supermercado_comparador/features/productos/presentation/widgets/producto_card.dart';

void main() {
  group('ProductoCard', () {
    late Producto testProducto;

    setUp(() {
      testProducto = Producto(
        id: 1,
        nombre: 'Test Product',
        precio: 2.50,
        peso: 1.0,
        tamano: '1L',
        codigoQR: 'TEST123',
        categoriaId: 1,
        almacenId: 1,
        fechaCreacion: DateTime(2024, 1, 1),
        fechaActualizacion: DateTime(2024, 1, 2),
      );
    });

    Widget createWidgetUnderTest({
      Producto? producto,
      String almacenNombre = 'Test Store',
      String categoriaNombre = 'Test Category',
      VoidCallback? onTap,
      VoidCallback? onDelete,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: ProductoCard(
            producto: producto ?? testProducto,
            almacenNombre: almacenNombre,
            categoriaNombre: categoriaNombre,
            onTap: onTap,
            onDelete: onDelete,
          ),
        ),
      );
    }

    testWidgets('displays product information correctly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('€2,50'), findsOneWidget);
      expect(find.text('Test Store'), findsOneWidget);
      expect(find.text('Test Category'), findsOneWidget);
      expect(find.text('1,00kg'), findsOneWidget);
      expect(find.text('1L'), findsOneWidget);
      expect(find.text('QR'), findsOneWidget);
    });

    testWidgets('displays creation date', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Creado: 01/01/2024'), findsOneWidget);
    });

    testWidgets('displays update date when different from creation', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Editado: 02/01/2024'), findsOneWidget);
    });

    testWidgets('does not display update date when same as creation', (tester) async {
      final producto = testProducto.copyWith(
        fechaActualizacion: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(createWidgetUnderTest(producto: producto));

      expect(find.text('Editado: 01/01/2024'), findsNothing);
    });

    testWidgets('handles missing optional fields', (tester) async {
      final producto = Producto(
        id: 1,
        nombre: 'Simple Product',
        precio: 1.99,
        categoriaId: 1,
        almacenId: 1,
        fechaCreacion: DateTime(2024, 1, 1),
        fechaActualizacion: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(createWidgetUnderTest(producto: producto));

      expect(find.text('Simple Product'), findsOneWidget);
      expect(find.text('€1,99'), findsOneWidget);
      expect(find.text('Test Store'), findsOneWidget);
      expect(find.text('Test Category'), findsOneWidget);
      
      // Optional fields should not be displayed
      expect(find.textContaining('kg'), findsNothing);
      expect(find.text('QR'), findsNothing);
    });

    testWidgets('calls onTap when card is tapped', (tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(createWidgetUnderTest(
        onTap: () => tapped = true,
      ));

      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });

    testWidgets('shows delete button when onDelete is provided', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest(
        onDelete: () {},
      ));

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('does not show delete button when onDelete is null', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.delete_outline), findsNothing);
    });

    testWidgets('calls onDelete when delete button is tapped', (tester) async {
      bool deleted = false;
      
      await tester.pumpWidget(createWidgetUnderTest(
        onDelete: () => deleted = true,
      ));

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(deleted, isTrue);
    });

    testWidgets('displays correct weight formatting', (tester) async {
      // Test weight less than 1kg
      final lightProduct = testProducto.copyWith(peso: 0.5);
      await tester.pumpWidget(createWidgetUnderTest(producto: lightProduct));
      expect(find.text('500g'), findsOneWidget);

      // Test weight more than 1kg
      final heavyProduct = testProducto.copyWith(peso: 2.5);
      await tester.pumpWidget(createWidgetUnderTest(producto: heavyProduct));
      await tester.pumpAndSettle();
      expect(find.text('2,50kg'), findsOneWidget);
    });

    testWidgets('displays all detail chips with correct icons', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byIcon(Icons.store), findsOneWidget);
      expect(find.byIcon(Icons.category), findsOneWidget);
      expect(find.byIcon(Icons.scale), findsOneWidget);
      expect(find.byIcon(Icons.straighten), findsOneWidget);
      expect(find.byIcon(Icons.qr_code), findsOneWidget);
    });
  });
}