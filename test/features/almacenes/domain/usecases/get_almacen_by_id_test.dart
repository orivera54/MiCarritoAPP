import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:supermercado_comparador/features/almacenes/domain/entities/almacen.dart';
import 'package:supermercado_comparador/features/almacenes/domain/repositories/almacen_repository.dart';
import 'package:supermercado_comparador/features/almacenes/domain/usecases/get_almacen_by_id.dart';

import 'get_almacen_by_id_test.mocks.dart';

@GenerateMocks([AlmacenRepository])
void main() {
  late GetAlmacenById usecase;
  late MockAlmacenRepository mockRepository;

  setUp(() {
    mockRepository = MockAlmacenRepository();
    usecase = GetAlmacenById(mockRepository);
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

  test('should get almacen by id from the repository', () async {
    // arrange
    when(mockRepository.getAlmacenById(tId)).thenAnswer((_) async => tAlmacen);

    // act
    final result = await usecase(tId);

    // assert
    expect(result, tAlmacen);
    verify(mockRepository.getAlmacenById(tId));
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return null when almacen does not exist', () async {
    // arrange
    when(mockRepository.getAlmacenById(tId)).thenAnswer((_) async => null);

    // act
    final result = await usecase(tId);

    // assert
    expect(result, null);
    verify(mockRepository.getAlmacenById(tId));
    verifyNoMoreInteractions(mockRepository);
  });
}