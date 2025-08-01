import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart' hide DatabaseException;
import 'package:supermercado_comparador/core/constants/app_constants.dart';
import 'package:supermercado_comparador/core/database/database_helper.dart';
import 'package:supermercado_comparador/core/errors/exceptions.dart';
import 'package:supermercado_comparador/features/categorias/data/datasources/categoria_local_data_source.dart';
import 'package:supermercado_comparador/features/categorias/data/models/categoria_model.dart';

import 'categoria_local_data_source_test.mocks.dart';

@GenerateMocks([DatabaseHelper, Database])
void main() {
  late CategoriaLocalDataSourceImpl dataSource;
  late MockDatabaseHelper mockDatabaseHelper;
  late MockDatabase mockDatabase;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();
    dataSource = CategoriaLocalDataSourceImpl(databaseHelper: mockDatabaseHelper);
  });

  group('CategoriaLocalDataSource', () {
    final testDate = DateTime(2024, 1, 1);
    
    final testCategoriaModel = CategoriaModel(
      id: 1,
      nombre: 'Lácteos',
      descripcion: 'Productos lácteos y derivados',
      fechaCreacion: testDate,
    );

    final testCategoriaJson = {
      'id': 1,
      'nombre': 'Lácteos',
      'descripcion': 'Productos lácteos y derivados',
      'fecha_creacion': testDate.toIso8601String(),
    };

    group('getAllCategorias', () {
      test('should return list of CategoriaModel when successful', () async {
        // Arrange
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          AppConstants.categoriasTable,
          orderBy: 'nombre ASC',
        )).thenAnswer((_) async => [testCategoriaJson]);

        // Act
        final result = await dataSource.getAllCategorias();

        // Assert
        expect(result, isA<List<CategoriaModel>>());
        expect(result.length, equals(1));
        expect(result.first, equals(testCategoriaModel));
        verify(mockDatabase.query(
          AppConstants.categoriasTable,
          orderBy: 'nombre ASC',
        )).called(1);
      });

      test('should throw DatabaseException when database operation fails', () async {
        // Arrange
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          AppConstants.categoriasTable,
          orderBy: 'nombre ASC',
        )).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => dataSource.getAllCategorias(),
          throwsA(isA<DatabaseException>()),
        );
      });
    });

    group('getCategoriaById', () {
      test('should return CategoriaModel when categoria exists', () async {
        // Arrange
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          AppConstants.categoriasTable,
          where: 'id = ?',
          whereArgs: [1],
        )).thenAnswer((_) async => [testCategoriaJson]);

        // Act
        final result = await dataSource.getCategoriaById(1);

        // Assert
        expect(result, equals(testCategoriaModel));
      });

      test('should return null when categoria does not exist', () async {
        // Arrange
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          AppConstants.categoriasTable,
          where: 'id = ?',
          whereArgs: [1],
        )).thenAnswer((_) async => []);

        // Act
        final result = await dataSource.getCategoriaById(1);

        // Assert
        expect(result, isNull);
      });

      test('should throw DatabaseException when database operation fails', () async {
        // Arrange
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          AppConstants.categoriasTable,
          where: 'id = ?',
          whereArgs: [1],
        )).thenThrow(Exception('Database error'));

        // Act & Assert
        expect(
          () => dataSource.getCategoriaById(1),
          throwsA(isA<DatabaseException>()),
        );
      });
    });

    group('getCategoriaByName', () {
      test('should return CategoriaModel when categoria exists', () async {
        // Arrange
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          AppConstants.categoriasTable,
          where: 'LOWER(nombre) = LOWER(?)',
          whereArgs: ['Lácteos'],
        )).thenAnswer((_) async => [testCategoriaJson]);

        // Act
        final result = await dataSource.getCategoriaByName('Lácteos');

        // Assert
        expect(result, equals(testCategoriaModel));
      });

      test('should return null when categoria does not exist', () async {
        // Arrange
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          AppConstants.categoriasTable,
          where: 'LOWER(nombre) = LOWER(?)',
          whereArgs: ['Lácteos'],
        )).thenAnswer((_) async => []);

        // Act
        final result = await dataSource.getCategoriaByName('Lácteos');

        // Assert
        expect(result, isNull);
      });
    });

    group('insertCategoria', () {
      test('should insert categoria and return CategoriaModel with id', () async {
        // Arrange
        final categoriaToInsert = CategoriaModel(
          nombre: 'Lácteos',
          descripcion: 'Productos lácteos y derivados',
          fechaCreacion: testDate,
        );
        
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          AppConstants.categoriasTable,
          where: 'LOWER(nombre) = LOWER(?)',
          whereArgs: ['Lácteos'],
        )).thenAnswer((_) async => []); // Name doesn't exist
        when(mockDatabase.insert(
          AppConstants.categoriasTable,
          any,
        )).thenAnswer((_) async => 1);

        // Act
        final result = await dataSource.insertCategoria(categoriaToInsert);

        // Assert
        expect(result.id, equals(1));
        expect(result.nombre, equals('Lácteos'));
        verify(mockDatabase.insert(AppConstants.categoriasTable, any)).called(1);
      });

      test('should throw ValidationException when categoria name already exists', () async {
        // Arrange
        final categoriaToInsert = CategoriaModel(
          nombre: 'Lácteos',
          descripcion: 'Productos lácteos y derivados',
          fechaCreacion: testDate,
        );
        
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          AppConstants.categoriasTable,
          where: 'LOWER(nombre) = LOWER(?)',
          whereArgs: ['Lácteos'],
        )).thenAnswer((_) async => [testCategoriaJson]); // Name exists

        // Act & Assert
        expect(
          () => dataSource.insertCategoria(categoriaToInsert),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw ValidationException when categoria data is invalid', () async {
        // Arrange
        final invalidCategoria = CategoriaModel(
          nombre: '', // Invalid empty name
          descripcion: 'Productos lácteos y derivados',
          fechaCreacion: testDate,
        );

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);

        // Act & Assert
        expect(
          () => dataSource.insertCategoria(invalidCategoria),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('updateCategoria', () {
      test('should update categoria and return updated CategoriaModel', () async {
        // Arrange
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          AppConstants.categoriasTable,
          where: 'LOWER(nombre) = LOWER(?) AND id != ?',
          whereArgs: ['Lácteos', 1],
        )).thenAnswer((_) async => []); // Name doesn't exist for other records
        when(mockDatabase.update(
          AppConstants.categoriasTable,
          any,
          where: 'id = ?',
          whereArgs: [1],
        )).thenAnswer((_) async => 1);

        // Act
        final result = await dataSource.updateCategoria(testCategoriaModel);

        // Assert
        expect(result.id, equals(1));
        expect(result.nombre, equals('Lácteos'));
        verify(mockDatabase.update(
          AppConstants.categoriasTable,
          any,
          where: 'id = ?',
          whereArgs: [1],
        )).called(1);
      });

      test('should throw ValidationException when id is null', () async {
        // Arrange
        final categoriaWithoutId = CategoriaModel(
          nombre: 'Lácteos',
          descripcion: 'Productos lácteos y derivados',
          fechaCreacion: testDate,
        );

        // Act & Assert
        expect(
          () => dataSource.updateCategoria(categoriaWithoutId),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw DatabaseException when categoria not found', () async {
        // Arrange
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          AppConstants.categoriasTable,
          where: 'LOWER(nombre) = LOWER(?) AND id != ?',
          whereArgs: ['Lácteos', 1],
        )).thenAnswer((_) async => []); // Name doesn't exist for other records
        when(mockDatabase.update(
          AppConstants.categoriasTable,
          any,
          where: 'id = ?',
          whereArgs: [1],
        )).thenAnswer((_) async => 0); // No rows affected

        // Act & Assert
        expect(
          () => dataSource.updateCategoria(testCategoriaModel),
          throwsA(isA<DatabaseException>()),
        );
      });
    });

    group('deleteCategoria', () {
      test('should delete categoria when no products are associated', () async {
        // Arrange
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery(
          'SELECT COUNT(*) FROM ${AppConstants.productosTable} WHERE categoria_id = ?',
          [1],
        )).thenAnswer((_) async => [{'COUNT(*)': 0}]);
        when(mockDatabase.query(
          AppConstants.categoriasTable,
          where: 'id = ?',
          whereArgs: [1],
        )).thenAnswer((_) async => [testCategoriaJson]);
        when(mockDatabase.delete(
          AppConstants.categoriasTable,
          where: 'id = ?',
          whereArgs: [1],
        )).thenAnswer((_) async => 1);

        // Act
        await dataSource.deleteCategoria(1);

        // Assert
        verify(mockDatabase.delete(
          AppConstants.categoriasTable,
          where: 'id = ?',
          whereArgs: [1],
        )).called(1);
      });

      test('should throw ValidationException when categoria has associated products', () async {
        // Arrange
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery(
          'SELECT COUNT(*) FROM ${AppConstants.productosTable} WHERE categoria_id = ?',
          [1],
        )).thenAnswer((_) async => [{'COUNT(*)': 5}]); // Has products

        // Act & Assert
        expect(
          () => dataSource.deleteCategoria(1),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw ValidationException when trying to delete default category', () async {
        // Arrange
        final defaultCategoriaJson = {
          'id': 1,
          'nombre': AppConstants.defaultCategory,
          'descripcion': 'Categoría por defecto',
          'fecha_creacion': testDate.toIso8601String(),
        };
        
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery(
          'SELECT COUNT(*) FROM ${AppConstants.productosTable} WHERE categoria_id = ?',
          [1],
        )).thenAnswer((_) async => [{'COUNT(*)': 0}]);
        when(mockDatabase.query(
          AppConstants.categoriasTable,
          where: 'id = ?',
          whereArgs: [1],
        )).thenAnswer((_) async => [defaultCategoriaJson]);

        // Act & Assert
        expect(
          () => dataSource.deleteCategoria(1),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('categoriaNameExists', () {
      test('should return true when categoria name exists', () async {
        // Arrange
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          AppConstants.categoriasTable,
          where: 'LOWER(nombre) = LOWER(?)',
          whereArgs: ['Lácteos'],
        )).thenAnswer((_) async => [testCategoriaJson]);

        // Act
        final result = await dataSource.categoriaNameExists('Lácteos');

        // Assert
        expect(result, isTrue);
      });

      test('should return false when categoria name does not exist', () async {
        // Arrange
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          AppConstants.categoriasTable,
          where: 'LOWER(nombre) = LOWER(?)',
          whereArgs: ['Lácteos'],
        )).thenAnswer((_) async => []);

        // Act
        final result = await dataSource.categoriaNameExists('Lácteos');

        // Assert
        expect(result, isFalse);
      });

      test('should exclude specified id when checking name existence', () async {
        // Arrange
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(
          AppConstants.categoriasTable,
          where: 'LOWER(nombre) = LOWER(?) AND id != ?',
          whereArgs: ['Lácteos', 1],
        )).thenAnswer((_) async => []);

        // Act
        final result = await dataSource.categoriaNameExists('Lácteos', excludeId: 1);

        // Assert
        expect(result, isFalse);
        verify(mockDatabase.query(
          AppConstants.categoriasTable,
          where: 'LOWER(nombre) = LOWER(?) AND id != ?',
          whereArgs: ['Lácteos', 1],
        )).called(1);
      });
    });
  });
}