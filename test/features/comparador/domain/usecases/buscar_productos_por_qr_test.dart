import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:supermercado_comparador/features/comparador/domain/entities/resultado_comparacion.dart';
import 'package:supermercado_comparador/features/comparador/domain/repositories/comparador_repository.dart';
import 'package:supermercado_comparador/features/comparador/domain/usecases/buscar_productos_por_qr.dart';

import 'buscar_productos_por_qr_test.mocks.dart';

@GenerateMocks([ComparadorRepository])
void main() {
  late BuscarProductosPorQR usecase;
  late MockComparadorRepository mockRepository;

  setUp(() {
    mockRepository = MockComparadorRepository();
    usecase = BuscarProductosPorQR(mockRepository);
  });

  group('BuscarProductosPorQR', () {
    const tCodigoQR = '1234567890';
    final tResultado = ResultadoComparacion(
      terminoBusqueda: tCodigoQR,
      productos: const [],
      fechaComparacion: DateTime.now(),
    );

    test('should return ResultadoComparacion when repository call is successful', () async {
      // arrange
      when(mockRepository.buscarProductosPorQR(any))
          .thenAnswer((_) async => tResultado);

      // act
      final result = await usecase(tCodigoQR);

      // assert
      expect(result, equals(tResultado));
      verify(mockRepository.buscarProductosPorQR(tCodigoQR));
      verifyNoMoreInteractions(mockRepository);
    });

    test('should trim the QR code before calling repository', () async {
      // arrange
      const tCodigoConEspacios = '  1234567890  ';
      when(mockRepository.buscarProductosPorQR(any))
          .thenAnswer((_) async => tResultado);

      // act
      await usecase(tCodigoConEspacios);

      // assert
      verify(mockRepository.buscarProductosPorQR(tCodigoQR));
    });

    test('should return empty result when QR code is empty', () async {
      // arrange
      const tCodigoVacio = '';

      // act
      final result = await usecase(tCodigoVacio);

      // assert
      expect(result.terminoBusqueda, equals(tCodigoVacio));
      expect(result.productos, isEmpty);
      verifyNever(mockRepository.buscarProductosPorQR(any));
    });

    test('should return empty result when QR code is only whitespace', () async {
      // arrange
      const tCodigoEspacios = '   ';

      // act
      final result = await usecase(tCodigoEspacios);

      // assert
      expect(result.terminoBusqueda, equals(tCodigoEspacios));
      expect(result.productos, isEmpty);
      verifyNever(mockRepository.buscarProductosPorQR(any));
    });

    test('should throw exception when repository throws', () async {
      // arrange
      when(mockRepository.buscarProductosPorQR(any))
          .thenThrow(Exception('Database error'));

      // act & assert
      expect(
        () => usecase(tCodigoQR),
        throwsA(isA<Exception>()),
      );
    });
  });
}