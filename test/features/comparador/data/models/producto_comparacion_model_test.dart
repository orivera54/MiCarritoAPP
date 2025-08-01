import 'package:flutter_test/flutter_test.dart';
import 'package:supermercado_comparador/features/comparador/data/models/producto_comparacion_model.dart';
import 'package:supermercado_comparador/features/comparador/domain/entities/producto_comparacion.dart';
import 'package:supermercado_comparador/features/productos/data/models/producto_model.dart';
import 'package:supermercado_comparador/features/almacenes/data/models/almacen_model.dart';

void main() {
  group('ProductoComparacionModel', () {
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

    final testProductoComparacionModel = ProductoComparacionModel(
      producto: testProductoModel,
      almacen: testAlmacenModel,
      esMejorPrecio: true,
    );

    test('should be a subclass of ProductoComparacion entity', () {
      expect(testProductoComparacionModel, isA<ProductoComparacion>());
    });

    group('fromJson', () {
      test('should return a valid model when JSON is valid', () {
        final Map<String, dynamic> jsonMap = {
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
        };

        final result = ProductoComparacionModel.fromJson(jsonMap);

        expect(result.producto.id, equals(1));
        expect(result.producto.nombre, equals('Test Product'));
        expect(result.producto.precio, equals(10.50));
        expect(result.almacen.id, equals(1));
        expect(result.almacen.nombre, equals('Test Store'));
        expect(result.esMejorPrecio, equals(true));
      });

      test('should handle null optional fields', () {
        final Map<String, dynamic> jsonMap = {
          'producto_id': 1,
          'producto_nombre': 'Test Product',
          'producto_precio': 10.50,
          'producto_peso': null,
          'producto_tamano': null,
          'producto_codigo_qr': null,
          'categoria_id': 1,
          'almacen_id': 1,
          'almacen_nombre': 'Test Store',
          'almacen_direccion': null,
          'almacen_descripcion': null,
          'producto_fecha_creacion': testDate.toIso8601String(),
          'producto_fecha_actualizacion': testDate.toIso8601String(),
          'almacen_fecha_creacion': testDate.toIso8601String(),
          'almacen_fecha_actualizacion': testDate.toIso8601String(),
          'es_mejor_precio': 0,
        };

        final result = ProductoComparacionModel.fromJson(jsonMap);

        expect(result.producto.peso, isNull);
        expect(result.producto.tamano, isNull);
        expect(result.producto.codigoQR, isNull);
        expect(result.almacen.direccion, isNull);
        expect(result.almacen.descripcion, isNull);
        expect(result.esMejorPrecio, equals(false));
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        final result = testProductoComparacionModel.toJson();

        expect(result['producto_id'], equals(1));
        expect(result['producto_nombre'], equals('Test Product'));
        expect(result['producto_precio'], equals(10.50));
        expect(result['almacen_id'], equals(1));
        expect(result['almacen_nombre'], equals('Test Store'));
        expect(result['es_mejor_precio'], equals(1));
      });
    });

    group('fromEntity', () {
      test('should create model from entity', () {
        final productoComparacionEntity = ProductoComparacion(
          producto: testProductoModel,
          almacen: testAlmacenModel,
          esMejorPrecio: true,
        );

        final result = ProductoComparacionModel.fromEntity(productoComparacionEntity);

        expect(result.producto, equals(testProductoModel));
        expect(result.almacen, equals(testAlmacenModel));
        expect(result.esMejorPrecio, equals(true));
      });
    });
  });
}