import 'package:flutter_test/flutter_test.dart';
import 'package:supermercado_comparador/features/calculadora/data/models/lista_compra_model.dart';
import 'package:supermercado_comparador/features/calculadora/domain/entities/lista_compra.dart';
import 'package:supermercado_comparador/features/calculadora/domain/entities/item_calculadora.dart';
import 'package:supermercado_comparador/features/productos/domain/entities/producto.dart';

void main() {
  group('ListaCompraModel', () {
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

    final testItems = [
      ItemCalculadora(
        id: 1,
        productoId: 1,
        producto: testProducto,
        cantidad: 2,
        subtotal: 21.00,
      ),
      ItemCalculadora(
        id: 2,
        productoId: 1,
        producto: testProducto,
        cantidad: 1,
        subtotal: 10.50,
      ),
    ];

    final testListaModel = ListaCompraModel(
      id: 1,
      nombre: 'Test Lista',
      items: testItems,
      total: 31.50,
      fechaCreacion: testDate,
    );

    test('should be a subclass of ListaCompra entity', () {
      expect(testListaModel, isA<ListaCompra>());
    });

    group('fromJson', () {
      test('should return a valid model when JSON is valid', () {
        final Map<String, dynamic> jsonMap = {
          'id': 1,
          'nombre': 'Test Lista',
          'total': 31.50,
          'fecha_creacion': testDate.toIso8601String(),
        };

        final result = ListaCompraModel.fromJson(jsonMap);

        expect(result.id, equals(1));
        expect(result.nombre, equals('Test Lista'));
        expect(result.total, equals(31.50));
        expect(result.items, isEmpty); // Items loaded separately
      });

      test('should handle null optional fields', () {
        final Map<String, dynamic> jsonMap = {
          'id': 1,
          'nombre': null,
          'total': 31.50,
          'fecha_creacion': testDate.toIso8601String(),
        };

        final result = ListaCompraModel.fromJson(jsonMap);

        expect(result.nombre, isNull);
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        final result = testListaModel.toJson();

        final expectedMap = {
          'id': 1,
          'nombre': 'Test Lista',
          'total': 31.50,
          'fecha_creacion': testDate.toIso8601String(),
        };

        expect(result, equals(expectedMap));
      });
    });

    group('fromEntity', () {
      test('should create model from entity', () {
        final listaEntity = ListaCompra(
          id: 1,
          nombre: 'Test Lista',
          items: testItems,
          total: 31.50,
          fechaCreacion: testDate,
        );

        final result = ListaCompraModel.fromEntity(listaEntity);

        expect(result.id, equals(listaEntity.id));
        expect(result.nombre, equals(listaEntity.nombre));
        expect(result.items, equals(listaEntity.items));
        expect(result.total, equals(listaEntity.total));
      });
    });

    group('copyWithItems', () {
      test('should create new model with items and recalculated total', () {
        final modelWithoutItems = ListaCompraModel(
          id: 1,
          nombre: 'Test Lista',
          items: const [],
          total: 0,
          fechaCreacion: testDate,
        );

        final result = modelWithoutItems.copyWithItems(testItems);

        expect(result.items, equals(testItems));
        expect(result.total, equals(31.50)); // Recalculated from items
      });
    });

    group('validate', () {
      test('should return null for valid data', () {
        final result = testListaModel.validate();
        expect(result, isNull);
      });

      test('should return error for empty nombre when provided', () {
        final invalidModel = testListaModel.copyWith(nombre: '');
        final result = (invalidModel as ListaCompraModel).validate();
        expect(result, equals('El nombre de la lista no puede estar vacío si se proporciona'));
      });

      test('should return error for long nombre', () {
        final invalidModel = testListaModel.copyWith(nombre: 'A' * 101);
        final result = (invalidModel as ListaCompraModel).validate();
        expect(result, equals('El nombre de la lista no puede exceder 100 caracteres'));
      });

      test('should return error for negative total', () {
        final invalidModel = testListaModel.copyWith(total: -1);
        final result = (invalidModel as ListaCompraModel).validate();
        expect(result, equals('El total no puede ser negativo'));
      });

      test('should return error for empty items', () {
        final invalidModel = testListaModel.copyWith(items: []);
        final result = (invalidModel as ListaCompraModel).validate();
        expect(result, equals('La lista debe tener al menos un item'));
      });

      test('should allow null nombre', () {
        final validModel = testListaModel.copyWith(nombre: null);
        final result = (validModel as ListaCompraModel).validate();
        expect(result, isNull);
      });
    });

    group('calculateTotal', () {
      test('should calculate total from items', () {
        final result = testListaModel.calculateTotal();
        expect(result, equals(31.50)); // 21.00 + 10.50
      });

      test('should return 0 for empty items', () {
        final emptyListaModel = testListaModel.copyWith(items: []);
        final result = (emptyListaModel as ListaCompraModel).calculateTotal();
        expect(result, equals(0.0));
      });
    });
  });
}