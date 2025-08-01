import 'package:flutter_test/flutter_test.dart';
import 'package:supermercado_comparador/features/productos/data/models/producto_model.dart';
import 'package:supermercado_comparador/features/productos/domain/entities/producto.dart';

void main() {
  group('ProductoModel', () {
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

    test('should be a subclass of Producto entity', () {
      expect(testProductoModel, isA<Producto>());
    });

    group('fromJson', () {
      test('should return a valid model when JSON is valid', () {
        final Map<String, dynamic> jsonMap = {
          'id': 1,
          'nombre': 'Test Product',
          'precio': 10.50,
          'peso': 1.5,
          'tamano': 'Medium',
          'codigo_qr': 'QR123',
          'categoria_id': 1,
          'almacen_id': 1,
          'fecha_creacion': testDate.toIso8601String(),
          'fecha_actualizacion': testDate.toIso8601String(),
        };

        final result = ProductoModel.fromJson(jsonMap);

        expect(result, equals(testProductoModel));
      });

      test('should handle null optional fields', () {
        final Map<String, dynamic> jsonMap = {
          'id': 1,
          'nombre': 'Test Product',
          'precio': 10.50,
          'peso': null,
          'tamano': null,
          'codigo_qr': null,
          'categoria_id': 1,
          'almacen_id': 1,
          'fecha_creacion': testDate.toIso8601String(),
          'fecha_actualizacion': testDate.toIso8601String(),
        };

        final result = ProductoModel.fromJson(jsonMap);

        expect(result.peso, isNull);
        expect(result.tamano, isNull);
        expect(result.codigoQR, isNull);
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        final result = testProductoModel.toJson();

        final expectedMap = {
          'id': 1,
          'nombre': 'Test Product',
          'precio': 10.50,
          'peso': 1.5,
          'tamano': 'Medium',
          'codigo_qr': 'QR123',
          'categoria_id': 1,
          'almacen_id': 1,
          'fecha_creacion': testDate.toIso8601String(),
          'fecha_actualizacion': testDate.toIso8601String(),
        };

        expect(result, equals(expectedMap));
      });
    });

    group('fromEntity', () {
      test('should create model from entity', () {
        final productoEntity = Producto(
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

        final result = ProductoModel.fromEntity(productoEntity);

        expect(result, equals(testProductoModel));
      });
    });

    group('validate', () {
      test('should return null for valid data', () {
        final result = testProductoModel.validate();
        expect(result, isNull);
      });

      test('should return error for empty nombre', () {
        final invalidModel = ProductoModel(
          id: testProductoModel.id,
          nombre: '',
          precio: testProductoModel.precio,
          peso: testProductoModel.peso,
          tamano: testProductoModel.tamano,
          codigoQR: testProductoModel.codigoQR,
          categoriaId: testProductoModel.categoriaId,
          almacenId: testProductoModel.almacenId,
          fechaCreacion: testProductoModel.fechaCreacion,
          fechaActualizacion: testProductoModel.fechaActualizacion,
        );
        final result = invalidModel.validate();
        expect(result, equals('El nombre del producto es obligatorio'));
      });

      test('should return error for short nombre', () {
        final invalidModel = ProductoModel(
          id: testProductoModel.id,
          nombre: 'A',
          precio: testProductoModel.precio,
          peso: testProductoModel.peso,
          tamano: testProductoModel.tamano,
          codigoQR: testProductoModel.codigoQR,
          categoriaId: testProductoModel.categoriaId,
          almacenId: testProductoModel.almacenId,
          fechaCreacion: testProductoModel.fechaCreacion,
          fechaActualizacion: testProductoModel.fechaActualizacion,
        );
        final result = invalidModel.validate();
        expect(result,
            equals('El nombre del producto debe tener al menos 2 caracteres'));
      });

      test('should return error for long nombre', () {
        final invalidModel = ProductoModel(
          id: testProductoModel.id,
          nombre: 'A' * 101,
          precio: testProductoModel.precio,
          peso: testProductoModel.peso,
          tamano: testProductoModel.tamano,
          codigoQR: testProductoModel.codigoQR,
          categoriaId: testProductoModel.categoriaId,
          almacenId: testProductoModel.almacenId,
          fechaCreacion: testProductoModel.fechaCreacion,
          fechaActualizacion: testProductoModel.fechaActualizacion,
        );
        final result = invalidModel.validate();
        expect(result,
            equals('El nombre del producto no puede exceder 100 caracteres'));
      });

      test('should return error for zero precio', () {
        final invalidModel = ProductoModel(
          id: testProductoModel.id,
          nombre: testProductoModel.nombre,
          precio: 0,
          peso: testProductoModel.peso,
          tamano: testProductoModel.tamano,
          codigoQR: testProductoModel.codigoQR,
          categoriaId: testProductoModel.categoriaId,
          almacenId: testProductoModel.almacenId,
          fechaCreacion: testProductoModel.fechaCreacion,
          fechaActualizacion: testProductoModel.fechaActualizacion,
        );
        final result = invalidModel.validate();
        expect(result, equals('El precio debe ser mayor a 0'));
      });

      test('should return error for negative precio', () {
        final invalidModel = ProductoModel(
          id: testProductoModel.id,
          nombre: testProductoModel.nombre,
          precio: -1,
          peso: testProductoModel.peso,
          tamano: testProductoModel.tamano,
          codigoQR: testProductoModel.codigoQR,
          categoriaId: testProductoModel.categoriaId,
          almacenId: testProductoModel.almacenId,
          fechaCreacion: testProductoModel.fechaCreacion,
          fechaActualizacion: testProductoModel.fechaActualizacion,
        );
        final result = invalidModel.validate();
        expect(result, equals('El precio debe ser mayor a 0'));
      });

      test('should return error for too high precio', () {
        final invalidModel = ProductoModel(
          id: testProductoModel.id,
          nombre: testProductoModel.nombre,
          precio: 1000000,
          peso: testProductoModel.peso,
          tamano: testProductoModel.tamano,
          codigoQR: testProductoModel.codigoQR,
          categoriaId: testProductoModel.categoriaId,
          almacenId: testProductoModel.almacenId,
          fechaCreacion: testProductoModel.fechaCreacion,
          fechaActualizacion: testProductoModel.fechaActualizacion,
        );
        final result = invalidModel.validate();
        expect(result, equals('El precio no puede exceder 999,999.99'));
      });

      test('should return error for zero peso', () {
        final invalidModel = ProductoModel(
          id: testProductoModel.id,
          nombre: testProductoModel.nombre,
          precio: testProductoModel.precio,
          peso: 0,
          tamano: testProductoModel.tamano,
          codigoQR: testProductoModel.codigoQR,
          categoriaId: testProductoModel.categoriaId,
          almacenId: testProductoModel.almacenId,
          fechaCreacion: testProductoModel.fechaCreacion,
          fechaActualizacion: testProductoModel.fechaActualizacion,
        );
        final result = invalidModel.validate();
        expect(result, equals('El peso debe ser mayor a 0'));
      });

      test('should return error for negative peso', () {
        final invalidModel = ProductoModel(
          id: testProductoModel.id,
          nombre: testProductoModel.nombre,
          precio: testProductoModel.precio,
          peso: -1,
          tamano: testProductoModel.tamano,
          codigoQR: testProductoModel.codigoQR,
          categoriaId: testProductoModel.categoriaId,
          almacenId: testProductoModel.almacenId,
          fechaCreacion: testProductoModel.fechaCreacion,
          fechaActualizacion: testProductoModel.fechaActualizacion,
        );
        final result = invalidModel.validate();
        expect(result, equals('El peso debe ser mayor a 0'));
      });

      test('should return error for too high peso', () {
        final invalidModel = ProductoModel(
          id: testProductoModel.id,
          nombre: testProductoModel.nombre,
          precio: testProductoModel.precio,
          peso: 100000,
          tamano: testProductoModel.tamano,
          codigoQR: testProductoModel.codigoQR,
          categoriaId: testProductoModel.categoriaId,
          almacenId: testProductoModel.almacenId,
          fechaCreacion: testProductoModel.fechaCreacion,
          fechaActualizacion: testProductoModel.fechaActualizacion,
        );
        final result = invalidModel.validate();
        expect(result, equals('El peso no puede exceder 99,999.99'));
      });

      test('should return error for long tamano', () {
        final invalidModel = ProductoModel(
          id: testProductoModel.id,
          nombre: testProductoModel.nombre,
          precio: testProductoModel.precio,
          peso: testProductoModel.peso,
          tamano: 'A' * 51,
          codigoQR: testProductoModel.codigoQR,
          categoriaId: testProductoModel.categoriaId,
          almacenId: testProductoModel.almacenId,
          fechaCreacion: testProductoModel.fechaCreacion,
          fechaActualizacion: testProductoModel.fechaActualizacion,
        );
        final result = invalidModel.validate();
        expect(result, equals('El tamano no puede exceder 50 caracteres'));
      });

      test('should return error for empty codigoQR', () {
        final invalidModel = ProductoModel(
          id: testProductoModel.id,
          nombre: testProductoModel.nombre,
          precio: testProductoModel.precio,
          peso: testProductoModel.peso,
          tamano: testProductoModel.tamano,
          codigoQR: '',
          categoriaId: testProductoModel.categoriaId,
          almacenId: testProductoModel.almacenId,
          fechaCreacion: testProductoModel.fechaCreacion,
          fechaActualizacion: testProductoModel.fechaActualizacion,
        );
        final result = invalidModel.validate();
        expect(result,
            equals('El codigo QR no puede estar vacio si se proporciona'));
      });

      test('should return error for long codigoQR', () {
        final invalidModel = ProductoModel(
          id: testProductoModel.id,
          nombre: testProductoModel.nombre,
          precio: testProductoModel.precio,
          peso: testProductoModel.peso,
          tamano: testProductoModel.tamano,
          codigoQR: 'A' * 101,
          categoriaId: testProductoModel.categoriaId,
          almacenId: testProductoModel.almacenId,
          fechaCreacion: testProductoModel.fechaCreacion,
          fechaActualizacion: testProductoModel.fechaActualizacion,
        );
        final result = invalidModel.validate();
        expect(result, equals('El codigo QR no puede exceder 100 caracteres'));
      });
    });
  });
}
