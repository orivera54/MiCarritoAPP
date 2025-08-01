import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:supermercado_comparador/features/calculadora/domain/entities/item_calculadora.dart';
import 'package:supermercado_comparador/features/calculadora/domain/entities/lista_compra.dart';
import 'package:supermercado_comparador/features/calculadora/domain/repositories/calculadora_repository.dart';
import 'package:supermercado_comparador/features/calculadora/domain/usecases/obtener_lista_actual.dart';
import 'package:supermercado_comparador/features/productos/domain/entities/producto.dart';

import 'obtener_lista_actual_test.mocks.dart';

@GenerateMocks([CalculadoraRepository])
void main() {
  late ObtenerListaActual usecase;
  late MockCalculadoraRepository mockRepository;

  setUp(() {
    mockRepository = MockCalculadoraRepository();
    usecase = ObtenerListaActual(mockRepository);
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

  group('ObtenerListaActual', () {
    test('should return existing current lista when available', () async {
      // arrange
      final existingItem = ItemCalculadora(
        productoId: 1,
        producto: testProducto,
        cantidad: 2,
        subtotal: 20.0,
      );

      final existingLista = ListaCompra(
        id: 1,
        nombre: 'Test Lista',
        items: [existingItem],
        total: 20.0,
        fechaCreacion: DateTime.now(),
      );

      when(mockRepository.getCurrentActiveLista())
          .thenAnswer((_) async => existingLista);

      // act
      final result = await usecase();

      // assert
      expect(result.id, 1);
      expect(result.nombre, 'Test Lista');
      expect(result.items.length, 1);
      expect(result.total, 20.0);
      verify(mockRepository.getCurrentActiveLista()).called(1);
      verifyNever(mockRepository.saveCurrentActiveLista(any));
    });

    test('should create and save new empty lista when no current lista exists', () async {
      // arrange
      when(mockRepository.getCurrentActiveLista()).thenAnswer((_) async => null);

      final newEmptyLista = ListaCompra(
        items: const [],
        total: 0.0,
        fechaCreacion: DateTime.now(),
      );

      when(mockRepository.saveCurrentActiveLista(any))
          .thenAnswer((_) async => newEmptyLista);

      // act
      final result = await usecase();

      // assert
      expect(result.items.length, 0);
      expect(result.total, 0.0);
      expect(result.nombre, null);
      verify(mockRepository.getCurrentActiveLista()).called(1);
      verify(mockRepository.saveCurrentActiveLista(any)).called(1);
    });

    test('should create lista with current timestamp', () async {
      // arrange
      when(mockRepository.getCurrentActiveLista()).thenAnswer((_) async => null);

      final newEmptyLista = ListaCompra(
        items: const [],
        total: 0.0,
        fechaCreacion: DateTime.now(),
      );

      when(mockRepository.saveCurrentActiveLista(any))
          .thenAnswer((_) async => newEmptyLista);

      final beforeCall = DateTime.now();

      // act
      final result = await usecase();

      final afterCall = DateTime.now();

      // assert
      expect(result.fechaCreacion.isAfter(beforeCall.subtract(const Duration(seconds: 1))), true);
      expect(result.fechaCreacion.isBefore(afterCall.add(const Duration(seconds: 1))), true);
      verify(mockRepository.getCurrentActiveLista()).called(1);
      verify(mockRepository.saveCurrentActiveLista(any)).called(1);
    });

    test('should handle repository errors gracefully', () async {
      // arrange
      when(mockRepository.getCurrentActiveLista())
          .thenThrow(Exception('Database error'));

      // act & assert
      expect(
        () => usecase(),
        throwsA(isA<Exception>()),
      );
      verify(mockRepository.getCurrentActiveLista()).called(1);
    });

    test('should save new lista when creating from null', () async {
      // arrange
      when(mockRepository.getCurrentActiveLista()).thenAnswer((_) async => null);

      final capturedLista = ListaCompra(
        items: const [],
        total: 0.0,
        fechaCreacion: DateTime.now(),
      );

      when(mockRepository.saveCurrentActiveLista(any))
          .thenAnswer((_) async => capturedLista);

      // act
      await usecase();

      // assert
      final captured = verify(mockRepository.saveCurrentActiveLista(captureAny)).captured;
      final savedLista = captured.first as ListaCompra;
      
      expect(savedLista.items.length, 0);
      expect(savedLista.total, 0.0);
      expect(savedLista.nombre, null);
    });
  });
}