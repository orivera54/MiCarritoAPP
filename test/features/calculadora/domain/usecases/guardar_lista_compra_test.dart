import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:supermercado_comparador/features/calculadora/domain/entities/item_calculadora.dart';
import 'package:supermercado_comparador/features/calculadora/domain/entities/lista_compra.dart';
import 'package:supermercado_comparador/features/calculadora/domain/repositories/calculadora_repository.dart';
import 'package:supermercado_comparador/features/calculadora/domain/usecases/guardar_lista_compra.dart';
import 'package:supermercado_comparador/features/productos/domain/entities/producto.dart';

import 'guardar_lista_compra_test.mocks.dart';

@GenerateMocks([CalculadoraRepository])
void main() {
  late GuardarListaCompra usecase;
  late MockCalculadoraRepository mockRepository;

  setUp(() {
    mockRepository = MockCalculadoraRepository();
    usecase = GuardarListaCompra(mockRepository);
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

  group('GuardarListaCompra', () {
    test('should save lista with custom name', () async {
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

      final savedLista = ListaCompra(
        id: 1,
        nombre: 'Mi Lista de Compras',
        items: [existingItem],
        total: 20.0,
        fechaCreacion: DateTime.now(),
      );

      when(mockRepository.createListaCompra(any))
          .thenAnswer((_) async => savedLista);

      when(mockRepository.clearCurrentActiveLista())
          .thenAnswer((_) async {});

      // act
      final result = await usecase(nombre: 'Mi Lista de Compras');

      // assert
      expect(result.id, 1);
      expect(result.nombre, 'Mi Lista de Compras');
      expect(result.items.length, 1);
      expect(result.total, 20.0);
      verify(mockRepository.getCurrentActiveLista()).called(1);
      verify(mockRepository.createListaCompra(any)).called(1);
      verify(mockRepository.clearCurrentActiveLista()).called(1);
    });

    test('should save lista with auto-generated name when no name provided', () async {
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

      final savedLista = ListaCompra(
        id: 1,
        nombre: 'Lista 2024-01-01 10:00',
        items: [existingItem],
        total: 20.0,
        fechaCreacion: DateTime.now(),
      );

      when(mockRepository.createListaCompra(any))
          .thenAnswer((_) async => savedLista);

      when(mockRepository.clearCurrentActiveLista())
          .thenAnswer((_) async {});

      // act
      final result = await usecase();

      // assert
      expect(result.id, 1);
      expect(result.nombre, isNotNull);
      expect(result.nombre!.startsWith('Lista'), true);
      expect(result.items.length, 1);
      expect(result.total, 20.0);
      verify(mockRepository.getCurrentActiveLista()).called(1);
      verify(mockRepository.createListaCompra(any)).called(1);
      verify(mockRepository.clearCurrentActiveLista()).called(1);
    });

    test('should throw error when no current lista exists', () async {
      // arrange
      when(mockRepository.getCurrentActiveLista()).thenAnswer((_) async => null);

      // act & assert
      expect(
        () => usecase(nombre: 'Test Lista'),
        throwsA(isA<StateError>()),
      );
      verify(mockRepository.getCurrentActiveLista()).called(1);
      verifyNever(mockRepository.createListaCompra(any));
      verifyNever(mockRepository.clearCurrentActiveLista());
    });

    test('should throw error when current lista is empty', () async {
      // arrange
      final emptyLista = ListaCompra(
        items: const [],
        total: 0.0,
        fechaCreacion: DateTime.now(),
      );

      when(mockRepository.getCurrentActiveLista())
          .thenAnswer((_) async => emptyLista);

      // act & assert
      expect(
        () => usecase(nombre: 'Test Lista'),
        throwsA(isA<StateError>()),
      );
      verify(mockRepository.getCurrentActiveLista()).called(1);
      verifyNever(mockRepository.createListaCompra(any));
      verifyNever(mockRepository.clearCurrentActiveLista());
    });

    test('should clear current lista after successful save', () async {
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

      final savedLista = ListaCompra(
        id: 1,
        nombre: 'Test Lista',
        items: [existingItem],
        total: 20.0,
        fechaCreacion: DateTime.now(),
      );

      when(mockRepository.createListaCompra(any))
          .thenAnswer((_) async => savedLista);

      when(mockRepository.clearCurrentActiveLista())
          .thenAnswer((_) async {});

      // act
      await usecase(nombre: 'Test Lista');

      // assert
      verify(mockRepository.clearCurrentActiveLista()).called(1);
    });

    test('should handle repository save errors', () async {
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

      when(mockRepository.createListaCompra(any))
          .thenThrow(Exception('Database error'));

      // act & assert
      expect(
        () => usecase(nombre: 'Test Lista'),
        throwsA(isA<Exception>()),
      );
    });

    test('should pass correct lista data to repository', () async {
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

      final savedLista = ListaCompra(
        id: 1,
        nombre: 'Custom Name',
        items: [existingItem],
        total: 20.0,
        fechaCreacion: DateTime.now(),
      );

      when(mockRepository.createListaCompra(any))
          .thenAnswer((_) async => savedLista);

      when(mockRepository.clearCurrentActiveLista())
          .thenAnswer((_) async {});

      // act
      await usecase(nombre: 'Custom Name');

      // assert
      final captured = verify(mockRepository.createListaCompra(captureAny)).captured;
      final passedLista = captured.first as ListaCompra;
      
      expect(passedLista.nombre, 'Custom Name');
      expect(passedLista.items.length, 1);
      expect(passedLista.total, 20.0);
    });
  });
}