import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

void main() {
  group('Database Integration Tests', () {
    late Database database;

    setUpAll(() {
      // Initialize FFI for testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() async {
      // Create a unique database for each test
      final dbPath = join(await getDatabasesPath(), 'test_${DateTime.now().millisecondsSinceEpoch}.db');
      
      database = await openDatabase(
        dbPath,
        version: 1,
        onCreate: (db, version) async {
          // Create almacenes table
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
          
          // Create categorias table
          await db.execute('''
            CREATE TABLE categorias (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre TEXT NOT NULL UNIQUE,
              descripcion TEXT,
              fecha_creacion TEXT NOT NULL
            )
          ''');
          
          // Create productos table
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
          
          // Create listas_compra table
          await db.execute('''
            CREATE TABLE listas_compra (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              nombre TEXT,
              total REAL NOT NULL,
              fecha_creacion TEXT NOT NULL
            )
          ''');
          
          // Create items_calculadora table
          await db.execute('''
            CREATE TABLE items_calculadora (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              lista_compra_id INTEGER NOT NULL,
              producto_id INTEGER NOT NULL,
              cantidad INTEGER NOT NULL,
              subtotal REAL NOT NULL,
              FOREIGN KEY (lista_compra_id) REFERENCES listas_compra (id),
              FOREIGN KEY (producto_id) REFERENCES productos (id)
            )
          ''');
          
          // Insert default category
          await db.insert('categorias', {
            'nombre': 'General',
            'descripcion': 'Categoría por defecto',
            'fecha_creacion': DateTime.now().toIso8601String(),
          });
        },
      );
    });

    tearDown(() async {
      await database.close();
    });

    test('Almacenes management flow integration', () async {
      // Create almacen
      final almacenId = await database.insert('almacenes', {
        'nombre': 'Supermercado Test',
        'direccion': 'Calle Test 123',
        'descripcion': 'Descripción de prueba',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });
      
      expect(almacenId, greaterThan(0));
      
      // Read almacen
      final almacenes = await database.query('almacenes', where: 'id = ?', whereArgs: [almacenId]);
      expect(almacenes.length, 1);
      expect(almacenes.first['nombre'], 'Supermercado Test');
      expect(almacenes.first['direccion'], 'Calle Test 123');
      
      // Update almacen
      final updateCount = await database.update('almacenes', {
        'nombre': 'Supermercado Actualizado',
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      }, where: 'id = ?', whereArgs: [almacenId]);
      
      expect(updateCount, 1);
      
      final updatedAlmacenes = await database.query('almacenes', where: 'id = ?', whereArgs: [almacenId]);
      expect(updatedAlmacenes.first['nombre'], 'Supermercado Actualizado');
      
      // Delete almacen
      final deleteCount = await database.delete('almacenes', where: 'id = ?', whereArgs: [almacenId]);
      expect(deleteCount, 1);
      
      final deletedAlmacenes = await database.query('almacenes', where: 'id = ?', whereArgs: [almacenId]);
      expect(deletedAlmacenes.length, 0);
    });

    test('Products search and QR integration', () async {
      // Setup test data
      final almacenId = await database.insert('almacenes', {
        'nombre': 'Test Almacen',
        'direccion': 'Test Address',
        'descripcion': 'Test Description',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });
      
      // Get default category
      final categorias = await database.query('categorias', where: 'nombre = ?', whereArgs: ['General']);
      final categoriaId = categorias.first['id'];
      
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
        await database.insert('productos', producto);
      }
      
      // Test search by name
      final lecheResults = await database.query(
        'productos',
        where: 'nombre LIKE ?',
        whereArgs: ['%Leche%'],
      );
      expect(lecheResults.length, 1);
      expect(lecheResults.first['nombre'], 'Leche Entera');
      
      // Test partial search
      final panResults = await database.query(
        'productos',
        where: 'nombre LIKE ?',
        whereArgs: ['%Pan%'],
      );
      expect(panResults.length, 1);
      expect(panResults.first['nombre'], 'Pan Integral');
      
      // Test search by QR
      final qrResults = await database.query(
        'productos',
        where: 'codigo_qr = ?',
        whereArgs: ['QR002'],
      );
      expect(qrResults.length, 1);
      expect(qrResults.first['nombre'], 'Pan Integral');
      
      // Test get all products
      final allProducts = await database.query('productos');
      expect(allProducts.length, 3);
      
      // Test case insensitive search
      final caseInsensitiveResults = await database.query(
        'productos',
        where: 'LOWER(nombre) LIKE LOWER(?)',
        whereArgs: ['%LECHE%'],
      );
      expect(caseInsensitiveResults.length, 1);
      expect(caseInsensitiveResults.first['nombre'], 'Leche Entera');
    });

    test('Calculadora complete flow integration', () async {
      // Setup test data
      final almacenId = await database.insert('almacenes', {
        'nombre': 'Test Almacen',
        'direccion': 'Test Address',
        'descripcion': 'Test Description',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });
      
      final categorias = await database.query('categorias', where: 'nombre = ?', whereArgs: ['General']);
      final categoriaId = categorias.first['id'];
      
      final producto1Id = await database.insert('productos', {
        'nombre': 'Producto 1',
        'precio': 5.0,
        'peso': 1.0,
        'tamano': '1kg',
        'codigo_qr': 'QR001',
        'categoria_id': categoriaId,
        'almacen_id': almacenId,
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });
      
      final producto2Id = await database.insert('productos', {
        'nombre': 'Producto 2',
        'precio': 3.0,
        'peso': 0.5,
        'tamano': '500g',
        'codigo_qr': 'QR002',
        'categoria_id': categoriaId,
        'almacen_id': almacenId,
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });
      
      // Create shopping list
      final listaId = await database.insert('listas_compra', {
        'nombre': 'Mi Lista de Compras',
        'total': 0.0,
        'fecha_creacion': DateTime.now().toIso8601String(),
      });
      
      // Add items to list
      await database.insert('items_calculadora', {
        'lista_compra_id': listaId,
        'producto_id': producto1Id,
        'cantidad': 2,
        'subtotal': 10.0, // 5.0 * 2
      });
      
      await database.insert('items_calculadora', {
        'lista_compra_id': listaId,
        'producto_id': producto2Id,
        'cantidad': 3,
        'subtotal': 9.0, // 3.0 * 3
      });
      
      // Update total
      await database.update('listas_compra', {
        'total': 19.0, // 10.0 + 9.0
      }, where: 'id = ?', whereArgs: [listaId]);
      
      // Verify list was created correctly
      final listas = await database.query('listas_compra', where: 'id = ?', whereArgs: [listaId]);
      expect(listas.length, 1);
      expect(listas.first['total'], 19.0);
      expect(listas.first['nombre'], 'Mi Lista de Compras');
      
      // Verify items were added correctly
      final items = await database.rawQuery('''
        SELECT ic.*, p.nombre as producto_nombre, p.precio
        FROM items_calculadora ic
        JOIN productos p ON ic.producto_id = p.id
        WHERE ic.lista_compra_id = ?
        ORDER BY ic.id
      ''', [listaId]);
      
      expect(items.length, 2);
      expect(items[0]['cantidad'], 2);
      expect(items[0]['subtotal'], 10.0);
      expect(items[0]['producto_nombre'], 'Producto 1');
      expect(items[1]['cantidad'], 3);
      expect(items[1]['subtotal'], 9.0);
      expect(items[1]['producto_nombre'], 'Producto 2');
      
      // Test quantity modification
      await database.update('items_calculadora', {
        'cantidad': 1,
        'subtotal': 5.0,
      }, where: 'lista_compra_id = ? AND producto_id = ?', whereArgs: [listaId, producto1Id]);
      
      await database.update('listas_compra', {
        'total': 14.0, // 5.0 + 9.0
      }, where: 'id = ?', whereArgs: [listaId]);
      
      // Verify updates
      final updatedItems = await database.query(
        'items_calculadora',
        where: 'lista_compra_id = ? AND producto_id = ?',
        whereArgs: [listaId, producto1Id],
      );
      expect(updatedItems.first['cantidad'], 1);
      expect(updatedItems.first['subtotal'], 5.0);
      
      final updatedListas = await database.query('listas_compra', where: 'id = ?', whereArgs: [listaId]);
      expect(updatedListas.first['total'], 14.0);
      
      // Test item removal
      await database.delete(
        'items_calculadora',
        where: 'lista_compra_id = ? AND producto_id = ?',
        whereArgs: [listaId, producto2Id],
      );
      
      await database.update('listas_compra', {
        'total': 5.0, // Only producto1 remains
      }, where: 'id = ?', whereArgs: [listaId]);
      
      final remainingItems = await database.query('items_calculadora', where: 'lista_compra_id = ?', whereArgs: [listaId]);
      expect(remainingItems.length, 1);
      expect(remainingItems.first['producto_id'], producto1Id);
    });

    test('Price comparison integration', () async {
      // Setup multiple stores
      final almacen1Id = await database.insert('almacenes', {
        'nombre': 'Supermercado A',
        'direccion': 'Calle A 123',
        'descripcion': 'Supermercado A',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });
      
      final almacen2Id = await database.insert('almacenes', {
        'nombre': 'Supermercado B',
        'direccion': 'Calle B 456',
        'descripcion': 'Supermercado B',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });
      
      final almacen3Id = await database.insert('almacenes', {
        'nombre': 'Supermercado C',
        'direccion': 'Calle C 789',
        'descripcion': 'Supermercado C',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });
      
      final categorias = await database.query('categorias', where: 'nombre = ?', whereArgs: ['General']);
      final categoriaId = categorias.first['id'];
      
      // Create same product in different stores with different prices
      await database.insert('productos', {
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
      
      await database.insert('productos', {
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
      
      await database.insert('productos', {
        'nombre': 'Leche Entera 1L',
        'precio': 2.80,
        'peso': 1.0,
        'tamano': '1L',
        'codigo_qr': 'QR001C',
        'categoria_id': categoriaId,
        'almacen_id': almacen3Id,
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });
      
      // Test price comparison query
      final results = await database.rawQuery('''
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
      
      // Test finding best price
      final bestPrice = await database.rawQuery('''
        SELECT MIN(precio) as mejor_precio, MAX(precio) as peor_precio
        FROM productos
        WHERE nombre LIKE ?
      ''', ['%Leche%']);
      
      expect(bestPrice.first['mejor_precio'], 2.30);
      expect(bestPrice.first['peor_precio'], 2.80);
      
      // Test savings calculation
      final savings = (bestPrice.first['peor_precio'] as double) - (bestPrice.first['mejor_precio'] as double);
      expect(savings, 0.50);
      
      // Test search for products that exist in multiple stores
      final multiStoreProducts = await database.rawQuery('''
        SELECT nombre, COUNT(*) as store_count
        FROM productos
        GROUP BY nombre
        HAVING COUNT(*) > 1
      ''');
      
      expect(multiStoreProducts.length, 1);
      expect(multiStoreProducts.first['nombre'], 'Leche Entera 1L');
      expect(multiStoreProducts.first['store_count'], 3);
    });

    test('QR code uniqueness per almacen constraint', () async {
      final almacenId = await database.insert('almacenes', {
        'nombre': 'Test Almacen',
        'direccion': 'Test Address',
        'descripcion': 'Test Description',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });
      
      final categorias = await database.query('categorias', where: 'nombre = ?', whereArgs: ['General']);
      final categoriaId = categorias.first['id'];
      
      // Insert first product with QR code
      await database.insert('productos', {
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
        await database.insert('productos', {
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
        
        // If we reach here, the constraint didn't work as expected
        // Let's check if there are duplicates
        final duplicates = await database.query(
          'productos',
          where: 'codigo_qr = ? AND almacen_id = ?',
          whereArgs: ['QR001', almacenId],
        );
        
        // Should have only one product due to unique constraint
        expect(duplicates.length, 1);
        
      } catch (e) {
        // Unique constraint is working - this is expected
        expect(e.toString(), contains('UNIQUE'));
      }
      
      // Verify we can insert same QR in different almacen
      final almacen2Id = await database.insert('almacenes', {
        'nombre': 'Test Almacen 2',
        'direccion': 'Test Address 2',
        'descripcion': 'Test Description 2',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });
      
      // This should work - same QR but different almacen
      await database.insert('productos', {
        'nombre': 'Product 3',
        'precio': 3.0,
        'peso': 1.0,
        'tamano': '1kg',
        'codigo_qr': 'QR001', // Same QR code
        'categoria_id': categoriaId,
        'almacen_id': almacen2Id, // Different almacen
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });
      
      // Verify both products exist
      final allQR001 = await database.query('productos', where: 'codigo_qr = ?', whereArgs: ['QR001']);
      expect(allQR001.length, 2);
    });

    test('Database table structure validation', () async {
      // Test that all required tables exist
      final tables = await database.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
      final tableNames = tables.map((table) => table['name']).toList();
      
      expect(tableNames, contains('almacenes'));
      expect(tableNames, contains('categorias'));
      expect(tableNames, contains('productos'));
      expect(tableNames, contains('listas_compra'));
      expect(tableNames, contains('items_calculadora'));
      
      // Test almacenes table structure
      final almacenesInfo = await database.rawQuery("PRAGMA table_info(almacenes)");
      final almacenesColumns = almacenesInfo.map((col) => col['name']).toList();
      
      expect(almacenesColumns, contains('id'));
      expect(almacenesColumns, contains('nombre'));
      expect(almacenesColumns, contains('direccion'));
      expect(almacenesColumns, contains('descripcion'));
      expect(almacenesColumns, contains('fecha_creacion'));
      expect(almacenesColumns, contains('fecha_actualizacion'));
      
      // Test productos table structure
      final productosInfo = await database.rawQuery("PRAGMA table_info(productos)");
      final productosColumns = productosInfo.map((col) => col['name']).toList();
      
      expect(productosColumns, contains('id'));
      expect(productosColumns, contains('nombre'));
      expect(productosColumns, contains('precio'));
      expect(productosColumns, contains('peso'));
      expect(productosColumns, contains('tamano'));
      expect(productosColumns, contains('codigo_qr'));
      expect(productosColumns, contains('categoria_id'));
      expect(productosColumns, contains('almacen_id'));
      expect(productosColumns, contains('fecha_creacion'));
      expect(productosColumns, contains('fecha_actualizacion'));
      
      // Test default category was created
      final defaultCategory = await database.query('categorias', where: 'nombre = ?', whereArgs: ['General']);
      expect(defaultCategory.length, 1);
      expect(defaultCategory.first['descripcion'], 'Categoría por defecto');
    });
  });
}