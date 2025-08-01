import 'package:flutter_test/flutter_test.dart';
import 'package:supermercado_comparador/features/comparador/domain/entities/producto_comparacion_almacen.dart';
import 'package:supermercado_comparador/features/productos/domain/entities/producto.dart';

void main() {
  group('ProductoComparacionAlmacen', () {
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

    final testProductoComparacion = ProductoComparacionAlmacen(
      almacenId: 1,
      almacenNombre: 'Test Almacen',
      precio: 10.0,
      esMejorPrecio: true,
      producto: testProducto,
    );

    test('should create ProductoComparacionAlmacen with correct properties', () {
      expect(testProductoComparacion.almacenId, equals(1));
      expect(testProductoComparacion.almacenNombre, equals('Test Almacen'));
      expect(testProductoComparacion.precio, equals(10.0));
      expect(testProductoComparacion.esMejorPrecio, equals(true));
      expect(testProductoComparacion.producto, equals(testProducto));
    });

    test('should support equality comparison', () {
      final otherProductoComparacion = ProductoComparacionAlmacen(
        almacenId: 1,
        almacenNombre: 'Test Almacen',
        precio: 10.0,
        esMejorPrecio: true,
        producto: testProducto,
      );

      expect(testProductoComparacion, equals(otherProductoComparacion));
    });

    test('should support copyWith', () {
      final copiedProductoComparacion = testProductoComparacion.copyWith(
        precio: 15.0,
        esMejorPrecio: false,
      );

      expect(copiedProductoComparacion.almacenId, equals(1));
      expect(copiedProductoComparacion.almacenNombre, equals('Test Almacen'));
      expect(copiedProductoComparacion.precio, equals(15.0));
      expect(copiedProductoComparacion.esMejorPrecio, equals(false));
      expect(copiedProductoComparacion.producto, equals(testProducto));
    });

    test('should have proper toString implementation', () {
      final string = testProductoComparacion.toString();
      
      expect(string, contains('ProductoComparacionAlmacen'));
      expect(string, contains('almacenId: 1'));
      expect(string, contains('almacenNombre: Test Almacen'));
      expect(string, contains('precio: 10.0'));
      expect(string, contains('esMejorPrecio: true'));
    });
  });
}