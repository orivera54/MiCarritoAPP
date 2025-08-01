import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supermercado_comparador/features/almacenes/domain/entities/almacen.dart';
import 'package:supermercado_comparador/features/productos/domain/entities/almacen_precio.dart';
import 'package:supermercado_comparador/features/productos/presentation/widgets/almacen_precio_selector.dart';

void main() {
  group('AlmacenPrecioSelector', () {
    late List<Almacen> testAlmacenes;

    setUp(() {
      testAlmacenes = [
        Almacen(
          id: 1,
          nombre: 'Almacén 1',
          direccion: 'Dirección 1',
          fechaCreacion: DateTime.now(),
          fechaActualizacion: DateTime.now(),
        ),
        Almacen(
          id: 2,
          nombre: 'Almacén 2',
          direccion: 'Dirección 2',
          fechaCreacion: DateTime.now(),
          fechaActualizacion: DateTime.now(),
        ),
        Almacen(
          id: 3,
          nombre: 'Almacén 3',
          fechaCreacion: DateTime.now(),
          fechaActualizacion: DateTime.now(),
        ),
      ];
    });

    testWidgets('should display all almacenes with price fields', (WidgetTester tester) async {
      List<AlmacenPrecio> almacenPrecios = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlmacenPrecioSelector(
              almacenes: testAlmacenes,
              almacenPrecios: almacenPrecios,
              onAlmacenPreciosChanged: (precios) {
                almacenPrecios = precios;
              },
            ),
          ),
        ),
      );

      // Verify all almacenes are displayed
      expect(find.text('Almacén 1'), findsOneWidget);
      expect(find.text('Almacén 2'), findsOneWidget);
      expect(find.text('Almacén 3'), findsOneWidget);

      // Verify addresses are displayed for almacenes that have them
      expect(find.text('Dirección 1'), findsOneWidget);
      expect(find.text('Dirección 2'), findsOneWidget);

      // Verify checkboxes and price fields are present
      expect(find.byType(Checkbox), findsNWidgets(3));
      expect(find.byType(TextFormField), findsNWidgets(3));
    });

    testWidgets('should show error message when no almacenes selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlmacenPrecioSelector(
              almacenes: testAlmacenes,
              almacenPrecios: const [],
              onAlmacenPreciosChanged: (precios) {},
            ),
          ),
        ),
      );

      expect(find.text('Selecciona al menos un almacén y especifica su precio'), findsOneWidget);
    });

    testWidgets('should enable price field when almacen is selected', (WidgetTester tester) async {
      List<AlmacenPrecio> almacenPrecios = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AlmacenPrecioSelector(
                  almacenes: testAlmacenes,
                  almacenPrecios: almacenPrecios,
                  onAlmacenPreciosChanged: (precios) {
                    setState(() {
                      almacenPrecios = precios;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Initially price fields should be disabled
      final priceFields = find.byType(TextFormField);
      expect(priceFields, findsNWidgets(3));

      // Tap first checkbox to select almacen
      await tester.tap(find.byType(Checkbox).first);
      await tester.pump();

      // Verify almacen was selected and price field is enabled
      expect(almacenPrecios.first.isSelected, isTrue);
    });

    testWidgets('should update price when text is entered', (WidgetTester tester) async {
      List<AlmacenPrecio> almacenPrecios = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AlmacenPrecioSelector(
                  almacenes: testAlmacenes,
                  almacenPrecios: almacenPrecios,
                  onAlmacenPreciosChanged: (precios) {
                    setState(() {
                      almacenPrecios = precios;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Select first almacen
      await tester.tap(find.byType(Checkbox).first);
      await tester.pump();

      // Enter price in the first price field
      await tester.enterText(find.byType(TextFormField).first, '10.50');
      await tester.pump();

      // Verify price was updated
      expect(almacenPrecios.first.precio, equals(10.50));
    });

    testWidgets('should show validation message for selected almacenes without valid prices', (WidgetTester tester) async {
      List<AlmacenPrecio> almacenPrecios = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AlmacenPrecioSelector(
                  almacenes: testAlmacenes,
                  almacenPrecios: almacenPrecios,
                  onAlmacenPreciosChanged: (precios) {
                    setState(() {
                      almacenPrecios = precios;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Select first almacen but don't enter price
      await tester.tap(find.byType(Checkbox).first);
      await tester.pump();

      expect(find.text('Todos los almacenes seleccionados deben tener un precio válido'), findsOneWidget);
    });

    testWidgets('should show success message when almacenes have valid prices', (WidgetTester tester) async {
      List<AlmacenPrecio> almacenPrecios = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return AlmacenPrecioSelector(
                  almacenes: testAlmacenes,
                  almacenPrecios: almacenPrecios,
                  onAlmacenPreciosChanged: (precios) {
                    setState(() {
                      almacenPrecios = precios;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Select first almacen and enter valid price
      await tester.tap(find.byType(Checkbox).first);
      await tester.pump();
      
      await tester.enterText(find.byType(TextFormField).first, '10.50');
      await tester.pump();

      expect(find.text('1 almacén(es) seleccionado(s) con precios válidos'), findsOneWidget);
    });

    testWidgets('should show create almacen button when callback provided', (WidgetTester tester) async {
      bool createCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlmacenPrecioSelector(
              almacenes: testAlmacenes,
              almacenPrecios: const [],
              onAlmacenPreciosChanged: (precios) {},
              onCreateAlmacen: () {
                createCalled = true;
              },
            ),
          ),
        ),
      );

      // Verify create button is present
      expect(find.byIcon(Icons.add_business), findsOneWidget);

      // Tap create button
      await tester.tap(find.byIcon(Icons.add_business));
      await tester.pump();

      // Verify callback was called
      expect(createCalled, isTrue);
    });

    testWidgets('should handle empty almacenes list', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AlmacenPrecioSelector(
              almacenes: const [],
              almacenPrecios: const [],
              onAlmacenPreciosChanged: (precios) {},
            ),
          ),
        ),
      );

      expect(find.text('No hay almacenes disponibles'), findsOneWidget);
    });
  });
}