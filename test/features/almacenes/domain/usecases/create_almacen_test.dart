import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:supermercado_comparador/core/errors/exceptions.dart';
import 'package:supermercado_comparador/features/almacenes/domain/entities/almacen.dart';
import 'package:supermercado_comparador/features/almacenes/domain/repositories/almacen_repository.dart';
import 'package:supermercado_comparador/features/almacenes/domain/usecases/create_almacen.dart';

import 'create_almacen_test.mocks.dart';

@GenerateMocks([AlmacenRepository])
void main() {
  late CreateAlmacen usecase;
  late MockAlmacenRepository mockRepository;

  setUp(() {
    mockRepository = MockAlmacenRepository();
    usecase = CreateAlmacen(mockRepository);
  });

  final tAlmacen = Almacen(
    nombre: 'Supermercado A',
    direccion: 'Calle 123',
    descripcion: 'Descripción A',
    fechaCreacion: DateTime(2024, 1, 1),
    fechaActualizacion: DateTime(2024, 1, 1),
  );

  final tCreatedAlmacen = tAlmacen.copyWith(id: 1);

  test('should create almacen when name does not exist', () async {
    // arrange
    when(mockRepository.almacenNameExists(tAlmacen.nombre))
        .thenAnswer((_) async => false);
    when(mockRepository.createAlmacen(any))
        .thenAnswer((_) async => tCreatedAlmacen);

    // act
    final result = await usecase(tAlmacen);

    // assert
    expect(result, tCreatedAlmacen);
    verify(mockRepository.almacenNameExists(tAlmacen.nombre));
    verify(mockRepository.createAlmacen(any));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw ValidationException when name already exists', () async {
    // arrange
    when(mockRepository.almacenNameExists(tAlmacen.nombre))
        .thenAnswer((_) async => true);

    // act & assert
    expect(
      () => usecase(tAlmacen),
      throwsA(isA<ValidationException>()),
    );
    verify(mockRepository.almacenNameExists(tAlmacen.nombre));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw ValidationException when name is empty', () async {
    // arrange
    final tEmptyNameAlmacen = tAlmacen.copyWith(nombre: '');

    // act & assert
    expect(
      () => usecase(tEmptyNameAlmacen),
      throwsA(isA<ValidationException>()),
    );
    verifyZeroInteractions(mockRepository);
  });

  test('should throw ValidationException when name is only whitespace', () async {
    // arrange
    final tWhitespaceNameAlmacen = tAlmacen.copyWith(nombre: '   ');

    // act & assert
    expect(
      () => usecase(tWhitespaceNameAlmacen),
      throwsA(isA<ValidationException>()),
    );
    verifyZeroInteractions(mockRepository);
  });
}