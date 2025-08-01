import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supermercado_comparador/features/productos/domain/entities/producto.dart';
import 'package:supermercado_comparador/features/productos/domain/repositories/producto_repository.dart';
import 'package:supermercado_comparador/features/productos/domain/usecases/search_productos_by_name.dart';

import 'search_productos_by_name_test.mocks.dart';

@GenerateMocks([ProductoRepository])
void main() {
  late SearchProductosByName usecase;
  late MockProductoRepository mockRepository;

  setUp(() {
    mockRepository = MockProductoRepository();
    usecase = SearchProductosByName(mockRepository);
  });

  final testDate = DateTime(2024, 1, 1);
  final testProductos = [
    Producto(
      id: 1,
      nombre: 'Test Producto',
      precio: 10.50,
      categoriaId: 1,
      almacenId: 1,
      fechaCreacion: testDate,
      fechaActualizacion: testDate,
    ),
  ];

  test('should search productos by name from repository', () async {
    // arrange
    const searchTerm = 'test';
    when(mockRepository.searchProductosByName(searchTerm))
        .thenAnswer((_) async => testProductos);

    // act
    final result = await usecase(searchTerm);

    // assert
    expect(result, equals(testProductos));
    verify(mockRepository.searchProductosByName(searchTerm));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return empty list when search term is empty', () async {
    // act
    final result = await usecase('');

    // assert
    expect(result, equals([]));
    verifyZeroInteractions(mockRepository);
  });

  test('should return empty list when search term is only whitespace', () async {
    // act
    final result = await usecase('   ');

    // assert
    expect(result, equals([]));
    verifyZeroInteractions(mockRepository);
  });

  test('should trim search term before calling repository', () async {
    // arrange
    const searchTerm = '  test  ';
    const trimmedTerm = 'test';
    when(mockRepository.searchProductosByName(trimmedTerm))
        .thenAnswer((_) async => testProductos);

    // act
    final result = await usecase(searchTerm);

    // assert
    expect(result, equals(testProductos));
    verify(mockRepository.searchProductosByName(trimmedTerm));
    verifyNoMoreInteractions(mockRepository);
  });
}