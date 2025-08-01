import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supermercado_comparador/features/comparador/domain/services/comparador_service.dart';
import 'package:supermercado_comparador/features/productos/domain/repositories/producto_repository.dart';
import 'package:supermercado_comparador/features/almacenes/domain/repositories/almacen_repository.dart';
import 'package:supermercado_comparador/features/productos/domain/entities/producto.dart';
import 'package:supermercado_comparador/features/almacenes/domain/entities/almacen.dart';

import 'comparador_service_multi_almacen_test.mocks.dart';

@GenerateMocks([
  ProductoRepository,
  AlmacenRepository,
])
void main() {
  late ComparadorService service;
  late MockProductoRepository mockProductoRepository;
  late MockAlmacenRepository mockAlmacenRepository;

  setUp(() {
    mockProductoRepository = MockProductoRepository();
    mockAlmacenRepository = MockAlmacenRepository();
    service = ComparadorService(
      productoRepository: mockProductoRepository,
      almacenRepository: mockAlmacenRepository,
    );
  });

  group('ComparadorService - obtenerAlmacenesProducto', () {
    final testAlmacen1 = Almacen(
      id: 1,
      nombre: 'Almacen A',
      fechaCreacion: DateTime.now(),
      fechaActualizacion: DateTime.now(),
    );

    final testAlmacen2 = Almacen(
      id: 2,
      nombre: 'Almacen B',
      fechaCreacion: DateTime.now(),
      fechaActualizacion: DateTime.now(),
    );

    final testProducto1 = Producto(
      id: 1,
      nombre: 'Leche',
      precio: 5.0,
      peso: 1.0,
      tamano: '1L',
      codigoQR: 'QR123',
      categoriaId: 1,
      almacenId: 1,
      fechaCreacion: DateTime.now(),
      fechaActualizacion: DateTime.now(),
    );

    final testProducto2 = Producto(
      id: 2,
      nombre: 'Leche',
      precio: 4.5,
      peso: 1.0,
      tamano: '1L',
      codigoQR: 'QR124',
      categoriaId: 1,
      almacenId: 2,
      fechaCreacion: DateTime.now(),
      fechaActualizacion: DateTime.now(),
    );

    test('should return empty list when no products found', () async {
      // Arrange
      when(mockProductoRepository.searchProductosByName('Inexistente'))
          .thenAnswer((_) async => []);

      // Act
      final result = await service.obtenerAlmacenesProducto('Inexistente');

      // Assert
      expect(result, isEmpty);
      verify(mockProductoRepository.searchProductosByName('Inexistente')).called(1);
    });

    test('should return products ordered by price with best price marked', () async {
      // Arrange
      when(mockProductoRepository.searchProductosByName('Leche'))
          .thenAnswer((_) async => [testProducto1, testProducto2]);
      when(mockAlmacenRepository.getAllAlmacenes())
          .thenAnswer((_) async => [testAlmacen1, testAlmacen2]);

      // Act
      final result = await service.obtenerAlmacenesProducto('Leche');

      // Assert
      expect(result, hasLength(2));
      
      // Should be ordered by price (ascending)
      expect(result[0].precio, equals(4.5));
      expect(result[1].precio, equals(5.0));
      
      // Best price should be marked
      expect(result[0].esMejorPrecio, isTrue);
      expect(result[1].esMejorPrecio, isFalse);
      
      // Almacen names should be correct
      expect(result[0].almacenNombre, equals('Almacen B'));
      expect(result[1].almacenNombre, equals('Almacen A'));
      
      verify(mockProductoRepository.searchProductosByName('Leche')).called(1);
      verify(mockAlmacenRepository.getAllAlmacenes()).called(1);
    });

    test('should mark multiple products as best price when they have same minimum price', () async {
      // Arrange
      final testProducto3 = testProducto2.copyWith(id: 3, almacenId: 1);
      
      when(mockProductoRepository.searchProductosByName('Leche'))
          .thenAnswer((_) async => [testProducto2, testProducto3]); // Both have price 4.5
      when(mockAlmacenRepository.getAllAlmacenes())
          .thenAnswer((_) async => [testAlmacen1, testAlmacen2]);

      // Act
      final result = await service.obtenerAlmacenesProducto('Leche');

      // Assert
      expect(result, hasLength(2));
      expect(result[0].esMejorPrecio, isTrue);
      expect(result[1].esMejorPrecio, isTrue);
      expect(result[0].precio, equals(4.5));
      expect(result[1].precio, equals(4.5));
    });

    test('should throw exception when almacen not found', () async {
      // Arrange
      when(mockProductoRepository.searchProductosByName('Leche'))
          .thenAnswer((_) async => [testProducto1]);
      when(mockAlmacenRepository.getAllAlmacenes())
          .thenAnswer((_) async => []); // No almacenes

      // Act & Assert
      expect(
        () => service.obtenerAlmacenesProducto('Leche'),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle repository errors gracefully', () async {
      // Arrange
      when(mockProductoRepository.searchProductosByName('Leche'))
          .thenThrow(Exception('Database error'));

      // Act & Assert
      expect(
        () => service.obtenerAlmacenesProducto('Leche'),
        throwsA(isA<Exception>()),
      );
    });
  });
}