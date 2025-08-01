import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:supermercado_comparador/core/database/database_helper.dart';
import 'package:supermercado_comparador/features/almacenes/data/datasources/almacen_local_data_source.dart';
import 'package:supermercado_comparador/features/almacenes/data/repositories/almacen_repository_impl.dart';
import 'package:supermercado_comparador/features/almacenes/domain/usecases/create_almacen.dart';
import 'package:supermercado_comparador/features/almacenes/domain/usecases/get_all_almacenes.dart';
import 'package:supermercado_comparador/features/almacenes/domain/usecases/get_almacen_by_id.dart';
import 'package:supermercado_comparador/features/almacenes/domain/usecases/update_almacen.dart';
import 'package:supermercado_comparador/features/almacenes/domain/usecases/delete_almacen.dart';
import 'package:supermercado_comparador/features/almacenes/presentation/bloc/almacen_bloc.dart';
import 'package:supermercado_comparador/features/almacenes/presentation/bloc/almacen_event.dart';
import 'package:supermercado_comparador/features/almacenes/presentation/bloc/almacen_state.dart';
import 'package:supermercado_comparador/features/almacenes/presentation/pages/almacenes_list_screen.dart';
import 'package:supermercado_comparador/features/almacenes/presentation/pages/almacen_form_screen.dart';
import 'package:supermercado_comparador/features/almacenes/domain/entities/almacen.dart';

void main() {
  group('Almacenes Integration Tests', () {
    late DatabaseHelper databaseHelper;
    late AlmacenLocalDataSourceImpl dataSource;
    late AlmacenRepositoryImpl repository;
    late AlmacenBloc almacenBloc;

    setUpAll(() {
      // Initialize FFI for testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      // Create in-memory database for testing
      databaseHelper = DatabaseHelper();
      await databaseHelper.database;

      dataSource = AlmacenLocalDataSourceImpl(databaseHelper: databaseHelper);
      repository = AlmacenRepositoryImpl(localDataSource: dataSource);

      almacenBloc = AlmacenBloc(
        createAlmacen: CreateAlmacen(repository),
        getAllAlmacenes: GetAllAlmacenes(repository),
        getAlmacenById: GetAlmacenById(repository),
        updateAlmacen: UpdateAlmacen(repository),
        deleteAlmacen: DeleteAlmacen(repository),
      );
    });

    tearDown(() async {
      await almacenBloc.close();
      await databaseHelper.close();
    });

    testWidgets('Complete almacenes management flow',
        (WidgetTester tester) async {
      // Build the widget tree with BLoC provider
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AlmacenBloc>(
            create: (context) => almacenBloc,
            child: const AlmacenesListScreen(),
          ),
        ),
      );

      // Initial state should show empty list
      expect(find.text('No hay almacenes registrados'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Tap the add button
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Should navigate to form screen
      expect(find.byType(AlmacenFormScreen), findsOneWidget);
      expect(find.text('Nuevo Almacén'), findsOneWidget);

      // Fill the form
      await tester.enterText(
          find.byKey(const Key('nombre_field')), 'Supermercado Test');
      await tester.enterText(
          find.byKey(const Key('direccion_field')), 'Calle Test 123');
      await tester.enterText(
          find.byKey(const Key('descripcion_field')), 'Descripción de prueba');

      // Submit the form
      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle();

      // Should navigate back to list and show the new almacen
      expect(find.byType(AlmacenesListScreen), findsOneWidget);
      expect(find.text('Supermercado Test'), findsOneWidget);
      expect(find.text('Calle Test 123'), findsOneWidget);

      // Test edit functionality
      await tester.tap(find.byKey(const Key('edit_button_1')));
      await tester.pumpAndSettle();

      // Should show form with existing data
      expect(find.byType(AlmacenFormScreen), findsOneWidget);
      expect(find.text('Editar Almacén'), findsOneWidget);

      // Update the name
      await tester.enterText(
          find.byKey(const Key('nombre_field')), 'Supermercado Actualizado');
      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle();

      // Should show updated name
      expect(find.text('Supermercado Actualizado'), findsOneWidget);

      // Test delete functionality
      await tester.tap(find.byKey(const Key('delete_button_1')));
      await tester.pumpAndSettle();

      // Should show confirmation dialog
      expect(find.text('Confirmar eliminación'), findsOneWidget);
      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();

      // Should show empty list again
      expect(find.text('No hay almacenes registrados'), findsOneWidget);
    });

    testWidgets('Form validation integration test',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<AlmacenBloc>(
            create: (context) => almacenBloc,
            child: const AlmacenFormScreen(),
          ),
        ),
      );

      // Try to submit empty form
      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('El nombre es requerido'), findsOneWidget);

      // Fill only name and try again
      await tester.enterText(find.byKey(const Key('nombre_field')), 'Test');
      await tester.tap(find.byKey(const Key('save_button')));
      await tester.pumpAndSettle();

      // Should succeed with minimal data
      expect(find.byType(AlmacenFormScreen), findsNothing);
    });

    test('Database persistence integration test', () async {
      // Create an almacen
      final almacen = Almacen(
        nombre: 'Test Almacen',
        direccion: 'Test Address',
        descripcion: 'Test Description',
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
      );

      // Add to bloc
      almacenBloc.add(CreateAlmacenEvent(almacen));
      await expectLater(
        almacenBloc.stream,
        emitsInOrder([
          isA<AlmacenLoading>(),
          isA<AlmacenLoaded>(),
        ]),
      );

      // Verify it was persisted
      final almacenes = await repository.getAllAlmacenes();
      expect(almacenes.length, 1);
      expect(almacenes.first.nombre, 'Test Almacen');
    });
  });
}
