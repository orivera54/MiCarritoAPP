import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supermercado_comparador/features/almacenes/data/datasources/almacen_local_data_source.dart';
import 'package:supermercado_comparador/features/almacenes/data/models/almacen_model.dart';
import 'package:supermercado_comparador/features/almacenes/data/repositories/almacen_repository_impl.dart';
import 'package:supermercado_comparador/features/almacenes/domain/entities/almacen.dart';

import 'almacen_repository_impl_test.mocks.dart';

@GenerateMocks([AlmacenLocalDataSource])
void main() {
  late AlmacenRepositoryImpl repository;
  late MockAlmacenLocalDataSource mockLocalDataSource;

  setUp(() {
    mockLocalDataSource = MockAlmacenLocalDataSource();
    repository = AlmacenRepositoryImpl(localDataSource: mockLocalDataSource);
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

  final testAlmacenEntity = Almacen(
    id: 1,
    nombre: 'Test Almacen',
    direccion: 'Test Address',
    descripcion: 'Test Description',
    fechaCreacion: testDate,
    fechaActualizacion: testDate,
  );

  group('getAllAlmacenes', () {
    test('should return list of Almacen entities when successful', () async {
      // arrange
      when(mockLocalDataSource.getAllAlmacenes())
          .thenAnswer((_) async => [testAlmacenModel]);

      // act
      final result = await repository.getAllAlmacenes();

      // assert
      expect(result, isA<List<Almacen>>());
      expect(result.length, 1);
      expect(result.first, equals(testAlmacenEntity));
      verify(mockLocalDataSource.getAllAlmacenes());
    });

    test('should forward exceptions from data source', () async {
      // arrange
      when(mockLocalDataSource.getAllAlmacenes())
          .thenThrow(Exception('Database error'));

      // act & assert
      expect(
        () => repository.getAllAlmacenes(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('getAlmacenById', () {
    test('should return Almacen entity when found', () async {
      // arrange
      when(mockLocalDataSource.getAlmacenById(1))
          .thenAnswer((_) async => testAlmacenModel);

      // act
      final result = await repository.getAlmacenById(1);

      // assert
      expect(result, equals(testAlmacenEntity));
      verify(mockLocalDataSource.getAlmacenById(1));
    });

    test('should return null when not found', () async {
      // arrange
      when(mockLocalDataSource.getAlmacenById(1))
          .thenAnswer((_) async => null);

      // act
      final result = await repository.getAlmacenById(1);

      // assert
      expect(result, isNull);
      verify(mockLocalDataSource.getAlmacenById(1));
    });

    test('should forward exceptions from data source', () async {
      // arrange
      when(mockLocalDataSource.getAlmacenById(1))
          .thenThrow(Exception('Database error'));

      // act & assert
      expect(
        () => repository.getAlmacenById(1),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('createAlmacen', () {
    test('should return created Almacen entity when successful', () async {
      // arrange
      final almacenToCreate = Almacen(
        nombre: 'New Almacen',
        direccion: 'New Address',
        descripcion: 'New Description',
        fechaCreacion: testDate,
        fechaActualizacion: testDate,
      );

      final createdAlmacenModel = AlmacenModel(
        id: 1,
        nombre: 'New Almacen',
        direccion: 'New Address',
        descripcion: 'New Description',
        fechaCreacion: testDate,
        fechaActualizacion: testDate,
      );

      when(mockLocalDataSource.insertAlmacen(any))
          .thenAnswer((_) async => createdAlmacenModel);

      // act
      final result = await repository.createAlmacen(almacenToCreate);

      // assert
      expect(result.id, equals(1));
      expect(result.nombre, equals('New Almacen'));
      verify(mockLocalDataSource.insertAlmacen(any));
    });

    test('should forward exceptions from data source', () async {
      // arrange
      final almacenToCreate = Almacen(
        nombre: 'New Almacen',
        fechaCreacion: testDate,
        fechaActualizacion: testDate,
      );

      when(mockLocalDataSource.insertAlmacen(any))
          .thenThrow(Exception('Database error'));

      // act & assert
      expect(
        () => repository.createAlmacen(almacenToCreate),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('updateAlmacen', () {
    test('should return updated Almacen entity when successful', () async {
      // arrange
      when(mockLocalDataSource.updateAlmacen(any))
          .thenAnswer((_) async => testAlmacenModel);

      // act
      final result = await repository.updateAlmacen(testAlmacenEntity);

      // assert
      expect(result, equals(testAlmacenEntity));
      verify(mockLocalDataSource.updateAlmacen(any));
    });

    test('should forward exceptions from data source', () async {
      // arrange
      when(mockLocalDataSource.updateAlmacen(any))
          .thenThrow(Exception('Database error'));

      // act & assert
      expect(
        () => repository.updateAlmacen(testAlmacenEntity),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('deleteAlmacen', () {
    test('should complete successfully when deletion is successful', () async {
      // arrange
      when(mockLocalDataSource.deleteAlmacen(1))
          .thenAnswer((_) async => {});

      // act
      await repository.deleteAlmacen(1);

      // assert
      verify(mockLocalDataSource.deleteAlmacen(1));
    });

    test('should forward exceptions from data source', () async {
      // arrange
      when(mockLocalDataSource.deleteAlmacen(1))
          .thenThrow(Exception('Database error'));

      // act & assert
      expect(
        () => repository.deleteAlmacen(1),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('almacenNameExists', () {
    test('should return true when name exists', () async {
      // arrange
      when(mockLocalDataSource.almacenNameExists('Test Almacen'))
          .thenAnswer((_) async => true);

      // act
      final result = await repository.almacenNameExists('Test Almacen');

      // assert
      expect(result, isTrue);
      verify(mockLocalDataSource.almacenNameExists('Test Almacen'));
    });

    test('should return false when name does not exist', () async {
      // arrange
      when(mockLocalDataSource.almacenNameExists('Non Existing'))
          .thenAnswer((_) async => false);

      // act
      final result = await repository.almacenNameExists('Non Existing');

      // assert
      expect(result, isFalse);
      verify(mockLocalDataSource.almacenNameExists('Non Existing'));
    });

    test('should pass excludeId parameter correctly', () async {
      // arrange
      when(mockLocalDataSource.almacenNameExists('Test Almacen', excludeId: 1))
          .thenAnswer((_) async => false);

      // act
      final result = await repository.almacenNameExists('Test Almacen', excludeId: 1);

      // assert
      expect(result, isFalse);
      verify(mockLocalDataSource.almacenNameExists('Test Almacen', excludeId: 1));
    });

    test('should forward exceptions from data source', () async {
      // arrange
      when(mockLocalDataSource.almacenNameExists('Test Almacen'))
          .thenThrow(Exception('Database error'));

      // act & assert
      expect(
        () => repository.almacenNameExists('Test Almacen'),
        throwsA(isA<Exception>()),
      );
    });
  });
}