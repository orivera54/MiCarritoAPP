import 'package:flutter_test/flutter_test.dart';

import 'package:supermercado_comparador/features/comparador/domain/entities/producto_comparacion.dart';
import 'package:supermercado_comparador/features/comparador/domain/entities/resultado_comparacion.dart';
import 'package:supermercado_comparador/features/comparador/domain/services/comparador_service.dart';
import 'package:supermercado_comparador/features/productos/domain/entities/producto.dart';
import 'package:supermercado_comparador/features/almacenes/domain/entities/almacen.dart';

void main() {
  group('ComparadorService', () {
    late List<ProductoComparacion> tProductos;
    late Almacen tAlmacen1;
    late Almacen tAlmacen2;
    late Producto tProducto1;
    late Producto tProducto2;
    late Producto tProducto3;

    setUp(() {
      tAlmacen1 = Almacen(
        id: 1,
        nombre: 'Almacén 1',
        fechaCreacion: DateTime.parse('2024-01-01T00:00:00.000Z'),
        fechaActualizacion: DateTime.parse('2024-01-01T00:00:00.000Z'),
      );

      tAlmacen2 = Almacen(
        id: 2,
        nombre: 'Almacén 2',
        fechaCreacion: DateTime.parse('2024-01-01T00:00:00.000Z'),
        fechaActualizacion: DateTime.parse('2024-01-01T00:00:00.000Z'),
      );

      tProducto1 = Producto(
        id: 1,
        nombre: 'Leche',
        precio: 2.50,
        categoriaId: 1,
        almacenId: 1,
        fechaCreacion: DateTime.parse('2024-01-01T00:00:00.000Z'),
        fechaActualizacion: DateTime.parse('2024-01-01T00:00:00.000Z'),
      );

      tProducto2 = Producto(
        id: 2,
        nombre: 'Leche',
        precio: 3.00,
        categoriaId: 1,
        almacenId: 2,
        fechaCreacion: DateTime.parse('2024-01-01T00:00:00.000Z'),
        fechaActualizacion: DateTime.parse('2024-01-01T00:00:00.000Z'),
      );

      tProducto3 = Producto(
        id: 3,
        nombre: 'Leche',
        precio: 2.75,
        categoriaId: 1,
        almacenId: 1,
        fechaCreacion: DateTime.parse('2024-01-01T00:00:00.000Z'),
        fechaActualizacion: DateTime.parse('2024-01-01T00:00:00.000Z'),
      );

      tProductos = [
        ProductoComparacion(producto: tProducto1, almacen: tAlmacen1, esMejorPrecio: true),
        ProductoComparacion(producto: tProducto2, almacen: tAlmacen2, esMejorPrecio: false),
        ProductoComparacion(producto: tProducto3, almacen: tAlmacen1, esMejorPrecio: false),
      ];
    });

    group('identificarMejorPrecio', () {
      test('should return product with lowest price', () {
        // act
        final result = ComparadorService.identificarMejorPrecio(tProductos);

        // assert
        expect(result?.producto.precio, equals(2.50));
        expect(result?.producto.id, equals(1));
      });

      test('should return null when list is empty', () {
        // act
        final result = ComparadorService.identificarMejorPrecio([]);

        // assert
        expect(result, isNull);
      });
    });

    group('calcularPrecioMinimo', () {
      test('should return minimum price from products', () {
        // act
        final result = ComparadorService.calcularPrecioMinimo(tProductos);

        // assert
        expect(result, equals(2.50));
      });

      test('should return null when list is empty', () {
        // act
        final result = ComparadorService.calcularPrecioMinimo([]);

        // assert
        expect(result, isNull);
      });
    });

    group('calcularPrecioMaximo', () {
      test('should return maximum price from products', () {
        // act
        final result = ComparadorService.calcularPrecioMaximo(tProductos);

        // assert
        expect(result, equals(3.00));
      });

      test('should return null when list is empty', () {
        // act
        final result = ComparadorService.calcularPrecioMaximo([]);

        // assert
        expect(result, isNull);
      });
    });

    group('calcularPrecioPromedio', () {
      test('should return average price from products', () {
        // act
        final result = ComparadorService.calcularPrecioPromedio(tProductos);

        // assert
        expect(result, closeTo(2.75, 0.01));
      });

      test('should return null when list is empty', () {
        // act
        final result = ComparadorService.calcularPrecioPromedio([]);

        // assert
        expect(result, isNull);
      });
    });

    group('calcularAhorroPotencial', () {
      test('should return difference between max and min price', () {
        // act
        final result = ComparadorService.calcularAhorroPotencial(tProductos);

        // assert
        expect(result, equals(0.50));
      });

      test('should return 0 when list has less than 2 products', () {
        // act
        final result = ComparadorService.calcularAhorroPotencial([tProductos.first]);

        // assert
        expect(result, equals(0.0));
      });
    });

    group('calcularPorcentajeAhorro', () {
      test('should return percentage savings', () {
        // act
        final result = ComparadorService.calcularPorcentajeAhorro(tProductos);

        // assert
        expect(result, closeTo(16.67, 0.01));
      });

      test('should return 0 when list has less than 2 products', () {
        // act
        final result = ComparadorService.calcularPorcentajeAhorro([tProductos.first]);

        // assert
        expect(result, equals(0.0));
      });
    });

    group('ordenarPorPrecio', () {
      test('should sort products by price ascending by default', () {
        // arrange
        final productosDesordenados = [tProductos[1], tProductos[0], tProductos[2]];

        // act
        final result = ComparadorService.ordenarPorPrecio(productosDesordenados);

        // assert
        expect(result[0].producto.precio, equals(2.50));
        expect(result[1].producto.precio, equals(2.75));
        expect(result[2].producto.precio, equals(3.00));
      });

      test('should sort products by price descending when specified', () {
        // arrange
        final productosDesordenados = [tProductos[1], tProductos[0], tProductos[2]];

        // act
        final result = ComparadorService.ordenarPorPrecio(productosDesordenados, ascendente: false);

        // assert
        expect(result[0].producto.precio, equals(3.00));
        expect(result[1].producto.precio, equals(2.75));
        expect(result[2].producto.precio, equals(2.50));
      });
    });

    group('filtrarPorRangoPrecio', () {
      test('should filter products within price range', () {
        // act
        final result = ComparadorService.filtrarPorRangoPrecio(tProductos, 2.60, 3.00);

        // assert
        expect(result.length, equals(2));
        expect(result.any((p) => p.producto.precio == 2.75), isTrue);
        expect(result.any((p) => p.producto.precio == 3.00), isTrue);
      });

      test('should return empty list when no products in range', () {
        // act
        final result = ComparadorService.filtrarPorRangoPrecio(tProductos, 4.00, 5.00);

        // assert
        expect(result, isEmpty);
      });
    });

    group('agruparPorAlmacen', () {
      test('should group products by store name', () {
        // act
        final result = ComparadorService.agruparPorAlmacen(tProductos);

        // assert
        expect(result.keys.length, equals(2));
        expect(result['Almacén 1']?.length, equals(2));
        expect(result['Almacén 2']?.length, equals(1));
      });
    });

    group('enriquecerResultado', () {
      test('should enrich result with best price', () {
        // arrange
        final resultado = ResultadoComparacion(
          terminoBusqueda: 'leche',
          productos: tProductos,
          fechaComparacion: DateTime.now(),
        );

        // act
        final result = ComparadorService.enriquecerResultado(resultado);

        // assert
        expect(result.mejorPrecio, equals(2.50));
      });

      test('should return same result when no products', () {
        // arrange
        final resultado = ResultadoComparacion(
          terminoBusqueda: 'leche',
          productos: const [],
          fechaComparacion: DateTime.now(),
        );

        // act
        final result = ComparadorService.enriquecerResultado(resultado);

        // assert
        expect(result, equals(resultado));
      });
    });
  });
}