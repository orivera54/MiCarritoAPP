import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'lib/core/database/database_helper.dart';
import 'lib/features/productos/data/datasources/producto_local_data_source.dart';
import 'lib/features/productos/data/models/producto_model.dart';

void main() async {
  // Initialize FFI
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('Debug Insert Producto', () {
    late DatabaseHelper databaseHelper;
    late ProductoLocalDataSourceImpl dataSource;

    setUp(() async {
      databaseHelper = DatabaseHelper();
      dataSource = ProductoLocalDataSourceImpl(databaseHelper: databaseHelper);
      
      // Recreate database for each test to ensure clean schema
      await databaseHelper.recreateDatabase();
    });

    test('should insert producto with all fields', () async {
      // Arrange
      final producto = ProductoModel(
        nombre: 'Leche Entera 1L',
        precio: 2500.0,
        peso: 1.0,
        volumen: 1000.0, // 1L en ml
        tamano: '1L',
        codigoQR: '123456789',
        categoriaId: 1, // Default category should exist
        almacenId: 1, // We need to create an almacen first
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
      );

      // First, let's create an almacen
      final db = await databaseHelper.database;
      final almacenId = await db.insert('almacenes', {
        'nombre': 'Supermercado Test',
        'direccion': 'Calle Test 123',
        'descripcion': 'Almacén de prueba',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });

      // Update producto with the created almacen ID
      final productoWithAlmacen = producto.copyWith(almacenId: almacenId);

      print('Attempting to insert producto: ${productoWithAlmacen.toJson()}');

      // Act & Assert
      try {
        final result = await dataSource.insertProducto(productoWithAlmacen);
        print('Insert successful: ${result.toJson()}');
        expect(result.id, isNotNull);
        expect(result.nombre, equals('Leche Entera 1L'));
      } catch (e) {
        print('Insert failed with error: $e');
        print('Error type: ${e.runtimeType}');
        if (e is Exception) {
          print('Exception details: ${e.toString()}');
        }
        rethrow;
      }
    });

    test('should insert producto with minimal fields', () async {
      // Arrange - minimal required fields only
      final producto = ProductoModel(
        nombre: 'Producto Mínimo',
        precio: 1000.0,
        categoriaId: 1, // Default category
        almacenId: 1, // We need to create an almacen first
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
      );

      // Create an almacen first
      final db = await databaseHelper.database;
      final almacenId = await db.insert('almacenes', {
        'nombre': 'Almacén Mínimo',
        'direccion': null,
        'descripcion': null,
        'fecha_creacion': DateTime.now().toIso8601String(),
        'fecha_actualizacion': DateTime.now().toIso8601String(),
      });

      final productoWithAlmacen = producto.copyWith(almacenId: almacenId);

      print('Attempting to insert minimal producto: ${productoWithAlmacen.toJson()}');

      // Act & Assert
      try {
        final result = await dataSource.insertProducto(productoWithAlmacen);
        print('Minimal insert successful: ${result.toJson()}');
        expect(result.id, isNotNull);
        expect(result.nombre, equals('Producto Mínimo'));
      } catch (e) {
        print('Minimal insert failed with error: $e');
        print('Error type: ${e.runtimeType}');
        rethrow;
      }
    });

    test('should show database schema', () async {
      final db = await databaseHelper.database;
      
      // Get table info for productos
      final tableInfo = await db.rawQuery("PRAGMA table_info(productos)");
      print('Productos table schema:');
      for (var column in tableInfo) {
        print('  ${column['name']}: ${column['type']} (nullable: ${column['notnull'] == 0})');
      }

      // Check if default category exists
      final categories = await db.query('categorias');
      print('Categories in database: $categories');

      // Check database version
      final version = await db.getVersion();
      print('Database version: $version');
    });
  });
}