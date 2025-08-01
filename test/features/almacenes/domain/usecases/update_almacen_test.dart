import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:supermercado_comparador/core/errors/exceptions.dart';
import 'package:supermercado_comparador/features/almacenes/domain/entities/almacen.dart';
import 'package:supermercado_comparador/features/almacenes/domain/repositories/almacen_repository.dart';
import 'package:supermercado_comparador/features/almacenes/domain/usecases/update_almacen.dart';

import 'update_almacen_test.mocks.dart';

@GenerateMocks([AlmacenRepository])
void main() {
  late UpdateAlmacen usecase;
  late MockAlmacenRepository mockRepository;

  setUp(() {
    mockRepository = MockAlmacenRepository();
    usecase = UpdateAlmacen(mockRepository);
  });

  final tAlmacen = Almacen(
    id: 1,
    nombre: 'Supermercado A',
    direccion: 'Calle 123',
    descripcion: 'Descripción A',
    fechaCreacion: DateTime(2024, 1, 1),
    fechaActualizacion: DateTime(2024, 1, 1),
  );

  test('should update almacen when name does not exist in other almacenes', () async {
    // arrange
    when(mockRepository.almacenNameExists(tAlmacen.nombre, excludeId: tAlmacen.id))
        .thenAnswer((_) async => false);
    when(mockRepository.updateAlmacen(any))
        .thenAnswer((_) async => tAlmacen);

    // act
    final result = await usecase(tAlmacen);

    // assert
    expect(result, tAlmacen);
    verify(mockRepository.almacenNameExists(tAlmacen.nombre, excludeId: tAlmacen.id));
    verify(mockRepository.updateAlmacen(any));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw ValidationException when almacen has no id', () async {
    // arrange
    final tAlmacenWithoutId = Almacen(
      nombre: 'Supermercado A',
      direccion: 'Calle 123',
      descripcion: 'Descripción A',
      fechaCreacion: DateTime(2024, 1, 1),
      fechaActualizacion: DateTime(2024, 1, 1),
    );

    // act & assert
    expect(
      () => usecase(tAlmacenWithoutId),
      throwsA(isA<ValidationException>()),
    );
    verifyZeroInteractions(mockRepository);
  });

  test('should throw ValidationException when name already exists in other almacen', () async {
    // arrange
    when(mockRepository.almacenNameExists(tAlmacen.nombre, excludeId: tAlmacen.id))
        .thenAnswer((_) async => true);

    // act & assert
    expect(
      () => usecase(tAlmacen),
      throwsA(isA<ValidationException>()),
    );
    verify(mockRepository.almacenNameExists(tAlmacen.nombre, excludeId: tAlmacen.id));
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