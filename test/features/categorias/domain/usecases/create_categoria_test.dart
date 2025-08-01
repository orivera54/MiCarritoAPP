import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supermercado_comparador/core/errors/exceptions.dart';
import 'package:supermercado_comparador/features/categorias/domain/entities/categoria.dart';
import 'package:supermercado_comparador/features/categorias/domain/repositories/categoria_repository.dart';
import 'package:supermercado_comparador/features/categorias/domain/usecases/create_categoria.dart';

import 'create_categoria_test.mocks.dart';

@GenerateMocks([CategoriaRepository])
void main() {
  late CreateCategoria usecase;
  late MockCategoriaRepository mockRepository;

  setUp(() {
    mockRepository = MockCategoriaRepository();
    usecase = CreateCategoria(mockRepository);
  });

  group('CreateCategoria', () {
    final testDate = DateTime(2024, 1, 1);
    
    final testCategoria = Categoria(
      nombre: 'Lácteos',
      descripcion: 'Productos lácteos y derivados',
      fechaCreacion: testDate,
    );

    final createdCategoria = Categoria(
      id: 1,
      nombre: 'Lácteos',
      descripcion: 'Productos lácteos y derivados',
      fechaCreacion: testDate,
    );

    test('should create categoria when data is valid', () async {
      // Arrange
      when(mockRepository.categoriaNameExists('Lácteos'))
          .thenAnswer((_) async => false);
      when(mockRepository.createCategoria(any))
          .thenAnswer((_) async => createdCategoria);

      // Act
      final result = await usecase(testCategoria);

      // Assert
      expect(result, equals(createdCategoria));
      verify(mockRepository.categoriaNameExists('Lácteos')).called(1);
      verify(mockRepository.createCategoria(any)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should throw ValidationException when nombre is empty', () async {
      // Arrange
      final invalidCategoria = testCategoria.copyWith(nombre: '');

      // Act & Assert
      expect(
        () => usecase(invalidCategoria),
        throwsA(isA<ValidationException>()),
      );
      verifyNever(mockRepository.categoriaNameExists(any));
      verifyNever(mockRepository.createCategoria(any));
    });

    test('should throw ValidationException when nombre is whitespace only', () async {
      // Arrange
      final invalidCategoria = testCategoria.copyWith(nombre: '   ');

      // Act & Assert
      expect(
        () => usecase(invalidCategoria),
        throwsA(isA<ValidationException>()),
      );
      verifyNever(mockRepository.categoriaNameExists(any));
      verifyNever(mockRepository.createCategoria(any));
    });

    test('should throw ValidationException when categoria name already exists', () async {
      // Arrange
      when(mockRepository.categoriaNameExists('Lácteos'))
          .thenAnswer((_) async => true);

      // Act & Assert
      expect(
        () => usecase(testCategoria),
        throwsA(isA<ValidationException>()),
      );
      verify(mockRepository.categoriaNameExists('Lácteos')).called(1);
      verifyNever(mockRepository.createCategoria(any));
    });

    test('should set fechaCreacion when creating categoria', () async {
      // Arrange
      final categoriaWithoutDate = Categoria(
        nombre: 'Lácteos',
        descripcion: 'Productos lácteos y derivados',
        fechaCreacion: DateTime(1970), // Old date
      );

      when(mockRepository.categoriaNameExists('Lácteos'))
          .thenAnswer((_) async => false);
      when(mockRepository.createCategoria(any))
          .thenAnswer((_) async => createdCategoria);

      // Act
      await usecase(categoriaWithoutDate);

      // Assert
      final captured = verify(mockRepository.createCategoria(captureAny)).captured.first as Categoria;
      expect(captured.fechaCreacion.isAfter(DateTime(2020)), isTrue);
    });
  });
}