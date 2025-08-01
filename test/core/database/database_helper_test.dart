import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supermercado_comparador/core/database/database_helper.dart';
import 'package:supermercado_comparador/core/constants/app_constants.dart';

void main() {
  group('DatabaseHelper', () {
    late DatabaseHelper databaseHelper;

    setUpAll(() {
      // Initialize FFI for testing
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    setUp(() {
      databaseHelper = DatabaseHelper();
    });

    tearDown(() async {
      await databaseHelper.close();
    });

    test('should be singleton', () {
      final instance1 = DatabaseHelper();
      final instance2 = DatabaseHelper();
      expect(identical(instance1, instance2), isTrue);
    });

    test('should initialize database', () async {
      final db = await databaseHelper.database;
      expect(db, isNotNull);
      expect(db.isOpen, isTrue);
    });

    test('should create all required tables', () async {
      final db = await databaseHelper.database;
      
      // Check if tables exist by querying sqlite_master
      final tables = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'"
      );
      
      final tableNames = tables.map((table) => table['name'] as String).toList();
      
      expect(tableNames, contains(AppConstants.almacenesTable));
      expect(tableNames, contains(AppConstants.categoriasTable));
      expect(tableNames, contains(AppConstants.productosTable));
      expect(tableNames, contains(AppConstants.listasCompraTable));
      expect(tableNames, contains(AppConstants.itemsCalculadoraTable));
    });

    test('should create default category', () async {
      final db = await databaseHelper.database;
      
      final result = await db.query(
        AppConstants.categoriasTable,
        where: 'nombre = ?',
        whereArgs: [AppConstants.defaultCategory],
      );
      
      expect(result, isNotEmpty);
      expect(result.first['nombre'], equals(AppConstants.defaultCategory));
    });

    test('should check if database exists', () async {
      await databaseHelper.database; // Initialize database
      final exists = await databaseHelper.databaseExists();
      expect(exists, isTrue);
    });

    test('should get database path', () async {
      final path = await databaseHelper.getDatabasePath();
      expect(path, isNotNull);
      expect(path, contains(AppConstants.databaseName));
    });

    test('should reset database', () async {
      final db1 = await databaseHelper.database;
      expect(db1.isOpen, isTrue);
      
      await databaseHelper.resetDatabase();
      
      final db2 = await databaseHelper.database;
      expect(db2.isOpen, isTrue);
      
      // Verify default category is recreated
      final result = await db2.query(
        AppConstants.categoriasTable,
        where: 'nombre = ?',
        whereArgs: [AppConstants.defaultCategory],
      );
      
      expect(result, isNotEmpty);
    });

    group('Table Structure', () {
      test('should have correct almacenes table structure', () async {
        final db = await databaseHelper.database;
        
        final columns = await db.rawQuery('PRAGMA table_info(${AppConstants.almacenesTable})');
        final columnNames = columns.map((col) => col['name'] as String).toList();
        
        expect(columnNames, contains('id'));
        expect(columnNames, contains('nombre'));
        expect(columnNames, contains('direccion'));
        expect(columnNames, contains('descripcion'));
        expect(columnNames, contains('fecha_creacion'));
        expect(columnNames, contains('fecha_actualizacion'));
      });

      test('should have correct productos table structure', () async {
        final db = await databaseHelper.database;
        
        final columns = await db.rawQuery('PRAGMA table_info(${AppConstants.productosTable})');
        final columnNames = columns.map((col) => col['name'] as String).toList();
        
        expect(columnNames, contains('id'));
        expect(columnNames, contains('nombre'));
        expect(columnNames, contains('precio'));
        expect(columnNames, contains('peso'));
        expect(columnNames, contains('tamano'));
        expect(columnNames, contains('codigo_qr'));
        expect(columnNames, contains('categoria_id'));
        expect(columnNames, contains('almacen_id'));
        expect(columnNames, contains('fecha_creacion'));
        expect(columnNames, contains('fecha_actualizacion'));
      });

      test('should have foreign key constraints', () async {
        final db = await databaseHelper.database;
        
        final foreignKeys = await db.rawQuery('PRAGMA foreign_key_list(${AppConstants.productosTable})');
        
        expect(foreignKeys, isNotEmpty);
        
        final tableReferences = foreignKeys.map((fk) => fk['table'] as String).toList();
        expect(tableReferences, contains(AppConstants.categoriasTable));
        expect(tableReferences, contains(AppConstants.almacenesTable));
      });
    });
  });
}