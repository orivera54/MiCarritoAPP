import 'package:flutter_test/flutter_test.dart';
import 'package:supermercado_comparador/features/almacenes/data/models/almacen_model.dart';
import 'package:supermercado_comparador/features/almacenes/domain/entities/almacen.dart';

void main() {
  group('AlmacenModel', () {
    final testDate = DateTime(2024, 1, 1);
    final testAlmacenModel = AlmacenModel(
      id: 1,
      nombre: 'Test Almacen',
      direccion: 'Test Address',
      descripcion: 'Test Description',
      fechaCreacion: testDate,
      fechaActualizacion: testDate,
    );

    test('should be a subclass of Almacen entity', () {
      expect(testAlmacenModel, isA<Almacen>());
    });

    group('fromJson', () {
      test('should return a valid model when JSON is valid', () {
        final Map<String, dynamic> jsonMap = {
          'id': 1,
          'nombre': 'Test Almacen',
          'direccion': 'Test Address',
          'descripcion': 'Test Description',
          'fecha_creacion': testDate.toIso8601String(),
          'fecha_actualizacion': testDate.toIso8601String(),
        };

        final result = AlmacenModel.fromJson(jsonMap);

        expect(result, equals(testAlmacenModel));
      });

      test('should handle null optional fields', () {
        final Map<String, dynamic> jsonMap = {
          'id': 1,
          'nombre': 'Test Almacen',
          'direccion': null,
          'descripcion': null,
          'fecha_creacion': testDate.toIso8601String(),
          'fecha_actualizacion': testDate.toIso8601String(),
        };

        final result = AlmacenModel.fromJson(jsonMap);

        expect(result.direccion, isNull);
        expect(result.descripcion, isNull);
      });
    });

    group('toJson', () {
      test('should return a JSON map containing proper data', () {
        final result = testAlmacenModel.toJson();

        final expectedMap = {
          'id': 1,
          'nombre': 'Test Almacen',
          'direccion': 'Test Address',
          'descripcion': 'Test Description',
          'fecha_creacion': testDate.toIso8601String(),
          'fecha_actualizacion': testDate.toIso8601String(),
        };

        expect(result, equals(expectedMap));
      });
    });

    group('fromEntity', () {
      test('should create model from entity', () {
        final almacenEntity = Almacen(
          id: 1,
          nombre: 'Test Almacen',
          direccion: 'Test Address',
          descripcion: 'Test Description',
          fechaCreacion: testDate,
          fechaActualizacion: testDate,
        );

        final result = AlmacenModel.fromEntity(almacenEntity);

        expect(result, equals(testAlmacenModel));
      });
    });

    group('validate', () {
      test('should return null for valid data', () {
        final result = testAlmacenModel.validate();
        expect(result, isNull);
      });

      test('should return error for empty nombre', () {
        final invalidModel = testAlmacenModel.copyWith(nombre: '');
        final result = (invalidModel).validate();
        expect(result, equals('El nombre del almacén es obligatorio'));
      });

      test('should return error for short nombre', () {
        final invalidModel = testAlmacenModel.copyWith(nombre: 'A');
        final result = (invalidModel).validate();
        expect(result, equals('El nombre del almacén debe tener al menos 2 caracteres'));
      });

      test('should return error for long nombre', () {
        final invalidModel = testAlmacenModel.copyWith(nombre: 'A' * 101);
        final result = (invalidModel).validate();
        expect(result, equals('El nombre del almacén no puede exceder 100 caracteres'));
      });

      test('should return error for long direccion', () {
        final invalidModel = testAlmacenModel.copyWith(direccion: 'A' * 201);
        final result = (invalidModel).validate();
        expect(result, equals('La dirección no puede exceder 200 caracteres'));
      });

      test('should return error for long descripcion', () {
        final invalidModel = testAlmacenModel.copyWith(descripcion: 'A' * 501);
        final result = (invalidModel).validate();
        expect(result, equals('La descripción no puede exceder 500 caracteres'));
      });
    });
  });
}