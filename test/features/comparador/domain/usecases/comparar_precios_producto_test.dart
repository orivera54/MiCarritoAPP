import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:supermercado_comparador/features/comparador/domain/entities/resultado_comparacion.dart';
import 'package:supermercado_comparador/features/comparador/domain/repositories/comparador_repository.dart';
import 'package:supermercado_comparador/features/comparador/domain/usecases/comparar_precios_producto.dart';

import 'comparar_precios_producto_test.mocks.dart';

@GenerateMocks([ComparadorRepository])
void main() {
  late CompararPreciosProducto usecase;
  late MockComparadorRepository mockRepository;

  setUp(() {
    mockRepository = MockComparadorRepository();
    usecase = CompararPreciosProducto(mockRepository);
  });

  group('CompararPreciosProducto', () {
    const tProductoId = 1;
    final tResultado = ResultadoComparacion(
      terminoBusqueda: 'Producto 1',
      productos: const [],
      fechaComparacion: DateTime.now(),
    );

    test('should return ResultadoComparacion when repository call is successful', () async {
      // arrange
      when(mockRepository.compararPreciosProducto(any))
          .thenAnswer((_) async => tResultado);

      // act
      final result = await usecase(tProductoId);

      // assert
      expect(result, equals(tResultado));
      verify(mockRepository.compararPreciosProducto(tProductoId));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should throw ArgumentError when producto ID is 0', () async {
      // arrange
      const tProductoIdInvalido = 0;

      // act & assert
      expect(
        () => usecase(tProductoIdInvalido),
        throwsA(isA<ArgumentError>()),
      );
      verifyNever(mockRepository.compararPreciosProducto(any));
    });

    test('should throw ArgumentError when producto ID is negative', () async {
      // arrange
      const tProductoIdNegativo = -1;

      // act & assert
      expect(
        () => usecase(tProductoIdNegativo),
        throwsA(isA<ArgumentError>()),
      );
      verifyNever(mockRepository.compararPreciosProducto(any));
    });

    test('should throw exception when repository throws', () async {
      // arrange
      when(mockRepository.compararPreciosProducto(any))
          .thenThrow(Exception('Database error'));

      // act & assert
      expect(
        () => usecase(tProductoId),
        throwsA(isA<Exception>()),
      );
    });
  });
}