import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:supermercado_comparador/core/errors/exceptions.dart';
import 'package:supermercado_comparador/features/almacenes/domain/entities/almacen.dart';
import 'package:supermercado_comparador/features/almacenes/domain/repositories/almacen_repository.dart';
import 'package:supermercado_comparador/features/almacenes/domain/usecases/delete_almacen.dart';

import 'delete_almacen_test.mocks.dart';

@GenerateMocks([AlmacenRepository])
void main() {
  late DeleteAlmacen usecase;
  late MockAlmacenRepository mockRepository;

  setUp(() {
    mockRepository = MockAlmacenRepository();
    usecase = DeleteAlmacen(mockRepository);
  });

  const tId = 1;
  final tAlmacen = Almacen(
    id: tId,
    nombre: 'Supermercado A',
    direccion: 'Calle 123',
    descripcion: 'Descripción A',
    fechaCreacion: DateTime(2024, 1, 1),
    fechaActualizacion: DateTime(2024, 1, 1),
  );

  test('should delete almacen when it exists', () async {
    // arrange
    when(mockRepository.getAlmacenById(tId)).thenAnswer((_) async => tAlmacen);
    when(mockRepository.deleteAlmacen(tId)).thenAnswer((_) async {});

    // act
    await usecase(tId);

    // assert
    verify(mockRepository.getAlmacenById(tId));
    verify(mockRepository.deleteAlmacen(tId));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should throw NotFoundException when almacen does not exist', () async {
    // arrange
    when(mockRepository.getAlmacenById(tId)).thenAnswer((_) async => null);

    // act & assert
    expect(
      () => usecase(tId),
      throwsA(isA<NotFoundException>()),
    );
    verify(mockRepository.getAlmacenById(tId));
    verifyNoMoreInteractions(mockRepository);
  });
}