import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:supermercado_comparador/core/initialization/app_initialization_service.dart';
import 'package:supermercado_comparador/core/initialization/app_initialization_result.dart';
import 'package:supermercado_comparador/core/database/database_helper.dart';
import 'package:supermercado_comparador/features/categorias/domain/usecases/ensure_default_category.dart';
import 'package:supermercado_comparador/features/almacenes/domain/usecases/get_all_almacenes.dart';
import 'package:supermercado_comparador/features/categorias/domain/usecases/get_all_categorias.dart';
import 'package:supermercado_comparador/features/categorias/domain/entities/categoria.dart';
import 'package:supermercado_comparador/features/almacenes/domain/entities/almacen.dart';

import 'app_initialization_service_test.mocks.dart';

@GenerateMocks([EnsureDefaultCategory, GetAllAlmacenes, GetAllCategorias, DatabaseHelper, Database])
void main() {
  group('AppInitializationService', () {
    late MockEnsureDefaultCategory mockEnsureDefaultCategory;
    late MockGetAllAlmacenes mockGetAllAlmacenes;
    late MockGetAllCategorias mockGetAllCategorias;
    late MockDatabaseHelper mockDatabaseHelper;
    late MockDatabase mockDatabase;

    setUp(() {
      mockEnsureDefaultCategory = MockEnsureDefaultCategory();
      mockGetAllAlmacenes = MockGetAllAlmacenes();
      mockGetAllCategorias = MockGetAllCategorias();
      mockDatabaseHelper = MockDatabaseHelper();
      mockDatabase = MockDatabase();
    });

    group('initialize', () {
      test('should return success with needsOnboarding true when no almacenes exist', () async {
        // Arrange
        final defaultCategory = Categoria(
          id: 1,
          nombre: 'General',
          descripcion: 'Categoría por defecto',
          fechaCreacion: DateTime.now(),
        );
        
        when(mockDatabaseHelper.database)
            .thenAnswer((_) async => mockDatabase);
        when(mockEnsureDefaultCategory.call())
            .thenAnswer((_) async => defaultCategory);
        when(mockGetAllCategorias.call())
            .thenAnswer((_) async => [defaultCategory]);
        when(mockGetAllAlmacenes.call())
            .thenAnswer((_) async => []);

        // Act
        final result = await AppInitializationService.initialize(
          ensureDefaultCategory: mockEnsureDefaultCategory,
          getAllAlmacenes: mockGetAllAlmacenes,
          getAllCategorias: mockGetAllCategorias,
          databaseHelper: mockDatabaseHelper,
        );

        // Assert
        expect(result.success, true);
        expect(result.isFirstRun, true);
        expect(result.needsOnboarding, true);
        expect(result.error, null);
        expect(result.metadata, isNotNull);
        expect(result.metadata['totalAlmacenes'], 0);
        expect(result.metadata['totalCategorias'], 1);
        
        verify(mockDatabaseHelper.database).called(1);
        verify(mockEnsureDefaultCategory.call()).called(1);
        verify(mockGetAllCategorias.call()).called(1);
        verify(mockGetAllAlmacenes.call()).called(1);
      });

      test('should return success with needsOnboarding false when almacenes exist', () async {
        // Arrange
        final defaultCategory = Categoria(
          id: 1,
          nombre: 'General',
          descripcion: 'Categoría por defecto',
          fechaCreacion: DateTime.now(),
        );
        
        final almacenes = [
          Almacen(
            id: 1,
            nombre: 'Supermercado Test',
            direccion: 'Test Address',
            descripcion: 'Test Description',
            fechaCreacion: DateTime.now(),
            fechaActualizacion: DateTime.now(),
          ),
        ];
        
        when(mockDatabaseHelper.database)
            .thenAnswer((_) async => mockDatabase);
        when(mockEnsureDefaultCategory.call())
            .thenAnswer((_) async => defaultCategory);
        when(mockGetAllCategorias.call())
            .thenAnswer((_) async => [defaultCategory]);
        when(mockGetAllAlmacenes.call())
            .thenAnswer((_) async => almacenes);

        // Act
        final result = await AppInitializationService.initialize(
          ensureDefaultCategory: mockEnsureDefaultCategory,
          getAllAlmacenes: mockGetAllAlmacenes,
          getAllCategorias: mockGetAllCategorias,
          databaseHelper: mockDatabaseHelper,
        );

        // Assert
        expect(result.success, true);
        expect(result.isFirstRun, false);
        expect(result.needsOnboarding, false);
        expect(result.error, null);
        expect(result.metadata, isNotNull);
        expect(result.metadata['totalAlmacenes'], 1);
        expect(result.metadata['totalCategorias'], 1);
        
        verify(mockDatabaseHelper.database).called(1);
        verify(mockEnsureDefaultCategory.call()).called(1);
        verify(mockGetAllCategorias.call()).called(1);
        verify(mockGetAllAlmacenes.call()).called(1);
      });

      test('should return failure when database initialization fails', () async {
        // Arrange
        when(mockDatabaseHelper.database)
            .thenThrow(Exception('Database error'));

        // Act
        final result = await AppInitializationService.initialize(
          ensureDefaultCategory: mockEnsureDefaultCategory,
          getAllAlmacenes: mockGetAllAlmacenes,
          getAllCategorias: mockGetAllCategorias,
          databaseHelper: mockDatabaseHelper,
        );

        // Assert
        expect(result.success, false);
        expect(result.isFirstRun, false);
        expect(result.needsOnboarding, false);
        expect(result.error, 'Exception: Database error');
        expect(result.metadata, isNotNull);
        expect(result.metadata['error'], 'Exception: Database error');
        
        verify(mockDatabaseHelper.database).called(1);
        verifyNever(mockEnsureDefaultCategory.call());
        verifyNever(mockGetAllCategorias.call());
        verifyNever(mockGetAllAlmacenes.call());
      });

      test('should return failure when ensure default category fails', () async {
        // Arrange
        when(mockDatabaseHelper.database)
            .thenAnswer((_) async => mockDatabase);
        when(mockEnsureDefaultCategory.call())
            .thenThrow(Exception('Category error'));

        // Act
        final result = await AppInitializationService.initialize(
          ensureDefaultCategory: mockEnsureDefaultCategory,
          getAllAlmacenes: mockGetAllAlmacenes,
          getAllCategorias: mockGetAllCategorias,
          databaseHelper: mockDatabaseHelper,
        );

        // Assert
        expect(result.success, false);
        expect(result.isFirstRun, false);
        expect(result.needsOnboarding, false);
        expect(result.error, 'Exception: Category error');
        
        verify(mockDatabaseHelper.database).called(1);
        verify(mockEnsureDefaultCategory.call()).called(1);
        verifyNever(mockGetAllCategorias.call());
        verifyNever(mockGetAllAlmacenes.call());
      });
    });

    group('AppInitializationResult', () {
      test('should create result with all parameters', () {
        // Act
        final result = AppInitializationResult(
          isFirstRun: true,
          needsOnboarding: true,
          success: true,
          error: 'Test error',
          metadata: {'test': 'value'},
        );

        // Assert
        expect(result.isFirstRun, true);
        expect(result.needsOnboarding, true);
        expect(result.success, true);
        expect(result.error, 'Test error');
        expect(result.metadata, {'test': 'value'});
      });

      test('should create result without error and metadata', () {
        // Act
        final result = AppInitializationResult(
          isFirstRun: false,
          needsOnboarding: false,
          success: true,
        );

        // Assert
        expect(result.isFirstRun, false);
        expect(result.needsOnboarding, false);
        expect(result.success, true);
        expect(result.error, null);
        expect(result.metadata, null);
      });

      test('should have proper toString representation', () {
        // Act
        final result = AppInitializationResult(
          isFirstRun: true,
          needsOnboarding: false,
          success: true,
          error: 'Test error',
          metadata: {'key': 'value'},
        );

        // Assert
        final toString = result.toString();
        expect(toString, contains('AppInitializationResult'));
        expect(toString, contains('isFirstRun: true'));
        expect(toString, contains('needsOnboarding: false'));
        expect(toString, contains('success: true'));
        expect(toString, contains('error: Test error'));
        expect(toString, contains('metadata: {key: value}'));
      });
    });
  });
}