import 'package:flutter_test/flutter_test.dart';
import 'package:supermercado_comparador/features/productos/data/models/categoria_model.dart';
import 'package:supermercado_comparador/features/productos/domain/entities/categoria.dart';

void main() {
  group('CategoriaModel', () {
    final testDate = DateTime(2024, 1, 1);
    final testCategoriaModel = CategoriaModel(
      id: 1,
      nombre: 'Test Category',
      descripcion: 'Test Description',
      fechaCreacion: testDate,
    );

    test('should be a subclass of Categoria entity', () {
      expect(testCategoriaModel, isA<Categoria>());
    });

    group('fromJson', () {
      test('should return a valid model when JSON is valid', () {
        final Map<String, dynamic> jsonMap = {
          'id': 1,
          'nombre': 'Test Category',
          'descripcion': 'Test Description',
          'fecha_creacion': testDate.toIso8601String(),
        };

        final result = CategoriaModel.fromJson(jsonMap);

        expect(result, equals(testCategoriaModel));
      });

      test('should handle null optional fields', () {
        final Map<String, dynamic> jsonMap = {
          'id': 1,
          'nombre': 'Test Category',
          'descripcion': null,
          'fecha_creacion': testDate.toIso8601String(),
        };

        final result = CategoriaModel.fromJson(jsonMap);

        expect(result.descripcion, isNull);
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        final result = testCategoriaModel.toJson();

        final expectedMap = {
          'id': 1,
          'nombre': 'Test Category',
          'descripcion': 'Test Description',
          'fecha_creacion': testDate.toIso8601String(),
        };

        expect(result, equals(expectedMap));
      });
    });

    group('fromEntity', () {
      test('should create model from entity', () {
        final categoriaEntity = Categoria(
          id: 1,
          nombre: 'Test Category',
          descripcion: 'Test Description',
          fechaCreacion: testDate,
        );

        final result = CategoriaModel.fromEntity(categoriaEntity);

        expect(result, equals(testCategoriaModel));
      });
    });

    group('validate', () {
      test('should return null for valid data', () {
        final result = testCategoriaModel.validate();
        expect(result, isNull);
      });

      test('should return error for empty nombre', () {
        final invalidModel = CategoriaModel(
          id: testCategoriaModel.id,
          nombre: '',
          descripcion: testCategoriaModel.descripcion,
          fechaCreacion: testCategoriaModel.fechaCreacion,
        );
        final result = invalidModel.validate();
        expect(result, equals('El nombre de la categoría es obligatorio'));
      });

      test('should return error for short nombre', () {
        final invalidModel = CategoriaModel(
          id: testCategoriaModel.id,
          nombre: 'A',
          descripcion: testCategoriaModel.descripcion,
          fechaCreacion: testCategoriaModel.fechaCreacion,
        );
        final result = invalidModel.validate();
        expect(result, equals('El nombre de la categoría debe tener al menos 2 caracteres'));
      });

      test('should return error for long nombre', () {
        final invalidModel = CategoriaModel(
          id: testCategoriaModel.id,
          nombre: 'A' * 51,
          descripcion: testCategoriaModel.descripcion,
          fechaCreacion: testCategoriaModel.fechaCreacion,
        );
        final result = invalidModel.validate();
        expect(result, equals('El nombre de la categoría no puede exceder 50 caracteres'));
      });

      test('should return error for long descripcion', () {
        final invalidModel = CategoriaModel(
          id: testCategoriaModel.id,
          nombre: testCategoriaModel.nombre,
          descripcion: 'A' * 201,
          fechaCreacion: testCategoriaModel.fechaCreacion,
        );
        final result = invalidModel.validate();
        expect(result, equals('La descripción no puede exceder 200 caracteres'));
      });
    });
  });
}