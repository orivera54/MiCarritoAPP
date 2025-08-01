import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supermercado_comparador/features/categorias/domain/entities/categoria.dart';
import 'package:supermercado_comparador/features/categorias/domain/repositories/categoria_repository.dart';
import 'package:supermercado_comparador/features/categorias/domain/usecases/get_all_categorias.dart';

import 'get_all_categorias_test.mocks.dart';

@GenerateMocks([CategoriaRepository])
void main() {
  late GetAllCategorias usecase;
  late MockCategoriaRepository mockRepository;

  setUp(() {
    mockRepository = MockCategoriaRepository();
    usecase = GetAllCategorias(mockRepository);
  });

  group('GetAllCategorias', () {
    final testDate = DateTime(2024, 1, 1);
    
    final testCategorias = [
      Categoria(
        id: 1,
        nombre: 'Lácteos',
        descripcion: 'Productos lácteos y derivados',
        fechaCreacion: testDate,
      ),
      Categoria(
        id: 2,
        nombre: 'Carnes',
        descripcion: 'Productos cárnicos',
        fechaCreacion: testDate,
      ),
    ];

    test('should return list of categorias from repository', () async {
      // Arrange
      when(mockRepository.getAllCategorias())
          .thenAnswer((_) async => testCategorias);

      // Act
      final result = await usecase();

      // Assert
      expect(result, equals(testCategorias));
      verify(mockRepository.getAllCategorias()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return empty list when no categorias exist', () async {
      // Arrange
      when(mockRepository.getAllCategorias())
          .thenAnswer((_) async => []);

      // Act
      final result = await usecase();

      // Assert
      expect(result, isEmpty);
      verify(mockRepository.getAllCategorias()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should throw exception when repository throws exception', () async {
      // Arrange
      when(mockRepository.getAllCategorias())
          .thenThrow(Exception('Database error'));

      // Act & Assert
      expect(() => usecase(), throwsException);
      verify(mockRepository.getAllCategorias()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });
  });
}