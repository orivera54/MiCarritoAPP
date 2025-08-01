import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite/sqflite.dart' hide DatabaseException;
import 'package:supermercado_comparador/core/database/database_helper.dart';
import 'package:supermercado_comparador/core/errors/exceptions.dart';
import 'package:supermercado_comparador/features/calculadora/data/datasources/calculadora_local_data_source.dart';
import 'package:supermercado_comparador/features/calculadora/data/models/lista_compra_model.dart';
import 'package:supermercado_comparador/features/calculadora/data/models/item_calculadora_model.dart';

import 'calculadora_local_data_source_test.mocks.dart';

@GenerateMocks([DatabaseHelper, Database])
void main() {
  late CalculadoraLocalDataSourceImpl dataSource;
  late MockDatabaseHelper mockDatabaseHelper;
  late MockDatabase mockDatabase;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();
    dataSource = CalculadoraLocalDataSourceImpl(mockDatabaseHelper);
  });

  final testDate = DateTime(2024, 1, 1);
  final testListaCompraJson = {
    'id': 1,
    'nombre': 'Test Lista',
    'total': 10.0,
    'fecha_creacion': testDate.toIso8601String(),
  };

  group('CalculadoraLocalDataSource', () {
    group('createListaCompra', () {
      test('should create lista compra successfully', () async {
        // Arrange
        final listaCompra = ListaCompraModel(
          nombre: 'Test Lista',
          items: const [],
          total: 10.0,
          fechaCreacion: testDate,
        );

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.insert('listas_compra', any))
            .thenAnswer((_) async => 1);

        // Act
        final result = await dataSource.createListaCompra(listaCompra);

        // Assert
        expect(result.id, equals(1));
        expect(result.nombre, equals('Test Lista'));
        expect(result.total, equals(10.0));
        verify(mockDatabase.insert('listas_compra', any)).called(1);
      });

      test('should throw ValidationException for invalid data', () async {
        // Arrange
        final listaCompra = ListaCompraModel(
          nombre: 'A' * 101, // Name too long should be invalid
          items: const [],
          total: -1.0, // Negative total should be invalid
          fechaCreacion: testDate,
        );

        // Act & Assert
        expect(
          () => dataSource.createListaCompra(listaCompra),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('getAllListasCompra', () {
      test('should return all listas compra', () async {
        // Arrange
        final listasJson = [
          {
            'id': 1,
            'nombre': 'Lista 1',
            'total': 10.0,
            'fecha_creacion': testDate.toIso8601String(),
          },
          {
            'id': 2,
            'nombre': 'Lista 2',
            'total': 20.0,
            'fecha_creacion': testDate.toIso8601String(),
          },
        ];

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query('listas_compra',
                orderBy: 'fecha_creacion DESC'))
            .thenAnswer((_) async => listasJson);
        when(mockDatabase.rawQuery(any, any)).thenAnswer((_) async => []);

        // Act
        final result = await dataSource.getAllListasCompra();

        // Assert
        expect(result.length, equals(2));
        expect(result[0].nombre, equals('Lista 1'));
        expect(result[1].nombre, equals('Lista 2'));
        verify(mockDatabase.query('listas_compra',
                orderBy: 'fecha_creacion DESC'))
            .called(1);
      });

      test('should return empty list when no listas exist', () async {
        // Arrange
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query('listas_compra',
                orderBy: 'fecha_creacion DESC'))
            .thenAnswer((_) async => []);

        // Act
        final result = await dataSource.getAllListasCompra();

        // Assert
        expect(result, isEmpty);
        verify(mockDatabase.query('listas_compra',
                orderBy: 'fecha_creacion DESC'))
            .called(1);
      });
    });

    group('getListaCompraById', () {
      test('should return lista compra when found', () async {
        // Arrange
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query('listas_compra',
            where: 'id = ?',
            whereArgs: [1])).thenAnswer((_) async => [testListaCompraJson]);
        when(mockDatabase.rawQuery(any, any)).thenAnswer((_) async => []);

        // Act
        final result = await dataSource.getListaCompraById(1);

        // Assert
        expect(result, isNotNull);
        expect(result!.id, equals(1));
        expect(result.nombre, equals('Test Lista'));
        verify(mockDatabase
            .query('listas_compra', where: 'id = ?', whereArgs: [1])).called(1);
      });

      test('should return null when lista not found', () async {
        // Arrange
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query('listas_compra',
            where: 'id = ?', whereArgs: [999])).thenAnswer((_) async => []);

        // Act
        final result = await dataSource.getListaCompraById(999);

        // Assert
        expect(result, isNull);
        verify(mockDatabase.query('listas_compra',
            where: 'id = ?', whereArgs: [999])).called(1);
      });
    });

    group('updateListaCompra', () {
      test('should update lista compra successfully', () async {
        // Arrange
        final updated = ListaCompraModel(
          id: 1,
          nombre: 'Updated Name',
          items: const [],
          total: 20.0,
          fechaCreacion: testDate,
        );

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.update('listas_compra', any,
            where: 'id = ?', whereArgs: [1])).thenAnswer((_) async => 1);

        // Act
        final result = await dataSource.updateListaCompra(updated);

        // Assert
        expect(result.nombre, equals('Updated Name'));
        expect(result.total, equals(20.0));
        verify(mockDatabase.update('listas_compra', any,
            where: 'id = ?', whereArgs: [1])).called(1);
      });

      test('should throw ValidationException when id is null', () async {
        // Arrange
        final listaCompra = ListaCompraModel(
          nombre: 'Test Lista',
          items: const [],
          total: 10.0,
          fechaCreacion: testDate,
        );

        // Act & Assert
        expect(
          () => dataSource.updateListaCompra(listaCompra),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw NotFoundException when lista not found', () async {
        // Arrange
        final listaCompra = ListaCompraModel(
          id: 999,
          nombre: 'Test Lista',
          items: const [],
          total: 10.0,
          fechaCreacion: testDate,
        );

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.update('listas_compra', any,
            where: 'id = ?', whereArgs: [999])).thenAnswer((_) async => 0);

        // Act & Assert
        expect(
          () => dataSource.updateListaCompra(listaCompra),
          throwsA(isA<NotFoundException>()),
        );
      });
    });

    group('deleteListaCompra', () {
      test('should delete lista compra successfully', () async {
        // Arrange
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.delete('items_calculadora',
            where: 'lista_compra_id = ?',
            whereArgs: [1])).thenAnswer((_) async => 0);
        when(mockDatabase.delete('listas_compra',
            where: 'id = ?', whereArgs: [1])).thenAnswer((_) async => 1);

        // Act
        await dataSource.deleteListaCompra(1);

        // Assert
        verify(mockDatabase.delete('items_calculadora',
            where: 'lista_compra_id = ?', whereArgs: [1])).called(1);
        verify(mockDatabase.delete('listas_compra',
            where: 'id = ?', whereArgs: [1])).called(1);
      });

      test('should throw NotFoundException when lista not found', () async {
        // Arrange
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.delete('items_calculadora',
            where: 'lista_compra_id = ?',
            whereArgs: [999])).thenAnswer((_) async => 0);
        when(mockDatabase.delete('listas_compra',
            where: 'id = ?', whereArgs: [999])).thenAnswer((_) async => 0);

        // Act & Assert
        expect(
          () => dataSource.deleteListaCompra(999),
          throwsA(isA<NotFoundException>()),
        );
      });
    });

    group('addItemToLista', () {
      test('should add item to lista successfully', () async {
        // Arrange
        const item = ItemCalculadoraModel(
          productoId: 1,
          cantidad: 2,
          subtotal: 20.0,
        );

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query('listas_compra',
            where: 'id = ?',
            whereArgs: [1])).thenAnswer((_) async => [testListaCompraJson]);
        when(mockDatabase.insert('items_calculadora', any))
            .thenAnswer((_) async => 1);
        when(mockDatabase.rawQuery(any, any)).thenAnswer((_) async => [
              {'total': 20.0}
            ]);
        when(mockDatabase.update('listas_compra', any,
            where: 'id = ?', whereArgs: [1])).thenAnswer((_) async => 1);

        // Act
        final result = await dataSource.addItemToLista(1, item);

        // Assert
        expect(result.id, equals(1));
        expect(result.productoId, equals(1));
        expect(result.cantidad, equals(2));
        expect(result.subtotal, equals(20.0));
        verify(mockDatabase.insert('items_calculadora', any)).called(1);
      });

      test('should throw ValidationException for invalid item', () async {
        // Arrange
        const item = ItemCalculadoraModel(
          productoId: 1,
          cantidad: 0, // Invalid quantity
          subtotal: 20.0,
        );

        // Act & Assert
        expect(
          () => dataSource.addItemToLista(1, item),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw NotFoundException when lista not found', () async {
        // Arrange
        const item = ItemCalculadoraModel(
          productoId: 1,
          cantidad: 2,
          subtotal: 20.0,
        );

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query('listas_compra',
            where: 'id = ?', whereArgs: [999])).thenAnswer((_) async => []);

        // Act & Assert
        expect(
          () => dataSource.addItemToLista(999, item),
          throwsA(isA<NotFoundException>()),
        );
      });
    });

    group('getItemsForLista', () {
      test('should return items for lista', () async {
        // Arrange
        final itemsJson = [
          {
            'id': 1,
            'producto_id': 1,
            'cantidad': 2,
            'subtotal': 20.0,
            'producto_nombre': 'Test Producto',
            'producto_precio': 10.0,
            'producto_peso': 1.0,
            'producto_tamano': 'Medium',
            'producto_codigo_qr': 'TEST123',
            'producto_categoria_id': 1,
            'producto_almacen_id': 1,
            'producto_fecha_creacion': testDate.toIso8601String(),
            'producto_fecha_actualizacion': testDate.toIso8601String(),
          },
          {
            'id': 2,
            'producto_id': 1,
            'cantidad': 1,
            'subtotal': 10.0,
            'producto_nombre': 'Test Producto',
            'producto_precio': 10.0,
            'producto_peso': 1.0,
            'producto_tamano': 'Medium',
            'producto_codigo_qr': 'TEST123',
            'producto_categoria_id': 1,
            'producto_almacen_id': 1,
            'producto_fecha_creacion': testDate.toIso8601String(),
            'producto_fecha_actualizacion': testDate.toIso8601String(),
          },
        ];

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery(any, [1]))
            .thenAnswer((_) async => itemsJson);

        // Act
        final result = await dataSource.getItemsForLista(1);

        // Assert
        expect(result.length, equals(2));
        expect(result.any((i) => i.cantidad == 2), isTrue);
        expect(result.any((i) => i.cantidad == 1), isTrue);
        verify(mockDatabase.rawQuery(any, [1])).called(1);
      });

      test('should return empty list when no items exist', () async {
        // Arrange
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery(any, [1])).thenAnswer((_) async => []);

        // Act
        final result = await dataSource.getItemsForLista(1);

        // Assert
        expect(result, isEmpty);
        verify(mockDatabase.rawQuery(any, [1])).called(1);
      });
    });

    group('updateItemInLista', () {
      test('should update item successfully', () async {
        // Arrange
        const updatedItem = ItemCalculadoraModel(
          id: 1,
          productoId: 1,
          cantidad: 3,
          subtotal: 30.0,
        );

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase
                .query('items_calculadora', where: 'id = ?', whereArgs: [1]))
            .thenAnswer((_) async => [
                  {'lista_compra_id': 1}
                ]);
        when(mockDatabase.update('items_calculadora', any,
            where: 'id = ?', whereArgs: [1])).thenAnswer((_) async => 1);
        when(mockDatabase.rawQuery(any, any)).thenAnswer((_) async => [
              {'total': 30.0}
            ]);
        when(mockDatabase.update('listas_compra', any,
            where: 'id = ?', whereArgs: [1])).thenAnswer((_) async => 1);

        // Act
        final result = await dataSource.updateItemInLista(updatedItem);

        // Assert
        expect(result.cantidad, equals(3));
        expect(result.subtotal, equals(30.0));
        verify(mockDatabase.update('items_calculadora', any,
            where: 'id = ?', whereArgs: [1])).called(1);
      });

      test('should throw ValidationException when id is null', () async {
        // Arrange
        const item = ItemCalculadoraModel(
          productoId: 1,
          cantidad: 2,
          subtotal: 20.0,
        );

        // Act & Assert
        expect(
          () => dataSource.updateItemInLista(item),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw NotFoundException when item not found', () async {
        // Arrange
        const item = ItemCalculadoraModel(
          id: 999,
          productoId: 1,
          cantidad: 2,
          subtotal: 20.0,
        );

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query('items_calculadora',
            where: 'id = ?', whereArgs: [999])).thenAnswer((_) async => []);

        // Act & Assert
        expect(
          () => dataSource.updateItemInLista(item),
          throwsA(isA<NotFoundException>()),
        );
      });
    });

    group('removeItemFromLista', () {
      test('should remove item successfully', () async {
        // Arrange
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase
                .query('items_calculadora', where: 'id = ?', whereArgs: [1]))
            .thenAnswer((_) async => [
                  {'lista_compra_id': 1}
                ]);
        when(mockDatabase.delete('items_calculadora',
            where: 'id = ?', whereArgs: [1])).thenAnswer((_) async => 1);
        when(mockDatabase.rawQuery(any, any)).thenAnswer((_) async => [
              {'total': 0.0}
            ]);
        when(mockDatabase.update('listas_compra', any,
            where: 'id = ?', whereArgs: [1])).thenAnswer((_) async => 1);

        // Act
        await dataSource.removeItemFromLista(1);

        // Assert
        verify(mockDatabase.delete('items_calculadora',
            where: 'id = ?', whereArgs: [1])).called(1);
      });

      test('should throw NotFoundException when item not found', () async {
        // Arrange
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query('items_calculadora',
            where: 'id = ?', whereArgs: [999])).thenAnswer((_) async => []);

        // Act & Assert
        expect(
          () => dataSource.removeItemFromLista(999),
          throwsA(isA<NotFoundException>()),
        );
      });
    });
  });
}
