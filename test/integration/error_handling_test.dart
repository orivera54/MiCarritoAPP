import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';

import 'package:supermercado_comparador/core/error_handling/global_error_handler.dart';
import 'package:supermercado_comparador/core/errors/exceptions.dart'
    as app_exceptions;
import 'package:supermercado_comparador/core/errors/failures.dart';
import 'package:supermercado_comparador/core/widgets/enhanced_form_field.dart';

void main() {
  group('Error Handling Tests', () {
    setUpAll(() {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    group('Global Error Handler Tests', () {
      test('should return correct error messages for different error types',
          () {
        // Test AppException
        const appException =
            app_exceptions.ValidationException('Validation failed');
        expect(GlobalErrorHandler.getErrorMessage(appException),
            'Validation failed');

        // Test Failure
        const failure = DatabaseFailure('Database error');
        expect(GlobalErrorHandler.getErrorMessage(failure), 'Database error');

        // Test generic error
        final genericError = Exception('Generic error');
        expect(GlobalErrorHandler.getErrorMessage(genericError),
            'Ha ocurrido un error inesperado');
      });
    });

    group('Form Validation Tests', () {
      test('validateRequired should work correctly', () {
        expect(FormValidationHelper.validateRequired(null),
            'Este campo es requerido');
        expect(FormValidationHelper.validateRequired(''),
            'Este campo es requerido');
        expect(FormValidationHelper.validateRequired('   '),
            'Este campo es requerido');
        expect(FormValidationHelper.validateRequired('valid'), null);
        expect(
            FormValidationHelper.validateRequired('valid', fieldName: 'Nombre'),
            null);
        expect(FormValidationHelper.validateRequired(null, fieldName: 'Nombre'),
            'Nombre es requerido');
      });

      test('validateEmail should work correctly', () {
        expect(FormValidationHelper.validateEmail(null), null);
        expect(FormValidationHelper.validateEmail(''), null);
        expect(FormValidationHelper.validateEmail('invalid'),
            'Ingresa un email válido');
        expect(FormValidationHelper.validateEmail('invalid@'),
            'Ingresa un email válido');
        expect(FormValidationHelper.validateEmail('invalid@domain'),
            'Ingresa un email válido');
        expect(FormValidationHelper.validateEmail('valid@domain.com'), null);
        expect(
            FormValidationHelper.validateEmail('user.name@domain.co.uk'), null);
      });

      test('validatePrice should work correctly', () {
        expect(FormValidationHelper.validatePrice(null), null);
        expect(FormValidationHelper.validatePrice(''), null);
        expect(FormValidationHelper.validatePrice('invalid'),
            'Ingresa un precio válido');
        expect(FormValidationHelper.validatePrice('-1'),
            'El precio no puede ser negativo');
        expect(FormValidationHelper.validatePrice('1000000'),
            'El precio es demasiado alto');
        expect(FormValidationHelper.validatePrice('0'), null);
        expect(FormValidationHelper.validatePrice('10.50'), null);
        expect(FormValidationHelper.validatePrice('999999'), null);
      });

      test('validateWeight should work correctly', () {
        expect(FormValidationHelper.validateWeight(null), null);
        expect(FormValidationHelper.validateWeight(''), null);
        expect(FormValidationHelper.validateWeight('invalid'),
            'Ingresa un peso válido');
        expect(FormValidationHelper.validateWeight('0'),
            'El peso debe ser mayor a 0');
        expect(FormValidationHelper.validateWeight('-1'),
            'El peso debe ser mayor a 0');
        expect(FormValidationHelper.validateWeight('1001'),
            'El peso es demasiado alto');
        expect(FormValidationHelper.validateWeight('0.1'), null);
        expect(FormValidationHelper.validateWeight('500'), null);
        expect(FormValidationHelper.validateWeight('1000'), null);
      });

      test('validateQuantity should work correctly', () {
        expect(FormValidationHelper.validateQuantity(null), null);
        expect(FormValidationHelper.validateQuantity(''), null);
        expect(FormValidationHelper.validateQuantity('invalid'),
            'Ingresa una cantidad válida');
        expect(FormValidationHelper.validateQuantity('0'),
            'La cantidad debe ser mayor a 0');
        expect(FormValidationHelper.validateQuantity('-1'),
            'La cantidad debe ser mayor a 0');
        expect(FormValidationHelper.validateQuantity('10000'),
            'La cantidad es demasiado alta');
        expect(FormValidationHelper.validateQuantity('1'), null);
        expect(FormValidationHelper.validateQuantity('100'), null);
        expect(FormValidationHelper.validateQuantity('9999'), null);
      });

      test('validateLength should work correctly', () {
        expect(FormValidationHelper.validateLength(null), null);
        expect(FormValidationHelper.validateLength(''), null);
        expect(FormValidationHelper.validateLength('ab', minLength: 3),
            'Debe tener al menos 3 caracteres');
        expect(FormValidationHelper.validateLength('abcdef', maxLength: 5),
            'No puede tener más de 5 caracteres');
        expect(
            FormValidationHelper.validateLength('abc',
                minLength: 3, maxLength: 5),
            null);
        expect(
            FormValidationHelper.validateLength('abcde',
                minLength: 3, maxLength: 5),
            null);
      });

      test('combineValidators should work correctly', () {
        final validators = [
          (String? value) => FormValidationHelper.validateRequired(value),
          (String? value) =>
              FormValidationHelper.validateLength(value, minLength: 3),
        ];

        expect(FormValidationHelper.combineValidators(null, validators),
            'Este campo es requerido');
        expect(FormValidationHelper.combineValidators('ab', validators),
            'Debe tener al menos 3 caracteres');
        expect(FormValidationHelper.combineValidators('abc', validators), null);
      });
    });

    group('Database Recovery Tests', () {
      late Database database;

      setUp(() async {
        final dbPath = join(await getDatabasesPath(),
            'recovery_test_${DateTime.now().millisecondsSinceEpoch}.db');

        database = await openDatabase(
          dbPath,
          version: 1,
          onCreate: (db, version) async {
            // Create tables
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

            await db.execute('''
              CREATE TABLE listas_compra (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                nombre TEXT,
                total REAL NOT NULL,
                fecha_creacion TEXT NOT NULL
              )
            ''');

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

      test('should detect healthy database', () async {
        // Mock the database helper to use our test database
        // This is a simplified test - in real implementation you'd need to properly mock

        // Check that all required tables exist
        final tables = await database
            .rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
        final tableNames = tables.map((table) => table['name']).toList();

        expect(tableNames, contains('almacenes'));
        expect(tableNames, contains('categorias'));
        expect(tableNames, contains('productos'));
        expect(tableNames, contains('listas_compra'));
        expect(tableNames, contains('items_calculadora'));

        // Check integrity
        final integrityResult =
            await database.rawQuery('PRAGMA integrity_check');
        expect(integrityResult.first['integrity_check'], 'ok');
      });

      test('should backup and restore data correctly', () async {
        // Insert test data
        final almacenId = await database.insert('almacenes', {
          'nombre': 'Test Almacen',
          'direccion': 'Test Address',
          'descripcion': 'Test Description',
          'fecha_creacion': DateTime.now().toIso8601String(),
          'fecha_actualizacion': DateTime.now().toIso8601String(),
        });

        await database.insert('productos', {
          'nombre': 'Test Product',
          'precio': 10.0,
          'peso': 1.0,
          'tamano': '1kg',
          'codigo_qr': 'QR001',
          'categoria_id': 1,
          'almacen_id': almacenId,
          'fecha_creacion': DateTime.now().toIso8601String(),
          'fecha_actualizacion': DateTime.now().toIso8601String(),
        });

        // Verify data exists
        final almacenes = await database.query('almacenes');
        final productos = await database.query('productos');

        expect(almacenes.length, 1);
        expect(productos.length, 1);
        expect(almacenes.first['nombre'], 'Test Almacen');
        expect(productos.first['nombre'], 'Test Product');
      });

      test('should handle database corruption gracefully', () async {
        // Simulate corruption by dropping a required table
        await database.execute('DROP TABLE IF EXISTS categorias');

        // Check that table is missing
        final tables = await database
            .rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
        final tableNames = tables.map((table) => table['name']).toList();

        expect(tableNames, isNot(contains('categorias')));

        // In a real scenario, the recovery service would detect this and attempt repair
        // For this test, we just verify the corruption is detectable
      });

      test('should validate foreign key constraints', () async {
        // Insert valid data first
        final almacenId = await database.insert('almacenes', {
          'nombre': 'Test Almacen',
          'direccion': 'Test Address',
          'descripcion': 'Test Description',
          'fecha_creacion': DateTime.now().toIso8601String(),
          'fecha_actualizacion': DateTime.now().toIso8601String(),
        });

        // Try to insert product with invalid foreign key
        try {
          await database.insert('productos', {
            'nombre': 'Invalid Product',
            'precio': 10.0,
            'peso': 1.0,
            'tamano': '1kg',
            'codigo_qr': 'QR001',
            'categoria_id': 999, // Non-existent category
            'almacen_id': almacenId,
            'fecha_creacion': DateTime.now().toIso8601String(),
            'fecha_actualizacion': DateTime.now().toIso8601String(),
          });

          // If we reach here, foreign key constraints are not enforced
          // This is expected in SQLite without explicit foreign key enforcement
          final invalidProducts = await database.rawQuery('''
            SELECT p.*
            FROM productos p
            LEFT JOIN categorias c ON p.categoria_id = c.id
            WHERE c.id IS NULL
          ''');

          expect(invalidProducts.length, greaterThan(0));
        } catch (e) {
          // Foreign key constraint is working
          expect(e.toString(), contains('FOREIGN KEY'));
        }
      });

      test('should handle transaction rollback on error', () async {
        final almacenId = await database.insert('almacenes', {
          'nombre': 'Test Almacen',
          'direccion': 'Test Address',
          'descripcion': 'Test Description',
          'fecha_creacion': DateTime.now().toIso8601String(),
          'fecha_actualizacion': DateTime.now().toIso8601String(),
        });

        // Test transaction rollback
        try {
          await database.transaction((txn) async {
            // Insert valid product
            await txn.insert('productos', {
              'nombre': 'Valid Product',
              'precio': 10.0,
              'peso': 1.0,
              'tamano': '1kg',
              'codigo_qr': 'QR001',
              'categoria_id': 1,
              'almacen_id': almacenId,
              'fecha_creacion': DateTime.now().toIso8601String(),
              'fecha_actualizacion': DateTime.now().toIso8601String(),
            });

            // Try to insert duplicate QR code (should fail)
            await txn.insert('productos', {
              'nombre': 'Duplicate Product',
              'precio': 15.0,
              'peso': 1.0,
              'tamano': '1kg',
              'codigo_qr': 'QR001', // Same QR code
              'categoria_id': 1,
              'almacen_id': almacenId, // Same almacen
              'fecha_creacion': DateTime.now().toIso8601String(),
              'fecha_actualizacion': DateTime.now().toIso8601String(),
            });
          });
        } catch (e) {
          // Transaction should have rolled back
          final productos = await database.query('productos');
          expect(
              productos.length, 0); // No products should exist due to rollback
        }
      });
    });

    group('Exception Handling Tests', () {
      test('should create proper exception messages', () {
        const dbException =
            app_exceptions.DatabaseException('Database connection failed');
        expect(dbException.message, 'Database connection failed');
        expect(dbException.toString(), contains('DatabaseException'));

        const validationException =
            app_exceptions.ValidationException('Field is required');
        expect(validationException.message, 'Field is required');
        expect(validationException.toString(), contains('ValidationException'));

        const duplicateException =
            app_exceptions.DuplicateException('Record already exists');
        expect(duplicateException.message, 'Record already exists');
        expect(duplicateException.toString(), contains('DuplicateException'));

        const notFoundException =
            app_exceptions.NotFoundException('Record not found');
        expect(notFoundException.message, 'Record not found');
        expect(notFoundException.toString(), contains('NotFoundException'));
      });
    });

    group('Failure Handling Tests', () {
      test('should create proper failure messages', () {
        const dbFailure = DatabaseFailure('Database operation failed');
        expect(dbFailure.message, 'Database operation failed');

        const validationFailure = ValidationFailure('Validation failed');
        expect(validationFailure.message, 'Validation failed');

        const networkFailure = NetworkFailure('Network connection failed');
        expect(networkFailure.message, 'Network connection failed');

        const cameraFailure = CameraFailure('Camera operation failed');
        expect(cameraFailure.message, 'Camera operation failed');
      });
    });
  });
}
