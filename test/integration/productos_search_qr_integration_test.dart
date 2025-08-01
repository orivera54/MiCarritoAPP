import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:supermercado_comparador/core/database/database_helper.dart';
import 'package:supermercado_comparador/core/services/qr_scanner_service.dart';
import 'package:supermercado_comparador/features/productos/data/datasources/producto_local_data_source.dart';
import 'package:supermercado_comparador/features/productos/data/repositories/producto_repository_impl.dart';
import 'package:supermercado_comparador/features/productos/domain/usecases/create_producto.dart';
import 'package:supermercado_comparador/features/productos/domain/usecases/get_all_productos.dart';
import 'package:supermercado_comparador/features/productos/domain/usecases/get_productos_by_almacen.dart';
import 'package:supermercado_comparador/features/productos/domain/usecases/get_productos_by_categoria.dart';
import 'package:supermercado_comparador/features/productos/domain/usecases/get_producto_by_id.dart';
import 'package:supermercado_comparador/features/productos/domain/usecases/get_producto_by_qr.dart';
import 'package:supermercado_comparador/features/productos/domain/usecases/search_productos_by_name.dart';
import 'package:supermercado_comparador/features/productos/domain/usecases/search_productos_with_filters.dart';
import 'package:supermercado_comparador/features/productos/domain/usecases/update_producto.dart';
import 'package:supermercado_comparador/features/productos/domain/usecases/delete_producto.dart';
import 'package:supermercado_comparador/features/productos/presentation/bloc/producto_bloc.dart';
import 'package:supermercado_comparador/features/productos/presentation/pages/productos_list_screen.dart';
import 'package:supermercado_comparador/features/productos/domain/entities/producto.dart';

// Mock classes
class MockQRScannerService extends Mock implements QRScannerService {}

void main() {
  group('Productos Search and QR Integration Tests', () {
    late DatabaseHelper databaseHelper;
    late ProductoLocalDataSourceImpl dataSource;
    late ProductoRepositoryImpl repository;
    late ProductoBloc productoBloc;
    late MockQRScannerService mockQRService;

    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    Future<void> setupTestData() async {
      // Create test almacen and categoria first
      final db = await databaseHelper.database;

      // Insert test almacen (ID 2 to avoid conflict with potential default data)
      await db.insert('almacenes', {
        'nombre': 'Test Almacen',
        'direccion': 'Test Address',
        'descripcion': 'Test Description',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });

      // Get the almacen ID that was just inserted
      final almacenResult = await db.query('almacenes', 
        where: 'nombre = ?', 
        whereArgs: ['Test Almacen'],
        limit: 1
      );
      final almacenId = almacenResult.first['id'] as int;

      // Get the default categoria ID (should be 1 for "General")
      final categoriaResult = await db.query('categorias', 
        where: 'nombre = ?', 
        whereArgs: ['General'],
        limit: 1
      );
      final categoriaId = categoriaResult.first['id'] as int;

      // Create test products
      final productos = [
        {
          'nombre': 'Leche Entera',
          'precio': 2.50,
          'peso': 1.0,
          'tamano': '1L',
          'codigo_qr': 'QR001',
          'categoria_id': categoriaId,
          'almacen_id': almacenId,
          'fecha_creacion': DateTime.now().toIso8601String(),
          'fecha_actualizacion': DateTime.now().toIso8601String(),
        },
        {
          'nombre': 'Pan Integral',
          'precio': 1.80,
          'peso': 0.5,
          'tamano': '500g',
          'codigo_qr': 'QR002',
          'categoria_id': categoriaId,
          'almacen_id': almacenId,
          'fecha_creacion': DateTime.now().toIso8601String(),
          'fecha_actualizacion': DateTime.now().toIso8601String(),
        },
        {
          'nombre': 'Arroz Blanco',
          'precio': 3.20,
          'peso': 2.0,
          'tamano': '2kg',
          'codigo_qr': 'QR003',
          'categoria_id': categoriaId,
          'almacen_id': almacenId,
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
      
      // Reset database to ensure clean state
      await databaseHelper.resetDatabase();
      
      dataSource = ProductoLocalDataSourceImpl(databaseHelper: databaseHelper);
      repository = ProductoRepositoryImpl(localDataSource: dataSource);
      mockQRService = MockQRScannerService();

      productoBloc = ProductoBloc(
        createProducto: CreateProducto(repository),
        getAllProductos: GetAllProductos(repository),
        getProductosByAlmacen: GetProductosByAlmacen(repository),
        getProductosByCategoria: GetProductosByCategoria(repository),
        getProductoById: GetProductoById(repository),
        getProductoByQR: GetProductoByQR(repository),
        searchProductosByName: SearchProductosByName(repository),
        searchProductosWithFilters: SearchProductosWithFilters(repository),
        updateProducto: UpdateProducto(repository),
        deleteProducto: DeleteProducto(repository),
      );

      // Setup test data
      await setupTestData();
    });

    tearDown(() async {
      await productoBloc.close();
      await databaseHelper.close();
    });

    testWidgets('Search functionality integration test',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ProductoBloc>(
            create: (context) => productoBloc,
            child: const ProductosListScreen(),
          ),
        ),
      );

      // Wait for initial load
      await tester.pumpAndSettle();

      // Should show all products initially
      expect(find.text('Leche Entera'), findsOneWidget);
      expect(find.text('Pan Integral'), findsOneWidget);
      expect(find.text('Arroz Blanco'), findsOneWidget);

      // Test search functionality
      final searchField = find.byKey(const Key('search_field'));
      expect(searchField, findsOneWidget);

      // Search for "Leche"
      await tester.enterText(searchField, 'Leche');
      await tester.pumpAndSettle();

      // Should show only Leche Entera
      expect(find.text('Leche Entera'), findsOneWidget);
      expect(find.text('Pan Integral'), findsNothing);
      expect(find.text('Arroz Blanco'), findsNothing);

      // Clear search
      await tester.enterText(searchField, '');
      await tester.pumpAndSettle();

      // Should show all products again
      expect(find.text('Leche Entera'), findsOneWidget);
      expect(find.text('Pan Integral'), findsOneWidget);
      expect(find.text('Arroz Blanco'), findsOneWidget);

      // Search for partial match
      await tester.enterText(searchField, 'an');
      await tester.pumpAndSettle();

      // Should show Pan Integral
      expect(find.text('Pan Integral'), findsOneWidget);
      expect(find.text('Leche Entera'), findsNothing);
      expect(find.text('Arroz Blanco'), findsNothing);
    });

    testWidgets('QR Scanner integration test', (WidgetTester tester) async {
      // Mock QR scanner to return a known QR code stream
      when(mockQRService.startScanning()).thenAnswer((_) => Stream.value('QR002'));
      when(mockQRService.hasCameraPermission()).thenAnswer((_) async => true);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ProductoBloc>(
            create: (context) => productoBloc,
            child: const ProductosListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap QR scanner button
      final qrButton = find.byKey(const Key('qr_scan_button'));
      expect(qrButton, findsOneWidget);

      await tester.tap(qrButton);
      await tester.pumpAndSettle();

      // Verify QR service methods were called
      verify(mockQRService.hasCameraPermission()).called(1);
      verify(mockQRService.startScanning()).called(1);

      // Should show product with QR002 (Pan Integral)
      expect(find.text('Pan Integral'), findsOneWidget);
      expect(find.text('Leche Entera'), findsNothing);
      expect(find.text('Arroz Blanco'), findsNothing);
    });

    testWidgets('QR Scanner error handling test', (WidgetTester tester) async {
      // Mock QR scanner to throw an error
      when(mockQRService.hasCameraPermission()).thenAnswer((_) async => false);
      when(mockQRService.startScanning())
          .thenThrow(Exception('Camera permission denied'));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<ProductoBloc>(
            create: (context) => productoBloc,
            child: const ProductosListScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap QR scanner button
      await tester.tap(find.byKey(const Key('qr_scan_button')));
      await tester.pumpAndSettle();

      // Should show error message
      expect(find.text('Error al escanear QR'), findsOneWidget);
      expect(find.byType(SnackBar), findsOneWidget);
    });

    test('Search by name use case integration', () async {
      // Test search functionality at the use case level
      final searchUseCase = SearchProductosByName(repository);

      // Search for "Leche"
      final productos = await searchUseCase('Leche');

      expect(productos.length, 1);
      expect(productos.first.nombre, 'Leche Entera');
    });

    test('Search with no results integration', () async {
      final searchUseCase = SearchProductosByName(repository);

      // Search for non-existent product
      final productos = await searchUseCase('Producto Inexistente');

      expect(productos.length, 0);
    });

    test('QR code uniqueness validation', () async {
      // Get the test almacen and categoria IDs
      final db = await databaseHelper.database;
      final almacenResult = await db.query('almacenes', 
        where: 'nombre = ?', 
        whereArgs: ['Test Almacen'],
        limit: 1
      );
      final almacenId = almacenResult.first['id'] as int;
      
      final categoriaResult = await db.query('categorias', 
        where: 'nombre = ?', 
        whereArgs: ['General'],
        limit: 1
      );
      final categoriaId = categoriaResult.first['id'] as int;

      // Try to create product with existing QR code
      final duplicateProduct = Producto(
        nombre: 'Producto Duplicado',
        precio: 5.0,
        peso: 1.0,
        tamano: '1kg',
        codigoQR: 'QR001', // This QR already exists
        categoriaId: categoriaId,
        almacenId: almacenId,
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
      );

      final createUseCase = CreateProducto(repository);
      
      // This should throw a DuplicateException due to QR uniqueness constraint
      expect(
        () async => await createUseCase(duplicateProduct),
        throwsA(isA<Exception>()),
      );
    });
  });
}
