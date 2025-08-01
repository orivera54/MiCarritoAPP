import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supermercado_comparador/features/calculadora/data/repositories/calculadora_repository_impl.dart';
import 'package:supermercado_comparador/features/calculadora/data/datasources/calculadora_local_data_source.dart';
import 'package:supermercado_comparador/features/calculadora/data/models/lista_compra_model.dart';
import 'package:supermercado_comparador/features/calculadora/data/models/item_calculadora_model.dart';
import 'package:supermercado_comparador/features/calculadora/domain/entities/lista_compra.dart';
import 'package:supermercado_comparador/features/calculadora/domain/entities/item_calculadora.dart';

@GenerateMocks([CalculadoraLocalDataSource])
import 'calculadora_repository_impl_test.mocks.dart';

void main() {
  late CalculadoraRepositoryImpl repository;
  late MockCalculadoraLocalDataSource mockLocalDataSource;

  setUp(() {
    mockLocalDataSource = MockCalculadoraLocalDataSource();
    repository = CalculadoraRepositoryImpl(mockLocalDataSource);
  });

  group('CalculadoraRepositoryImpl', () {
    group('createListaCompra', () {
      test('should create lista compra successfully', () async {
        // Arrange
        final listaCompra = ListaCompra(
          nombre: 'Test Lista',
          items: const [],
          total: 0.0,
          fechaCreacion: DateTime.now(),
        );
        
        final expectedModel = ListaCompraModel(
          id: 1,
          nombre: 'Test Lista',
          items: const [],
          total: 0.0,
          fechaCreacion: listaCompra.fechaCreacion,
        );

        when(mockLocalDataSource.createListaCompra(any))
            .thenAnswer((_) async => expectedModel);

        // Act
        final result = await repository.createListaCompra(listaCompra);

        // Assert
        expect(result.id, equals(1));
        expect(result.nombre, equals('Test Lista'));
        verify(mockLocalDataSource.createListaCompra(any)).called(1);
      });
    });

    group('getAllListasCompra', () {
      test('should return all listas compra', () async {
        // Arrange
        final expectedModels = [
          ListaCompraModel(
            id: 1,
            nombre: 'Lista 1',
            items: const [],
            total: 10.0,
            fechaCreacion: DateTime.now(),
          ),
          ListaCompraModel(
            id: 2,
            nombre: 'Lista 2',
            items: const [],
            total: 20.0,
            fechaCreacion: DateTime.now(),
          ),
        ];

        when(mockLocalDataSource.getAllListasCompra())
            .thenAnswer((_) async => expectedModels);

        // Act
        final result = await repository.getAllListasCompra();

        // Assert
        expect(result.length, equals(2));
        expect(result[0].nombre, equals('Lista 1'));
        expect(result[1].nombre, equals('Lista 2'));
        verify(mockLocalDataSource.getAllListasCompra()).called(1);
      });
    });

    group('getListaCompraById', () {
      test('should return lista compra when found', () async {
        // Arrange
        const id = 1;
        final expectedModel = ListaCompraModel(
          id: id,
          nombre: 'Test Lista',
          items: const [],
          total: 15.0,
          fechaCreacion: DateTime.now(),
        );

        when(mockLocalDataSource.getListaCompraById(id))
            .thenAnswer((_) async => expectedModel);

        // Act
        final result = await repository.getListaCompraById(id);

        // Assert
        expect(result, isNotNull);
        expect(result!.id, equals(id));
        expect(result.nombre, equals('Test Lista'));
        verify(mockLocalDataSource.getListaCompraById(id)).called(1);
      });

      test('should return null when lista not found', () async {
        // Arrange
        const id = 999;
        when(mockLocalDataSource.getListaCompraById(id))
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getListaCompraById(id);

        // Assert
        expect(result, isNull);
        verify(mockLocalDataSource.getListaCompraById(id)).called(1);
      });
    });

    group('updateListaCompra', () {
      test('should update lista compra successfully', () async {
        // Arrange
        final listaCompra = ListaCompra(
          id: 1,
          nombre: 'Updated Lista',
          items: const [],
          total: 25.0,
          fechaCreacion: DateTime.now(),
        );
        
        final expectedModel = ListaCompraModel.fromEntity(listaCompra);

        when(mockLocalDataSource.updateListaCompra(any))
            .thenAnswer((_) async => expectedModel);

        // Act
        final result = await repository.updateListaCompra(listaCompra);

        // Assert
        expect(result.nombre, equals('Updated Lista'));
        expect(result.total, equals(25.0));
        verify(mockLocalDataSource.updateListaCompra(any)).called(1);
      });
    });

    group('deleteListaCompra', () {
      test('should delete lista compra successfully', () async {
        // Arrange
        const id = 1;
        when(mockLocalDataSource.deleteListaCompra(id))
            .thenAnswer((_) async {});

        // Act
        await repository.deleteListaCompra(id);

        // Assert
        verify(mockLocalDataSource.deleteListaCompra(id)).called(1);
      });
    });

    group('addItemToLista', () {
      test('should add item to lista successfully', () async {
        // Arrange
        const listaId = 1;
        const item = ItemCalculadora(
          productoId: 1,
          cantidad: 2,
          subtotal: 20.0,
        );
        
        const expectedModel = ItemCalculadoraModel(
          id: 1,
          productoId: 1,
          cantidad: 2,
          subtotal: 20.0,
        );

        when(mockLocalDataSource.addItemToLista(listaId, any))
            .thenAnswer((_) async => expectedModel);

        // Act
        final result = await repository.addItemToLista(listaId, item);

        // Assert
        expect(result.id, equals(1));
        expect(result.productoId, equals(1));
        expect(result.cantidad, equals(2));
        verify(mockLocalDataSource.addItemToLista(listaId, any)).called(1);
      });
    });

    group('updateItemInLista', () {
      test('should update item successfully', () async {
        // Arrange
        const item = ItemCalculadora(
          id: 1,
          productoId: 1,
          cantidad: 3,
          subtotal: 30.0,
        );
        
        final expectedModel = ItemCalculadoraModel.fromEntity(item);

        when(mockLocalDataSource.updateItemInLista(any))
            .thenAnswer((_) async => expectedModel);

        // Act
        final result = await repository.updateItemInLista(item);

        // Assert
        expect(result.cantidad, equals(3));
        expect(result.subtotal, equals(30.0));
        verify(mockLocalDataSource.updateItemInLista(any)).called(1);
      });
    });

    group('removeItemFromLista', () {
      test('should remove item successfully', () async {
        // Arrange
        const itemId = 1;
        when(mockLocalDataSource.removeItemFromLista(itemId))
            .thenAnswer((_) async {});

        // Act
        await repository.removeItemFromLista(itemId);

        // Assert
        verify(mockLocalDataSource.removeItemFromLista(itemId)).called(1);
      });
    });

    group('getItemsForLista', () {
      test('should return items for lista', () async {
        // Arrange
        const listaId = 1;
        final expectedModels = [
          const ItemCalculadoraModel(
            id: 1,
            productoId: 1,
            cantidad: 2,
            subtotal: 20.0,
          ),
          const ItemCalculadoraModel(
            id: 2,
            productoId: 2,
            cantidad: 1,
            subtotal: 15.0,
          ),
        ];

        when(mockLocalDataSource.getItemsForLista(listaId))
            .thenAnswer((_) async => expectedModels);

        // Act
        final result = await repository.getItemsForLista(listaId);

        // Assert
        expect(result.length, equals(2));
        expect(result[0].cantidad, equals(2));
        expect(result[1].cantidad, equals(1));
        verify(mockLocalDataSource.getItemsForLista(listaId)).called(1);
      });
    });

    group('getCurrentActiveLista', () {
      test('should return null initially', () async {
        // Act
        final result = await repository.getCurrentActiveLista();

        // Assert
        expect(result, isNull);
      });

      test('should return current active lista after setting', () async {
        // Arrange
        final listaCompra = ListaCompra(
          nombre: 'Active Lista',
          items: const [],
          total: 10.0,
          fechaCreacion: DateTime.now(),
        );
        
        final expectedModel = ListaCompraModel(
          id: 1,
          nombre: 'Active Lista',
          items: const [],
          total: 10.0,
          fechaCreacion: listaCompra.fechaCreacion,
        );

        when(mockLocalDataSource.createListaCompra(any))
            .thenAnswer((_) async => expectedModel);

        // Act
        await repository.saveCurrentActiveLista(listaCompra);
        final result = await repository.getCurrentActiveLista();

        // Assert
        expect(result, isNotNull);
        expect(result!.nombre, equals('Active Lista'));
      });
    });

    group('saveCurrentActiveLista', () {
      test('should create new lista when id is null', () async {
        // Arrange
        final listaCompra = ListaCompra(
          nombre: 'New Lista',
          items: const [],
          total: 10.0,
          fechaCreacion: DateTime.now(),
        );
        
        final expectedModel = ListaCompraModel(
          id: 1,
          nombre: 'New Lista',
          items: const [],
          total: 10.0,
          fechaCreacion: listaCompra.fechaCreacion,
        );

        when(mockLocalDataSource.createListaCompra(any))
            .thenAnswer((_) async => expectedModel);

        // Act
        final result = await repository.saveCurrentActiveLista(listaCompra);

        // Assert
        expect(result.id, equals(1));
        verify(mockLocalDataSource.createListaCompra(any)).called(1);
      });

      test('should update existing lista when id is not null', () async {
        // Arrange
        final listaCompra = ListaCompra(
          id: 1,
          nombre: 'Existing Lista',
          items: const [],
          total: 15.0,
          fechaCreacion: DateTime.now(),
        );
        
        final expectedModel = ListaCompraModel.fromEntity(listaCompra);

        when(mockLocalDataSource.updateListaCompra(any))
            .thenAnswer((_) async => expectedModel);

        // Act
        final result = await repository.saveCurrentActiveLista(listaCompra);

        // Assert
        expect(result.id, equals(1));
        verify(mockLocalDataSource.updateListaCompra(any)).called(1);
      });
    });

    group('clearCurrentActiveLista', () {
      test('should clear current active lista', () async {
        // Arrange
        final listaCompra = ListaCompra(
          nombre: 'Active Lista',
          items: const [],
          total: 10.0,
          fechaCreacion: DateTime.now(),
        );
        
        final expectedModel = ListaCompraModel(
          id: 1,
          nombre: 'Active Lista',
          items: const [],
          total: 10.0,
          fechaCreacion: listaCompra.fechaCreacion,
        );

        when(mockLocalDataSource.createListaCompra(any))
            .thenAnswer((_) async => expectedModel);
            
        await repository.saveCurrentActiveLista(listaCompra);

        // Act
        await repository.clearCurrentActiveLista();
        final result = await repository.getCurrentActiveLista();

        // Assert
        expect(result, isNull);
      });
    });
  });
}