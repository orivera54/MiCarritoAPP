import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supermercado_comparador/features/productos/data/datasources/producto_local_data_source.dart';
import 'package:supermercado_comparador/features/productos/data/models/producto_model.dart';
import 'package:supermercado_comparador/features/productos/data/repositories/producto_repository_impl.dart';
import 'package:supermercado_comparador/features/productos/domain/entities/producto.dart';

import 'producto_repository_impl_test.mocks.dart';

@GenerateMocks([ProductoLocalDataSource])
void main() {
  late ProductoRepositoryImpl repository;
  late MockProductoLocalDataSource mockLocalDataSource;

  setUp(() {
    mockLocalDataSource = MockProductoLocalDataSource();
    repository = ProductoRepositoryImpl(localDataSource: mockLocalDataSource);
  });

  final testDate = DateTime(2024, 1, 1);
  final testProductoModel = ProductoModel(
    id: 1,
    nombre: 'Test Producto',
    precio: 10.50,
    peso: 1.5,
    tamano: 'Grande',
    codigoQR: 'QR123',
    categoriaId: 1,
    almacenId: 1,
    fechaCreacion: testDate,
    fechaActualizacion: testDate,
  );

  final testProducto = Producto(
    id: 1,
    nombre: 'Test Producto',
    precio: 10.50,
    peso: 1.5,
    tamano: 'Grande',
    codigoQR: 'QR123',
    categoriaId: 1,
    almacenId: 1,
    fechaCreacion: testDate,
    fechaActualizacion: testDate,
  );

  group('getAllProductos', () {
    test('should return list of Producto entities', () async {
      // arrange
      when(mockLocalDataSource.getAllProductos())
          .thenAnswer((_) async => [testProductoModel]);

      // act
      final result = await repository.getAllProductos();

      // assert
      expect(result, isA<List<Producto>>());
      expect(result.length, 1);
      expect(result.first.nombre, equals('Test Producto'));
      verify(mockLocalDataSource.getAllProductos());
    });
  });

  group('getProductosByAlmacen', () {
    test('should return list of Producto entities filtered by almacen', () async {
      // arrange
      when(mockLocalDataSource.getProductosByAlmacen(1))
          .thenAnswer((_) async => [testProductoModel]);

      // act
      final result = await repository.getProductosByAlmacen(1);

      // assert
      expect(result, isA<List<Producto>>());
      expect(result.length, 1);
      expect(result.first.almacenId, equals(1));
      verify(mockLocalDataSource.getProductosByAlmacen(1));
    });
  });

  group('getProductosByCategoria', () {
    test('should return list of Producto entities filtered by categoria', () async {
      // arrange
      when(mockLocalDataSource.getProductosByCategoria(1))
          .thenAnswer((_) async => [testProductoModel]);

      // act
      final result = await repository.getProductosByCategoria(1);

      // assert
      expect(result, isA<List<Producto>>());
      expect(result.length, 1);
      expect(result.first.categoriaId, equals(1));
      verify(mockLocalDataSource.getProductosByCategoria(1));
    });
  });

  group('getProductoById', () {
    test('should return Producto entity when found', () async {
      // arrange
      when(mockLocalDataSource.getProductoById(1))
          .thenAnswer((_) async => testProductoModel);

      // act
      final result = await repository.getProductoById(1);

      // assert
      expect(result, isA<Producto>());
      expect(result!.id, equals(1));
      expect(result.nombre, equals('Test Producto'));
      verify(mockLocalDataSource.getProductoById(1));
    });

    test('should return null when not found', () async {
      // arrange
      when(mockLocalDataSource.getProductoById(1))
          .thenAnswer((_) async => null);

      // act
      final result = await repository.getProductoById(1);

      // assert
      expect(result, isNull);
      verify(mockLocalDataSource.getProductoById(1));
    });
  });

  group('searchProductosByName', () {
    test('should return list of Producto entities matching search term', () async {
      // arrange
      when(mockLocalDataSource.searchProductosByName('test'))
          .thenAnswer((_) async => [testProductoModel]);

      // act
      final result = await repository.searchProductosByName('test');

      // assert
      expect(result, isA<List<Producto>>());
      expect(result.length, 1);
      expect(result.first.nombre.toLowerCase(), contains('test'));
      verify(mockLocalDataSource.searchProductosByName('test'));
    });
  });

  group('getProductoByQR', () {
    test('should return Producto entity when QR code found', () async {
      // arrange
      when(mockLocalDataSource.getProductoByQR('QR123'))
          .thenAnswer((_) async => testProductoModel);

      // act
      final result = await repository.getProductoByQR('QR123');

      // assert
      expect(result, isA<Producto>());
      expect(result!.codigoQR, equals('QR123'));
      verify(mockLocalDataSource.getProductoByQR('QR123'));
    });

    test('should return null when QR code not found', () async {
      // arrange
      when(mockLocalDataSource.getProductoByQR('NONEXISTENT'))
          .thenAnswer((_) async => null);

      // act
      final result = await repository.getProductoByQR('NONEXISTENT');

      // assert
      expect(result, isNull);
      verify(mockLocalDataSource.getProductoByQR('NONEXISTENT'));
    });
  });

  group('createProducto', () {
    test('should return created Producto entity', () async {
      // arrange
      when(mockLocalDataSource.insertProducto(any))
          .thenAnswer((_) async => testProductoModel);

      // act
      final result = await repository.createProducto(testProducto);

      // assert
      expect(result, isA<Producto>());
      expect(result.nombre, equals('Test Producto'));
      verify(mockLocalDataSource.insertProducto(any));
    });
  });

  group('updateProducto', () {
    test('should return updated Producto entity', () async {
      // arrange
      when(mockLocalDataSource.updateProducto(any))
          .thenAnswer((_) async => testProductoModel);

      // act
      final result = await repository.updateProducto(testProducto);

      // assert
      expect(result, isA<Producto>());
      expect(result.nombre, equals('Test Producto'));
      verify(mockLocalDataSource.updateProducto(any));
    });
  });

  group('deleteProducto', () {
    test('should call local data source delete method', () async {
      // arrange
      when(mockLocalDataSource.deleteProducto(1))
          .thenAnswer((_) async => {});

      // act
      await repository.deleteProducto(1);

      // assert
      verify(mockLocalDataSource.deleteProducto(1));
    });
  });

  group('qrExistsInAlmacen', () {
    test('should return true when QR exists in almacen', () async {
      // arrange
      when(mockLocalDataSource.qrExistsInAlmacen('QR123', 1))
          .thenAnswer((_) async => true);

      // act
      final result = await repository.qrExistsInAlmacen('QR123', 1);

      // assert
      expect(result, isTrue);
      verify(mockLocalDataSource.qrExistsInAlmacen('QR123', 1));
    });

    test('should return false when QR does not exist in almacen', () async {
      // arrange
      when(mockLocalDataSource.qrExistsInAlmacen('NONEXISTENT', 1))
          .thenAnswer((_) async => false);

      // act
      final result = await repository.qrExistsInAlmacen('NONEXISTENT', 1);

      // assert
      expect(result, isFalse);
      verify(mockLocalDataSource.qrExistsInAlmacen('NONEXISTENT', 1));
    });

    test('should exclude specified id when checking QR existence', () async {
      // arrange
      when(mockLocalDataSource.qrExistsInAlmacen('QR123', 1, excludeId: 1))
          .thenAnswer((_) async => false);

      // act
      final result = await repository.qrExistsInAlmacen('QR123', 1, excludeId: 1);

      // assert
      expect(result, isFalse);
      verify(mockLocalDataSource.qrExistsInAlmacen('QR123', 1, excludeId: 1));
    });
  });

  group('getProductosWithDetails', () {
    test('should return productos with detailed information', () async {
      // arrange
      final testDetailsMap = {
        'id': 1,
        'nombre': 'Test Producto',
        'almacen_nombre': 'Test Almacen',
        'categoria_nombre': 'Test Categoria',
      };
      when(mockLocalDataSource.getProductosWithDetails())
          .thenAnswer((_) async => [testDetailsMap]);

      // act
      final result = await repository.getProductosWithDetails();

      // assert
      expect(result, isA<List<Map<String, dynamic>>>());
      expect(result.length, 1);
      expect(result.first['almacen_nombre'], equals('Test Almacen'));
      expect(result.first['categoria_nombre'], equals('Test Categoria'));
      verify(mockLocalDataSource.getProductosWithDetails());
    });
  });

  group('searchProductosWithFilters', () {
    test('should return filtered productos based on multiple criteria', () async {
      // arrange
      when(mockLocalDataSource.searchProductosWithFilters(
        searchTerm: 'test',
        almacenId: 1,
        categoriaId: 1,
        minPrice: 5.0,
        maxPrice: 20.0,
      )).thenAnswer((_) async => [testProductoModel]);

      // act
      final result = await repository.searchProductosWithFilters(
        searchTerm: 'test',
        almacenId: 1,
        categoriaId: 1,
        minPrice: 5.0,
        maxPrice: 20.0,
      );

      // assert
      expect(result, isA<List<Producto>>());
      expect(result.length, 1);
      verify(mockLocalDataSource.searchProductosWithFilters(
        searchTerm: 'test',
        almacenId: 1,
        categoriaId: 1,
        minPrice: 5.0,
        maxPrice: 20.0,
      ));
    });

    test('should handle empty filters', () async {
      // arrange
      when(mockLocalDataSource.searchProductosWithFilters())
          .thenAnswer((_) async => [testProductoModel]);

      // act
      final result = await repository.searchProductosWithFilters();

      // assert
      expect(result, isA<List<Producto>>());
      expect(result.length, 1);
      verify(mockLocalDataSource.searchProductosWithFilters());
    });
  });
}