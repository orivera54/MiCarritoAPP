import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supermercado_comparador/features/productos/domain/entities/producto.dart';
import 'package:supermercado_comparador/features/productos/domain/repositories/producto_repository.dart';
import 'package:supermercado_comparador/features/productos/domain/usecases/create_producto.dart';

import 'create_producto_test.mocks.dart';

@GenerateMocks([ProductoRepository])
void main() {
  late CreateProducto usecase;
  late MockProductoRepository mockRepository;

  setUp(() {
    mockRepository = MockProductoRepository();
    usecase = CreateProducto(mockRepository);
  });

  final testDate = DateTime(2024, 1, 1);
  final testProducto = Producto(
    nombre: 'Test Producto',
    precio: 10.50,
    categoriaId: 1,
    almacenId: 1,
    fechaCreacion: testDate,
    fechaActualizacion: testDate,
  );

  final createdProducto = Producto(
    id: 1,
    nombre: 'Test Producto',
    precio: 10.50,
    categoriaId: 1,
    almacenId: 1,
    fechaCreacion: testDate,
    fechaActualizacion: testDate,
  );

  test('should create producto through repository', () async {
    // arrange
    when(mockRepository.createProducto(testProducto))
        .thenAnswer((_) async => createdProducto);

    // act
    final result = await usecase(testProducto);

    // assert
    expect(result, equals(createdProducto));
    verify(mockRepository.createProducto(testProducto));
    verifyNoMoreInteractions(mockRepository);
  });
}