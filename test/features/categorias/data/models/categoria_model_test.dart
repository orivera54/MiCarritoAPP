import 'package:flutter_test/flutter_test.dart';
import 'package:supermercado_comparador/features/categorias/data/models/categoria_model.dart';
import 'package:supermercado_comparador/features/categorias/domain/entities/categoria.dart';

void main() {
  group('CategoriaModel', () {
    final testDate = DateTime(2024, 1, 1);
    
    final testCategoriaModel = CategoriaModel(
      id: 1,
      nombre: 'Lácteos',
      descripcion: 'Productos lácteos y derivados',
      fechaCreacion: testDate,
    );

    final testJson = {
      'id': 1,
      'nombre': 'Lácteos',
      'descripcion': 'Productos lácteos y derivados',
      'fecha_creacion': testDate.toIso8601String(),
    };

    group('fromJson', () {
      test('should return a valid CategoriaModel from JSON', () {
        // Act
        final result = CategoriaModel.fromJson(testJson);

        // Assert
        expect(result, equals(testCategoriaModel));
      });

      test('should handle null descripcion', () {
        // Arrange
        final jsonWithNullDescripcion = {
          'id': 1,
          'nombre': 'Lácteos',
          'descripcion': null,
          'fecha_creacion': testDate.toIso8601String(),
        };

        // Act
        final result = CategoriaModel.fromJson(jsonWithNullDescripcion);

        // Assert
        expect(result.descripcion, isNull);
        expect(result.nombre, equals('Lácteos'));
      });
    });

    group('toJson', () {
      test('should return a valid JSON map', () {
        // Act
        final result = testCategoriaModel.toJson();

        // Assert
        expect(result, equals(testJson));
      });

      test('should handle null descripcion', () {
        // Arrange
        final categoriaWithNullDescripcion = CategoriaModel(
          id: 1,
          nombre: 'Lácteos',
          descripcion: null,
          fechaCreacion: testDate,
        );

        // Act
        final result = categoriaWithNullDescripcion.toJson();

        // Assert
        expect(result['descripcion'], isNull);
      });
    });

    group('fromEntity', () {
      test('should create CategoriaModel from Categoria entity', () {
        // Arrange
        final categoria = Categoria(
          id: 1,
          nombre: 'Lácteos',
          descripcion: 'Productos lácteos y derivados',
          fechaCreacion: testDate,
        );

        // Act
        final result = CategoriaModel.fromEntity(categoria);

        // Assert
        expect(result, equals(testCategoriaModel));
      });
    });

    group('validate', () {
      test('should return null for valid categoria', () {
        // Act
        final result = testCategoriaModel.validate();

        // Assert
        expect(result, isNull);
      });

      test('should return error for empty nombre', () {
        // Arrange
        final invalidCategoria = testCategoriaModel.copyWith(nombre: '');

        // Act
        final result = invalidCategoria.validate();

        // Assert
        expect(result, equals('El nombre de la categoría es obligatorio'));
      });

      test('should return error for whitespace-only nombre', () {
        // Arrange
        final invalidCategoria = testCategoriaModel.copyWith(nombre: '   ');

        // Act
        final result = invalidCategoria.validate();

        // Assert
        expect(result, equals('El nombre de la categoría es obligatorio'));
      });

      test('should return error for short nombre', () {
        // Arrange
        final invalidCategoria = testCategoriaModel.copyWith(nombre: 'A');

        // Act
        final result = invalidCategoria.validate();

        // Assert
        expect(result, equals('El nombre de la categoría debe tener al menos 2 caracteres'));
      });

      test('should return error for long nombre', () {
        // Arrange
        final longName = 'A' * 51;
        final invalidCategoria = testCategoriaModel.copyWith(nombre: longName);

        // Act
        final result = invalidCategoria.validate();

        // Assert
        expect(result, equals('El nombre de la categoría no puede exceder 50 caracteres'));
      });

      test('should return error for long descripcion', () {
        // Arrange
        final longDescription = 'A' * 201;
        final invalidCategoria = testCategoriaModel.copyWith(descripcion: longDescription);

        // Act
        final result = invalidCategoria.validate();

        // Assert
        expect(result, equals('La descripción no puede exceder 200 caracteres'));
      });

      test('should accept null descripcion', () {
        // Arrange
        final categoriaWithNullDescripcion = testCategoriaModel.copyWith(descripcion: null);

        // Act
        final result = categoriaWithNullDescripcion.validate();

        // Assert
        expect(result, isNull);
      });
    });

    group('copyWith', () {
      test('should create a copy with updated values', () {
        // Act
        final result = testCategoriaModel.copyWith(
          nombre: 'Carnes',
          descripcion: 'Productos cárnicos',
        );

        // Assert
        expect(result.id, equals(testCategoriaModel.id));
        expect(result.nombre, equals('Carnes'));
        expect(result.descripcion, equals('Productos cárnicos'));
        expect(result.fechaCreacion, equals(testCategoriaModel.fechaCreacion));
      });

      test('should keep original values when no parameters provided', () {
        // Act
        final result = testCategoriaModel.copyWith();

        // Assert
        expect(result, equals(testCategoriaModel));
      });
    });

    group('equality', () {
      test('should be equal when all properties are the same', () {
        // Arrange
        final categoria1 = CategoriaModel(
          id: 1,
          nombre: 'Lácteos',
          descripcion: 'Productos lácteos',
          fechaCreacion: testDate,
        );
        
        final categoria2 = CategoriaModel(
          id: 1,
          nombre: 'Lácteos',
          descripcion: 'Productos lácteos',
          fechaCreacion: testDate,
        );

        // Assert
        expect(categoria1, equals(categoria2));
      });

      test('should not be equal when properties differ', () {
        // Arrange
        final categoria1 = testCategoriaModel;
        final categoria2 = testCategoriaModel.copyWith(nombre: 'Carnes');

        // Assert
        expect(categoria1, isNot(equals(categoria2)));
      });
    });
  });
}