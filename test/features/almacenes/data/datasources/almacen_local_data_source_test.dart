import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite/sqflite.dart' hide DatabaseException;
import 'package:supermercado_comparador/core/database/database_helper.dart';
import 'package:supermercado_comparador/core/errors/exceptions.dart';
import 'package:supermercado_comparador/features/almacenes/data/datasources/almacen_local_data_source.dart';
import 'package:supermercado_comparador/features/almacenes/data/models/almacen_model.dart';

import 'almacen_local_data_source_test.mocks.dart';

@GenerateMocks([DatabaseHelper, Database])
void main() {
  late AlmacenLocalDataSourceImpl dataSource;
  late MockDatabaseHelper mockDatabaseHelper;
  late MockDatabase mockDatabase;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();
    dataSource = AlmacenLocalDataSourceImpl(databaseHelper: mockDatabaseHelper);
  });

  final testDate = DateTime(2024, 1, 1);
  final testAlmacenModel = AlmacenModel(
    id: 1,
    nombre: 'Test Almacen',
    direccion: 'Test Address',
    descripcion: 'Test Description',
    fechaCreacion: testDate,
    fechaActualizacion: testDate,
  );

  final testAlmacenJson = {
    'id': 1,
    'nombre': 'Test Almacen',
    'direccion': 'Test Address',
    'descripcion': 'Test Description',
    'fecha_creacion': testDate.toIso8601String(),
    'fecha_actualizacion': testDate.toIso8601String(),
  };

  group('getAllAlmacenes', () {
    test('should return list of AlmacenModel when successful', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.query(
        'almacenes',
        orderBy: 'fecha_creacion DESC',
      )).thenAnswer((_) async => [testAlmacenJson]);

      // act
      final result = await dataSource.getAllAlmacenes();

      // assert
      expect(result, isA<List<AlmacenModel>>());
      expect(result.length, 1);
      expect(result.first, equals(testAlmacenModel));
      verify(mockDatabase.query(
        'almacenes',
        orderBy: 'fecha_creacion DESC',
      ));
    });

    test('should throw DatabaseException when database query fails', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.query(
        'almacenes',
        orderBy: 'fecha_creacion DESC',
      )).thenThrow(Exception('Database error'));

      // act & assert
      expect(
        () => dataSource.getAllAlmacenes(),
        throwsA(isA<DatabaseException>()),
      );
    });
  });

  group('getAlmacenById', () {
    test('should return AlmacenModel when almacen exists', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.query(
        'almacenes',
        where: 'id = ?',
        whereArgs: [1],
      )).thenAnswer((_) async => [testAlmacenJson]);

      // act
      final result = await dataSource.getAlmacenById(1);

      // assert
      expect(result, equals(testAlmacenModel));
      verify(mockDatabase.query(
        'almacenes',
        where: 'id = ?',
        whereArgs: [1],
      ));
    });

    test('should return null when almacen does not exist', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.query(
        'almacenes',
        where: 'id = ?',
        whereArgs: [1],
      )).thenAnswer((_) async => []);

      // act
      final result = await dataSource.getAlmacenById(1);

      // assert
      expect(result, isNull);
    });

    test('should throw DatabaseException when database query fails', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.query(
        'almacenes',
        where: 'id = ?',
        whereArgs: [1],
      )).thenThrow(Exception('Database error'));

      // act & assert
      expect(
        () => dataSource.getAlmacenById(1),
        throwsA(isA<DatabaseException>()),
      );
    });
  });

  group('insertAlmacen', () {
    test('should return AlmacenModel with id when successful', () async {
      // arrange
      final almacenToInsert = AlmacenModel(
        nombre: 'New Almacen',
        direccion: 'New Address',
        descripcion: 'New Description',
        fechaCreacion: testDate,
        fechaActualizacion: testDate,
      );

      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.query(
        'almacenes',
        where: 'LOWER(nombre) = LOWER(?)',
        whereArgs: ['New Almacen'],
      )).thenAnswer((_) async => []);
      when(mockDatabase.insert('almacenes', any)).thenAnswer((_) async => 1);

      // act
      final result = await dataSource.insertAlmacen(almacenToInsert);

      // assert
      expect(result.id, equals(1));
      expect(result.nombre, equals('New Almacen'));
      verify(mockDatabase.insert('almacenes', any));
    });

    test('should throw ValidationException when almacen data is invalid', () async {
      // arrange
      final invalidAlmacen = AlmacenModel(
        nombre: '', // Invalid empty name
        fechaCreacion: testDate,
        fechaActualizacion: testDate,
      );

      // act & assert
      expect(
        () => dataSource.insertAlmacen(invalidAlmacen),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should throw ValidationException when name already exists', () async {
      // arrange
      final almacenToInsert = AlmacenModel(
        nombre: 'Existing Almacen',
        fechaCreacion: testDate,
        fechaActualizacion: testDate,
      );

      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.query(
        'almacenes',
        where: 'LOWER(nombre) = LOWER(?)',
        whereArgs: ['Existing Almacen'],
      )).thenAnswer((_) async => [testAlmacenJson]);

      // act & assert
      expect(
        () => dataSource.insertAlmacen(almacenToInsert),
        throwsA(isA<ValidationException>()),
      );
    });
  });

  group('updateAlmacen', () {
    test('should return updated AlmacenModel when successful', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.query(
        'almacenes',
        where: 'LOWER(nombre) = LOWER(?) AND id != ?',
        whereArgs: ['Test Almacen', 1],
      )).thenAnswer((_) async => []);
      when(mockDatabase.update(
        'almacenes',
        any,
        where: 'id = ?',
        whereArgs: [1],
      )).thenAnswer((_) async => 1);

      // act
      final result = await dataSource.updateAlmacen(testAlmacenModel);

      // assert
      expect(result.id, equals(1));
      expect(result.nombre, equals('Test Almacen'));
      verify(mockDatabase.update(
        'almacenes',
        any,
        where: 'id = ?',
        whereArgs: [1],
      ));
    });

    test('should throw ValidationException when id is null', () async {
      // arrange
      final almacenWithoutId = AlmacenModel(
        nombre: 'Test Almacen',
        fechaCreacion: testDate,
        fechaActualizacion: testDate,
      );

      // act & assert
      expect(
        () => dataSource.updateAlmacen(almacenWithoutId),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should throw DatabaseException when almacen not found', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.query(
        'almacenes',
        where: 'LOWER(nombre) = LOWER(?) AND id != ?',
        whereArgs: ['Test Almacen', 1],
      )).thenAnswer((_) async => []);
      when(mockDatabase.update(
        'almacenes',
        any,
        where: 'id = ?',
        whereArgs: [1],
      )).thenAnswer((_) async => 0);

      // act & assert
      expect(
        () => dataSource.updateAlmacen(testAlmacenModel),
        throwsA(isA<DatabaseException>()),
      );
    });
  });

  group('deleteAlmacen', () {
    test('should delete almacen when no associated products', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.rawQuery(
        'SELECT COUNT(*) FROM productos WHERE almacen_id = ?',
        [1],
      )).thenAnswer((_) async => [{'COUNT(*)': 0}]);
      when(mockDatabase.delete(
        'almacenes',
        where: 'id = ?',
        whereArgs: [1],
      )).thenAnswer((_) async => 1);

      // act
      await dataSource.deleteAlmacen(1);

      // assert
      verify(mockDatabase.delete(
        'almacenes',
        where: 'id = ?',
        whereArgs: [1],
      ));
    });

    test('should throw ValidationException when almacen has associated products', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.rawQuery(
        'SELECT COUNT(*) FROM productos WHERE almacen_id = ?',
        [1],
      )).thenAnswer((_) async => [{'COUNT(*)': 1}]);

      // act & assert
      expect(
        () => dataSource.deleteAlmacen(1),
        throwsA(isA<ValidationException>()),
      );
    });

    test('should throw DatabaseException when almacen not found', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.rawQuery(
        'SELECT COUNT(*) FROM productos WHERE almacen_id = ?',
        [1],
      )).thenAnswer((_) async => []);
      when(mockDatabase.delete(
        'almacenes',
        where: 'id = ?',
        whereArgs: [1],
      )).thenAnswer((_) async => 0);

      // act & assert
      expect(
        () => dataSource.deleteAlmacen(1),
        throwsA(isA<DatabaseException>()),
      );
    });
  });

  group('almacenNameExists', () {
    test('should return true when name exists', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.query(
        'almacenes',
        where: 'LOWER(nombre) = LOWER(?)',
        whereArgs: ['Test Almacen'],
      )).thenAnswer((_) async => [testAlmacenJson]);

      // act
      final result = await dataSource.almacenNameExists('Test Almacen');

      // assert
      expect(result, isTrue);
    });

    test('should return false when name does not exist', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.query(
        'almacenes',
        where: 'LOWER(nombre) = LOWER(?)',
        whereArgs: ['Non Existing'],
      )).thenAnswer((_) async => []);

      // act
      final result = await dataSource.almacenNameExists('Non Existing');

      // assert
      expect(result, isFalse);
    });

    test('should exclude specified id when checking name existence', () async {
      // arrange
      when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
      when(mockDatabase.query(
        'almacenes',
        where: 'LOWER(nombre) = LOWER(?) AND id != ?',
        whereArgs: ['Test Almacen', 1],
      )).thenAnswer((_) async => []);

      // act
      final result = await dataSource.almacenNameExists('Test Almacen', excludeId: 1);

      // assert
      expect(result, isFalse);
      verify(mockDatabase.query(
        'almacenes',
        where: 'LOWER(nombre) = LOWER(?) AND id != ?',
        whereArgs: ['Test Almacen', 1],
      ));
    });
  });
}