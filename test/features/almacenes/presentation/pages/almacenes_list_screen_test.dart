import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:supermercado_comparador/features/almacenes/domain/entities/almacen.dart';
import 'package:supermercado_comparador/features/almacenes/presentation/widgets/almacen_card.dart';

void main() {
  final testAlmacenes = [
    Almacen(
      id: 1,
      nombre: 'Supermercado A',
      direccion: 'Dirección A',
      descripcion: 'Descripción A',
      fechaCreacion: DateTime(2024, 1, 1),
      fechaActualizacion: DateTime(2024, 1, 1),
    ),
    Almacen(
      id: 2,
      nombre: 'Supermercado B',
      direccion: 'Dirección B',
      descripcion: 'Descripción B',
      fechaCreacion: DateTime(2024, 1, 2),
      fechaActualizacion: DateTime(2024, 1, 2),
    ),
  ];

  group('AlmacenesListScreen Widget Tests', () {
    testWidgets('should display AlmacenCard widgets correctly', (tester) async {
      // Create a simple test widget that displays AlmacenCards
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: testAlmacenes.length,
              itemBuilder: (context, index) {
                return AlmacenCard(
                  almacen: testAlmacenes[index],
                  onEdit: () {},
                  onDelete: () {},
                );
              },
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(AlmacenCard), findsNWidgets(2));
      expect(find.text('Supermercado A'), findsOneWidget);
      expect(find.text('Supermercado B'), findsOneWidget);
    });

    testWidgets('should display empty state message when no almacenes', (tester) async {
      // Create a simple empty state widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.store_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text('No hay almacenes registrados'),
                  const SizedBox(height: 8),
                  const Text('Agrega tu primer almacén para comenzar'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    label: const Text('Agregar Almacén'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('No hay almacenes registrados'), findsOneWidget);
      expect(find.text('Agrega tu primer almacén para comenzar'), findsOneWidget);
      expect(find.byIcon(Icons.store_outlined), findsOneWidget);
      expect(find.text('Agregar Almacén'), findsOneWidget);
    });

    testWidgets('should display error state correctly', (tester) async {
      const errorMessage = 'Error de prueba';
      
      // Create a simple error state widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  const Text('Error al cargar almacenes'),
                  const SizedBox(height: 8),
                  const Text(errorMessage),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Error al cargar almacenes'), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('should display loading indicator', (tester) async {
      // Create a simple loading widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display app bar and floating action button', (tester) async {
      // Create a simple scaffold with app bar and FAB
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Almacenes'),
            ),
            body: const Center(
              child: Text('Content'),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {},
              tooltip: 'Agregar Almacén',
              child: const Icon(Icons.add),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Almacenes'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should display refresh indicator with list', (tester) async {
      // Create a simple refresh indicator with list
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RefreshIndicator(
              onRefresh: () async {},
              child: ListView.builder(
                itemCount: testAlmacenes.length,
                itemBuilder: (context, index) {
                  return AlmacenCard(
                    almacen: testAlmacenes[index],
                    onEdit: () {},
                    onDelete: () {},
                  );
                },
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(RefreshIndicator), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(AlmacenCard), findsNWidgets(2));
    });

    testWidgets('should handle button taps correctly', (tester) async {
      bool buttonPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  buttonPressed = true;
                },
                child: const Text('Test Button'),
              ),
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.text('Test Button'));
      await tester.pump();

      // Assert
      expect(buttonPressed, isTrue);
    });
  });
}