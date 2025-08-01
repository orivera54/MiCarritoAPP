import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:supermercado_comparador/core/database/database_helper.dart';
import 'package:supermercado_comparador/features/calculadora/data/datasources/calculadora_local_data_source.dart';
import 'package:supermercado_comparador/features/calculadora/data/repositories/calculadora_repository_impl.dart';
import 'package:supermercado_comparador/features/calculadora/domain/usecases/agregar_item_calculadora.dart';
import 'package:supermercado_comparador/features/calculadora/domain/usecases/modificar_cantidad_item.dart';
import 'package:supermercado_comparador/features/calculadora/domain/usecases/eliminar_item_calculadora.dart';
import 'package:supermercado_comparador/features/calculadora/domain/usecases/obtener_lista_actual.dart';
import 'package:supermercado_comparador/features/calculadora/domain/usecases/guardar_lista_compra.dart';
import 'package:supermercado_comparador/features/calculadora/domain/usecases/limpiar_lista_actual.dart';
import 'package:supermercado_comparador/features/calculadora/presentation/bloc/calculadora_bloc.dart';
import 'package:supermercado_comparador/features/calculadora/presentation/bloc/calculadora_event.dart';
import 'package:supermercado_comparador/features/calculadora/presentation/bloc/calculadora_state.dart';
import 'package:supermercado_comparador/features/calculadora/presentation/pages/calculadora_screen.dart';
import 'package:supermercado_comparador/features/calculadora/domain/services/mejor_precio_service.dart';
import 'package:supermercado_comparador/features/productos/domain/entities/producto.dart';
import 'package:supermercado_comparador/features/productos/data/repositories/producto_repository_impl.dart';
import 'package:supermercado_comparador/features/productos/data/datasources/producto_local_data_source.dart';
import 'package:supermercado_comparador/features/almacenes/data/repositories/almacen_repository_impl.dart';
import 'package:supermercado_comparador/features/almacenes/data/datasources/almacen_local_data_source.dart';

void main() {
  group('Calculadora Integration Tests', () {
    late DatabaseHelper databaseHelper;
    late CalculadoraLocalDataSourceImpl dataSource;
    late CalculadoraRepositoryImpl repository;
    late CalculadoraBloc calculadoraBloc;
    late MejorPrecioService mejorPrecioService;
    late ProductoLocalDataSourceImpl productoDataSource;
    late ProductoRepositoryImpl productoRepository;
    late AlmacenLocalDataSourceImpl almacenDataSource;
    late AlmacenRepositoryImpl almacenRepository;

    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    Future<void> setupTestData() async {
      final db = await databaseHelper.database;

      // Create test almacen and categoria
      await db.insert('almacenes', {
        'id': 1,
        'nombre': 'Test Almacen',
        'direccion': 'Test Address',
        'descripcion': 'Test Description',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });

      await db.insert('categorias', {
        'id': 1,
        'nombre': 'General',
        'descripcion': 'Categoría general',
        'fecha_creacion': DateTime.now().toIso8601String(),
      });

      // Create test products
      await db.insert('productos', {
        'id': 1,
        'nombre': 'Leche Entera',
        'precio': 2.50,
        'peso': 1.0,
        'tamano': '1L',
        'codigo_qr': 'QR001',
        'categoria_id': 1,
        'almacen_id': 1,
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });

      await db.insert('productos', {
        'id': 2,
        'nombre': 'Pan Integral',
        'precio': 1.80,
        'peso': 0.5,
        'tamano': '500g',
        'codigo_qr': 'QR002',
        'categoria_id': 1,
        'almacen_id': 1,
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });
    }

    setUp(() async {
      databaseHelper = DatabaseHelper();
      await databaseHelper.database;

      // Initialize data sources and repositories
      dataSource = CalculadoraLocalDataSourceImpl(databaseHelper);
      repository = CalculadoraRepositoryImpl(dataSource);
      
      productoDataSource = ProductoLocalDataSourceImpl(databaseHelper: databaseHelper);
      productoRepository = ProductoRepositoryImpl(localDataSource: productoDataSource);
      
      almacenDataSource = AlmacenLocalDataSourceImpl(databaseHelper: databaseHelper);
      almacenRepository = AlmacenRepositoryImpl(localDataSource: almacenDataSource);
      
      // Initialize MejorPrecioService
      mejorPrecioService = MejorPrecioService(
        productoRepository: productoRepository,
        almacenRepository: almacenRepository,
      );

      calculadoraBloc = CalculadoraBloc(
        agregarItemCalculadora: AgregarItemCalculadora(repository),
        modificarCantidadItem: ModificarCantidadItem(repository),
        eliminarItemCalculadora: EliminarItemCalculadora(repository),
        obtenerListaActual: ObtenerListaActual(repository),
        guardarListaCompra: GuardarListaCompra(repository),
        limpiarListaActual: LimpiarListaActual(repository),
        mejorPrecioService: mejorPrecioService,
      );

      await setupTestData();
    });

    tearDown(() async {
      await calculadoraBloc.close();
      await databaseHelper.close();
    });

    testWidgets('Complete calculadora flow integration test',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CalculadoraBloc>(
            create: (context) => calculadoraBloc,
            child: const CalculadoraScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initial state should show empty list
      expect(find.text('Tu lista está vacía'), findsOneWidget);
      expect(find.text('Total: \$0.00'), findsOneWidget);

      // Add first item
      await tester.tap(find.byKey(const Key('add_item_button')));
      await tester.pumpAndSettle();

      // Should show product selection dialog
      expect(find.text('Agregar Producto'), findsOneWidget);

      // Select first product (Leche Entera)
      await tester.tap(find.text('Leche Entera'));
      await tester.pumpAndSettle();

      // Set quantity
      await tester.enterText(find.byKey(const Key('quantity_field')), '2');
      await tester.tap(find.text('Agregar'));
      await tester.pumpAndSettle();

      // Should show item in list with correct subtotal
      expect(find.text('Leche Entera'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('\$5.00'), findsOneWidget); // 2.50 * 2
      expect(find.text('Total: \$5.00'), findsOneWidget);

      // Add second item
      await tester.tap(find.byKey(const Key('add_item_button')));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pan Integral'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('quantity_field')), '3');
      await tester.tap(find.text('Agregar'));
      await tester.pumpAndSettle();

      // Should show both items with updated total
      expect(find.text('Pan Integral'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
      expect(find.text('\$5.40'), findsOneWidget); // 1.80 * 3
      expect(find.text('Total: \$10.40'), findsOneWidget); // 5.00 + 5.40

      // Test quantity modification
      final quantityField = find.byKey(const Key('quantity_field_1')).first;
      await tester.tap(quantityField);
      await tester.enterText(quantityField, '1');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Should update subtotal and total
      expect(find.text('\$2.50'), findsOneWidget); // 2.50 * 1
      expect(find.text('Total: \$7.90'), findsOneWidget); // 2.50 + 5.40

      // Test item deletion
      await tester.tap(find.byKey(const Key('delete_item_2')));
      await tester.pumpAndSettle();

      // Should show confirmation dialog
      expect(find.text('Eliminar producto'), findsOneWidget);
      await tester.tap(find.text('Eliminar'));
      await tester.pumpAndSettle();

      // Should remove item and update total
      expect(find.text('Pan Integral'), findsNothing);
      expect(find.text('Total: \$2.50'), findsOneWidget);

      // Test save list
      await tester.tap(find.byKey(const Key('save_list_button')));
      await tester.pumpAndSettle();

      // Should show save dialog
      expect(find.text('Guardar Lista'), findsOneWidget);
      await tester.enterText(
          find.byKey(const Key('list_name_field')), 'Mi Lista de Compras');
      await tester.tap(find.text('Guardar'));
      await tester.pumpAndSettle();

      // Should show success message
      expect(find.text('Lista guardada exitosamente'), findsOneWidget);
    });

    testWidgets('Real-time calculation test', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CalculadoraBloc>(
            create: (context) => calculadoraBloc,
            child: const CalculadoraScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Add item through bloc directly to test calculation
      final producto = Producto(
        id: 1,
        nombre: 'Leche Entera',
        precio: 2.50,
        peso: 1.0,
        tamano: '1L',
        codigoQR: 'QR001',
        categoriaId: 1,
        almacenId: 1,
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
      );

      calculadoraBloc.add(AgregarProducto(producto: producto, cantidad: 3));
      await tester.pumpAndSettle();

      // Should show correct calculation
      expect(find.text('Total: \$7.50'), findsOneWidget);

      // Modify quantity
      calculadoraBloc
          .add(const ModificarCantidad(productoId: 1, nuevaCantidad: 5));
      await tester.pumpAndSettle();

      // Should update total
      expect(find.text('Total: \$12.50'), findsOneWidget);
    });

    test('Calculadora business logic integration', () async {
      final producto = Producto(
        id: 1,
        nombre: 'Test Product',
        precio: 10.0,
        peso: 1.0,
        tamano: '1kg',
        codigoQR: 'QR001',
        categoriaId: 1,
        almacenId: 1,
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
      );

      // Add item
      calculadoraBloc.add(AgregarProducto(producto: producto, cantidad: 2));

      await expectLater(
        calculadoraBloc.stream,
        emitsInOrder([
          isA<CalculadoraLoading>(),
          predicate<CalculadoraLoaded>((state) =>
              state.listaCompra.items.length == 1 &&
              state.listaCompra.total == 20.0),
        ]),
      );

      // Modify quantity
      calculadoraBloc
          .add(const ModificarCantidad(productoId: 1, nuevaCantidad: 3));

      await expectLater(
        calculadoraBloc.stream,
        emits(predicate<CalculadoraLoaded>((state) =>
            state.listaCompra.items.first.cantidad == 3 &&
            state.listaCompra.total == 30.0)),
      );

      // Remove item
      calculadoraBloc.add(const EliminarProducto(productoId: 1));

      await expectLater(
        calculadoraBloc.stream,
        emits(predicate<CalculadoraLoaded>((state) =>
            state.listaCompra.items.isEmpty && state.listaCompra.total == 0.0)),
      );
    });

    test('Save and load list integration', () async {
      final producto = Producto(
        id: 1,
        nombre: 'Test Product',
        precio: 5.0,
        peso: 1.0,
        tamano: '1kg',
        codigoQR: 'QR001',
        categoriaId: 1,
        almacenId: 1,
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
      );

      // Add item and save list
      calculadoraBloc.add(AgregarProducto(producto: producto, cantidad: 2));
      await calculadoraBloc.stream.first;

      calculadoraBloc.add(const GuardarLista(nombre: 'Test List'));
      await calculadoraBloc.stream.first;

      // Verify list was saved in database
      final db = await databaseHelper.database;
      final savedLists = await db.query('listas_compra');
      expect(savedLists.length, 1);
      expect(savedLists.first['nombre'], 'Test List');
      expect(savedLists.first['total'], 10.0);

      final savedItems = await db.query('items_calculadora');
      expect(savedItems.length, 1);
      expect(savedItems.first['cantidad'], 2);
      expect(savedItems.first['subtotal'], 10.0);
    });

    test('Clear list integration', () async {
      final producto = Producto(
        id: 1,
        nombre: 'Test Product',
        precio: 5.0,
        peso: 1.0,
        tamano: '1kg',
        codigoQR: 'QR001',
        categoriaId: 1,
        almacenId: 1,
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
      );

      // Add item
      calculadoraBloc.add(AgregarProducto(producto: producto, cantidad: 2));
      await calculadoraBloc.stream.first;

      // Clear list
      calculadoraBloc.add(LimpiarLista());

      await expectLater(
        calculadoraBloc.stream,
        emits(predicate<CalculadoraLoaded>((state) =>
            state.listaCompra.items.isEmpty && state.listaCompra.total == 0.0)),
      );
    });
  });
}
