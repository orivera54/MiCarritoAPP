import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:supermercado_comparador/features/comparador/domain/entities/resultado_comparacion.dart';
import 'package:supermercado_comparador/features/comparador/domain/repositories/comparador_repository.dart';
import 'package:supermercado_comparador/features/comparador/domain/usecases/buscar_productos_similares.dart';

import 'buscar_productos_similares_test.mocks.dart';

@GenerateMocks([ComparadorRepository])
void main() {
  late BuscarProductosSimilares usecase;
  late MockComparadorRepository mockRepository;

  setUp(() {
    mockRepository = MockComparadorRepository();
    usecase = BuscarProductosSimilares(mockRepository);
  });

  group('BuscarProductosSimilares', () {
    const tTerminoBusqueda = 'leche';
    final tResultado = ResultadoComparacion(
      terminoBusqueda: tTerminoBusqueda,
      productos: const [],
      fechaComparacion: DateTime.now(),
    );

    test('should return ResultadoComparacion when repository call is successful', () async {
      // arrange
      when(mockRepository.buscarProductosSimilares(any))
          .thenAnswer((_) async => tResultado);

      // act
      final result = await usecase(tTerminoBusqueda);

      // assert
      expect(result, equals(tResultado));
      verify(mockRepository.buscarProductosSimilares(tTerminoBusqueda));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should trim the search term before calling repository', () async {
      // arrange
      const tTerminoConEspacios = '  leche  ';
      when(mockRepository.buscarProductosSimilares(any))
          .thenAnswer((_) async => tResultado);

      // act
      await usecase(tTerminoConEspacios);

      // assert
      verify(mockRepository.buscarProductosSimilares(tTerminoBusqueda));
    });

    test('should return empty result when search term is empty', () async {
      // arrange
      const tTerminoVacio = '';

      // act
      final result = await usecase(tTerminoVacio);

      // assert
      expect(result.terminoBusqueda, equals(tTerminoVacio));
      expect(result.productos, isEmpty);
      verifyNever(mockRepository.buscarProductosSimilares(any));
    });

    test('should return empty result when search term is only whitespace', () async {
      // arrange
      const tTerminoEspacios = '   ';

      // act
      final result = await usecase(tTerminoEspacios);

      // assert
      expect(result.terminoBusqueda, equals(tTerminoEspacios));
      expect(result.productos, isEmpty);
      verifyNever(mockRepository.buscarProductosSimilares(any));
    });

    test('should throw exception when repository throws', () async {
      // arrange
      when(mockRepository.buscarProductosSimilares(any))
          .thenThrow(Exception('Database error'));

      // act & assert
      expect(
        () => usecase(tTerminoBusqueda),
        throwsA(isA<Exception>()),
      );
    });
  });
}