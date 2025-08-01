import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:supermercado_comparador/core/database/database_helper.dart';
import 'package:supermercado_comparador/features/comparador/data/datasources/comparador_local_data_source.dart';
import 'package:supermercado_comparador/features/comparador/data/repositories/comparador_repository_impl.dart';
import 'package:supermercado_comparador/features/comparador/domain/usecases/comparar_precios_producto.dart';
import 'package:supermercado_comparador/features/comparador/domain/usecases/buscar_productos_similares.dart';
import 'package:supermercado_comparador/features/comparador/domain/usecases/buscar_productos_por_qr.dart';
import 'package:supermercado_comparador/features/comparador/domain/services/comparador_service.dart';
import 'package:supermercado_comparador/features/comparador/presentation/bloc/comparador_bloc.dart';
import 'package:supermercado_comparador/features/comparador/presentation/pages/comparador_screen.dart';
import 'package:supermercado_comparador/features/productos/data/datasources/producto_local_data_source.dart';
import 'package:supermercado_comparador/features/productos/data/repositories/producto_repository_impl.dart';
import 'package:supermercado_comparador/features/almacenes/data/datasources/almacen_local_data_source.dart';
import 'package:supermercado_comparador/features/almacenes/data/repositories/almacen_repository_impl.dart';

void main() {
  group('Comparador Integration Tests', () {
    late DatabaseHelper databaseHelper;
    late ComparadorLocalDataSourceImpl dataSource;
    late ComparadorRepositoryImpl repository;
    late ProductoLocalDataSourceImpl productoDataSource;
    late ProductoRepositoryImpl productoRepository;
    late AlmacenLocalDataSourceImpl almacenDataSource;
    late AlmacenRepositoryImpl almacenRepository;
    late ComparadorService comparadorService;
    late ComparadorBloc comparadorBloc;

    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    Future<void> setupTestData() async {
      final db = await databaseHelper.database;

      // Create test almacenes
      await db.insert('almacenes', {
        'id': 1,
        'nombre': 'Supermercado A',
        'direccion': 'Calle A 123',
        'descripcion': 'Supermercado A',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });

      await db.insert('almacenes', {
        'id': 2,
        'nombre': 'Supermercado B',
        'direccion': 'Calle B 456',
        'descripcion': 'Supermercado B',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });

      await db.insert('almacenes', {
        'id': 3,
        'nombre': 'Supermercado C',
        'direccion': 'Calle C 789',
        'descripcion': 'Supermercado C',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });

      // Check if default category exists, if not create it
      final existingCategoria =
          await db.query('categorias', where: 'id = ?', whereArgs: [1]);
      if (existingCategoria.isEmpty) {
        await db.insert('categorias', {
          'id': 1,
          'nombre': 'General',
          'descripcion': 'Categoría general',
          'fecha_creacion': DateTime.now().toIso8601String(),
        });
      }

      // Create similar products in different stores
      final productos = [
        // Leche in different stores
        {
          'id': 1,
          'nombre': 'Leche Entera 1L',
          'precio': 2.50,
          'peso': 1.0,
          'tamano': '1L',
          'codigo_qr': 'QR001A',
          'categoria_id': 1,
          'almacen_id': 1,
          'fecha_creacion': DateTime.now().toIso8601String(),
          'fecha_actualizacion': DateTime.now().toIso8601String(),
        },
        {
          'id': 2,
          'nombre': 'Leche Entera 1L',
          'precio': 2.30,
          'peso': 1.0,
          'tamano': '1L',
          'codigo_qr': 'QR001B',
          'categoria_id': 1,
          'almacen_id': 2,
          'fecha_creacion': DateTime.now().toIso8601String(),
          'fecha_actualizacion': DateTime.now().toIso8601String(),
        },
        {
          'id': 3,
          'nombre': 'Leche Entera 1L',
          'precio': 2.80,
          'peso': 1.0,
          'tamano': '1L',
          'codigo_qr': 'QR001C',
          'categoria_id': 1,
          'almacen_id': 3,
          'fecha_creacion': DateTime.now().toIso8601String(),
          'fecha_actualizacion': DateTime.now().toIso8601String(),
        },
        // Pan in different stores
        {
          'id': 4,
          'nombre': 'Pan Integral 500g',
          'precio': 1.80,
          'peso': 0.5,
          'tamano': '500g',
          'codigo_qr': 'QR002A',
          'categoria_id': 1,
          'almacen_id': 1,
          'fecha_creacion': DateTime.now().toIso8601String(),
          'fecha_actualizacion': DateTime.now().toIso8601String(),
        },
        {
          'id': 5,
          'nombre': 'Pan Integral 500g',
          'precio': 1.60,
          'peso': 0.5,
          'tamano': '500g',
          'codigo_qr': 'QR002B',
          'categoria_id': 1,
          'almacen_id': 2,
          'fecha_creacion': DateTime.now().toIso8601String(),
          'fecha_actualizacion': DateTime.now().toIso8601String(),
        },
        // Unique product in one store
        {
          'id': 6,
          'nombre': 'Producto Único',
          'precio': 5.00,
          'peso': 1.0,
          'tamano': '1kg',
          'codigo_qr': 'QR003A',
          'categoria_id': 1,
          'almacen_id': 1,
          'fecha_creacion': DateTime.now().toIso8601String(),
          'fecha_actualizacion': DateTime.now().toIso8601String(),
        },
      ];

      for (final producto in productos) {
        await db.insert('productos', producto);
      }
    }

    setUp(() async {
      databaseHelper = DatabaseHelper();
      await databaseHelper.database;

      // Setup comparador dependencies
      dataSource =
          ComparadorLocalDataSourceImpl(databaseHelper: databaseHelper);
      repository = ComparadorRepositoryImpl(localDataSource: dataSource);

      // Setup producto dependencies
      productoDataSource = ProductoLocalDataSourceImpl(databaseHelper: databaseHelper);
      productoRepository = ProductoRepositoryImpl(localDataSource: productoDataSource);

      // Setup almacen dependencies
      almacenDataSource = AlmacenLocalDataSourceImpl(databaseHelper: databaseHelper);
      almacenRepository = AlmacenRepositoryImpl(localDataSource: almacenDataSource);

      // Setup comparador service
      comparadorService = ComparadorService(
        productoRepository: productoRepository,
        almacenRepository: almacenRepository,
      );

      comparadorBloc = ComparadorBloc(
        buscarProductosSimilares: BuscarProductosSimilares(repository),
        compararPreciosProducto: CompararPreciosProducto(repository),
        buscarProductosPorQR: BuscarProductosPorQR(repository),
        comparadorService: comparadorService,
      );

      await setupTestData();
    });

    tearDown(() async {
      await comparadorBloc.close();
      await databaseHelper.close();
    });

    testWidgets('Complete price comparison flow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ComparadorBloc>(
            create: (context) => comparadorBloc,
            child: const ComparadorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initial state should show search interface
      expect(find.text('Comparador de Precios'), findsOneWidget);
      expect(find.byKey(const Key('search_field')), findsOneWidget);

      // Search for "Leche"
      await tester.enterText(find.byKey(const Key('search_field')), 'Leche');
      await tester.tap(find.byKey(const Key('search_button')));
      await tester.pumpAndSettle();

      // Should show comparison results
      expect(find.text('Leche Entera 1L'), findsWidgets);
      expect(find.text('Supermercado A'), findsOneWidget);
      expect(find.text('Supermercado B'), findsOneWidget);
      expect(find.text('Supermercado C'), findsOneWidget);

      // Should highlight best price (Supermercado B - $2.30)
      expect(find.text('\$2.30'), findsOneWidget);
      expect(find.text('\$2.50'), findsOneWidget);
      expect(find.text('\$2.80'), findsOneWidget);

      // Best price should be highlighted
      final bestPriceWidget = find.byKey(const Key('best_price_2'));
      expect(bestPriceWidget, findsOneWidget);
    });

    testWidgets('No results comparison test', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ComparadorBloc>(
            create: (context) => comparadorBloc,
            child: const ComparadorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Search for non-existent product
      await tester.enterText(
          find.byKey(const Key('search_field')), 'Producto Inexistente');
      await tester.tap(find.byKey(const Key('search_button')));
      await tester.pumpAndSettle();

      // Should show no results message
      expect(find.text('No se encontraron productos para comparar'),
          findsOneWidget);
    });

    testWidgets('Single store product test', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ComparadorBloc>(
            create: (context) => comparadorBloc,
            child: const ComparadorScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Search for unique product
      await tester.enterText(
          find.byKey(const Key('search_field')), 'Producto Único');
      await tester.tap(find.byKey(const Key('search_button')));
      await tester.pumpAndSettle();

      // Should show single result with message
      expect(find.text('Producto Único'), findsOneWidget);
      expect(find.text('Solo disponible en un almacén'), findsOneWidget);
    });

    test('Database setup validation', () async {
      // Test that the test data was set up correctly
      final db = await databaseHelper.database;

      // Check almacenes were created
      final almacenes = await db.query('almacenes');
      expect(almacenes.length, 3);

      // Check productos were created
      final productos = await db.query('productos');
      expect(productos.length, 6);

      // Check we have Leche products in different stores
      final lecheProducts = await db
          .query('productos', where: 'nombre LIKE ?', whereArgs: ['%Leche%']);
      expect(lecheProducts.length, 3);
    });

    test('Direct database query for price comparison', () async {
      // Test price comparison logic at database level
      final db = await databaseHelper.database;

      final results = await db.rawQuery('''
        SELECT p.*, a.nombre as almacen_nombre
        FROM productos p
        JOIN almacenes a ON p.almacen_id = a.id
        WHERE p.nombre LIKE ?
        ORDER BY p.precio ASC
      ''', ['%Leche%']);

      expect(results.length, 3);
      expect(results[0]['precio'], 2.30); // Best price first
      expect(results[0]['almacen_nombre'], 'Supermercado B');
      expect(results[1]['precio'], 2.50);
      expect(results[1]['almacen_nombre'], 'Supermercado A');
      expect(results[2]['precio'], 2.80);
      expect(results[2]['almacen_nombre'], 'Supermercado C');
    });

    test('Search for products by name', () async {
      final db = await databaseHelper.database;

      // Search for Pan products
      final panResults = await db.query(
        'productos',
        where: 'nombre LIKE ?',
        whereArgs: ['%Pan%'],
      );

      expect(panResults.length, 2);
      expect(panResults.every((p) => (p['nombre'] as String).contains('Pan')),
          true);
    });

    test('QR code search functionality', () async {
      final db = await databaseHelper.database;

      // Search by QR code
      final qrResults = await db.query(
        'productos',
        where: 'codigo_qr = ?',
        whereArgs: ['QR001A'],
      );

      expect(qrResults.length, 1);
      expect(qrResults.first['nombre'], 'Leche Entera 1L');
      expect(qrResults.first['precio'], 2.50);
      expect(qrResults.first['almacen_id'], 1);
    });

    test('Price range analysis', () async {
      final db = await databaseHelper.database;

      // Get price statistics for Leche
      final priceStats = await db.rawQuery('''
        SELECT 
          MIN(precio) as min_precio,
          MAX(precio) as max_precio,
          AVG(precio) as avg_precio,
          COUNT(*) as total_stores
        FROM productos
        WHERE nombre LIKE ?
      ''', ['%Leche%']);

      final stats = priceStats.first;
      expect(stats['min_precio'], 2.30);
      expect(stats['max_precio'], 2.80);
      expect(stats['total_stores'], 3);

      // Calculate potential savings
      final savings =
          (stats['max_precio'] as double) - (stats['min_precio'] as double);
      expect(savings, 0.50);
    });
  });
}
