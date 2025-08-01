import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supermercado_comparador/core/errors/exceptions.dart';
import 'package:supermercado_comparador/features/categorias/domain/entities/categoria.dart';
import 'package:supermercado_comparador/features/categorias/domain/usecases/create_categoria.dart';
import 'package:supermercado_comparador/features/categorias/domain/usecases/delete_categoria.dart';
import 'package:supermercado_comparador/features/categorias/domain/usecases/ensure_default_category.dart';
import 'package:supermercado_comparador/features/categorias/domain/usecases/get_all_categorias.dart';
import 'package:supermercado_comparador/features/categorias/domain/usecases/get_categoria_by_id.dart';
import 'package:supermercado_comparador/features/categorias/domain/usecases/update_categoria.dart';
import 'package:supermercado_comparador/features/categorias/presentation/bloc/categoria_bloc.dart';
import 'package:supermercado_comparador/features/categorias/presentation/bloc/categoria_event.dart';
import 'package:supermercado_comparador/features/categorias/presentation/bloc/categoria_state.dart';

import 'categoria_bloc_test.mocks.dart';

@GenerateMocks([
  GetAllCategorias,
  GetCategoriaById,
  CreateCategoria,
  UpdateCategoria,
  DeleteCategoria,
  EnsureDefaultCategory,
])
void main() {
  late CategoriaBloc bloc;
  late MockGetAllCategorias mockGetAllCategorias;
  late MockGetCategoriaById mockGetCategoriaById;
  late MockCreateCategoria mockCreateCategoria;
  late MockUpdateCategoria mockUpdateCategoria;
  late MockDeleteCategoria mockDeleteCategoria;
  late MockEnsureDefaultCategory mockEnsureDefaultCategory;

  setUp(() {
    mockGetAllCategorias = MockGetAllCategorias();
    mockGetCategoriaById = MockGetCategoriaById();
    mockCreateCategoria = MockCreateCategoria();
    mockUpdateCategoria = MockUpdateCategoria();
    mockDeleteCategoria = MockDeleteCategoria();
    mockEnsureDefaultCategory = MockEnsureDefaultCategory();

    bloc = CategoriaBloc(
      getAllCategorias: mockGetAllCategorias,
      getCategoriaById: mockGetCategoriaById,
      createCategoria: mockCreateCategoria,
      updateCategoria: mockUpdateCategoria,
      deleteCategoria: mockDeleteCategoria,
      ensureDefaultCategory: mockEnsureDefaultCategory,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('CategoriaBloc', () {
    final testDate = DateTime(2024, 1, 1);
    
    final testCategorias = [
      Categoria(
        id: 1,
        nombre: 'Lácteos',
        descripcion: 'Productos lácteos y derivados',
        fechaCreacion: testDate,
      ),
      Categoria(
        id: 2,
        nombre: 'Carnes',
        descripcion: 'Productos cárnicos',
        fechaCreacion: testDate,
      ),
    ];

    final testCategoria = testCategorias.first;

    test('initial state is CategoriaInitial', () {
      expect(bloc.state, equals(CategoriaInitial()));
    });

    group('LoadCategorias', () {
      blocTest<CategoriaBloc, CategoriaState>(
        'emits [CategoriaLoading, CategoriasLoaded] when successful',
        build: () {
          when(mockGetAllCategorias()).thenAnswer((_) async => testCategorias);
          return bloc;
        },
        act: (bloc) => bloc.add(LoadCategorias()),
        expect: () => [
          CategoriaLoading(),
          CategoriasLoaded(testCategorias),
        ],
        verify: (_) {
          verify(mockGetAllCategorias()).called(1);
        },
      );

      blocTest<CategoriaBloc, CategoriaState>(
        'emits [CategoriaLoading, CategoriaError] when fails',
        build: () {
          when(mockGetAllCategorias()).thenThrow(const DatabaseException('Database error'));
          return bloc;
        },
        act: (bloc) => bloc.add(LoadCategorias()),
        expect: () => [
          CategoriaLoading(),
          const CategoriaError('Error de base de datos: Database error'),
        ],
        verify: (_) {
          verify(mockGetAllCategorias()).called(1);
        },
      );
    });

    group('GetCategoriaByIdEvent', () {
      blocTest<CategoriaBloc, CategoriaState>(
        'emits [CategoriaLoading, CategoriaLoaded] when categoria exists',
        build: () {
          when(mockGetCategoriaById(1)).thenAnswer((_) async => testCategoria);
          return bloc;
        },
        act: (bloc) => bloc.add(const GetCategoriaByIdEvent(1)),
        expect: () => [
          CategoriaLoading(),
          CategoriaLoaded(testCategoria),
        ],
        verify: (_) {
          verify(mockGetCategoriaById(1)).called(1);
        },
      );

      blocTest<CategoriaBloc, CategoriaState>(
        'emits [CategoriaLoading, CategoriaError] when categoria does not exist',
        build: () {
          when(mockGetCategoriaById(1)).thenAnswer((_) async => null);
          return bloc;
        },
        act: (bloc) => bloc.add(const GetCategoriaByIdEvent(1)),
        expect: () => [
          CategoriaLoading(),
          const CategoriaError('Categoría no encontrada'),
        ],
        verify: (_) {
          verify(mockGetCategoriaById(1)).called(1);
        },
      );
    });

    group('CreateCategoriaEvent', () {
      blocTest<CategoriaBloc, CategoriaState>(
        'emits [CategoriaLoading, CategoriaCreated] when successful',
        build: () {
          when(mockCreateCategoria(testCategoria)).thenAnswer((_) async => testCategoria);
          return bloc;
        },
        act: (bloc) => bloc.add(CreateCategoriaEvent(testCategoria)),
        expect: () => [
          CategoriaLoading(),
          CategoriaCreated(testCategoria),
        ],
        verify: (_) {
          verify(mockCreateCategoria(testCategoria)).called(1);
        },
      );

      blocTest<CategoriaBloc, CategoriaState>(
        'emits [CategoriaLoading, CategoriaError] when validation fails',
        build: () {
          when(mockCreateCategoria(testCategoria))
              .thenThrow(const ValidationException('El nombre de la categoría es obligatorio'));
          return bloc;
        },
        act: (bloc) => bloc.add(CreateCategoriaEvent(testCategoria)),
        expect: () => [
          CategoriaLoading(),
          const CategoriaError('El nombre de la categoría es obligatorio'),
        ],
        verify: (_) {
          verify(mockCreateCategoria(testCategoria)).called(1);
        },
      );
    });

    group('UpdateCategoriaEvent', () {
      blocTest<CategoriaBloc, CategoriaState>(
        'emits [CategoriaLoading, CategoriaUpdated] when successful',
        build: () {
          when(mockUpdateCategoria(testCategoria)).thenAnswer((_) async => testCategoria);
          return bloc;
        },
        act: (bloc) => bloc.add(UpdateCategoriaEvent(testCategoria)),
        expect: () => [
          CategoriaLoading(),
          CategoriaUpdated(testCategoria),
        ],
        verify: (_) {
          verify(mockUpdateCategoria(testCategoria)).called(1);
        },
      );

      blocTest<CategoriaBloc, CategoriaState>(
        'emits [CategoriaLoading, CategoriaError] when validation fails',
        build: () {
          when(mockUpdateCategoria(testCategoria))
              .thenThrow(const ValidationException('Ya existe una categoría con ese nombre'));
          return bloc;
        },
        act: (bloc) => bloc.add(UpdateCategoriaEvent(testCategoria)),
        expect: () => [
          CategoriaLoading(),
          const CategoriaError('Ya existe una categoría con ese nombre'),
        ],
        verify: (_) {
          verify(mockUpdateCategoria(testCategoria)).called(1);
        },
      );
    });

    group('DeleteCategoriaEvent', () {
      blocTest<CategoriaBloc, CategoriaState>(
        'emits [CategoriaLoading, CategoriaDeleted] when successful',
        build: () {
          when(mockDeleteCategoria(1)).thenAnswer((_) async {});
          return bloc;
        },
        act: (bloc) => bloc.add(const DeleteCategoriaEvent(1)),
        expect: () => [
          CategoriaLoading(),
          CategoriaDeleted(),
        ],
        verify: (_) {
          verify(mockDeleteCategoria(1)).called(1);
        },
      );

      blocTest<CategoriaBloc, CategoriaState>(
        'emits [CategoriaLoading, CategoriaError] when categoria has products',
        build: () {
          when(mockDeleteCategoria(1))
              .thenThrow(const ValidationException('No se puede eliminar la categoría porque tiene productos asociados'));
          return bloc;
        },
        act: (bloc) => bloc.add(const DeleteCategoriaEvent(1)),
        expect: () => [
          CategoriaLoading(),
          const CategoriaError('No se puede eliminar la categoría porque tiene productos asociados'),
        ],
        verify: (_) {
          verify(mockDeleteCategoria(1)).called(1);
        },
      );
    });

    group('EnsureDefaultCategoryEvent', () {
      final defaultCategoria = Categoria(
        id: 1,
        nombre: 'General',
        descripcion: 'Categoría por defecto para productos sin categoría específica',
        fechaCreacion: testDate,
      );

      blocTest<CategoriaBloc, CategoriaState>(
        'emits [CategoriaLoading, DefaultCategoryEnsured] when successful',
        build: () {
          when(mockEnsureDefaultCategory()).thenAnswer((_) async => defaultCategoria);
          return bloc;
        },
        act: (bloc) => bloc.add(EnsureDefaultCategoryEvent()),
        expect: () => [
          CategoriaLoading(),
          DefaultCategoryEnsured(defaultCategoria),
        ],
        verify: (_) {
          verify(mockEnsureDefaultCategory()).called(1);
        },
      );

      blocTest<CategoriaBloc, CategoriaState>(
        'emits [CategoriaLoading, CategoriaError] when fails',
        build: () {
          when(mockEnsureDefaultCategory()).thenThrow(const DatabaseException('Database error'));
          return bloc;
        },
        act: (bloc) => bloc.add(EnsureDefaultCategoryEvent()),
        expect: () => [
          CategoriaLoading(),
          const CategoriaError('Error de base de datos: Database error'),
        ],
        verify: (_) {
          verify(mockEnsureDefaultCategory()).called(1);
        },
      );
    });
  });
}