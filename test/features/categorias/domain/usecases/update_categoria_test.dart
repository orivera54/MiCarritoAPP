import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supermercado_comparador/core/errors/exceptions.dart';
import 'package:supermercado_comparador/features/categorias/domain/entities/categoria.dart';
import 'package:supermercado_comparador/features/categorias/domain/repositories/categoria_repository.dart';
import 'package:supermercado_comparador/features/categorias/domain/usecases/update_categoria.dart';

import 'update_categoria_test.mocks.dart';

@GenerateMocks([CategoriaRepository])
void main() {
  late UpdateCategoria usecase;
  late MockCategoriaRepository mockRepository;

  setUp(() {
    mockRepository = MockCategoriaRepository();
    usecase = UpdateCategoria(mockRepository);
  });

  group('UpdateCategoria', () {
    final testDate = DateTime(2024, 1, 1);
    
    final testCategoria = Categoria(
      id: 1,
      nombre: 'Lácteos',
      descripcion: 'Productos lácteos y derivados',
      fechaCreacion: testDate,
    );

    test('should update categoria when data is valid', () async {
      // Arrange
      when(mockRepository.categoriaNameExists('Lácteos', excludeId: 1))
          .thenAnswer((_) async => false);
      when(mockRepository.updateCategoria(testCategoria))
          .thenAnswer((_) async => testCategoria);

      // Act
      final result = await usecase(testCategoria);

      // Assert
      expect(result, equals(testCategoria));
      verify(mockRepository.categoriaNameExists('Lácteos', excludeId: 1)).called(1);
      verify(mockRepository.updateCategoria(testCategoria)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should throw ValidationException when id is null', () async {
      // Arrange
      final categoriaWithoutId = Categoria(
        nombre: 'Lácteos',
        descripcion: 'Productos lácteos y derivados',
        fechaCreacion: testDate,
      );

      // Act & Assert
      expect(
        () => usecase(categoriaWithoutId),
        throwsA(isA<ValidationException>()),
      );
      verifyNever(mockRepository.categoriaNameExists(any, excludeId: anyNamed('excludeId')));
      verifyNever(mockRepository.updateCategoria(any));
    });

    test('should throw ValidationException when nombre is empty', () async {
      // Arrange
      final invalidCategoria = testCategoria.copyWith(nombre: '');

      // Act & Assert
      expect(
        () => usecase(invalidCategoria),
        throwsA(isA<ValidationException>()),
      );
      verifyNever(mockRepository.categoriaNameExists(any, excludeId: anyNamed('excludeId')));
      verifyNever(mockRepository.updateCategoria(any));
    });

    test('should throw ValidationException when nombre is whitespace only', () async {
      // Arrange
      final invalidCategoria = testCategoria.copyWith(nombre: '   ');

      // Act & Assert
      expect(
        () => usecase(invalidCategoria),
        throwsA(isA<ValidationException>()),
      );
      verifyNever(mockRepository.categoriaNameExists(any, excludeId: anyNamed('excludeId')));
      verifyNever(mockRepository.updateCategoria(any));
    });

    test('should throw ValidationException when categoria name already exists for different categoria', () async {
      // Arrange
      when(mockRepository.categoriaNameExists('Lácteos', excludeId: 1))
          .thenAnswer((_) async => true);

      // Act & Assert
      expect(
        () => usecase(testCategoria),
        throwsA(isA<ValidationException>()),
      );
      verify(mockRepository.categoriaNameExists('Lácteos', excludeId: 1)).called(1);
      verifyNever(mockRepository.updateCategoria(any));
    });

    test('should allow same name for same categoria', () async {
      // Arrange
      when(mockRepository.categoriaNameExists('Lácteos', excludeId: 1))
          .thenAnswer((_) async => false);
      when(mockRepository.updateCategoria(testCategoria))
          .thenAnswer((_) async => testCategoria);

      // Act
      final result = await usecase(testCategoria);

      // Assert
      expect(result, equals(testCategoria));
      verify(mockRepository.categoriaNameExists('Lácteos', excludeId: 1)).called(1);
      verify(mockRepository.updateCategoria(testCategoria)).called(1);
    });
  });
}