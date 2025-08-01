import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:supermercado_comparador/features/almacenes/domain/entities/almacen.dart';
import 'package:supermercado_comparador/features/almacenes/presentation/widgets/almacen_card.dart';

void main() {
  final testAlmacen = Almacen(
    id: 1,
    nombre: 'Supermercado Test',
    direccion: 'Dirección Test',
    descripcion: 'Descripción Test',
    fechaCreacion: DateTime(2024, 1, 1),
    fechaActualizacion: DateTime(2024, 1, 2),
  );

  final testAlmacenWithoutOptionalFields = Almacen(
    id: 2,
    nombre: 'Supermercado Sin Extras',
    direccion: null,
    descripcion: null,
    fechaCreacion: DateTime(2024, 1, 1),
    fechaActualizacion: DateTime(2024, 1, 1),
  );

  Widget createWidgetUnderTest({
    required Almacen almacen,
    VoidCallback? onEdit,
    VoidCallback? onDelete,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: AlmacenCard(
          almacen: almacen,
          onEdit: onEdit ?? () {},
          onDelete: onDelete ?? () {},
        ),
      ),
    );
  }

  group('AlmacenCard', () {
    testWidgets('should display almacen name', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest(almacen: testAlmacen));

      // Assert
      expect(find.text('Supermercado Test'), findsOneWidget);
    });

    testWidgets('should display direccion when provided', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest(almacen: testAlmacen));

      // Assert
      expect(find.text('Dirección Test'), findsOneWidget);
      expect(find.byIcon(Icons.location_on_outlined), findsOneWidget);
    });

    testWidgets('should not display direccion when null', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest(almacen: testAlmacenWithoutOptionalFields));

      // Assert
      expect(find.byIcon(Icons.location_on_outlined), findsNothing);
    });

    testWidgets('should display descripcion when provided', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest(almacen: testAlmacen));

      // Assert
      expect(find.text('Descripción Test'), findsOneWidget);
    });

    testWidgets('should not display descripcion when null', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest(almacen: testAlmacenWithoutOptionalFields));

      // Assert
      expect(find.text('Descripción Test'), findsNothing);
    });

    testWidgets('should display creation date', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest(almacen: testAlmacen));

      // Assert
      expect(find.text('Creado: 01/01/2024'), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('should display update date when different from creation date', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest(almacen: testAlmacen));

      // Assert
      expect(find.text('Actualizado: 02/01/2024'), findsOneWidget);
      expect(find.byIcon(Icons.update), findsOneWidget);
    });

    testWidgets('should not display update date when same as creation date', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest(almacen: testAlmacenWithoutOptionalFields));

      // Assert
      expect(find.text('Actualizado:'), findsNothing);
      expect(find.byIcon(Icons.update), findsNothing);
    });

    testWidgets('should display popup menu button', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest(almacen: testAlmacen));

      // Assert
      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
    });

    testWidgets('should show popup menu when tapped', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest(almacen: testAlmacen));
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Editar'), findsOneWidget);
      expect(find.text('Eliminar'), findsOneWidget);
      expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('should call onEdit when edit menu item is tapped', (tester) async {
      // Arrange
      bool editCalled = false;
      
      // Act
      await tester.pumpWidget(createWidgetUnderTest(
        almacen: testAlmacen,
        onEdit: () => editCalled = true,
      ));
      
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Editar'));
      await tester.pumpAndSettle();

      // Assert
      expect(editCalled, isTrue);
    });

    testWidgets('should call onDelete when delete menu item is tapped', (tester) async {
      // Arrange
      bool deleteCalled = false;
      
      // Act
      await tester.pumpWidget(createWidgetUnderTest(
        almacen: testAlmacen,
        onDelete: () => deleteCalled = true,
      ));
      
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();

      // Assert
      expect(deleteCalled, isTrue);
    });

    testWidgets('should display card with proper styling', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest(almacen: testAlmacen));

      // Assert
      expect(find.byType(Card), findsOneWidget);
      
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, equals(2));
    });

    testWidgets('should format dates correctly', (tester) async {
      // Arrange
      final almacenWithSpecificDate = Almacen(
        id: 3,
        nombre: 'Test Store',
        fechaCreacion: DateTime(2024, 12, 5),
        fechaActualizacion: DateTime(2024, 12, 25),
      );

      // Act
      await tester.pumpWidget(createWidgetUnderTest(almacen: almacenWithSpecificDate));

      // Assert
      expect(find.text('Creado: 05/12/2024'), findsOneWidget);
      expect(find.text('Actualizado: 25/12/2024'), findsOneWidget);
    });
  });
}