import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supermercado_comparador/core/constants/app_constants.dart';
import 'package:supermercado_comparador/features/categorias/domain/entities/categoria.dart';
import 'package:supermercado_comparador/features/categorias/domain/repositories/categoria_repository.dart';
import 'package:supermercado_comparador/features/categorias/domain/usecases/ensure_default_category.dart';

import 'ensure_default_category_test.mocks.dart';

@GenerateMocks([CategoriaRepository])
void main() {
  late EnsureDefaultCategory usecase;
  late MockCategoriaRepository mockRepository;

  setUp(() {
    mockRepository = MockCategoriaRepository();
    usecase = EnsureDefaultCategory(mockRepository);
  });

  group('EnsureDefaultCategory', () {
    final testDate = DateTime(2024, 1, 1);
    
    final defaultCategoria = Categoria(
      id: 1,
      nombre: AppConstants.defaultCategory,
      descripcion: 'Categoría por defecto para productos sin categoría específica',
      fechaCreacion: testDate,
    );

    test('should return existing default category when it exists', () async {
      // Arrange
      when(mockRepository.ensureDefaultCategory())
          .thenAnswer((_) async => defaultCategoria);

      // Act
      final result = await usecase();

      // Assert
      expect(result, equals(defaultCategoria));
      expect(result.nombre, equals(AppConstants.defaultCategory));
      verify(mockRepository.ensureDefaultCategory()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should create and return default category when it does not exist', () async {
      // Arrange
      when(mockRepository.ensureDefaultCategory())
          .thenAnswer((_) async => defaultCategoria);

      // Act
      final result = await usecase();

      // Assert
      expect(result, equals(defaultCategoria));
      expect(result.nombre, equals(AppConstants.defaultCategory));
      verify(mockRepository.ensureDefaultCategory()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should propagate repository exceptions', () async {
      // Arrange
      when(mockRepository.ensureDefaultCategory())
          .thenThrow(Exception('Database error'));

      // Act & Assert
      expect(() => usecase(), throwsException);
      verify(mockRepository.ensureDefaultCategory()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}