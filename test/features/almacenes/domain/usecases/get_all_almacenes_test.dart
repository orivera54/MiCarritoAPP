import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:supermercado_comparador/features/almacenes/domain/entities/almacen.dart';
import 'package:supermercado_comparador/features/almacenes/domain/repositories/almacen_repository.dart';
import 'package:supermercado_comparador/features/almacenes/domain/usecases/get_all_almacenes.dart';

import 'get_all_almacenes_test.mocks.dart';

@GenerateMocks([AlmacenRepository])
void main() {
  late GetAllAlmacenes usecase;
  late MockAlmacenRepository mockRepository;

  setUp(() {
    mockRepository = MockAlmacenRepository();
    usecase = GetAllAlmacenes(mockRepository);
  });

  final tAlmacenes = [
    Almacen(
      id: 1,
      nombre: 'Supermercado A',
      direccion: 'Calle 123',
      descripcion: 'Descripción A',
      fechaCreacion: DateTime(2024, 1, 1),
      fechaActualizacion: DateTime(2024, 1, 1),
    ),
    Almacen(
      id: 2,
      nombre: 'Supermercado B',
      direccion: 'Calle 456',
      descripcion: 'Descripción B',
      fechaCreacion: DateTime(2024, 1, 2),
      fechaActualizacion: DateTime(2024, 1, 2),
    ),
  ];

  test('should get all almacenes from the repository', () async {
    // arrange
    when(mockRepository.getAllAlmacenes()).thenAnswer((_) async => tAlmacenes);

    // act
    final result = await usecase();

    // assert
    expect(result, tAlmacenes);
    verify(mockRepository.getAllAlmacenes());
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return empty list when no almacenes exist', () async {
    // arrange
    when(mockRepository.getAllAlmacenes()).thenAnswer((_) async => []);

    // act
    final result = await usecase();

    // assert
    expect(result, []);
    verify(mockRepository.getAllAlmacenes());
    verifyNoMoreInteractions(mockRepository);
  });
}