import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:supermercado_comparador/features/comparador/domain/entities/resultado_comparacion.dart';
import 'package:supermercado_comparador/features/comparador/domain/entities/producto_comparacion.dart';
import 'package:supermercado_comparador/features/comparador/domain/usecases/buscar_productos_similares.dart';
import 'package:supermercado_comparador/features/comparador/domain/usecases/comparar_precios_producto.dart';
import 'package:supermercado_comparador/features/comparador/domain/usecases/buscar_productos_por_qr.dart';
import 'package:supermercado_comparador/features/comparador/domain/services/comparador_service.dart';
import 'package:supermercado_comparador/features/comparador/presentation/bloc/comparador_bloc.dart';
import 'package:supermercado_comparador/features/comparador/presentation/bloc/comparador_event.dart';
import 'package:supermercado_comparador/features/comparador/presentation/bloc/comparador_state.dart';
import 'package:supermercado_comparador/features/productos/domain/entities/producto.dart';
import 'package:supermercado_comparador/features/almacenes/domain/entities/almacen.dart';

import 'comparador_bloc_test.mocks.dart';

@GenerateMocks([
  BuscarProductosSimilares,
  CompararPreciosProducto,
  BuscarProductosPorQR,
  ComparadorService,
])
void main() {
  group('ComparadorBloc', () {
    test('initial state should be ComparadorInitial', () {
      final mockBuscarProductosSimilares = MockBuscarProductosSimilares();
      final mockCompararPreciosProducto = MockCompararPreciosProducto();
      final mockBuscarProductosPorQR = MockBuscarProductosPorQR();
      final mockComparadorService = MockComparadorService();

      final bloc = ComparadorBloc(
        buscarProductosSimilares: mockBuscarProductosSimilares,
        compararPreciosProducto: mockCompararPreciosProducto,
        buscarProductosPorQR: mockBuscarProductosPorQR,
        comparadorService: mockComparadorService,
      );

      expect(bloc.state, equals(const ComparadorInitial()));
      bloc.close();
    });

    group('BuscarProductosSimilaresEvent', () {
      const tTerminoBusqueda = 'leche';
      final tResultadoConProductos = ResultadoComparacion(
        terminoBusqueda: tTerminoBusqueda,
        productos: [
          ProductoComparacion(
            producto: Producto(
              id: 1,
              nombre: 'Leche',
              precio: 2.50,
              categoriaId: 1,
              almacenId: 1,
              fechaCreacion: DateTime.now(),
              fechaActualizacion: DateTime.now(),
            ),
            almacen: Almacen(
              id: 1,
              nombre: 'Almacén 1',
              fechaCreacion: DateTime.now(),
              fechaActualizacion: DateTime.now(),
            ),
            esMejorPrecio: true,
          ),
        ],
        fechaComparacion: DateTime.now(),
      );
      final tResultadoVacio = ResultadoComparacion(
        terminoBusqueda: tTerminoBusqueda,
        productos: const [],
        fechaComparacion: DateTime.now(),
      );

      blocTest<ComparadorBloc, ComparadorState>(
        'should emit [ComparadorLoading, ComparadorLoaded] when search is successful with results',
        build: () {
          final mockBuscarProductosSimilares = MockBuscarProductosSimilares();
          final mockCompararPreciosProducto = MockCompararPreciosProducto();
          final mockBuscarProductosPorQR = MockBuscarProductosPorQR();
          final mockComparadorService = MockComparadorService();

          when(mockBuscarProductosSimilares(tTerminoBusqueda))
              .thenAnswer((_) async => tResultadoConProductos);

          return ComparadorBloc(
            buscarProductosSimilares: mockBuscarProductosSimilares,
            compararPreciosProducto: mockCompararPreciosProducto,
            buscarProductosPorQR: mockBuscarProductosPorQR,
            comparadorService: mockComparadorService,
          );
        },
        act: (bloc) =>
            bloc.add(const BuscarProductosSimilaresEvent(tTerminoBusqueda)),
        expect: () => [
          const ComparadorLoading(),
          ComparadorLoaded(tResultadoConProductos),
        ],
      );

      blocTest<ComparadorBloc, ComparadorState>(
        'should emit [ComparadorLoading, ComparadorEmpty] when search returns no results',
        build: () {
          final mockBuscarProductosSimilares = MockBuscarProductosSimilares();
          final mockCompararPreciosProducto = MockCompararPreciosProducto();
          final mockBuscarProductosPorQR = MockBuscarProductosPorQR();
          final mockComparadorService = MockComparadorService();

          when(mockBuscarProductosSimilares(tTerminoBusqueda))
              .thenAnswer((_) async => tResultadoVacio);

          return ComparadorBloc(
            buscarProductosSimilares: mockBuscarProductosSimilares,
            compararPreciosProducto: mockCompararPreciosProducto,
            buscarProductosPorQR: mockBuscarProductosPorQR,
            comparadorService: mockComparadorService,
          );
        },
        act: (bloc) =>
            bloc.add(const BuscarProductosSimilaresEvent(tTerminoBusqueda)),
        expect: () => [
          const ComparadorLoading(),
          const ComparadorEmpty(tTerminoBusqueda),
        ],
      );

      blocTest<ComparadorBloc, ComparadorState>(
        'should emit [ComparadorLoading, ComparadorError] when search fails',
        build: () {
          final mockBuscarProductosSimilares = MockBuscarProductosSimilares();
          final mockCompararPreciosProducto = MockCompararPreciosProducto();
          final mockBuscarProductosPorQR = MockBuscarProductosPorQR();
          final mockComparadorService = MockComparadorService();

          when(mockBuscarProductosSimilares(tTerminoBusqueda))
              .thenThrow(Exception('Database error'));

          return ComparadorBloc(
            buscarProductosSimilares: mockBuscarProductosSimilares,
            compararPreciosProducto: mockCompararPreciosProducto,
            buscarProductosPorQR: mockBuscarProductosPorQR,
            comparadorService: mockComparadorService,
          );
        },
        act: (bloc) =>
            bloc.add(const BuscarProductosSimilaresEvent(tTerminoBusqueda)),
        expect: () => [
          const ComparadorLoading(),
          const ComparadorError(
              'Error al buscar productos similares: Exception: Database error'),
        ],
      );
    });

    group('CompararPreciosProductoEvent', () {
      const tProductoId = 1;
      final tResultadoConProductos = ResultadoComparacion(
        terminoBusqueda: 'Producto 1',
        productos: [
          ProductoComparacion(
            producto: Producto(
              id: 1,
              nombre: 'Producto 1',
              precio: 3.00,
              categoriaId: 1,
              almacenId: 1,
              fechaCreacion: DateTime.now(),
              fechaActualizacion: DateTime.now(),
            ),
            almacen: Almacen(
              id: 1,
              nombre: 'Almacén 1',
              fechaCreacion: DateTime.now(),
              fechaActualizacion: DateTime.now(),
            ),
            esMejorPrecio: true,
          ),
        ],
        fechaComparacion: DateTime.now(),
      );
      final tResultadoVacio = ResultadoComparacion(
        terminoBusqueda: 'Producto 1',
        productos: const [],
        fechaComparacion: DateTime.now(),
      );

      blocTest<ComparadorBloc, ComparadorState>(
        'should emit [ComparadorLoading, ComparadorLoaded] when comparison is successful with results',
        build: () {
          final mockBuscarProductosSimilares = MockBuscarProductosSimilares();
          final mockCompararPreciosProducto = MockCompararPreciosProducto();
          final mockBuscarProductosPorQR = MockBuscarProductosPorQR();
          final mockComparadorService = MockComparadorService();

          when(mockCompararPreciosProducto(tProductoId))
              .thenAnswer((_) async => tResultadoConProductos);

          return ComparadorBloc(
            buscarProductosSimilares: mockBuscarProductosSimilares,
            compararPreciosProducto: mockCompararPreciosProducto,
            buscarProductosPorQR: mockBuscarProductosPorQR,
            comparadorService: mockComparadorService,
          );
        },
        act: (bloc) =>
            bloc.add(const CompararPreciosProductoEvent(tProductoId)),
        expect: () => [
          const ComparadorLoading(),
          ComparadorLoaded(tResultadoConProductos),
        ],
      );

      blocTest<ComparadorBloc, ComparadorState>(
        'should emit [ComparadorLoading, ComparadorEmpty] when comparison returns no results',
        build: () {
          final mockBuscarProductosSimilares = MockBuscarProductosSimilares();
          final mockCompararPreciosProducto = MockCompararPreciosProducto();
          final mockBuscarProductosPorQR = MockBuscarProductosPorQR();
          final mockComparadorService = MockComparadorService();

          when(mockCompararPreciosProducto(tProductoId))
              .thenAnswer((_) async => tResultadoVacio);

          return ComparadorBloc(
            buscarProductosSimilares: mockBuscarProductosSimilares,
            compararPreciosProducto: mockCompararPreciosProducto,
            buscarProductosPorQR: mockBuscarProductosPorQR,
            comparadorService: mockComparadorService,
          );
        },
        act: (bloc) =>
            bloc.add(const CompararPreciosProductoEvent(tProductoId)),
        expect: () => [
          const ComparadorLoading(),
          const ComparadorEmpty('Producto no encontrado'),
        ],
      );

      blocTest<ComparadorBloc, ComparadorState>(
        'should emit [ComparadorLoading, ComparadorError] when comparison fails',
        build: () {
          final mockBuscarProductosSimilares = MockBuscarProductosSimilares();
          final mockCompararPreciosProducto = MockCompararPreciosProducto();
          final mockBuscarProductosPorQR = MockBuscarProductosPorQR();
          final mockComparadorService = MockComparadorService();

          when(mockCompararPreciosProducto(tProductoId))
              .thenThrow(Exception('Database error'));

          return ComparadorBloc(
            buscarProductosSimilares: mockBuscarProductosSimilares,
            compararPreciosProducto: mockCompararPreciosProducto,
            buscarProductosPorQR: mockBuscarProductosPorQR,
            comparadorService: mockComparadorService,
          );
        },
        act: (bloc) =>
            bloc.add(const CompararPreciosProductoEvent(tProductoId)),
        expect: () => [
          const ComparadorLoading(),
          const ComparadorError(
              'Error al comparar precios: Exception: Database error'),
        ],
      );
    });

    group('BuscarProductosPorQREvent', () {
      const tCodigoQR = '1234567890';
      final tResultadoConProductos = ResultadoComparacion(
        terminoBusqueda: tCodigoQR,
        productos: [
          ProductoComparacion(
            producto: Producto(
              id: 1,
              nombre: 'Producto QR',
              precio: 1.50,
              categoriaId: 1,
              almacenId: 1,
              fechaCreacion: DateTime.now(),
              fechaActualizacion: DateTime.now(),
            ),
            almacen: Almacen(
              id: 1,
              nombre: 'Almacén 1',
              fechaCreacion: DateTime.now(),
              fechaActualizacion: DateTime.now(),
            ),
            esMejorPrecio: true,
          ),
        ],
        fechaComparacion: DateTime.now(),
      );
      final tResultadoVacio = ResultadoComparacion(
        terminoBusqueda: tCodigoQR,
        productos: const [],
        fechaComparacion: DateTime.now(),
      );

      blocTest<ComparadorBloc, ComparadorState>(
        'should emit [ComparadorLoading, ComparadorLoaded] when QR search is successful with results',
        build: () {
          final mockBuscarProductosSimilares = MockBuscarProductosSimilares();
          final mockCompararPreciosProducto = MockCompararPreciosProducto();
          final mockBuscarProductosPorQR = MockBuscarProductosPorQR();
          final mockComparadorService = MockComparadorService();

          when(mockBuscarProductosPorQR(tCodigoQR))
              .thenAnswer((_) async => tResultadoConProductos);

          return ComparadorBloc(
            buscarProductosSimilares: mockBuscarProductosSimilares,
            compararPreciosProducto: mockCompararPreciosProducto,
            buscarProductosPorQR: mockBuscarProductosPorQR,
            comparadorService: mockComparadorService,
          );
        },
        act: (bloc) => bloc.add(const BuscarProductosPorQREvent(tCodigoQR)),
        expect: () => [
          const ComparadorLoading(),
          ComparadorLoaded(tResultadoConProductos),
        ],
      );

      blocTest<ComparadorBloc, ComparadorState>(
        'should emit [ComparadorLoading, ComparadorEmpty] when QR search returns no results',
        build: () {
          final mockBuscarProductosSimilares = MockBuscarProductosSimilares();
          final mockCompararPreciosProducto = MockCompararPreciosProducto();
          final mockBuscarProductosPorQR = MockBuscarProductosPorQR();
          final mockComparadorService = MockComparadorService();

          when(mockBuscarProductosPorQR(tCodigoQR))
              .thenAnswer((_) async => tResultadoVacio);

          return ComparadorBloc(
            buscarProductosSimilares: mockBuscarProductosSimilares,
            compararPreciosProducto: mockCompararPreciosProducto,
            buscarProductosPorQR: mockBuscarProductosPorQR,
            comparadorService: mockComparadorService,
          );
        },
        act: (bloc) => bloc.add(const BuscarProductosPorQREvent(tCodigoQR)),
        expect: () => [
          const ComparadorLoading(),
          const ComparadorEmpty(tCodigoQR),
        ],
      );

      blocTest<ComparadorBloc, ComparadorState>(
        'should emit [ComparadorLoading, ComparadorError] when QR search fails',
        build: () {
          final mockBuscarProductosSimilares = MockBuscarProductosSimilares();
          final mockCompararPreciosProducto = MockCompararPreciosProducto();
          final mockBuscarProductosPorQR = MockBuscarProductosPorQR();
          final mockComparadorService = MockComparadorService();

          when(mockBuscarProductosPorQR(tCodigoQR))
              .thenThrow(Exception('Database error'));

          return ComparadorBloc(
            buscarProductosSimilares: mockBuscarProductosSimilares,
            compararPreciosProducto: mockCompararPreciosProducto,
            buscarProductosPorQR: mockBuscarProductosPorQR,
            comparadorService: mockComparadorService,
          );
        },
        act: (bloc) => bloc.add(const BuscarProductosPorQREvent(tCodigoQR)),
        expect: () => [
          const ComparadorLoading(),
          const ComparadorError(
              'Error al buscar productos por QR: Exception: Database error'),
        ],
      );
    });

    group('LimpiarResultadosEvent', () {
      blocTest<ComparadorBloc, ComparadorState>(
        'should emit ComparadorInitial when clearing results',
        build: () {
          final mockBuscarProductosSimilares = MockBuscarProductosSimilares();
          final mockCompararPreciosProducto = MockCompararPreciosProducto();
          final mockBuscarProductosPorQR = MockBuscarProductosPorQR();
          final mockComparadorService = MockComparadorService();

          return ComparadorBloc(
            buscarProductosSimilares: mockBuscarProductosSimilares,
            compararPreciosProducto: mockCompararPreciosProducto,
            buscarProductosPorQR: mockBuscarProductosPorQR,
            comparadorService: mockComparadorService,
          );
        },
        seed: () => ComparadorLoaded(
          ResultadoComparacion(
            terminoBusqueda: 'test',
            productos: const [],
            fechaComparacion: DateTime.now(),
          ),
        ),
        act: (bloc) => bloc.add(const LimpiarResultadosEvent()),
        expect: () => [const ComparadorInitial()],
      );
    });
  });
}
