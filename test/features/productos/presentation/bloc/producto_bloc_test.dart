import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:supermercado_comparador/core/errors/exceptions.dart';
import 'package:supermercado_comparador/features/productos/domain/entities/producto.dart';
import 'package:supermercado_comparador/features/productos/domain/usecases/get_all_productos.dart';
import 'package:supermercado_comparador/features/productos/domain/usecases/get_productos_by_almacen.dart';
import 'package:supermercado_comparador/features/productos/domain/usecases/get_productos_by_categoria.dart';
import 'package:supermercado_comparador/features/productos/domain/usecases/get_producto_by_id.dart';
import 'package:supermercado_comparador/features/productos/domain/usecases/search_productos_by_name.dart'
    as search_usecase;
import 'package:supermercado_comparador/features/productos/domain/usecases/get_producto_by_qr.dart';
import 'package:supermercado_comparador/features/productos/domain/usecases/search_productos_with_filters.dart'
    as filter_usecase;
import 'package:supermercado_comparador/features/productos/domain/usecases/create_producto.dart'
    as create_usecase;
import 'package:supermercado_comparador/features/productos/domain/usecases/update_producto.dart'
    as update_usecase;
import 'package:supermercado_comparador/features/productos/domain/usecases/delete_producto.dart'
    as delete_usecase;
import 'package:supermercado_comparador/features/productos/presentation/bloc/producto_bloc.dart';
import 'package:supermercado_comparador/features/productos/presentation/bloc/producto_event.dart';
import 'package:supermercado_comparador/features/productos/presentation/bloc/producto_state.dart';

import 'producto_bloc_test.mocks.dart';

@GenerateMocks([
  GetAllProductos,
  GetProductosByAlmacen,
  GetProductosByCategoria,
  GetProductoById,
  search_usecase.SearchProductosByName,
  GetProductoByQR,
  filter_usecase.SearchProductosWithFilters,
  create_usecase.CreateProducto,
  update_usecase.UpdateProducto,
  delete_usecase.DeleteProducto,
])
void main() {
  late ProductoBloc bloc;
  late MockGetAllProductos mockGetAllProductos;
  late MockGetProductosByAlmacen mockGetProductosByAlmacen;
  late MockGetProductosByCategoria mockGetProductosByCategoria;
  late MockGetProductoById mockGetProductoById;
  late MockSearchProductosByName mockSearchProductosByName;
  late MockGetProductoByQR mockGetProductoByQR;
  late MockSearchProductosWithFilters mockSearchProductosWithFilters;
  late MockCreateProducto mockCreateProducto;
  late MockUpdateProducto mockUpdateProducto;
  late MockDeleteProducto mockDeleteProducto;

  setUp(() {
    mockGetAllProductos = MockGetAllProductos();
    mockGetProductosByAlmacen = MockGetProductosByAlmacen();
    mockGetProductosByCategoria = MockGetProductosByCategoria();
    mockGetProductoById = MockGetProductoById();
    mockSearchProductosByName = MockSearchProductosByName();
    mockGetProductoByQR = MockGetProductoByQR();
    mockSearchProductosWithFilters = MockSearchProductosWithFilters();
    mockCreateProducto = MockCreateProducto();
    mockUpdateProducto = MockUpdateProducto();
    mockDeleteProducto = MockDeleteProducto();

    bloc = ProductoBloc(
      getAllProductos: mockGetAllProductos,
      getProductosByAlmacen: mockGetProductosByAlmacen,
      getProductosByCategoria: mockGetProductosByCategoria,
      getProductoById: mockGetProductoById,
      searchProductosByName: mockSearchProductosByName,
      getProductoByQR: mockGetProductoByQR,
      searchProductosWithFilters: mockSearchProductosWithFilters,
      createProducto: mockCreateProducto,
      updateProducto: mockUpdateProducto,
      deleteProducto: mockDeleteProducto,
    );
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

  final testProducto = testProductos.first;

  group('ProductoBloc', () {
    test('initial state is ProductoInitial', () {
      expect(bloc.state, equals(ProductoInitial()));
    });

    group('LoadAllProductos', () {
      blocTest<ProductoBloc, ProductoState>(
        'emits [ProductoLoading, ProductoLoaded] when successful',
        build: () {
          when(mockGetAllProductos()).thenAnswer((_) async => testProductos);
          return bloc;
        },
        act: (bloc) => bloc.add(LoadAllProductos()),
        expect: () => [
          ProductoLoading(),
          ProductoLoaded(testProductos),
        ],
        verify: (_) {
          verify(mockGetAllProductos()).called(1);
        },
      );

      blocTest<ProductoBloc, ProductoState>(
        'emits [ProductoLoading, ProductoError] when fails',
        build: () {
          when(mockGetAllProductos())
              .thenThrow(const DatabaseException('Database error'));
          return bloc;
        },
        act: (bloc) => bloc.add(LoadAllProductos()),
        expect: () => [
          ProductoLoading(),
          const ProductoError('Error de base de datos: Database error'),
        ],
      );
    });

    group('LoadProductosByAlmacen', () {
      blocTest<ProductoBloc, ProductoState>(
        'emits [ProductoLoading, ProductoLoaded] when successful',
        build: () {
          when(mockGetProductosByAlmacen(1))
              .thenAnswer((_) async => testProductos);
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadProductosByAlmacen(1)),
        expect: () => [
          ProductoLoading(),
          ProductoLoaded(testProductos),
        ],
        verify: (_) {
          verify(mockGetProductosByAlmacen(1)).called(1);
        },
      );
    });

    group('LoadProductoById', () {
      blocTest<ProductoBloc, ProductoState>(
        'emits [ProductoLoading, ProductoSelected] when producto found',
        build: () {
          when(mockGetProductoById(1)).thenAnswer((_) async => testProducto);
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadProductoById(1)),
        expect: () => [
          ProductoLoading(),
          ProductoSelected(testProducto),
        ],
        verify: (_) {
          verify(mockGetProductoById(1)).called(1);
        },
      );

      blocTest<ProductoBloc, ProductoState>(
        'emits [ProductoLoading, ProductoError] when producto not found',
        build: () {
          when(mockGetProductoById(1)).thenAnswer((_) async => null);
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadProductoById(1)),
        expect: () => [
          ProductoLoading(),
          const ProductoError('Producto no encontrado'),
        ],
      );
    });

    group('SearchProductosByName', () {
      blocTest<ProductoBloc, ProductoState>(
        'emits [ProductoLoading, ProductoSearchResults] when successful',
        build: () {
          when(mockSearchProductosByName('test'))
              .thenAnswer((_) async => testProductos);
          return bloc;
        },
        act: (bloc) => bloc.add(const SearchProductosByName('test')),
        expect: () => [
          ProductoLoading(),
          ProductoSearchResults(testProductos, 'test'),
        ],
        verify: (_) {
          verify(mockSearchProductosByName('test')).called(1);
        },
      );
    });

    group('SearchProductoByQR', () {
      blocTest<ProductoBloc, ProductoState>(
        'emits [ProductoLoading, ProductoQRResult] when QR found',
        build: () {
          when(mockGetProductoByQR('QR123'))
              .thenAnswer((_) async => testProducto);
          return bloc;
        },
        act: (bloc) => bloc.add(const SearchProductoByQR('QR123')),
        expect: () => [
          ProductoLoading(),
          ProductoQRResult(testProducto, 'QR123'),
        ],
        verify: (_) {
          verify(mockGetProductoByQR('QR123')).called(1);
        },
      );

      blocTest<ProductoBloc, ProductoState>(
        'emits [ProductoLoading, ProductoQRResult] when QR not found',
        build: () {
          when(mockGetProductoByQR('NONEXISTENT'))
              .thenAnswer((_) async => null);
          return bloc;
        },
        act: (bloc) => bloc.add(const SearchProductoByQR('NONEXISTENT')),
        expect: () => [
          ProductoLoading(),
          const ProductoQRResult(null, 'NONEXISTENT'),
        ],
      );
    });

    group('CreateProducto', () {
      blocTest<ProductoBloc, ProductoState>(
        'emits [ProductoLoading, ProductoCreated] when successful',
        build: () {
          when(mockCreateProducto(testProducto))
              .thenAnswer((_) async => testProducto);
          return bloc;
        },
        act: (bloc) => bloc.add(CreateProducto(testProducto)),
        expect: () => [
          ProductoLoading(),
          ProductoCreated(testProducto),
        ],
        verify: (_) {
          verify(mockCreateProducto(testProducto)).called(1);
        },
      );

      blocTest<ProductoBloc, ProductoState>(
        'emits [ProductoLoading, ProductoError] when validation fails',
        build: () {
          when(mockCreateProducto(testProducto))
              .thenThrow(const ValidationException('Validation error'));
          return bloc;
        },
        act: (bloc) => bloc.add(CreateProducto(testProducto)),
        expect: () => [
          ProductoLoading(),
          const ProductoError('Validation error'),
        ],
      );

      blocTest<ProductoBloc, ProductoState>(
        'emits [ProductoLoading, ProductoError] when duplicate QR',
        build: () {
          when(mockCreateProducto(testProducto))
              .thenThrow(const DuplicateException('QR already exists'));
          return bloc;
        },
        act: (bloc) => bloc.add(CreateProducto(testProducto)),
        expect: () => [
          ProductoLoading(),
          const ProductoError('QR already exists'),
        ],
      );
    });

    group('UpdateProducto', () {
      blocTest<ProductoBloc, ProductoState>(
        'emits [ProductoLoading, ProductoUpdated] when successful',
        build: () {
          when(mockUpdateProducto(testProducto))
              .thenAnswer((_) async => testProducto);
          return bloc;
        },
        act: (bloc) => bloc.add(UpdateProducto(testProducto)),
        expect: () => [
          ProductoLoading(),
          ProductoUpdated(testProducto),
        ],
        verify: (_) {
          verify(mockUpdateProducto(testProducto)).called(1);
        },
      );
    });

    group('DeleteProducto', () {
      blocTest<ProductoBloc, ProductoState>(
        'emits [ProductoLoading, ProductoDeleted] when successful',
        build: () {
          when(mockDeleteProducto(1)).thenAnswer((_) async {});
          return bloc;
        },
        act: (bloc) => bloc.add(const DeleteProducto(1)),
        expect: () => [
          ProductoLoading(),
          const ProductoDeleted(1),
        ],
        verify: (_) {
          verify(mockDeleteProducto(1)).called(1);
        },
      );

      blocTest<ProductoBloc, ProductoState>(
        'emits [ProductoLoading, ProductoError] when producto has dependencies',
        build: () {
          when(mockDeleteProducto(1)).thenThrow(const ValidationException(
              'Cannot delete producto with dependencies'));
          return bloc;
        },
        act: (bloc) => bloc.add(const DeleteProducto(1)),
        expect: () => [
          ProductoLoading(),
          const ProductoError('Cannot delete producto with dependencies'),
        ],
      );
    });

    group('ClearProductoSelection', () {
      blocTest<ProductoBloc, ProductoState>(
        'emits [ProductoInitial] when called',
        build: () => bloc,
        act: (bloc) => bloc.add(ClearProductoSelection()),
        expect: () => [ProductoInitial()],
      );
    });

    group('ClearProductoSearch', () {
      blocTest<ProductoBloc, ProductoState>(
        'emits [ProductoInitial] when called',
        build: () => bloc,
        act: (bloc) => bloc.add(ClearProductoSearch()),
        expect: () => [ProductoInitial()],
      );
    });
  });
}
