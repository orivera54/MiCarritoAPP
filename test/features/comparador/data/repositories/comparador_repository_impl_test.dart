import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supermercado_comparador/features/comparador/data/datasources/comparador_local_data_source.dart';
import 'package:supermercado_comparador/features/comparador/data/repositories/comparador_repository_impl.dart';
import 'package:supermercado_comparador/features/comparador/data/models/producto_comparacion_model.dart';
import 'package:supermercado_comparador/features/productos/data/models/producto_model.dart';
import 'package:supermercado_comparador/features/almacenes/data/models/almacen_model.dart';

@GenerateMocks([ComparadorLocalDataSource])
import 'comparador_repository_impl_test.mocks.dart';

void main() {
  late ComparadorRepositoryImpl repository;
  late MockComparadorLocalDataSource mockLocalDataSource;

  setUp(() {
    mockLocalDataSource = MockComparadorLocalDataSource();
    repository = ComparadorRepositoryImpl(localDataSource: mockLocalDataSource);
  });

  final testDate = DateTime(2024, 1, 1);

  final testProductoModel = ProductoModel(
    id: 1,
    nombre: 'Test Product',
    precio: 10.50,
    peso: 1.5,
    tamano: 'Medium',
    codigoQR: 'QR123',
    categoriaId: 1,
    almacenId: 1,
    fechaCreacion: testDate,
    fechaActualizacion: testDate,
  );

  final testAlmacenModel = AlmacenModel(
    id: 1,
    nombre: 'Test Store',
    direccion: 'Test Address',
    descripcion: 'Test Description',
    fechaCreacion: testDate,
    fechaActualizacion: testDate,
  );

  final testProductoComparacion = ProductoComparacionModel(
    producto: testProductoModel,
    almacen: testAlmacenModel,
    esMejorPrecio: true,
  );

  group('ComparadorRepositoryImpl', () {
    group('buscarProductosSimilares', () {
      test('should return ResultadoComparacion with products when search is successful', () async {
        // arrange
        when(mockLocalDataSource.buscarProductosSimilares(any))
            .thenAnswer((_) async => [testProductoComparacion]);

        // act
        final result = await repository.buscarProductosSimilares('test');

        // assert
        expect(result.terminoBusqueda, equals('test'));
        expect(result.productos.length, equals(1));
        expect(result.mejorPrecio, equals(10.50));
        expect(result.tieneResultados, equals(true));
        verify(mockLocalDataSource.buscarProductosSimilares('test'));
      });

      test('should return empty ResultadoComparacion when no products found', () async {
        // arrange
        when(mockLocalDataSource.buscarProductosSimilares(any))
            .thenAnswer((_) async => []);

        // act
        final result = await repository.buscarProductosSimilares('nonexistent');

        // assert
        expect(result.terminoBusqueda, equals('nonexistent'));
        expect(result.productos, isEmpty);
        expect(result.mejorPrecio, isNull);
        expect(result.tieneResultados, equals(false));
        verify(mockLocalDataSource.buscarProductosSimilares('nonexistent'));
      });

      test('should calculate correct mejor precio with multiple products', () async {
        // arrange
        final expensiveProduct = ProductoComparacionModel(
          producto: testProductoModel.copyWith(precio: 15.00),
          almacen: testAlmacenModel,
          esMejorPrecio: false,
        );

        when(mockLocalDataSource.buscarProductosSimilares(any))
            .thenAnswer((_) async => [testProductoComparacion, expensiveProduct]);

        // act
        final result = await repository.buscarProductosSimilares('test');

        // assert
        expect(result.mejorPrecio, equals(10.50));
        expect(result.productos.length, equals(2));
        verify(mockLocalDataSource.buscarProductosSimilares('test'));
      });
    });

    group('compararPreciosProducto', () {
      test('should return comparison results for existing product', () async {
        // arrange
        when(mockLocalDataSource.compararPreciosProducto(any))
            .thenAnswer((_) async => [testProductoComparacion]);

        // act
        final result = await repository.compararPreciosProducto(1);

        // assert
        expect(result.terminoBusqueda, equals('Test Product'));
        expect(result.productos.length, equals(1));
        expect(result.mejorPrecio, equals(10.50));
        verify(mockLocalDataSource.compararPreciosProducto(1));
      });

      test('should return empty result when product not found', () async {
        // arrange
        when(mockLocalDataSource.compararPreciosProducto(any))
            .thenAnswer((_) async => []);

        // act
        final result = await repository.compararPreciosProducto(999);

        // assert
        expect(result.terminoBusqueda, equals(''));
        expect(result.productos, isEmpty);
        expect(result.mejorPrecio, isNull);
        verify(mockLocalDataSource.compararPreciosProducto(999));
      });
    });

    group('buscarProductosPorQR', () {
      test('should return products with same QR code', () async {
        // arrange
        when(mockLocalDataSource.buscarProductosPorQR(any))
            .thenAnswer((_) async => [testProductoComparacion]);

        // act
        final result = await repository.buscarProductosPorQR('QR123');

        // assert
        expect(result.terminoBusqueda, equals('Test Product'));
        expect(result.productos.length, equals(1));
        expect(result.mejorPrecio, equals(10.50));
        verify(mockLocalDataSource.buscarProductosPorQR('QR123'));
      });

      test('should use QR code as search term when no products found', () async {
        // arrange
        when(mockLocalDataSource.buscarProductosPorQR(any))
            .thenAnswer((_) async => []);

        // act
        final result = await repository.buscarProductosPorQR('NONEXISTENT');

        // assert
        expect(result.terminoBusqueda, equals('QR: NONEXISTENT'));
        expect(result.productos, isEmpty);
        expect(result.mejorPrecio, isNull);
        verify(mockLocalDataSource.buscarProductosPorQR('NONEXISTENT'));
      });
    });

    group('obtenerProductosSimilares', () {
      test('should return similar products data', () async {
        // arrange
        final similarProductsData = [
          {
            'id': 1,
            'nombre': 'Test Product',
            'precio': 10.50,
            'almacen_id': 1,
            'almacen_nombre': 'Test Store',
            'coincidencias': 1,
          }
        ];

        when(mockLocalDataSource.obtenerProductosSimilares(any))
            .thenAnswer((_) async => similarProductsData);

        // act
        final result = await repository.obtenerProductosSimilares('test');

        // assert
        expect(result.length, equals(1));
        expect(result.first['nombre'], equals('Test Product'));
        verify(mockLocalDataSource.obtenerProductosSimilares('test'));
      });

      test('should return empty list when no similar products found', () async {
        // arrange
        when(mockLocalDataSource.obtenerProductosSimilares(any))
            .thenAnswer((_) async => []);

        // act
        final result = await repository.obtenerProductosSimilares('nonexistent');

        // assert
        expect(result, isEmpty);
        verify(mockLocalDataSource.obtenerProductosSimilares('nonexistent'));
      });
    });
  });
}