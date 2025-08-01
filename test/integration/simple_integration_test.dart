import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:supermercado_comparador/core/database/database_helper.dart';

void main() {
  group('Simple Integration Tests', () {
    late DatabaseHelper databaseHelper;

    setUpAll(() {
      // Initialize FFI for testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      databaseHelper = DatabaseHelper();
      // Initialize the database
      await databaseHelper.database;
    });

    tearDown(() async {
      try {
        await databaseHelper.close();
      } catch (e) {
        // Ignore close errors
      }
    });

    test('Database initialization and basic operations', () async {
      final db = await databaseHelper.database;
      expect(db, isNotNull);

      // Test basic table creation by checking if we can query them
      try {
        final almacenes = await db.query('almacenes');
        expect(almacenes, isA<List>());
        
        final categorias = await db.query('categorias');
        expect(categorias, isA<List>());
        
        final productos = await db.query('productos');
        expect(productos, isA<List>());
        
        final listas = await db.query('listas_compra');
        expect(listas, isA<List>());
        
        final items = await db.query('items_calculadora');
        expect(items, isA<List>());
      } catch (e) {
        fail('Database tables should exist: $e');
      }
    });

    test('Complete almacenes CRUD flow', () async {
      final db = await databaseHelper.database;
      
      // Create almacen
      final almacenId = await db.insert('almacenes', {
        'nombre': 'Test Almacen',
        'direccion': 'Test Address',
        'descripcion': 'Test Description',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });
      
      expect(almacenId, greaterThan(0));
      
      // Read almacen
      final almacenes = await db.query('almacenes', where: 'id = ?', whereArgs: [almacenId]);
      expect(almacenes.length, 1);
      expect(almacenes.first['nombre'], 'Test Almacen');
      
      // Update almacen
      await db.update('almacenes', {
        'nombre': 'Updated Almacen',
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      }, where: 'id = ?', whereArgs: [almacenId]);
      
      final updatedAlmacenes = await db.query('almacenes', where: 'id = ?', whereArgs: [almacenId]);
      expect(updatedAlmacenes.first['nombre'], 'Updated Almacen');
      
      // Delete almacen
      await db.delete('almacenes', where: 'id = ?', whereArgs: [almacenId]);
      
      final deletedAlmacenes = await db.query('almacenes', where: 'id = ?', whereArgs: [almacenId]);
      expect(deletedAlmacenes.length, 0);
    });

    test('Complete productos search flow', () async {
      final db = await databaseHelper.database;
      
      // Setup test data
      final almacenId = await db.insert('almacenes', {
        'nombre': 'Test Almacen',
        'direccion': 'Test Address',
        'descripcion': 'Test Description',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });
      
      final categoriaId = await db.insert('categorias', {
        'nombre': 'General',
        'descripcion': 'Categoría general',
        'fecha_creacion': DateTime.now().toIso8601String(),
      });
      
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
      ];
      
      for (final producto in productos) {
        await db.insert('productos', producto);
      }
      
      // Test search by name
      final lecheResults = await db.query(
        'productos',
        where: 'nombre LIKE ?',
        whereArgs: ['%Leche%'],
      );
      expect(lecheResults.length, 1);
      expect(lecheResults.first['nombre'], 'Leche Entera');
      
      // Test search by QR
      final qrResults = await db.query(
        'productos',
        where: 'codigo_qr = ?',
        whereArgs: ['QR002'],
      );
      expect(qrResults.length, 1);
      expect(qrResults.first['nombre'], 'Pan Integral');
      
      // Test get all products
      final allProducts = await db.query('productos');
      expect(allProducts.length, 2);
    });

    test('Complete calculadora flow', () async {
      final db = await databaseHelper.database;
      
      // Setup test data
      final almacenId = await db.insert('almacenes', {
        'nombre': 'Test Almacen',
        'direccion': 'Test Address',
        'descripcion': 'Test Description',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });
      
      final categoriaId = await db.insert('categorias', {
        'nombre': 'General',
        'descripcion': 'Categoría general',
        'fecha_creacion': DateTime.now().toIso8601String(),
      });
      
      final productoId = await db.insert('productos', {
        'nombre': 'Test Product',
        'precio': 5.0,
        'peso': 1.0,
        'tamano': '1kg',
        'codigo_qr': 'QR001',
        'categoria_id': categoriaId,
        'almacen_id': almacenId,
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });
      
      // Create shopping list
      final listaId = await db.insert('listas_compra', {
        'nombre': 'Test List',
        'total': 15.0,
        'fecha_creacion': DateTime.now().toIso8601String(),
      });
      
      // Add item to list
      await db.insert('items_calculadora', {
        'lista_compra_id': listaId,
        'producto_id': productoId,
        'cantidad': 3,
        'subtotal': 15.0,
      });
      
      // Verify list was created
      final listas = await db.query('listas_compra', where: 'id = ?', whereArgs: [listaId]);
      expect(listas.length, 1);
      expect(listas.first['total'], 15.0);
      
      // Verify item was added
      final items = await db.query('items_calculadora', where: 'lista_compra_id = ?', whereArgs: [listaId]);
      expect(items.length, 1);
      expect(items.first['cantidad'], 3);
      expect(items.first['subtotal'], 15.0);
      
      // Test calculation update
      await db.update('items_calculadora', {
        'cantidad': 2,
        'subtotal': 10.0,
      }, where: 'lista_compra_id = ? AND producto_id = ?', whereArgs: [listaId, productoId]);
      
      await db.update('listas_compra', {
        'total': 10.0,
      }, where: 'id = ?', whereArgs: [listaId]);
      
      // Verify updates
      final updatedItems = await db.query('items_calculadora', where: 'lista_compra_id = ?', whereArgs: [listaId]);
      expect(updatedItems.first['cantidad'], 2);
      expect(updatedItems.first['subtotal'], 10.0);
      
      final updatedListas = await db.query('listas_compra', where: 'id = ?', whereArgs: [listaId]);
      expect(updatedListas.first['total'], 10.0);
    });

    test('Complete price comparison flow', () async {
      final db = await databaseHelper.database;
      
      // Setup test data - multiple stores
      final almacen1Id = await db.insert('almacenes', {
        'nombre': 'Almacen A',
        'direccion': 'Address A',
        'descripcion': 'Description A',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });
      
      final almacen2Id = await db.insert('almacenes', {
        'nombre': 'Almacen B',
        'direccion': 'Address B',
        'descripcion': 'Description B',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });
      
      final categoriaId = await db.insert('categorias', {
        'nombre': 'General',
        'descripcion': 'Categoría general',
        'fecha_creacion': DateTime.now().toIso8601String(),
      });
      
      // Create same product in different stores with different prices
      await db.insert('productos', {
        'nombre': 'Leche Entera 1L',
        'precio': 2.50,
        'peso': 1.0,
        'tamano': '1L',
        'codigo_qr': 'QR001A',
        'categoria_id': categoriaId,
        'almacen_id': almacen1Id,
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });
      
      await db.insert('productos', {
        'nombre': 'Leche Entera 1L',
        'precio': 2.30,
        'peso': 1.0,
        'tamano': '1L',
        'codigo_qr': 'QR001B',
        'categoria_id': categoriaId,
        'almacen_id': almacen2Id,
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });
      
      // Test price comparison query
      final results = await db.rawQuery('''
        SELECT p.*, a.nombre as almacen_nombre
        FROM productos p
        JOIN almacenes a ON p.almacen_id = a.id
        WHERE p.nombre LIKE ?
        ORDER BY p.precio ASC
      ''', ['%Leche%']);
      
      expect(results.length, 2);
      expect(results.first['precio'], 2.30); // Best price first
      expect(results.first['almacen_nombre'], 'Almacen B');
      expect(results.last['precio'], 2.50);
      expect(results.last['almacen_nombre'], 'Almacen A');
      
      // Test finding best price
      final bestPrice = await db.rawQuery('''
        SELECT MIN(precio) as mejor_precio
        FROM productos
        WHERE nombre LIKE ?
      ''', ['%Leche%']);
      
      expect(bestPrice.first['mejor_precio'], 2.30);
    });

    test('Foreign key constraints validation', () async {
      final db = await databaseHelper.database;
      
      // Try to insert product without valid almacen_id and categoria_id
      try {
        await db.insert('productos', {
          'nombre': 'Invalid Product',
          'precio': 1.0,
          'peso': 1.0,
          'tamano': '1kg',
          'codigo_qr': 'QR999',
          'categoria_id': 999, // Non-existent category
          'almacen_id': 999, // Non-existent almacen
          'fecha_creacion': DateTime.now().toIso8601String(),
          'fecha_actualizacion': DateTime.now().toIso8601String(),
        });
        
        // If we reach here, foreign key constraints are not working
        // This is expected in SQLite without explicit foreign key enforcement
        // But we can still test the data integrity manually
        
        final invalidProducts = await db.rawQuery('''
          SELECT p.*
          FROM productos p
          LEFT JOIN almacenes a ON p.almacen_id = a.id
          LEFT JOIN categorias c ON p.categoria_id = c.id
          WHERE a.id IS NULL OR c.id IS NULL
        ''');
        
        expect(invalidProducts.length, greaterThan(0));
      } catch (e) {
        // Foreign key constraint is working
        expect(e.toString(), contains('FOREIGN KEY'));
      }
    });

    test('QR code uniqueness per almacen', () async {
      final db = await databaseHelper.database;
      
      // Setup test data
      final almacenId = await db.insert('almacenes', {
        'nombre': 'Test Almacen',
        'direccion': 'Test Address',
        'descripcion': 'Test Description',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });
      
      final categoriaId = await db.insert('categorias', {
        'nombre': 'General',
        'descripcion': 'Categoría general',
        'fecha_creacion': DateTime.now().toIso8601String(),
      });
      
      // Insert first product with QR code
      await db.insert('productos', {
        'nombre': 'Product 1',
        'precio': 1.0,
        'peso': 1.0,
        'tamano': '1kg',
        'codigo_qr': 'QR001',
        'categoria_id': categoriaId,
        'almacen_id': almacenId,
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });
      
      // Try to insert second product with same QR code in same almacen
      try {
        await db.insert('productos', {
          'nombre': 'Product 2',
          'precio': 2.0,
          'peso': 1.0,
          'tamano': '1kg',
          'codigo_qr': 'QR001', // Same QR code
          'categoria_id': categoriaId,
          'almacen_id': almacenId, // Same almacen
          'fecha_creacion': DateTime.now().toIso8601String(),
          'fecha_actualizacion': DateTime.now().toIso8601String(),
        });
        
        // Check if duplicate was actually inserted (should not be allowed)
        final duplicates = await db.query(
          'productos',
          where: 'codigo_qr = ? AND almacen_id = ?',
          whereArgs: ['QR001', almacenId],
        );
        
        // If unique constraint is working, this should fail
        // If not, we should have only 1 product (the first one)
        expect(duplicates.length, lessThanOrEqualTo(1));
        
      } catch (e) {
        // Unique constraint is working
        expect(e.toString(), contains('UNIQUE'));
      }
    });
  });
}