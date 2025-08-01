import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supermercado_comparador/features/almacenes/domain/entities/almacen.dart';
import 'package:supermercado_comparador/features/productos/presentation/widgets/multi_almacen_selector.dart';

void main() {
  group('MultiAlmacenSelector', () {
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

    testWidgets('should display all almacenes as checkboxes', (WidgetTester tester) async {
      List<int> selectedIds = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiAlmacenSelector(
              almacenes: testAlmacenes,
              selectedAlmacenIds: selectedIds,
              onSelectionChanged: (ids) {
                selectedIds = ids;
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

      // Verify checkboxes are present
      expect(find.byType(CheckboxListTile), findsNWidgets(3));
    });

    testWidgets('should show error message when no almacenes selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiAlmacenSelector(
              almacenes: testAlmacenes,
              selectedAlmacenIds: const [],
              onSelectionChanged: (ids) {},
            ),
          ),
        ),
      );

      expect(find.text('Selecciona al menos un almacén'), findsOneWidget);
    });

    testWidgets('should show selection count when almacenes are selected', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiAlmacenSelector(
              almacenes: testAlmacenes,
              selectedAlmacenIds: const [1, 2],
              onSelectionChanged: (ids) {},
            ),
          ),
        ),
      );

      expect(find.text('2 almacén(es) seleccionado(s)'), findsOneWidget);
    });

    testWidgets('should toggle selection when checkbox is tapped', (WidgetTester tester) async {
      List<int> selectedIds = [];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return MultiAlmacenSelector(
                  almacenes: testAlmacenes,
                  selectedAlmacenIds: selectedIds,
                  onSelectionChanged: (ids) {
                    setState(() {
                      selectedIds = ids;
                    });
                  },
                );
              },
            ),
          ),
        ),
      );

      // Initially no almacenes selected
      expect(selectedIds, isEmpty);

      // Tap first checkbox
      await tester.tap(find.byType(CheckboxListTile).first);
      await tester.pump();

      // Verify selection changed
      expect(selectedIds, contains(1));

      // Tap second checkbox
      await tester.tap(find.byType(CheckboxListTile).at(1));
      await tester.pump();

      // Verify both are selected
      expect(selectedIds, containsAll([1, 2]));

      // Tap first checkbox again to deselect
      await tester.tap(find.byType(CheckboxListTile).first);
      await tester.pump();

      // Verify only second is selected
      expect(selectedIds, equals([2]));
    });

    testWidgets('should show create almacen button when callback provided', (WidgetTester tester) async {
      bool createCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultiAlmacenSelector(
              almacenes: testAlmacenes,
              selectedAlmacenIds: const [],
              onSelectionChanged: (ids) {},
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
            body: MultiAlmacenSelector(
              almacenes: const [],
              selectedAlmacenIds: const [],
              onSelectionChanged: (ids) {},
            ),
          ),
        ),
      );

      expect(find.text('No hay almacenes disponibles'), findsOneWidget);
    });
  });
}