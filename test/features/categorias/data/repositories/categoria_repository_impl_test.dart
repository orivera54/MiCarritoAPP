import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supermercado_comparador/core/constants/app_constants.dart';
import 'package:supermercado_comparador/features/categorias/data/datasources/categoria_local_data_source.dart';
import 'package:supermercado_comparador/features/categorias/data/models/categoria_model.dart';
import 'package:supermercado_comparador/features/categorias/data/repositories/categoria_repository_impl.dart';
import 'package:supermercado_comparador/features/categorias/domain/entities/categoria.dart';

import 'categoria_repository_impl_test.mocks.dart';

@GenerateMocks([CategoriaLocalDataSource])
void main() {
  late CategoriaRepositoryImpl repository;
  late MockCategoriaLocalDataSource mockLocalDataSource;

  setUp(() {
    mockLocalDataSource = MockCategoriaLocalDataSource();
    repository = CategoriaRepositoryImpl(localDataSource: mockLocalDataSource);
  });

  group('CategoriaRepositoryImpl', () {
    final testDate = DateTime(2024, 1, 1);
    
    final testCategoriaModel = CategoriaModel(
      id: 1,
      nombre: 'Lácteos',
      descripcion: 'Productos lácteos y derivados',
      fechaCreacion: testDate,
    );

    final testCategoria = Categoria(
      id: 1,
      nombre: 'Lácteos',
      descripcion: 'Productos lácteos y derivados',
      fechaCreacion: testDate,
    );

    group('getAllCategorias', () {
      test('should return list of Categoria entities', () async {
        // Arrange
        when(mockLocalDataSource.getAllCategorias())
            .thenAnswer((_) async => [testCategoriaModel]);

        // Act
        final result = await repository.getAllCategorias();

        // Assert
        expect(result, isA<List<Categoria>>());
        expect(result.length, equals(1));
        expect(result.first.id, equals(testCategoria.id));
        expect(result.first.nombre, equals(testCategoria.nombre));
        expect(result.first.descripcion, equals(testCategoria.descripcion));
        expect(result.first.fechaCreacion, equals(testCategoria.fechaCreacion));
        verify(mockLocalDataSource.getAllCategorias()).called(1);
      });
    });

    group('getCategoriaById', () {
      test('should return Categoria when found', () async {
        // Arrange
        when(mockLocalDataSource.getCategoriaById(1))
            .thenAnswer((_) async => testCategoriaModel);

        // Act
        final result = await repository.getCategoriaById(1);

        // Assert
        expect(result!.id, equals(testCategoria.id));
        expect(result.nombre, equals(testCategoria.nombre));
        expect(result.descripcion, equals(testCategoria.descripcion));
        expect(result.fechaCreacion, equals(testCategoria.fechaCreacion));
        verify(mockLocalDataSource.getCategoriaById(1)).called(1);
      });

      test('should return null when not found', () async {
        // Arrange
        when(mockLocalDataSource.getCategoriaById(1))
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getCategoriaById(1);

        // Assert
        expect(result, isNull);
        verify(mockLocalDataSource.getCategoriaById(1)).called(1);
      });
    });

    group('getCategoriaByName', () {
      test('should return Categoria when found', () async {
        // Arrange
        when(mockLocalDataSource.getCategoriaByName('Lácteos'))
            .thenAnswer((_) async => testCategoriaModel);

        // Act
        final result = await repository.getCategoriaByName('Lácteos');

        // Assert
        expect(result!.id, equals(testCategoria.id));
        expect(result.nombre, equals(testCategoria.nombre));
        expect(result.descripcion, equals(testCategoria.descripcion));
        expect(result.fechaCreacion, equals(testCategoria.fechaCreacion));
        verify(mockLocalDataSource.getCategoriaByName('Lácteos')).called(1);
      });

      test('should return null when not found', () async {
        // Arrange
        when(mockLocalDataSource.getCategoriaByName('Lácteos'))
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getCategoriaByName('Lácteos');

        // Assert
        expect(result, isNull);
        verify(mockLocalDataSource.getCategoriaByName('Lácteos')).called(1);
      });
    });

    group('createCategoria', () {
      test('should create categoria and return Categoria entity', () async {
        // Arrange
        final categoriaToCreate = Categoria(
          nombre: 'Lácteos',
          descripcion: 'Productos lácteos y derivados',
          fechaCreacion: testDate,
        );

        when(mockLocalDataSource.insertCategoria(any))
            .thenAnswer((_) async => testCategoriaModel);

        // Act
        final result = await repository.createCategoria(categoriaToCreate);

        // Assert
        expect(result.id, equals(testCategoria.id));
        expect(result.nombre, equals(testCategoria.nombre));
        expect(result.descripcion, equals(testCategoria.descripcion));
        expect(result.fechaCreacion, equals(testCategoria.fechaCreacion));
        verify(mockLocalDataSource.insertCategoria(any)).called(1);
      });
    });

    group('updateCategoria', () {
      test('should update categoria and return updated Categoria entity', () async {
        // Arrange
        when(mockLocalDataSource.updateCategoria(any))
            .thenAnswer((_) async => testCategoriaModel);

        // Act
        final result = await repository.updateCategoria(testCategoria);

        // Assert
        expect(result.id, equals(testCategoria.id));
        expect(result.nombre, equals(testCategoria.nombre));
        expect(result.descripcion, equals(testCategoria.descripcion));
        expect(result.fechaCreacion, equals(testCategoria.fechaCreacion));
        verify(mockLocalDataSource.updateCategoria(any)).called(1);
      });
    });

    group('deleteCategoria', () {
      test('should delete categoria', () async {
        // Arrange
        when(mockLocalDataSource.deleteCategoria(1))
            .thenAnswer((_) async {});

        // Act
        await repository.deleteCategoria(1);

        // Assert
        verify(mockLocalDataSource.deleteCategoria(1)).called(1);
      });
    });

    group('categoriaNameExists', () {
      test('should return true when name exists', () async {
        // Arrange
        when(mockLocalDataSource.categoriaNameExists('Lácteos'))
            .thenAnswer((_) async => true);

        // Act
        final result = await repository.categoriaNameExists('Lácteos');

        // Assert
        expect(result, isTrue);
        verify(mockLocalDataSource.categoriaNameExists('Lácteos')).called(1);
      });

      test('should return false when name does not exist', () async {
        // Arrange
        when(mockLocalDataSource.categoriaNameExists('Lácteos'))
            .thenAnswer((_) async => false);

        // Act
        final result = await repository.categoriaNameExists('Lácteos');

        // Assert
        expect(result, isFalse);
        verify(mockLocalDataSource.categoriaNameExists('Lácteos')).called(1);
      });

      test('should pass excludeId parameter', () async {
        // Arrange
        when(mockLocalDataSource.categoriaNameExists('Lácteos', excludeId: 1))
            .thenAnswer((_) async => false);

        // Act
        final result = await repository.categoriaNameExists('Lácteos', excludeId: 1);

        // Assert
        expect(result, isFalse);
        verify(mockLocalDataSource.categoriaNameExists('Lácteos', excludeId: 1)).called(1);
      });
    });

    group('ensureDefaultCategory', () {
      test('should return existing default category when it exists', () async {
        // Arrange
        final defaultCategoriaModel = CategoriaModel(
          id: 1,
          nombre: AppConstants.defaultCategory,
          descripcion: 'Categoría por defecto para productos sin categoría específica',
          fechaCreacion: testDate,
        );

        when(mockLocalDataSource.getCategoriaByName(AppConstants.defaultCategory))
            .thenAnswer((_) async => defaultCategoriaModel);

        // Act
        final result = await repository.ensureDefaultCategory();

        // Assert
        expect(result.nombre, equals(AppConstants.defaultCategory));
        expect(result.id, equals(1));
        verify(mockLocalDataSource.getCategoriaByName(AppConstants.defaultCategory)).called(1);
        verifyNever(mockLocalDataSource.insertCategoria(any));
      });

      test('should create default category when it does not exist', () async {
        // Arrange
        final defaultCategoriaModel = CategoriaModel(
          id: 1,
          nombre: AppConstants.defaultCategory,
          descripcion: 'Categoría por defecto para productos sin categoría específica',
          fechaCreacion: testDate,
        );

        when(mockLocalDataSource.getCategoriaByName(AppConstants.defaultCategory))
            .thenAnswer((_) async => null);
        when(mockLocalDataSource.insertCategoria(any))
            .thenAnswer((_) async => defaultCategoriaModel);

        // Act
        final result = await repository.ensureDefaultCategory();

        // Assert
        expect(result.nombre, equals(AppConstants.defaultCategory));
        expect(result.id, equals(1));
        verify(mockLocalDataSource.getCategoriaByName(AppConstants.defaultCategory)).called(1);
        verify(mockLocalDataSource.insertCategoria(any)).called(1);
      });
    });
  });
}