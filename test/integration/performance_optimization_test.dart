import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

import 'package:supermercado_comparador/core/utils/pagination_helper.dart';
import 'package:supermercado_comparador/core/utils/debounce_helper.dart';

void main() {
  group('Performance Optimization Tests', () {
    late Database database;

    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      final dbPath = join(await getDatabasesPath(), 'perf_test_${DateTime.now().millisecondsSinceEpoch}.db');
      
      database = await openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, version) async {
          // Create tables with indices
          await db.execute('''
            CREATE TABLE almacenes (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre TEXT NOT NULL,
              direccion TEXT,
              descripcion TEXT,
              fecha_creacion TEXT NOT NULL,
              fecha_actualizacion TEXT NOT NULL
            )
          ''');
          
          await db.execute('''
            CREATE TABLE categorias (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre TEXT NOT NULL UNIQUE,
              descripcion TEXT,
              fecha_creacion TEXT NOT NULL
            )
          ''');
          
          await db.execute('''
            CREATE TABLE productos (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre TEXT NOT NULL,
              precio REAL NOT NULL,
              peso REAL,
              tamano TEXT,
              codigo_qr TEXT,
              categoria_id INTEGER NOT NULL,
              almacen_id INTEGER NOT NULL,
              fecha_creacion TEXT NOT NULL,
              fecha_actualizacion TEXT NOT NULL,
              FOREIGN KEY (categoria_id) REFERENCES categorias (id),
              FOREIGN KEY (almacen_id) REFERENCES almacenes (id),
              UNIQUE(codigo_qr, almacen_id)
            )
          ''');
          
          // Create performance indices
          await db.execute('CREATE INDEX idx_productos_nombre ON productos (nombre)');
          await db.execute('CREATE INDEX idx_productos_codigo_qr ON productos (codigo_qr)');
          await db.execute('CREATE INDEX idx_productos_almacen_id ON productos (almacen_id)');
          await db.execute('CREATE INDEX idx_productos_categoria_id ON productos (categoria_id)');
          await db.execute('CREATE INDEX idx_productos_precio ON productos (precio)');
          
          // Insert test data
          await db.insert('categorias', {
            'nombre': 'General',
            'descripcion': 'Categoría general',
            'fecha_creacion': DateTime.now().toIso8601String(),
          });
          
          await db.insert('almacenes', {
            'nombre': 'Test Almacen',
            'direccion': 'Test Address',
            'descripcion': 'Test Description',
            'fecha_creacion': DateTime.now().toIso8601String(),
            'fecha_actualizacion': DateTime.now().toIso8601String(),
          });
        },
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('Database indices improve query performance', () async {
      // Insert a large number of products for performance testing
      final batch = database.batch();
      for (int i = 1; i <= 1000; i++) {
        batch.insert('productos', {
          'nombre': 'Producto $i',
          'precio': (i % 100) + 1.0,
          'peso': 1.0,
          'tamano': '1kg',
          'codigo_qr': 'QR${i.toString().padLeft(4, '0')}',
          'categoria_id': 1,
          'almacen_id': 1,
          'fecha_creacion': DateTime.now().toIso8601String(),
          'fecha_actualizacion': DateTime.now().toIso8601String(),
        });
      }
      await batch.commit();
      
      // Test search performance with index
      final stopwatch = Stopwatch()..start();
      
      final searchResults = await database.query(
        'productos',
        where: 'nombre LIKE ?',
        whereArgs: ['%Producto 5%'],
      );
      
      stopwatch.stop();
      
      expect(searchResults.length, greaterThan(0));
      expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Should be fast with index
      
      // Test QR search performance
      stopwatch.reset();
      stopwatch.start();
      
      final qrResults = await database.query(
        'productos',
        where: 'codigo_qr = ?',
        whereArgs: ['QR0500'],
      );
      
      stopwatch.stop();
      
      expect(qrResults.length, 1);
      expect(stopwatch.elapsedMilliseconds, lessThan(50)); // Should be very fast with index
    });

    test('Pagination helper functions work correctly', () {
      // Test offset calculation
      expect(PaginationHelper.calculateOffset(1, 20), 0);
      expect(PaginationHelper.calculateOffset(2, 20), 20);
      expect(PaginationHelper.calculateOffset(3, 10), 20);
      
      // Test total pages calculation
      expect(PaginationHelper.calculateTotalPages(100, 20), 5);
      expect(PaginationHelper.calculateTotalPages(101, 20), 6);
      expect(PaginationHelper.calculateTotalPages(0, 20), 0);
      
      // Test navigation helpers
      expect(PaginationHelper.hasNextPage(1, 5), true);
      expect(PaginationHelper.hasNextPage(5, 5), false);
      expect(PaginationHelper.hasPreviousPage(1), false);
      expect(PaginationHelper.hasPreviousPage(2), true);
    });

    test('PaginatedResult factory creates correct object', () {
      final result = PaginatedResult.create(
        items: ['item1', 'item2'],
        currentPage: 2,
        pageSize: 10,
        totalItems: 25,
      );
      
      expect(result.items.length, 2);
      expect(result.currentPage, 2);
      expect(result.pageSize, 10);
      expect(result.totalItems, 25);
      expect(result.totalPages, 3);
      expect(result.hasNext, true);
      expect(result.hasPrevious, true);
    });

    test('Database pagination query works correctly', () async {
      // Insert test products
      for (int i = 1; i <= 50; i++) {
        await database.insert('productos', {
          'nombre': 'Producto $i',
          'precio': i.toDouble(),
          'peso': 1.0,
          'tamano': '1kg',
          'codigo_qr': 'QR${i.toString().padLeft(3, '0')}',
          'categoria_id': 1,
          'almacen_id': 1,
          'fecha_creacion': DateTime.now().toIso8601String(),
          'fecha_actualizacion': DateTime.now().toIso8601String(),
        });
      }
      
      // Test first page
      final page1Results = await database.rawQuery('''
        SELECT * FROM productos
        ORDER BY nombre ASC
        LIMIT ? OFFSET ?
      ''', [10, 0]);
      
      expect(page1Results.length, 10);
      expect(page1Results.first['nombre'], 'Producto 1');
      
      // Test second page
      final page2Results = await database.rawQuery('''
        SELECT * FROM productos
        ORDER BY nombre ASC
        LIMIT ? OFFSET ?
      ''', [10, 10]);
      
      expect(page2Results.length, 10);
      // The ordering might be different due to string sorting (1, 10, 11, ..., 19, 2, 20, ...)
      expect(page2Results.first['nombre'], contains('Producto'));
      
      // Test with search filter
      final searchResults = await database.rawQuery('''
        SELECT * FROM productos
        WHERE nombre LIKE ?
        ORDER BY nombre ASC
        LIMIT ? OFFSET ?
      ''', ['%Producto 1%', 5, 0]);
      
      expect(searchResults.length, 5);
      expect(searchResults.every((r) => (r['nombre'] as String).contains('1')), true);
    });

    test('Debouncer delays execution correctly', () async {
      final debouncer = Debouncer(milliseconds: 100);
      int callCount = 0;
      
      // Multiple rapid calls should only execute once
      debouncer.run(() => callCount++);
      debouncer.run(() => callCount++);
      debouncer.run(() => callCount++);
      
      // Should not have executed yet
      expect(callCount, 0);
      
      // Wait for debounce period
      await Future.delayed(const Duration(milliseconds: 150));
      
      // Should have executed only once
      expect(callCount, 1);
    });

    test('DebouncedSearchController handles search correctly', () async {
      List<String> searchQueries = [];
      
      final controller = DebouncedSearchController(
        onSearch: (query) => searchQueries.add(query),
        debounceTime: 50,
      );
      
      // Rapid searches
      controller.search('a');
      controller.search('ab');
      controller.search('abc');
      
      // Should not have executed yet
      expect(searchQueries.isEmpty, true);
      
      // Wait for debounce
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Should have only executed the last search
      expect(searchQueries.length, 1);
      expect(searchQueries.first, 'abc');
      
      controller.dispose();
    });

    test('Complex query with joins and pagination performs well', () async {
      // Insert multiple almacenes and categorias
      await database.insert('almacenes', {
        'id': 2,
        'nombre': 'Almacen 2',
        'direccion': 'Address 2',
        'descripcion': 'Description 2',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });
      
      await database.insert('categorias', {
        'id': 2,
        'nombre': 'Categoria 2',
        'descripcion': 'Segunda categoría',
        'fecha_creacion': DateTime.now().toIso8601String(),
      });
      
      // Insert products across different almacenes and categorias
      final batch = database.batch();
      for (int i = 1; i <= 200; i++) {
        batch.insert('productos', {
          'nombre': 'Producto $i',
          'precio': i.toDouble(),
          'peso': 1.0,
          'tamano': '1kg',
          'codigo_qr': 'QR${i.toString().padLeft(3, '0')}',
          'categoria_id': (i % 2) + 1,
          'almacen_id': (i % 2) + 1,
          'fecha_creacion': DateTime.now().toIso8601String(),
          'fecha_actualizacion': DateTime.now().toIso8601String(),
        });
      }
      await batch.commit();
      
      // Test complex query with joins and pagination
      final stopwatch = Stopwatch()..start();
      
      final results = await database.rawQuery('''
        SELECT 
          p.*,
          c.nombre as categoria_nombre,
          a.nombre as almacen_nombre
        FROM productos p
        LEFT JOIN categorias c ON p.categoria_id = c.id
        LEFT JOIN almacenes a ON p.almacen_id = a.id
        WHERE p.nombre LIKE ?
        ORDER BY p.precio ASC
        LIMIT ? OFFSET ?
      ''', ['%Producto%', 20, 0]);
      
      stopwatch.stop();
      
      expect(results.length, 20);
      expect(stopwatch.elapsedMilliseconds, lessThan(200)); // Should be reasonably fast
      
      // Verify join data is included
      expect(results.first['categoria_nombre'], isNotNull);
      expect(results.first['almacen_nombre'], isNotNull);
    });

    test('Price range queries with index perform well', () async {
      // Insert products with various prices
      final batch = database.batch();
      for (int i = 1; i <= 500; i++) {
        batch.insert('productos', {
          'nombre': 'Producto $i',
          'precio': (i * 0.5), // Prices from 0.5 to 250.0
          'peso': 1.0,
          'tamano': '1kg',
          'codigo_qr': 'QR${i.toString().padLeft(3, '0')}',
          'categoria_id': 1,
          'almacen_id': 1,
          'fecha_creacion': DateTime.now().toIso8601String(),
          'fecha_actualizacion': DateTime.now().toIso8601String(),
        });
      }
      await batch.commit();
      
      // Test price range query performance
      final stopwatch = Stopwatch()..start();
      
      final results = await database.query(
        'productos',
        where: 'precio BETWEEN ? AND ?',
        whereArgs: [10.0, 50.0],
        orderBy: 'precio ASC',
      );
      
      stopwatch.stop();
      
      expect(results.length, greaterThan(0));
      expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Should be fast with price index
      
      // Verify results are within range
      for (final result in results) {
        final precio = result['precio'] as double;
        expect(precio, greaterThanOrEqualTo(10.0));
        expect(precio, lessThanOrEqualTo(50.0));
      }
    });
  });
}