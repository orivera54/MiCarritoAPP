import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:supermercado_comparador/features/calculadora/domain/entities/item_calculadora.dart';
import 'package:supermercado_comparador/features/calculadora/domain/entities/lista_compra.dart';
import 'package:supermercado_comparador/features/calculadora/domain/repositories/calculadora_repository.dart';
import 'package:supermercado_comparador/features/calculadora/domain/usecases/eliminar_item_calculadora.dart';
import 'package:supermercado_comparador/features/productos/domain/entities/producto.dart';

import 'eliminar_item_calculadora_test.mocks.dart';

@GenerateMocks([CalculadoraRepository])
void main() {
  late EliminarItemCalculadora usecase;
  late MockCalculadoraRepository mockRepository;

  setUp(() {
    mockRepository = MockCalculadoraRepository();
    usecase = EliminarItemCalculadora(mockRepository);
  });

  final testProducto1 = Producto(
    id: 1,
    nombre: 'Test Product 1',
    precio: 10.0,
    peso: 1.0,
    tamano: 'Medium',
    codigoQR: 'QR123',
    categoriaId: 1,
    almacenId: 1,
    fechaCreacion: DateTime.now(),
    fechaActualizacion: DateTime.now(),
  );

  final testProducto2 = Producto(
    id: 2,
    nombre: 'Test Product 2',
    precio: 5.0,
    peso: 1.0,
    tamano: 'Small',
    codigoQR: 'QR456',
    categoriaId: 1,
    almacenId: 1,
    fechaCreacion: DateTime.now(),
    fechaActualizacion: DateTime.now(),
  );

  group('EliminarItemCalculadora', () {
    test('should remove item from lista', () async {
      // arrange
      final item1 = ItemCalculadora(
        productoId: 1,
        producto: testProducto1,
        cantidad: 2,
        subtotal: 20.0,
      );

      final item2 = ItemCalculadora(
        productoId: 2,
        producto: testProducto2,
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
        items: [item2],
        total: 15.0,
        fechaCreacion: DateTime.now(),
      );

      when(mockRepository.saveCurrentActiveLista(any))
          .thenAnswer((_) async => expectedLista);

      // act
      final result = await usecase(productoId: 1);

      // assert
      expect(result.items.length, 1);
      expect(result.items.first.productoId, 2);
      expect(result.total, 15.0);
      verify(mockRepository.getCurrentActiveLista()).called(1);
      verify(mockRepository.saveCurrentActiveLista(any)).called(1);
    });

    test('should remove all items when only one exists', () async {
      // arrange
      final item1 = ItemCalculadora(
        productoId: 1,
        producto: testProducto1,
        cantidad: 2,
        subtotal: 20.0,
      );

      final currentLista = ListaCompra(
        items: [item1],
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
      final result = await usecase(productoId: 1);

      // assert
      expect(result.items.length, 0);
      expect(result.total, 0.0);
      verify(mockRepository.getCurrentActiveLista()).called(1);
      verify(mockRepository.saveCurrentActiveLista(any)).called(1);
    });

    test('should throw error when no current lista exists', () async {
      // arrange
      when(mockRepository.getCurrentActiveLista()).thenAnswer((_) async => null);

      // act & assert
      expect(
        () => usecase(productoId: 1),
        throwsA(isA<StateError>()),
      );
    });

    test('should handle removing non-existent product gracefully', () async {
      // arrange
      final item1 = ItemCalculadora(
        productoId: 1,
        producto: testProducto1,
        cantidad: 2,
        subtotal: 20.0,
      );

      final currentLista = ListaCompra(
        items: [item1],
        total: 20.0,
        fechaCreacion: DateTime.now(),
      );

      when(mockRepository.getCurrentActiveLista())
          .thenAnswer((_) async => currentLista);

      final expectedLista = ListaCompra(
        items: [item1],
        total: 20.0,
        fechaCreacion: DateTime.now(),
      );

      when(mockRepository.saveCurrentActiveLista(any))
          .thenAnswer((_) async => expectedLista);

      // act
      final result = await usecase(productoId: 999); // Non-existent product

      // assert
      expect(result.items.length, 1);
      expect(result.items.first.productoId, 1);
      expect(result.total, 20.0);
      verify(mockRepository.getCurrentActiveLista()).called(1);
      verify(mockRepository.saveCurrentActiveLista(any)).called(1);
    });

    test('should recalculate total correctly after removal', () async {
      // arrange
      final item1 = ItemCalculadora(
        productoId: 1,
        producto: testProducto1,
        cantidad: 2,
        subtotal: 20.0,
      );

      final item2 = ItemCalculadora(
        productoId: 2,
        producto: testProducto2,
        cantidad: 4,
        subtotal: 20.0,
      );

      final item3 = ItemCalculadora(
        productoId: 3,
        producto: Producto(
          id: 3,
          nombre: 'Test Product 3',
          precio: 15.0,
          peso: 1.0,
          tamano: 'Large',
          codigoQR: 'QR789',
          categoriaId: 1,
          almacenId: 1,
          fechaCreacion: DateTime.now(),
          fechaActualizacion: DateTime.now(),
        ),
        cantidad: 1,
        subtotal: 15.0,
      );

      final currentLista = ListaCompra(
        items: [item1, item2, item3],
        total: 55.0,
        fechaCreacion: DateTime.now(),
      );

      when(mockRepository.getCurrentActiveLista())
          .thenAnswer((_) async => currentLista);

      final expectedLista = ListaCompra(
        items: [item1, item3],
        total: 35.0,
        fechaCreacion: DateTime.now(),
      );

      when(mockRepository.saveCurrentActiveLista(any))
          .thenAnswer((_) async => expectedLista);

      // act
      final result = await usecase(productoId: 2);

      // assert
      expect(result.items.length, 2);
      expect(result.total, 35.0);
      expect(result.items.any((item) => item.productoId == 2), false);
      verify(mockRepository.getCurrentActiveLista()).called(1);
      verify(mockRepository.saveCurrentActiveLista(any)).called(1);
    });
  });
}