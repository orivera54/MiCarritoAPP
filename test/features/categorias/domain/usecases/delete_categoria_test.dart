import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supermercado_comparador/core/errors/exceptions.dart';
import 'package:supermercado_comparador/features/categorias/domain/repositories/categoria_repository.dart';
import 'package:supermercado_comparador/features/categorias/domain/usecases/delete_categoria.dart';

import 'delete_categoria_test.mocks.dart';

@GenerateMocks([CategoriaRepository])
void main() {
  late DeleteCategoria usecase;
  late MockCategoriaRepository mockRepository;

  setUp(() {
    mockRepository = MockCategoriaRepository();
    usecase = DeleteCategoria(mockRepository);
  });

  group('DeleteCategoria', () {
    test('should delete categoria when id is valid', () async {
      // Arrange
      const categoriaId = 1;
      when(mockRepository.deleteCategoria(categoriaId))
          .thenAnswer((_) async {});

      // Act
      await usecase(categoriaId);

      // Assert
      verify(mockRepository.deleteCategoria(categoriaId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should throw ValidationException when id is zero', () async {
      // Act & Assert
      expect(
        () => usecase(0),
        throwsA(isA<ValidationException>()),
      );
      verifyNever(mockRepository.deleteCategoria(any));
    });

    test('should throw ValidationException when id is negative', () async {
      // Act & Assert
      expect(
        () => usecase(-1),
        throwsA(isA<ValidationException>()),
      );
      verifyNever(mockRepository.deleteCategoria(any));
    });

    test('should propagate repository exceptions', () async {
      // Arrange
      const categoriaId = 1;
      when(mockRepository.deleteCategoria(categoriaId))
          .thenThrow(const ValidationException('Cannot delete category with products'));

      // Act & Assert
      expect(
        () => usecase(categoriaId),
        throwsA(isA<ValidationException>()),
      );
      verify(mockRepository.deleteCategoria(categoriaId)).called(1);
    });
  });
}