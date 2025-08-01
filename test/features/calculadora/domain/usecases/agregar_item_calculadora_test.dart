import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:supermercado_comparador/features/calculadora/domain/entities/item_calculadora.dart';
import 'package:supermercado_comparador/features/calculadora/domain/entities/lista_compra.dart';
import 'package:supermercado_comparador/features/calculadora/domain/repositories/calculadora_repository.dart';
import 'package:supermercado_comparador/features/calculadora/domain/usecases/agregar_item_calculadora.dart';
import 'package:supermercado_comparador/features/productos/domain/entities/producto.dart';

import 'agregar_item_calculadora_test.mocks.dart';

@GenerateMocks([CalculadoraRepository])
void main() {
  late AgregarItemCalculadora usecase;
  late MockCalculadoraRepository mockRepository;

  setUp(() {
    mockRepository = MockCalculadoraRepository();
    usecase = AgregarItemCalculadora(mockRepository);
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

  group('AgregarItemCalculadora', () {
    test('should create new lista when no current lista exists', () async {
      // arrange
      when(mockRepository.getCurrentActiveLista()).thenAnswer((_) async => null);
      
      final expectedLista = ListaCompra(
        items: [
          ItemCalculadora(
            productoId: 1,
            producto: testProducto,
            cantidad: 1,
            subtotal: 10.0,
          ),
        ],
        total: 10.0,
        fechaCreacion: DateTime.now(),
      );
      
      when(mockRepository.saveCurrentActiveLista(any))
          .thenAnswer((_) async => expectedLista);

      // act
      final result = await usecase(producto: testProducto);

      // assert
      expect(result.items.length, 1);
      expect(result.items.first.productoId, 1);
      expect(result.items.first.cantidad, 1);
      expect(result.items.first.subtotal, 10.0);
      expect(result.total, 10.0);
      verify(mockRepository.getCurrentActiveLista()).called(1);
      verify(mockRepository.saveCurrentActiveLista(any)).called(1);
    });

    test('should add new item to existing lista', () async {
      // arrange
      final existingItem = ItemCalculadora(
        productoId: 2,
        producto: Producto(
          id: 2,
          nombre: 'Existing Product',
          precio: 5.0,
          peso: 1.0,
          tamano: 'Small',
          codigoQR: 'QR456',
          categoriaId: 1,
          almacenId: 1,
          fechaCreacion: DateTime.now(),
          fechaActualizacion: DateTime.now(),
        ),
        cantidad: 2,
        subtotal: 10.0,
      );

      final currentLista = ListaCompra(
        items: [existingItem],
        total: 10.0,
        fechaCreacion: DateTime.now(),
      );

      when(mockRepository.getCurrentActiveLista())
          .thenAnswer((_) async => currentLista);

      final expectedLista = ListaCompra(
        items: [
          existingItem,
          ItemCalculadora(
            productoId: 1,
            producto: testProducto,
            cantidad: 1,
            subtotal: 10.0,
          ),
        ],
        total: 20.0,
        fechaCreacion: DateTime.now(),
      );

      when(mockRepository.saveCurrentActiveLista(any))
          .thenAnswer((_) async => expectedLista);

      // act
      final result = await usecase(producto: testProducto);

      // assert
      expect(result.items.length, 2);
      expect(result.total, 20.0);
      verify(mockRepository.getCurrentActiveLista()).called(1);
      verify(mockRepository.saveCurrentActiveLista(any)).called(1);
    });

    test('should update quantity when product already exists in lista', () async {
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
            cantidad: 3,
            subtotal: 30.0,
          ),
        ],
        total: 30.0,
        fechaCreacion: DateTime.now(),
      );

      when(mockRepository.saveCurrentActiveLista(any))
          .thenAnswer((_) async => expectedLista);

      // act
      final result = await usecase(producto: testProducto, cantidad: 1);

      // assert
      expect(result.items.length, 1);
      expect(result.items.first.cantidad, 3);
      expect(result.items.first.subtotal, 30.0);
      expect(result.total, 30.0);
      verify(mockRepository.getCurrentActiveLista()).called(1);
      verify(mockRepository.saveCurrentActiveLista(any)).called(1);
    });

    test('should add multiple quantity at once', () async {
      // arrange
      when(mockRepository.getCurrentActiveLista()).thenAnswer((_) async => null);

      final expectedLista = ListaCompra(
        items: [
          ItemCalculadora(
            productoId: 1,
            producto: testProducto,
            cantidad: 3,
            subtotal: 30.0,
          ),
        ],
        total: 30.0,
        fechaCreacion: DateTime.now(),
      );

      when(mockRepository.saveCurrentActiveLista(any))
          .thenAnswer((_) async => expectedLista);

      // act
      final result = await usecase(producto: testProducto, cantidad: 3);

      // assert
      expect(result.items.length, 1);
      expect(result.items.first.cantidad, 3);
      expect(result.items.first.subtotal, 30.0);
      expect(result.total, 30.0);
      verify(mockRepository.getCurrentActiveLista()).called(1);
      verify(mockRepository.saveCurrentActiveLista(any)).called(1);
    });
  });
}