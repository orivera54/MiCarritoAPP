import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:supermercado_comparador/features/calculadora/domain/entities/lista_compra.dart';
import 'package:supermercado_comparador/features/calculadora/domain/repositories/calculadora_repository.dart';
import 'package:supermercado_comparador/features/calculadora/domain/usecases/limpiar_lista_actual.dart';

import 'limpiar_lista_actual_test.mocks.dart';

@GenerateMocks([CalculadoraRepository])
void main() {
  late LimpiarListaActual usecase;
  late MockCalculadoraRepository mockRepository;

  setUp(() {
    mockRepository = MockCalculadoraRepository();
    usecase = LimpiarListaActual(mockRepository);
  });

  group('LimpiarListaActual', () {
    test('should clear current lista and return new empty lista', () async {
      // arrange
      final newEmptyLista = ListaCompra(
        items: const [],
        total: 0.0,
        fechaCreacion: DateTime.now(),
      );

      when(mockRepository.clearCurrentActiveLista())
          .thenAnswer((_) async {});

      when(mockRepository.saveCurrentActiveLista(any))
          .thenAnswer((_) async => newEmptyLista);

      // act
      final result = await usecase();

      // assert
      expect(result.items.length, 0);
      expect(result.total, 0.0);
      expect(result.nombre, null);
      verify(mockRepository.clearCurrentActiveLista()).called(1);
      verify(mockRepository.saveCurrentActiveLista(any)).called(1);
    });

    test('should create lista with current timestamp', () async {
      // arrange
      final newEmptyLista = ListaCompra(
        items: const [],
        total: 0.0,
        fechaCreacion: DateTime.now(),
      );

      when(mockRepository.clearCurrentActiveLista())
          .thenAnswer((_) async {});

      when(mockRepository.saveCurrentActiveLista(any))
          .thenAnswer((_) async => newEmptyLista);

      final beforeCall = DateTime.now();

      // act
      final result = await usecase();

      final afterCall = DateTime.now();

      // assert
      expect(result.fechaCreacion.isAfter(beforeCall.subtract(const Duration(seconds: 1))), true);
      expect(result.fechaCreacion.isBefore(afterCall.add(const Duration(seconds: 1))), true);
      verify(mockRepository.clearCurrentActiveLista()).called(1);
      verify(mockRepository.saveCurrentActiveLista(any)).called(1);
    });

    test('should handle clear repository errors', () async {
      // arrange
      when(mockRepository.clearCurrentActiveLista())
          .thenThrow(Exception('Clear error'));

      // act & assert
      expect(
        () => usecase(),
        throwsA(isA<Exception>()),
      );
      verify(mockRepository.clearCurrentActiveLista()).called(1);
      verifyNever(mockRepository.saveCurrentActiveLista(any));
    });

    test('should handle save repository errors', () async {
      // arrange
      when(mockRepository.clearCurrentActiveLista())
          .thenAnswer((_) async {});

      when(mockRepository.saveCurrentActiveLista(any))
          .thenThrow(Exception('Save error'));

      // act & assert
      expect(
        () => usecase(),
        throwsA(isA<Exception>()),
      );
    });

    test('should pass correct empty lista to repository', () async {
      // arrange
      final newEmptyLista = ListaCompra(
        items: const [],
        total: 0.0,
        fechaCreacion: DateTime.now(),
      );

      when(mockRepository.clearCurrentActiveLista())
          .thenAnswer((_) async {});

      when(mockRepository.saveCurrentActiveLista(any))
          .thenAnswer((_) async => newEmptyLista);

      // act
      await usecase();

      // assert
      final captured = verify(mockRepository.saveCurrentActiveLista(captureAny)).captured;
      final passedLista = captured.first as ListaCompra;
      
      expect(passedLista.items.length, 0);
      expect(passedLista.total, 0.0);
      expect(passedLista.nombre, null);
    });

    test('should call repository methods in correct order', () async {
      // arrange
      final newEmptyLista = ListaCompra(
        items: const [],
        total: 0.0,
        fechaCreacion: DateTime.now(),
      );

      when(mockRepository.clearCurrentActiveLista())
          .thenAnswer((_) async {});

      when(mockRepository.saveCurrentActiveLista(any))
          .thenAnswer((_) async => newEmptyLista);

      // act
      await usecase();

      // assert
      verifyInOrder([
        mockRepository.clearCurrentActiveLista(),
        mockRepository.saveCurrentActiveLista(any),
      ]);
    });
  });
}