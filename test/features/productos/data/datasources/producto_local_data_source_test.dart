import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite/sqflite.dart' hide DatabaseException;
import 'package:supermercado_comparador/core/database/database_helper.dart';
import 'package:supermercado_comparador/core/errors/exceptions.dart';
import 'package:supermercado_comparador/features/productos/data/datasources/producto_local_data_source.dart';
import 'package:supermercado_comparador/features/productos/data/models/producto_model.dart';

import 'producto_local_data_source_test.mocks.dart';

@GenerateMocks([DatabaseHelper, Database])
void main() {
  late ProductoLocalDataSourceImpl dataSource;
  late MockDatabaseHelper mockDatabaseHelper;
  late MockDatabase mockDatabase;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();
    dataSource = ProductoLocalDataSourceImpl(databaseHelper: mockDatabaseHelper);
  });

  final testDate = DateTime(2024, 1, 1);
  final testProductoModel = ProductoModel(
    id: 1,
    nombre: 'Test Producto',
    precio: 10.50,
    peso: 1.5,
    tamano: 'Grande',
    codigoQR: 'QR123',
    categoriaId: 1,
    almacenId: 1,
    fechaCreacion: testDate,
    fechaActualizacion: testDate,
  );

  final testProductoJson = {
    'id': 1,
    'nombre': 'Test Producto',
    'precio': 10.50,
    'peso': 1.5,
    'tamano': 'Grande',
    'codigo_qr': 'QR123',
    'categoria_id': 1,
    'almacen_id': 1,
    'fecha_creacion': testDate.toIso8601String(),
    'fecha_actualizacion': testDate.toIso8601String(),
  };

  group('getAllProductos', () {
    test('should return list of ProductoModel when successful', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.query(
        'productos',
        orderBy: 'fecha_creacion DESC',
      )).thenAnswer((_) async => [testProductoJson]);

      // act
      final result = await dataSource.getAllProductos();

      // assert
      expect(result, isA<List<ProductoModel>>());
      expect(result.length, 1);
      expect(result.first, equals(testProductoModel));
      verify(mockDatabase.query(
        'productos',
        orderBy: 'fecha_creacion DESC',
      ));
    });

    test('should throw DatabaseException when database query fails', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.query(
        'productos',
        orderBy: 'fecha_creacion DESC',
      )).thenThrow(Exception('Database error'));

      // act & assert
      expect(
        () => dataSource.getAllProductos(),
        throwsA(isA<DatabaseException>()),
      );
    });
  });

  group('getProductosByAlmacen', () {
    test('should return list of ProductoModel filtered by almacen', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.query(
        'productos',
        where: 'almacen_id = ?',
        whereArgs: [1],
        orderBy: 'nombre ASC',
      )).thenAnswer((_) async => [testProductoJson]);

      // act
      final result = await dataSource.getProductosByAlmacen(1);

      // assert
      expect(result, isA<List<ProductoModel>>());
      expect(result.length, 1);
      expect(result.first.almacenId, equals(1));
      verify(mockDatabase.query(
        'productos',
        where: 'almacen_id = ?',
        whereArgs: [1],
        orderBy: 'nombre ASC',
      ));
    });
  });

  group('getProductosByCategoria', () {
    test('should return list of ProductoModel filtered by categoria', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.query(
        'productos',
        where: 'categoria_id = ?',
        whereArgs: [1],
        orderBy: 'nombre ASC',
      )).thenAnswer((_) async => [testProductoJson]);

      // act
      final result = await dataSource.getProductosByCategoria(1);

      // assert
      expect(result, isA<List<ProductoModel>>());
      expect(result.length, 1);
      expect(result.first.categoriaId, equals(1));
      verify(mockDatabase.query(
        'productos',
        where: 'categoria_id = ?',
        whereArgs: [1],
        orderBy: 'nombre ASC',
      ));
    });
  });

  group('getProductoById', () {
    test('should return ProductoModel when producto exists', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.query(
        'productos',
        where: 'id = ?',
        whereArgs: [1],
      )).thenAnswer((_) async => [testProductoJson]);

      // act
      final result = await dataSource.getProductoById(1);

      // assert
      expect(result, equals(testProductoModel));
      verify(mockDatabase.query(
        'productos',
        where: 'id = ?',
        whereArgs: [1],
      ));
    });

    test('should return null when producto does not exist', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.query(
        'productos',
        where: 'id = ?',
        whereArgs: [1],
      )).thenAnswer((_) async => []);

      // act
      final result = await dataSource.getProductoById(1);

      // assert
      expect(result, isNull);
    });

    test('should throw DatabaseException when database query fails', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.query(
        'productos',
        where: 'id = ?',
        whereArgs: [1],
      )).thenThrow(Exception('Database error'));

      // act & assert
      expect(
        () => dataSource.getProductoById(1),
        throwsA(isA<DatabaseException>()),
      );
    });
  });

  group('searchProductosByName', () {
    test('should return list of ProductoModel matching search term', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.rawQuery(any, any)).thenAnswer((_) async => [testProductoJson]);

      // act
      final result = await dataSource.searchProductosByName('test');

      // assert
      expect(result, isA<List<ProductoModel>>());
      expect(result.length, 1);
      expect(result.first.nombre.toLowerCase(), contains('test'));
    });

    test('should throw DatabaseException when search fails', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.rawQuery(any, any)).thenThrow(Exception('Database error'));

      // act & assert
      expect(
        () => dataSource.searchProductosByName('test'),
        throwsA(isA<DatabaseException>()),
      );
    });
  });

  group('getProductoByQR', () {
    test('should return ProductoModel when QR code exists', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.query(
        'productos',
        where: 'codigo_qr = ?',
        whereArgs: ['QR123'],
      )).thenAnswer((_) async => [testProductoJson]);

      // act
      final result = await dataSource.getProductoByQR('QR123');

      // assert
      expect(result, equals(testProductoModel));
      verify(mockDatabase.query(
        'productos',
        where: 'codigo_qr = ?',
        whereArgs: ['QR123'],
      ));
    });

    test('should return null when QR code does not exist', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.query(
        'productos',
        where: 'codigo_qr = ?',
        whereArgs: ['NONEXISTENT'],
      )).thenAnswer((_) async => []);

      // act
      final result = await dataSource.getProductoByQR('NONEXISTENT');

      // assert
      expect(result, isNull);
    });
  });

  group('insertProducto', () {
    test('should return ProductoModel with id when successful', () async {
      // arrange
      final productoToInsert = ProductoModel(
        nombre: 'New Producto',
        precio: 15.99,
        categoriaId: 1,
        almacenId: 1,
        fechaCreacion: testDate,
        fechaActualizacion: testDate,
      );

      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.insert('productos', any)).thenAnswer((_) async => 1);

      // act
      final result = await dataSource.insertProducto(productoToInsert);

      // assert
      expect(result.id, equals(1));
      expect(result.nombre, equals('New Producto'));
      verify(mockDatabase.insert('productos', any));
    });

    test('should throw ValidationException when producto data is invalid', () async {
      // arrange
      final invalidProducto = ProductoModel(
        nombre: '', // Invalid empty name
        precio: 10.0,
        categoriaId: 1,
        almacenId: 1,
        fechaCreacion: testDate,
        fechaActualizacion: testDate,
      );

      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);

      // act & assert
      expect(
        () => dataSource.insertProducto(invalidProducto),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should throw DuplicateException when QR code already exists in almacen', () async {
      // arrange
      final productoWithDuplicateQR = ProductoModel(
        nombre: 'Duplicate QR Producto',
        precio: 10.0,
        codigoQR: 'EXISTING_QR',
        categoriaId: 1,
        almacenId: 1,
        fechaCreacion: testDate,
        fechaActualizacion: testDate,
      );

      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.query(
        'productos',
        where: 'codigo_qr = ? AND almacen_id = ?',
        whereArgs: ['EXISTING_QR', 1],
      )).thenAnswer((_) async => [testProductoJson]);

      // act & assert
      expect(
        () => dataSource.insertProducto(productoWithDuplicateQR),
        throwsA(isA<DuplicateException>()),
      );
    });
  });

  group('updateProducto', () {
    test('should return updated ProductoModel when successful', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.query(
        'productos',
        where: 'codigo_qr = ? AND almacen_id = ? AND id != ?',
        whereArgs: ['QR123', 1, 1],
      )).thenAnswer((_) async => []);
      when(mockDatabase.update(
        'productos',
        any,
        where: 'id = ?',
        whereArgs: [1],
      )).thenAnswer((_) async => 1);

      // act
      final result = await dataSource.updateProducto(testProductoModel);

      // assert
      expect(result.id, equals(1));
      expect(result.nombre, equals('Test Producto'));
      verify(mockDatabase.update(
        'productos',
        any,
        where: 'id = ?',
        whereArgs: [1],
      ));
    });

    test('should throw ValidationException when id is null', () async {
      // arrange
      final productoWithoutId = ProductoModel(
        nombre: 'Test Producto',
        precio: 10.0,
        categoriaId: 1,
        almacenId: 1,
        fechaCreacion: testDate,
        fechaActualizacion: testDate,
      );

      // act & assert
      expect(
        () => dataSource.updateProducto(productoWithoutId),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should throw NotFoundException when producto not found', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.query(
        'productos',
        where: 'codigo_qr = ? AND almacen_id = ? AND id != ?',
        whereArgs: ['QR123', 1, 1],
      )).thenAnswer((_) async => []);
      when(mockDatabase.update(
        'productos',
        any,
        where: 'id = ?',
        whereArgs: [1],
      )).thenAnswer((_) async => 0);

      // act & assert
      expect(
        () => dataSource.updateProducto(testProductoModel),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('deleteProducto', () {
    test('should delete producto when no associated items in calculadora', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.rawQuery(
        'SELECT COUNT(*) FROM items_calculadora WHERE producto_id = ?',
        [1],
      )).thenAnswer((_) async => [{'COUNT(*)': 0}]);
      when(mockDatabase.delete(
        'productos',
        where: 'id = ?',
        whereArgs: [1],
      )).thenAnswer((_) async => 1);

      // act
      await dataSource.deleteProducto(1);

      // assert
      verify(mockDatabase.delete(
        'productos',
        where: 'id = ?',
        whereArgs: [1],
      ));
    });

    test('should throw ValidationException when producto has associated items', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.rawQuery(
        'SELECT COUNT(*) FROM items_calculadora WHERE producto_id = ?',
        [1],
      )).thenAnswer((_) async => [{'COUNT(*)': 1}]);

      // act & assert
      expect(
        () => dataSource.deleteProducto(1),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should throw NotFoundException when producto not found', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.rawQuery(
        'SELECT COUNT(*) FROM items_calculadora WHERE producto_id = ?',
        [1],
      )).thenAnswer((_) async => []);
      when(mockDatabase.delete(
        'productos',
        where: 'id = ?',
        whereArgs: [1],
      )).thenAnswer((_) async => 0);

      // act & assert
      expect(
        () => dataSource.deleteProducto(1),
        throwsA(isA<NotFoundException>()),
      );
    });
  });

  group('qrExistsInAlmacen', () {
    test('should return true when QR exists in almacen', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.query(
        'productos',
        where: 'codigo_qr = ? AND almacen_id = ?',
        whereArgs: ['QR123', 1],
      )).thenAnswer((_) async => [testProductoJson]);

      // act
      final result = await dataSource.qrExistsInAlmacen('QR123', 1);

      // assert
      expect(result, isTrue);
    });

    test('should return false when QR does not exist in almacen', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.query(
        'productos',
        where: 'codigo_qr = ? AND almacen_id = ?',
        whereArgs: ['NONEXISTENT', 1],
      )).thenAnswer((_) async => []);

      // act
      final result = await dataSource.qrExistsInAlmacen('NONEXISTENT', 1);

      // assert
      expect(result, isFalse);
    });

    test('should exclude specified id when checking QR existence', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.query(
        'productos',
        where: 'codigo_qr = ? AND almacen_id = ? AND id != ?',
        whereArgs: ['QR123', 1, 1],
      )).thenAnswer((_) async => []);

      // act
      final result = await dataSource.qrExistsInAlmacen('QR123', 1, excludeId: 1);

      // assert
      expect(result, isFalse);
      verify(mockDatabase.query(
        'productos',
        where: 'codigo_qr = ? AND almacen_id = ? AND id != ?',
        whereArgs: ['QR123', 1, 1],
      ));
    });
  });

  group('getProductosWithDetails', () {
    test('should return productos with almacen and categoria names', () async {
      // arrange
      final testProductoWithDetails = {
        ...testProductoJson,
        'almacen_nombre': 'Test Almacen',
        'categoria_nombre': 'Test Categoria',
      };

      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.rawQuery(any)).thenAnswer((_) async => [testProductoWithDetails]);

      // act
      final result = await dataSource.getProductosWithDetails();

      // assert
      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result.length, 1);
      expect(result.first['almacen_nombre'], equals('Test Almacen'));
      expect(result.first['categoria_nombre'], equals('Test Categoria'));
    });
  });

  group('searchProductosWithFilters', () {
    test('should return filtered productos based on multiple criteria', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.rawQuery(any, any)).thenAnswer((_) async => [testProductoJson]);

      // act
      final result = await dataSource.searchProductosWithFilters(
        searchTerm: 'test',
        almacenId: 1,
        categoriaId: 1,
        minPrice: 5.0,
        maxPrice: 20.0,
      );

      // assert
      expect(result, isA<List<ProductoModel>>());
      expect(result.length, 1);
    });

    test('should handle empty filters', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.rawQuery(any, any)).thenAnswer((_) async => [testProductoJson]);

      // act
      final result = await dataSource.searchProductosWithFilters();

      // assert
      expect(result, isA<List<ProductoModel>>());
      expect(result.length, 1);
    });
  });
}