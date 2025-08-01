import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supermercado_comparador/features/productos/domain/entities/producto.dart';
import 'package:supermercado_comparador/features/productos/domain/repositories/producto_repository.dart';
import 'package:supermercado_comparador/features/productos/domain/usecases/get_all_productos.dart';

import 'get_all_productos_test.mocks.dart';

@GenerateMocks([ProductoRepository])
void main() {
  late GetAllProductos usecase;
  late MockProductoRepository mockRepository;

  setUp(() {
    mockRepository = MockProductoRepository();
    usecase = GetAllProductos(mockRepository);
  });

  final testDate = DateTime(2024, 1, 1);
  final testProductos = [
    Producto(
      id: 1,
      nombre: 'Test Producto 1',
      precio: 10.50,
      categoriaId: 1,
      almacenId: 1,
      fechaCreacion: testDate,
      fechaActualizacion: testDate,
    ),
    Producto(
      id: 2,
      nombre: 'Test Producto 2',
      precio: 15.99,
      categoriaId: 2,
      almacenId: 1,
      fechaCreacion: testDate,
      fechaActualizacion: testDate,
    ),
  ];

  test('should get all productos from repository', () async {
    // arrange
    when(mockRepository.getAllProductos())
        .thenAnswer((_) async => testProductos);

    // act
    final result = await usecase();

    // assert
    expect(result, equals(testProductos));
    verify(mockRepository.getAllProductos());
    verifyNoMoreInteractions(mockRepository);
  });
}