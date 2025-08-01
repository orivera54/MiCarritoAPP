import 'package:flutter_test/flutter_test.dart';
import 'package:supermercado_comparador/features/comparador/data/models/resultado_comparacion_model.dart';
import 'package:supermercado_comparador/features/comparador/data/models/producto_comparacion_model.dart';
import 'package:supermercado_comparador/features/comparador/domain/entities/resultado_comparacion.dart';
import 'package:supermercado_comparador/features/productos/data/models/producto_model.dart';
import 'package:supermercado_comparador/features/almacenes/data/models/almacen_model.dart';

void main() {
  group('ResultadoComparacionModel', () {
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

    final testResultadoComparacionModel = ResultadoComparacionModel(
      terminoBusqueda: 'test search',
      productos: [testProductoComparacion],
      mejorPrecio: 10.50,
      fechaComparacion: testDate,
    );

    test('should be a subclass of ResultadoComparacion entity', () {
      expect(testResultadoComparacionModel, isA<ResultadoComparacion>());
    });

    group('fromJson', () {
      test('should return a valid model when JSON is valid', () {
        final Map<String, dynamic> jsonMap = {
          'termino_busqueda': 'test search',
          'productos': [
            {
              'producto_id': 1,
              'producto_nombre': 'Test Product',
              'producto_precio': 10.50,
              'producto_peso': 1.5,
              'producto_tamano': 'Medium',
              'producto_codigo_qr': 'QR123',
              'categoria_id': 1,
              'almacen_id': 1,
              'almacen_nombre': 'Test Store',
              'almacen_direccion': 'Test Address',
              'almacen_descripcion': 'Test Description',
              'producto_fecha_creacion': testDate.toIso8601String(),
              'producto_fecha_actualizacion': testDate.toIso8601String(),
              'almacen_fecha_creacion': testDate.toIso8601String(),
              'almacen_fecha_actualizacion': testDate.toIso8601String(),
              'es_mejor_precio': 1,
            }
          ],
          'mejor_precio': 10.50,
          'fecha_comparacion': testDate.toIso8601String(),
        };

        final result = ResultadoComparacionModel.fromJson(jsonMap);

        expect(result.terminoBusqueda, equals('test search'));
        expect(result.productos.length, equals(1));
        expect(result.mejorPrecio, equals(10.50));
        expect(result.fechaComparacion, equals(testDate));
      });

      test('should handle null mejor_precio', () {
        final Map<String, dynamic> jsonMap = {
          'termino_busqueda': 'test search',
          'productos': [],
          'mejor_precio': null,
          'fecha_comparacion': testDate.toIso8601String(),
        };

        final result = ResultadoComparacionModel.fromJson(jsonMap);

        expect(result.terminoBusqueda, equals('test search'));
        expect(result.productos.length, equals(0));
        expect(result.mejorPrecio, isNull);
        expect(result.fechaComparacion, equals(testDate));
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        final result = testResultadoComparacionModel.toJson();

        expect(result['termino_busqueda'], equals('test search'));
        expect(result['productos'], isA<List>());
        expect(result['mejor_precio'], equals(10.50));
        expect(result['fecha_comparacion'], equals(testDate.toIso8601String()));
      });
    });

    group('fromEntity', () {
      test('should create model from entity', () {
        final resultadoComparacionEntity = ResultadoComparacion(
          terminoBusqueda: 'test search',
          productos: [testProductoComparacion],
          mejorPrecio: 10.50,
          fechaComparacion: testDate,
        );

        final result = ResultadoComparacionModel.fromEntity(resultadoComparacionEntity);

        expect(result.terminoBusqueda, equals('test search'));
        expect(result.productos.length, equals(1));
        expect(result.mejorPrecio, equals(10.50));
        expect(result.fechaComparacion, equals(testDate));
      });
    });
  });
}