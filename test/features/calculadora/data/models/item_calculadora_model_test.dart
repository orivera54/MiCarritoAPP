import 'package:flutter_test/flutter_test.dart';
import 'package:supermercado_comparador/features/calculadora/data/models/item_calculadora_model.dart';
import 'package:supermercado_comparador/features/calculadora/domain/entities/item_calculadora.dart';
import 'package:supermercado_comparador/features/productos/domain/entities/producto.dart';

void main() {
  group('ItemCalculadoraModel', () {
    final testDate = DateTime(2024, 1, 1);
    final testProducto = Producto(
      id: 1,
      nombre: 'Test Product',
      precio: 10.50,
      categoriaId: 1,
      almacenId: 1,
      fechaCreacion: testDate,
      fechaActualizacion: testDate,
    );

    final testItemModel = ItemCalculadoraModel(
      id: 1,
      productoId: 1,
      producto: testProducto,
      cantidad: 2,
      subtotal: 21.00,
    );

    test('should be a subclass of ItemCalculadora entity', () {
      expect(testItemModel, isA<ItemCalculadora>());
    });

    group('fromJson', () {
      test('should return a valid model when JSON is valid', () {
        final Map<String, dynamic> jsonMap = {
          'id': 1,
          'producto_id': 1,
          'cantidad': 2,
          'subtotal': 21.00,
        };

        final result = ItemCalculadoraModel.fromJson(jsonMap);

        expect(result.id, equals(1));
        expect(result.productoId, equals(1));
        expect(result.cantidad, equals(2));
        expect(result.subtotal, equals(21.00));
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        final result = testItemModel.toJson();

        final expectedMap = {
          'id': 1,
          'producto_id': 1,
          'cantidad': 2,
          'subtotal': 21.00,
        };

        expect(result, equals(expectedMap));
      });
    });

    group('fromEntity', () {
      test('should create model from entity', () {
        final itemEntity = ItemCalculadora(
          id: 1,
          productoId: 1,
          producto: testProducto,
          cantidad: 2,
          subtotal: 21.00,
        );

        final result = ItemCalculadoraModel.fromEntity(itemEntity);

        expect(result.id, equals(itemEntity.id));
        expect(result.productoId, equals(itemEntity.productoId));
        expect(result.cantidad, equals(itemEntity.cantidad));
        expect(result.subtotal, equals(itemEntity.subtotal));
      });
    });

    group('copyWithProducto', () {
      test('should create new model with producto', () {
        const modelWithoutProducto = ItemCalculadoraModel(
          id: 1,
          productoId: 1,
          cantidad: 2,
          subtotal: 21.00,
        );

        final result = modelWithoutProducto.copyWithProducto(testProducto);

        expect(result.producto, equals(testProducto));
        expect(result.id, equals(modelWithoutProducto.id));
        expect(result.productoId, equals(modelWithoutProducto.productoId));
      });
    });

    group('validate', () {
      test('should return null for valid data', () {
        final result = testItemModel.validate();
        expect(result, isNull);
      });

      test('should return error for zero cantidad', () {
        final invalidModel = testItemModel.copyWith(cantidad: 0);
        final result = (invalidModel as ItemCalculadoraModel).validate();
        expect(result, equals('La cantidad debe ser mayor a 0'));
      });

      test('should return error for negative cantidad', () {
        final invalidModel = testItemModel.copyWith(cantidad: -1);
        final result = (invalidModel as ItemCalculadoraModel).validate();
        expect(result, equals('La cantidad debe ser mayor a 0'));
      });

      test('should return error for too high cantidad', () {
        final invalidModel = testItemModel.copyWith(cantidad: 10000);
        final result = (invalidModel as ItemCalculadoraModel).validate();
        expect(result, equals('La cantidad no puede exceder 9,999'));
      });

      test('should return error for negative subtotal', () {
        final invalidModel = testItemModel.copyWith(subtotal: -1);
        final result = (invalidModel as ItemCalculadoraModel).validate();
        expect(result, equals('El subtotal no puede ser negativo'));
      });

      test('should return error for too high subtotal', () {
        final invalidModel = testItemModel.copyWith(subtotal: 10000000);
        final result = (invalidModel as ItemCalculadoraModel).validate();
        expect(result, equals('El subtotal no puede exceder 9,999,999.99'));
      });
    });

    group('calculateSubtotal', () {
      test('should calculate subtotal from producto price and cantidad', () {
        final result = testItemModel.calculateSubtotal();
        expect(result, equals(21.00)); // 10.50 * 2
      });

      test('should return current subtotal when producto is null', () {
        const itemWithoutProducto = ItemCalculadoraModel(
          id: 1,
          productoId: 1,
          cantidad: 2,
          subtotal: 15.00,
        );

        final result = itemWithoutProducto.calculateSubtotal();
        expect(result, equals(15.00));
      });
    });
  });
}