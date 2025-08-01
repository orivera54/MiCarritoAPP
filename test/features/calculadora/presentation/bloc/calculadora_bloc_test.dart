import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:supermercado_comparador/features/calculadora/domain/entities/item_calculadora.dart';
import 'package:supermercado_comparador/features/calculadora/domain/entities/lista_compra.dart';
import 'package:supermercado_comparador/features/calculadora/domain/usecases/agregar_item_calculadora.dart';
import 'package:supermercado_comparador/features/calculadora/domain/usecases/modificar_cantidad_item.dart';
import 'package:supermercado_comparador/features/calculadora/domain/usecases/eliminar_item_calculadora.dart';
import 'package:supermercado_comparador/features/calculadora/domain/usecases/obtener_lista_actual.dart';
import 'package:supermercado_comparador/features/calculadora/domain/usecases/guardar_lista_compra.dart';
import 'package:supermercado_comparador/features/calculadora/domain/usecases/limpiar_lista_actual.dart';
import 'package:supermercado_comparador/features/calculadora/presentation/bloc/calculadora_bloc.dart';
import 'package:supermercado_comparador/features/calculadora/presentation/bloc/calculadora_event.dart';
import 'package:supermercado_comparador/features/calculadora/presentation/bloc/calculadora_state.dart';
import 'package:supermercado_comparador/features/calculadora/domain/services/mejor_precio_service.dart';
import 'package:supermercado_comparador/features/productos/domain/entities/producto.dart';

import 'calculadora_bloc_test.mocks.dart';

@GenerateMocks([
  AgregarItemCalculadora,
  ModificarCantidadItem,
  EliminarItemCalculadora,
  ObtenerListaActual,
  GuardarListaCompra,
  LimpiarListaActual,
  MejorPrecioService,
])
void main() {
  late CalculadoraBloc bloc;
  late MockAgregarItemCalculadora mockAgregarItemCalculadora;
  late MockModificarCantidadItem mockModificarCantidadItem;
  late MockEliminarItemCalculadora mockEliminarItemCalculadora;
  late MockObtenerListaActual mockObtenerListaActual;
  late MockGuardarListaCompra mockGuardarListaCompra;
  late MockLimpiarListaActual mockLimpiarListaActual;
  late MockMejorPrecioService mockMejorPrecioService;

  setUp(() {
    mockAgregarItemCalculadora = MockAgregarItemCalculadora();
    mockModificarCantidadItem = MockModificarCantidadItem();
    mockEliminarItemCalculadora = MockEliminarItemCalculadora();
    mockObtenerListaActual = MockObtenerListaActual();
    mockGuardarListaCompra = MockGuardarListaCompra();
    mockLimpiarListaActual = MockLimpiarListaActual();
    mockMejorPrecioService = MockMejorPrecioService();

    bloc = CalculadoraBloc(
      agregarItemCalculadora: mockAgregarItemCalculadora,
      modificarCantidadItem: mockModificarCantidadItem,
      eliminarItemCalculadora: mockEliminarItemCalculadora,
      obtenerListaActual: mockObtenerListaActual,
      guardarListaCompra: mockGuardarListaCompra,
      limpiarListaActual: mockLimpiarListaActual,
      mejorPrecioService: mockMejorPrecioService,
    );
  });

  tearDown(() {
    bloc.close();
  });

  final testProducto = Producto(
    id: 1,
    nombre: 'Test Product',
    precio: 10.0,
    peso: 1.0,
    tamano: 'Medium',
    codigoQR: 'QR123',
    categoriaId: 1,
    almacenId: 1,
    fechaCreacion: DateTime.now(),
    fechaActualizacion: DateTime.now(),
  );

  final testLista = ListaCompra(
    items: const [],
    total: 0.0,
    fechaCreacion: DateTime.now(),
  );

  group('CalculadoraBloc', () {
    test('initial state is CalculadoraInitial', () {
      expect(bloc.state, equals(CalculadoraInitial()));
    });

    group('CargarListaActual', () {
      blocTest<CalculadoraBloc, CalculadoraState>(
        'emits [CalculadoraLoading, CalculadoraLoaded] when successful',
        build: () {
          when(mockObtenerListaActual()).thenAnswer((_) async => testLista);
          return bloc;
        },
        act: (bloc) => bloc.add(CargarListaActual()),
        expect: () => [
          CalculadoraLoading(),
          CalculadoraLoaded(listaCompra: testLista),
        ],
        verify: (_) {
          verify(mockObtenerListaActual()).called(1);
        },
      );

      blocTest<CalculadoraBloc, CalculadoraState>(
        'emits [CalculadoraLoading, CalculadoraError] when fails',
        build: () {
          when(mockObtenerListaActual()).thenThrow(Exception('Error'));
          return bloc;
        },
        act: (bloc) => bloc.add(CargarListaActual()),
        expect: () => [
          CalculadoraLoading(),
          const CalculadoraError(
              message: 'Error al cargar la lista: Exception: Error'),
        ],
        verify: (_) {
          verify(mockObtenerListaActual()).called(1);
        },
      );
    });

    group('AgregarProducto', () {
      blocTest<CalculadoraBloc, CalculadoraState>(
        'emits [CalculadoraLoaded] when successful',
        build: () {
          final updatedLista = testLista.copyWith(
            items: [
              ItemCalculadora(
                productoId: 1,
                producto: testProducto,
                cantidad: 1,
                subtotal: 10.0,
              ),
            ],
            total: 10.0,
          );
          when(mockMejorPrecioService.obtenerMejorPrecio(any))
              .thenAnswer((_) async => null);
          when(mockAgregarItemCalculadora(
            producto: anyNamed('producto'),
            cantidad: anyNamed('cantidad'),
          )).thenAnswer((_) async => updatedLista);
          return bloc;
        },
        seed: () => CalculadoraLoaded(listaCompra: testLista),
        act: (bloc) => bloc.add(AgregarProducto(producto: testProducto)),
        expect: () => [
          isA<CalculadoraLoaded>()
              .having(
                  (state) => state.listaCompra.items.length, 'items length', 1)
              .having((state) => state.listaCompra.total, 'total', 10.0),
        ],
        verify: (_) {
          verify(mockAgregarItemCalculadora(
            producto: testProducto,
            cantidad: 1,
          )).called(1);
        },
      );

      blocTest<CalculadoraBloc, CalculadoraState>(
        'emits [CalculadoraError] when not loaded',
        build: () => bloc,
        act: (bloc) => bloc.add(AgregarProducto(producto: testProducto)),
        expect: () => [
          const CalculadoraError(message: 'Lista no cargada'),
        ],
        verify: (_) {
          verifyNever(mockAgregarItemCalculadora(
            producto: anyNamed('producto'),
            cantidad: anyNamed('cantidad'),
          ));
        },
      );

      blocTest<CalculadoraBloc, CalculadoraState>(
        'emits [CalculadoraError, CalculadoraLoaded] when fails and recovers',
        build: () {
          when(mockMejorPrecioService.obtenerMejorPrecio(any))
              .thenAnswer((_) async => null);
          when(mockAgregarItemCalculadora(
            producto: anyNamed('producto'),
            cantidad: anyNamed('cantidad'),
          )).thenThrow(Exception('Error'));
          when(mockObtenerListaActual()).thenAnswer((_) async => testLista);
          return bloc;
        },
        seed: () => CalculadoraLoaded(listaCompra: testLista),
        act: (bloc) => bloc.add(AgregarProducto(producto: testProducto)),
        expect: () => [
          const CalculadoraError(
              message: 'Error al agregar producto: Exception: Error'),
          CalculadoraLoaded(listaCompra: testLista),
        ],
        verify: (_) {
          verify(mockAgregarItemCalculadora(
            producto: testProducto,
            cantidad: 1,
          )).called(1);
          verify(mockObtenerListaActual()).called(1);
        },
      );
    });

    group('ModificarCantidad', () {
      blocTest<CalculadoraBloc, CalculadoraState>(
        'emits [CalculadoraLoaded] when successful',
        build: () {
          final updatedLista = testLista.copyWith(
            items: [
              ItemCalculadora(
                productoId: 1,
                producto: testProducto,
                cantidad: 5,
                subtotal: 50.0,
              ),
            ],
            total: 50.0,
          );
          when(mockModificarCantidadItem(
            productoId: anyNamed('productoId'),
            nuevaCantidad: anyNamed('nuevaCantidad'),
          )).thenAnswer((_) async => updatedLista);
          return bloc;
        },
        seed: () => CalculadoraLoaded(listaCompra: testLista),
        act: (bloc) =>
            bloc.add(const ModificarCantidad(productoId: 1, nuevaCantidad: 5)),
        expect: () => [
          isA<CalculadoraLoaded>()
              .having((state) => state.listaCompra.items.first.cantidad,
                  'cantidad', 5)
              .having((state) => state.listaCompra.total, 'total', 50.0),
        ],
        verify: (_) {
          verify(mockModificarCantidadItem(
            productoId: 1,
            nuevaCantidad: 5,
          )).called(1);
        },
      );

      blocTest<CalculadoraBloc, CalculadoraState>(
        'emits [CalculadoraError] when not loaded',
        build: () => bloc,
        act: (bloc) =>
            bloc.add(const ModificarCantidad(productoId: 1, nuevaCantidad: 5)),
        expect: () => [
          const CalculadoraError(message: 'Lista no cargada'),
        ],
        verify: (_) {
          verifyNever(mockModificarCantidadItem(
            productoId: anyNamed('productoId'),
            nuevaCantidad: anyNamed('nuevaCantidad'),
          ));
        },
      );
    });

    group('EliminarProducto', () {
      blocTest<CalculadoraBloc, CalculadoraState>(
        'emits [CalculadoraLoaded] when successful',
        build: () {
          final updatedLista = testLista.copyWith(items: [], total: 0.0);
          when(mockEliminarItemCalculadora(productoId: anyNamed('productoId')))
              .thenAnswer((_) async => updatedLista);
          return bloc;
        },
        seed: () => CalculadoraLoaded(
            listaCompra: ListaCompra(
          items: [
            ItemCalculadora(
              productoId: 1,
              producto: testProducto,
              cantidad: 1,
              subtotal: 10.0,
            ),
          ],
          total: 10.0,
          fechaCreacion: DateTime.now(),
        )),
        act: (bloc) => bloc.add(const EliminarProducto(productoId: 1)),
        expect: () => [
          isA<CalculadoraLoaded>()
              .having(
                  (state) => state.listaCompra.items.length, 'items length', 0)
              .having((state) => state.listaCompra.total, 'total', 0.0),
        ],
        verify: (_) {
          verify(mockEliminarItemCalculadora(productoId: 1)).called(1);
        },
      );

      blocTest<CalculadoraBloc, CalculadoraState>(
        'emits [CalculadoraError] when not loaded',
        build: () => bloc,
        act: (bloc) => bloc.add(const EliminarProducto(productoId: 1)),
        expect: () => [
          const CalculadoraError(message: 'Lista no cargada'),
        ],
        verify: (_) {
          verifyNever(
              mockEliminarItemCalculadora(productoId: anyNamed('productoId')));
        },
      );
    });

    group('GuardarLista', () {
      blocTest<CalculadoraBloc, CalculadoraState>(
        'emits [CalculadoraListaGuardada, CalculadoraLoaded] when successful',
        build: () {
          final savedLista = testLista.copyWith(id: 1, nombre: 'Test Lista');
          final newEmptyLista = ListaCompra(
            items: const [],
            total: 0.0,
            fechaCreacion: DateTime.now(),
          );
          when(mockGuardarListaCompra(nombre: anyNamed('nombre')))
              .thenAnswer((_) async => savedLista);
          when(mockObtenerListaActual()).thenAnswer((_) async => newEmptyLista);
          return bloc;
        },
        seed: () => CalculadoraLoaded(listaCompra: testLista),
        act: (bloc) => bloc.add(const GuardarLista(nombre: 'Test Lista')),
        expect: () => [
          isA<CalculadoraListaGuardada>()
              .having((state) => state.listaGuardada.id, 'id', 1)
              .having((state) => state.listaGuardada.nombre, 'nombre',
                  'Test Lista'),
          isA<CalculadoraLoaded>().having(
              (state) => state.listaCompra.items.length, 'items length', 0),
        ],
        verify: (_) {
          verify(mockGuardarListaCompra(nombre: 'Test Lista')).called(1);
          verify(mockObtenerListaActual()).called(1);
        },
      );

      blocTest<CalculadoraBloc, CalculadoraState>(
        'emits [CalculadoraError] when not loaded',
        build: () => bloc,
        act: (bloc) => bloc.add(const GuardarLista(nombre: 'Test Lista')),
        expect: () => [
          const CalculadoraError(message: 'Lista no cargada'),
        ],
        verify: (_) {
          verifyNever(mockGuardarListaCompra(nombre: anyNamed('nombre')));
        },
      );
    });

    group('LimpiarLista', () {
      blocTest<CalculadoraBloc, CalculadoraState>(
        'emits [CalculadoraLoaded] when successful',
        build: () {
          final newEmptyLista = ListaCompra(
            items: const [],
            total: 0.0,
            fechaCreacion: DateTime.now(),
          );
          when(mockLimpiarListaActual()).thenAnswer((_) async => newEmptyLista);
          return bloc;
        },
        act: (bloc) => bloc.add(LimpiarLista()),
        expect: () => [
          isA<CalculadoraLoaded>()
              .having(
                  (state) => state.listaCompra.items.length, 'items length', 0)
              .having((state) => state.listaCompra.total, 'total', 0.0),
        ],
        verify: (_) {
          verify(mockLimpiarListaActual()).called(1);
        },
      );

      blocTest<CalculadoraBloc, CalculadoraState>(
        'emits [CalculadoraError] when fails',
        build: () {
          when(mockLimpiarListaActual()).thenThrow(Exception('Error'));
          return bloc;
        },
        act: (bloc) => bloc.add(LimpiarLista()),
        expect: () => [
          const CalculadoraError(
              message: 'Error al limpiar lista: Exception: Error'),
        ],
        verify: (_) {
          verify(mockLimpiarListaActual()).called(1);
        },
      );
    });
  });
}
