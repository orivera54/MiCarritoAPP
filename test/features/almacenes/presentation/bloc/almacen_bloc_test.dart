import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:supermercado_comparador/core/errors/exceptions.dart';
import 'package:supermercado_comparador/features/almacenes/domain/entities/almacen.dart';
import 'package:supermercado_comparador/features/almacenes/domain/usecases/create_almacen.dart';
import 'package:supermercado_comparador/features/almacenes/domain/usecases/delete_almacen.dart';
import 'package:supermercado_comparador/features/almacenes/domain/usecases/get_all_almacenes.dart';
import 'package:supermercado_comparador/features/almacenes/domain/usecases/get_almacen_by_id.dart';
import 'package:supermercado_comparador/features/almacenes/domain/usecases/update_almacen.dart';
import 'package:supermercado_comparador/features/almacenes/presentation/bloc/bloc.dart';

import 'almacen_bloc_test.mocks.dart';

@GenerateMocks([
  GetAllAlmacenes,
  GetAlmacenById,
  CreateAlmacen,
  UpdateAlmacen,
  DeleteAlmacen,
])
void main() {
  late AlmacenBloc bloc;
  late MockGetAllAlmacenes mockGetAllAlmacenes;
  late MockGetAlmacenById mockGetAlmacenById;
  late MockCreateAlmacen mockCreateAlmacen;
  late MockUpdateAlmacen mockUpdateAlmacen;
  late MockDeleteAlmacen mockDeleteAlmacen;

  setUp(() {
    mockGetAllAlmacenes = MockGetAllAlmacenes();
    mockGetAlmacenById = MockGetAlmacenById();
    mockCreateAlmacen = MockCreateAlmacen();
    mockUpdateAlmacen = MockUpdateAlmacen();
    mockDeleteAlmacen = MockDeleteAlmacen();

    bloc = AlmacenBloc(
      getAllAlmacenes: mockGetAllAlmacenes,
      getAlmacenById: mockGetAlmacenById,
      createAlmacen: mockCreateAlmacen,
      updateAlmacen: mockUpdateAlmacen,
      deleteAlmacen: mockDeleteAlmacen,
    );
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

  final tAlmacen = tAlmacenes[0];

  group('LoadAlmacenes', () {
    blocTest<AlmacenBloc, AlmacenState>(
      'should emit [AlmacenLoading, AlmacenesLoaded] when data is gotten successfully',
      build: () {
        when(mockGetAllAlmacenes()).thenAnswer((_) async => tAlmacenes);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadAlmacenes()),
      expect: () => [
        AlmacenLoading(),
        AlmacenesLoaded(tAlmacenes),
      ],
      verify: (_) {
        verify(mockGetAllAlmacenes());
      },
    );

    blocTest<AlmacenBloc, AlmacenState>(
      'should emit [AlmacenLoading, AlmacenError] when getting data fails',
      build: () {
        when(mockGetAllAlmacenes()).thenThrow(const DatabaseException('Database error'));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadAlmacenes()),
      expect: () => [
        AlmacenLoading(),
        const AlmacenError('Error de base de datos: Database error'),
      ],
      verify: (_) {
        verify(mockGetAllAlmacenes());
      },
    );
  });

  group('GetAlmacenByIdEvent', () {
    const tId = 1;

    blocTest<AlmacenBloc, AlmacenState>(
      'should emit [AlmacenLoading, AlmacenLoaded] when almacen is found',
      build: () {
        when(mockGetAlmacenById(tId)).thenAnswer((_) async => tAlmacen);
        return bloc;
      },
      act: (bloc) => bloc.add(const GetAlmacenByIdEvent(tId)),
      expect: () => [
        AlmacenLoading(),
        AlmacenLoaded(tAlmacen),
      ],
      verify: (_) {
        verify(mockGetAlmacenById(tId));
      },
    );

    blocTest<AlmacenBloc, AlmacenState>(
      'should emit [AlmacenLoading, AlmacenError] when almacen is not found',
      build: () {
        when(mockGetAlmacenById(tId)).thenAnswer((_) async => null);
        return bloc;
      },
      act: (bloc) => bloc.add(const GetAlmacenByIdEvent(tId)),
      expect: () => [
        AlmacenLoading(),
        const AlmacenError('Almacén no encontrado'),
      ],
      verify: (_) {
        verify(mockGetAlmacenById(tId));
      },
    );
  });

  group('CreateAlmacenEvent', () {
    blocTest<AlmacenBloc, AlmacenState>(
      'should emit [AlmacenLoading, AlmacenCreated] when almacen is created successfully',
      build: () {
        when(mockCreateAlmacen(tAlmacen)).thenAnswer((_) async => tAlmacen);
        return bloc;
      },
      act: (bloc) => bloc.add(CreateAlmacenEvent(tAlmacen)),
      expect: () => [
        AlmacenLoading(),
        AlmacenCreated(tAlmacen),
      ],
      verify: (_) {
        verify(mockCreateAlmacen(tAlmacen));
      },
    );

    blocTest<AlmacenBloc, AlmacenState>(
      'should emit [AlmacenLoading, AlmacenError] when creation fails with ValidationException',
      build: () {
        when(mockCreateAlmacen(tAlmacen))
            .thenThrow(const ValidationException('Ya existe un almacén con este nombre'));
        return bloc;
      },
      act: (bloc) => bloc.add(CreateAlmacenEvent(tAlmacen)),
      expect: () => [
        AlmacenLoading(),
        const AlmacenError('Ya existe un almacén con este nombre'),
      ],
      verify: (_) {
        verify(mockCreateAlmacen(tAlmacen));
      },
    );
  });

  group('UpdateAlmacenEvent', () {
    blocTest<AlmacenBloc, AlmacenState>(
      'should emit [AlmacenLoading, AlmacenUpdated] when almacen is updated successfully',
      build: () {
        when(mockUpdateAlmacen(tAlmacen)).thenAnswer((_) async => tAlmacen);
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateAlmacenEvent(tAlmacen)),
      expect: () => [
        AlmacenLoading(),
        AlmacenUpdated(tAlmacen),
      ],
      verify: (_) {
        verify(mockUpdateAlmacen(tAlmacen));
      },
    );

    blocTest<AlmacenBloc, AlmacenState>(
      'should emit [AlmacenLoading, AlmacenError] when update fails',
      build: () {
        when(mockUpdateAlmacen(tAlmacen))
            .thenThrow(const ValidationException('Ya existe un almacén con este nombre'));
        return bloc;
      },
      act: (bloc) => bloc.add(UpdateAlmacenEvent(tAlmacen)),
      expect: () => [
        AlmacenLoading(),
        const AlmacenError('Ya existe un almacén con este nombre'),
      ],
      verify: (_) {
        verify(mockUpdateAlmacen(tAlmacen));
      },
    );
  });

  group('DeleteAlmacenEvent', () {
    const tId = 1;

    blocTest<AlmacenBloc, AlmacenState>(
      'should emit [AlmacenLoading, AlmacenDeleted] when almacen is deleted successfully',
      build: () {
        when(mockDeleteAlmacen(tId)).thenAnswer((_) async {});
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteAlmacenEvent(tId)),
      expect: () => [
        AlmacenLoading(),
        AlmacenDeleted(),
      ],
      verify: (_) {
        verify(mockDeleteAlmacen(tId));
      },
    );

    blocTest<AlmacenBloc, AlmacenState>(
      'should emit [AlmacenLoading, AlmacenError] when deletion fails',
      build: () {
        when(mockDeleteAlmacen(tId))
            .thenThrow(const NotFoundException('Almacén no encontrado'));
        return bloc;
      },
      act: (bloc) => bloc.add(const DeleteAlmacenEvent(tId)),
      expect: () => [
        AlmacenLoading(),
        const AlmacenError('Almacén no encontrado'),
      ],
      verify: (_) {
        verify(mockDeleteAlmacen(tId));
      },
    );
  });
}