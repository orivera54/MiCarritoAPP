import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:supermercado_comparador/core/database/database_helper.dart';
import 'package:supermercado_comparador/features/comparador/data/datasources/comparador_local_data_source.dart';

@GenerateMocks([DatabaseHelper, Database])
import 'comparador_local_data_source_test.mocks.dart';

void main() {
  late ComparadorLocalDataSourceImpl dataSource;
  late MockDatabaseHelper mockDatabaseHelper;
  late MockDatabase mockDatabase;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    mockDatabase = MockDatabase();
    dataSource = ComparadorLocalDataSourceImpl(databaseHelper: mockDatabaseHelper);
  });

  final testDate = DateTime(2024, 1, 1);

  final testProductoComparacionJson = {
    'producto_id': 1,
    'producto_nombre': 'Test Product',
    'producto_precio': 10.50,
    'producto_peso': 1.5,
    'producto_tamano': 'Medium',
    'producto_codigo_qr': 'QR123',
    'categoria_id': 1,
    'almacen_id': 1,
    'almacen_nombre': 'Test Store',
    'almacen_direccion': 'Test Address',
    'almacen_descripcion': 'Test Description',
    'producto_fecha_creacion': testDate.toIso8601String(),
    'producto_fecha_actualizacion': testDate.toIso8601String(),
    'almacen_fecha_creacion': testDate.toIso8601String(),
    'almacen_fecha_actualizacion': testDate.toIso8601String(),
    'es_mejor_precio': 1,
  };

  group('ComparadorLocalDataSourceImpl', () {
    group('buscarProductosSimilares', () {
      test('should return list of ProductoComparacionModel when search is successful', () async {
        // arrange
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery(any, any))
            .thenAnswer((_) async => [testProductoComparacionJson]);

        // act
        final result = await dataSource.buscarProductosSimilares('test');

        // assert
        expect(result.length, equals(1));
        expect(result.first.producto.nombre, equals('Test Product'));
        expect(result.first.almacen.nombre, equals('Test Store'));
        expect(result.first.esMejorPrecio, equals(true));
        verify(mockDatabase.rawQuery(any, ['%test%', '%test%']));
      });

      test('should return empty list when no products found', () async {
        // arrange
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery(any, any)).thenAnswer((_) async => []);

        // act
        final result = await dataSource.buscarProductosSimilares('nonexistent');

        // assert
        expect(result, isEmpty);
        verify(mockDatabase.rawQuery(any, ['%nonexistent%', '%nonexistent%']));
      });
    });

    group('compararPreciosProducto', () {
      test('should return comparison results for existing product', () async {
        // arrange
        final productoBaseJson = {
          'id': 1,
          'nombre': 'Test Product',
          'precio': 10.50,
          'peso': 1.5,
          'tamano': 'Medium',
          'codigo_qr': 'QR123',
          'categoria_id': 1,
          'almacen_id': 1,
          'fecha_creacion': testDate.toIso8601String(),
          'fecha_actualizacion': testDate.toIso8601String(),
        };

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(any, where: anyNamed('where'), whereArgs: anyNamed('whereArgs'), limit: anyNamed('limit')))
            .thenAnswer((_) async => [productoBaseJson]);
        when(mockDatabase.rawQuery(any, any))
            .thenAnswer((_) async => [testProductoComparacionJson]);

        // act
        final result = await dataSource.compararPreciosProducto(1);

        // assert
        expect(result.length, equals(1));
        expect(result.first.producto.nombre, equals('Test Product'));
        verify(mockDatabase.query(any, where: 'id = ?', whereArgs: [1], limit: 1));
        verify(mockDatabase.rawQuery(any, ['Test Product', 'Test Product']));
      });

      test('should return empty list when product not found', () async {
        // arrange
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.query(any, where: anyNamed('where'), whereArgs: anyNamed('whereArgs'), limit: anyNamed('limit')))
            .thenAnswer((_) async => []);

        // act
        final result = await dataSource.compararPreciosProducto(999);

        // assert
        expect(result, isEmpty);
        verify(mockDatabase.query(any, where: 'id = ?', whereArgs: [999], limit: 1));
        verifyNever(mockDatabase.rawQuery(any, any));
      });
    });

    group('buscarProductosPorQR', () {
      test('should return products with same QR code', () async {
        // arrange
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery(any, any))
            .thenAnswer((_) async => [testProductoComparacionJson]);

        // act
        final result = await dataSource.buscarProductosPorQR('QR123');

        // assert
        expect(result.length, equals(1));
        expect(result.first.producto.codigoQR, equals('QR123'));
        verify(mockDatabase.rawQuery(any, ['QR123', 'QR123']));
      });

      test('should return empty list when QR not found', () async {
        // arrange
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery(any, any)).thenAnswer((_) async => []);

        // act
        final result = await dataSource.buscarProductosPorQR('NONEXISTENT');

        // assert
        expect(result, isEmpty);
        verify(mockDatabase.rawQuery(any, ['NONEXISTENT', 'NONEXISTENT']));
      });
    });

    group('obtenerProductosSimilares', () {
      test('should return similar products based on name matching', () async {
        // arrange
        final similarProductJson = {
          'id': 1,
          'nombre': 'Test Product',
          'precio': 10.50,
          'almacen_id': 1,
          'almacen_nombre': 'Test Store',
          'coincidencias': 1,
        };

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery(any, any))
            .thenAnswer((_) async => [similarProductJson]);

        // act
        final result = await dataSource.obtenerProductosSimilares('test product');

        // assert
        expect(result.length, equals(1));
        expect(result.first['nombre'], equals('Test Product'));
        expect(result.first['coincidencias'], equals(1));
        verify(mockDatabase.rawQuery(any, ['%test%', '%product%']));
      });

      test('should return empty list for short search terms', () async {
        // arrange
        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);

        // act
        final result = await dataSource.obtenerProductosSimilares('ab');

        // assert
        expect(result, isEmpty);
        verifyNever(mockDatabase.rawQuery(any, any));
      });

      test('should handle single word search', () async {
        // arrange
        final similarProductJson = {
          'id': 1,
          'nombre': 'Test Product',
          'precio': 10.50,
          'almacen_id': 1,
          'almacen_nombre': 'Test Store',
          'coincidencias': 1,
        };

        when(mockDatabaseHelper.database).thenAnswer((_) async => mockDatabase);
        when(mockDatabase.rawQuery(any, any))
            .thenAnswer((_) async => [similarProductJson]);

        // act
        final result = await dataSource.obtenerProductosSimilares('test');

        // assert
        expect(result.length, equals(1));
        verify(mockDatabase.rawQuery(any, ['%test%']));
      });
    });
  });
}