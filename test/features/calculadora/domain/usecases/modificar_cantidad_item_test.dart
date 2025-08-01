import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:supermercado_comparador/features/calculadora/domain/entities/item_calculadora.dart';
import 'package:supermercado_comparador/features/calculadora/domain/entities/lista_compra.dart';
import 'package:supermercado_comparador/features/calculadora/domain/repositories/calculadora_repository.dart';
import 'package:supermercado_comparador/features/calculadora/domain/usecases/modificar_cantidad_item.dart';
import 'package:supermercado_comparador/features/productos/domain/entities/producto.dart';

import 'modificar_cantidad_item_test.mocks.dart';

@GenerateMocks([CalculadoraRepository])
void main() {
  late ModificarCantidadItem usecase;
  late MockCalculadoraRepository mockRepository;

  setUp(() {
    mockRepository = MockCalculadoraRepository();
    usecase = ModificarCantidadItem(mockRepository);
  });

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

  group('ModificarCantidadItem', () {
    test('should modify quantity of existing item', () async {
      // arrange
      final existingItem = ItemCalculadora(
        productoId: 1,
        producto: testProducto,
        cantidad: 2,
        subtotal: 20.0,
      );

      final currentLista = ListaCompra(
        items: [existingItem],
        total: 20.0,
        fechaCreacion: DateTime.now(),
      );

      when(mockRepository.getCurrentActiveLista())
          .thenAnswer((_) async => currentLista);

      final expectedLista = ListaCompra(
        items: [
          ItemCalculadora(
            productoId: 1,
            producto: testProducto,
            cantidad: 5,
            subtotal: 50.0,
          ),
        ],
        total: 50.0,
        fechaCreacion: DateTime.now(),
      );

      when(mockRepository.saveCurrentActiveLista(any))
          .thenAnswer((_) async => expectedLista);

      // act
      final result = await usecase(productoId: 1, nuevaCantidad: 5);

      // assert
      expect(result.items.length, 1);
      expect(result.items.first.cantidad, 5);
      expect(result.items.first.subtotal, 50.0);
      expect(result.total, 50.0);
      verify(mockRepository.getCurrentActiveLista()).called(1);
      verify(mockRepository.saveCurrentActiveLista(any)).called(1);
    });

    test('should remove item when quantity is 0', () async {
      // arrange
      final existingItem = ItemCalculadora(
        productoId: 1,
        producto: testProducto,
        cantidad: 2,
        subtotal: 20.0,
      );

      final currentLista = ListaCompra(
        items: [existingItem],
        total: 20.0,
        fechaCreacion: DateTime.now(),
      );

      when(mockRepository.getCurrentActiveLista())
          .thenAnswer((_) async => currentLista);

      final expectedLista = ListaCompra(
        items: const [],
        total: 0.0,
        fechaCreacion: DateTime.now(),
      );

      when(mockRepository.saveCurrentActiveLista(any))
          .thenAnswer((_) async => expectedLista);

      // act
      final result = await usecase(productoId: 1, nuevaCantidad: 0);

      // assert
      expect(result.items.length, 0);
      expect(result.total, 0.0);
      verify(mockRepository.getCurrentActiveLista()).called(1);
      verify(mockRepository.saveCurrentActiveLista(any)).called(1);
    });

    test('should throw error when quantity is negative', () async {
      // act & assert
      expect(
        () => usecase(productoId: 1, nuevaCantidad: -1),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should throw error when no current lista exists', () async {
      // arrange
      when(mockRepository.getCurrentActiveLista()).thenAnswer((_) async => null);

      // act & assert
      expect(
        () => usecase(productoId: 1, nuevaCantidad: 5),
        throwsA(isA<StateError>()),
      );
    });

    test('should throw error when product not found in lista', () async {
      // arrange
      final currentLista = ListaCompra(
        items: const [],
        total: 0.0,
        fechaCreacion: DateTime.now(),
      );

      when(mockRepository.getCurrentActiveLista())
          .thenAnswer((_) async => currentLista);

      // act & assert
      expect(
        () => usecase(productoId: 1, nuevaCantidad: 5),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should handle multiple items correctly', () async {
      // arrange
      final item1 = ItemCalculadora(
        productoId: 1,
        producto: testProducto,
        cantidad: 2,
        subtotal: 20.0,
      );

      final item2 = ItemCalculadora(
        productoId: 2,
        producto: Producto(
          id: 2,
          nombre: 'Product 2',
          precio: 5.0,
          peso: 1.0,
          tamano: 'Small',
          codigoQR: 'QR456',
          categoriaId: 1,
          almacenId: 1,
          fechaCreacion: DateTime.now(),
          fechaActualizacion: DateTime.now(),
        ),
        cantidad: 3,
        subtotal: 15.0,
      );

      final currentLista = ListaCompra(
        items: [item1, item2],
        total: 35.0,
        fechaCreacion: DateTime.now(),
      );

      when(mockRepository.getCurrentActiveLista())
          .thenAnswer((_) async => currentLista);

      final expectedLista = ListaCompra(
        items: [
          ItemCalculadora(
            productoId: 1,
            producto: testProducto,
            cantidad: 4,
            subtotal: 40.0,
          ),
          item2,
        ],
        total: 55.0,
        fechaCreacion: DateTime.now(),
      );

      when(mockRepository.saveCurrentActiveLista(any))
          .thenAnswer((_) async => expectedLista);

      // act
      final result = await usecase(productoId: 1, nuevaCantidad: 4);

      // assert
      expect(result.items.length, 2);
      expect(result.items.first.cantidad, 4);
      expect(result.items.first.subtotal, 40.0);
      expect(result.total, 55.0);
      verify(mockRepository.getCurrentActiveLista()).called(1);
      verify(mockRepository.saveCurrentActiveLista(any)).called(1);
    });
  });
}