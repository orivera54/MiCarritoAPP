import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:supermercado_comparador/features/almacenes/domain/entities/almacen.dart';
import 'package:supermercado_comparador/features/almacenes/presentation/bloc/almacen_bloc.dart';
import 'package:supermercado_comparador/features/almacenes/presentation/bloc/almacen_state.dart';
import 'package:supermercado_comparador/features/categorias/domain/entities/categoria.dart';
import 'package:supermercado_comparador/features/categorias/presentation/bloc/categoria_bloc.dart';
import 'package:supermercado_comparador/features/categorias/presentation/bloc/categoria_state.dart';
import 'package:supermercado_comparador/features/productos/domain/entities/producto.dart';
import 'package:supermercado_comparador/features/productos/presentation/bloc/producto_bloc.dart';
import 'package:supermercado_comparador/features/productos/presentation/bloc/producto_state.dart';
import 'package:supermercado_comparador/features/productos/presentation/pages/producto_form_screen.dart';

class MockAlmacenBloc extends Mock implements AlmacenBloc {}
class MockCategoriaBloc extends Mock implements CategoriaBloc {}
class MockProductoBloc extends Mock implements ProductoBloc {}

void main() {
  group('ProductoFormScreen Multi-Almacén Tests', () {
    late MockAlmacenBloc mockAlmacenBloc;
    late MockCategoriaBloc mockCategoriaBloc;
    late MockProductoBloc mockProductoBloc;

    setUp(() {
      mockAlmacenBloc = MockAlmacenBloc();
      mockCategoriaBloc = MockCategoriaBloc();
      mockProductoBloc = MockProductoBloc();

      // Setup default streams
      when(mockAlmacenBloc.stream).thenAnswer((_) => Stream.value(const AlmacenesLoaded([])));
      when(mockCategoriaBloc.stream).thenAnswer((_) => Stream.value(const CategoriasLoaded([])));
      when(mockProductoBloc.stream).thenAnswer((_) => Stream.value(ProductoInitial()));
    });

    testWidgets('should load related products when editing', (WidgetTester tester) async {
      final testAlmacenes = [
        Almacen(
          id: 1,
          nombre: 'Almacén 1',
          fechaCreacion: DateTime.now(),
          fechaActualizacion: DateTime.now(),
        ),
        Almacen(
          id: 2,
          nombre: 'Almacén 2',
          fechaCreacion: DateTime.now(),
          fechaActualizacion: DateTime.now(),
        ),
      ];

      final List<Categoria> testCategorias = [
        Categoria(
          id: 1,
          nombre: 'Categoría 1',
          fechaCreacion: DateTime.now(),
        ),
      ];

      final testProducto = Producto(
        id: 1,
        nombre: 'Producto Test',
        precio: 10.0,
        categoriaId: 1,
        almacenId: 1,
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
      );

      final relatedProducts = [
        testProducto,
        Producto(
          id: 2,
          nombre: 'Producto Test',
          precio: 12.0,
          categoriaId: 1,
          almacenId: 2,
          fechaCreacion: DateTime.now(),
          fechaActualizacion: DateTime.now(),
        ),
      ];

      when(mockAlmacenBloc.state).thenReturn(AlmacenesLoaded(testAlmacenes));
      when(mockCategoriaBloc.state).thenReturn(CategoriasLoaded(testCategorias));
      when(mockProductoBloc.state).thenReturn(ProductoSearchResults(relatedProducts, 'Producto Test'));

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AlmacenBloc>.value(value: mockAlmacenBloc),
              BlocProvider<CategoriaBloc>.value(value: mockCategoriaBloc),
              BlocProvider<ProductoBloc>.value(value: mockProductoBloc),
            ],
            child: ProductoFormScreen(producto: testProducto),
          ),
        ),
      );

      await tester.pump();

      // Verify that the form is in editing mode
      expect(find.text('Editar Producto'), findsOneWidget);
      
      // Verify that the product name is populated
      expect(find.text('Producto Test'), findsOneWidget);
    });

    testWidgets('should show multi-almacen selector in edit mode', (WidgetTester tester) async {
      final testProducto = Producto(
        id: 1,
        nombre: 'Producto Test',
        precio: 10.0,
        categoriaId: 1,
        almacenId: 1,
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
      );

      when(mockAlmacenBloc.state).thenReturn(const AlmacenesLoaded([]));
      when(mockCategoriaBloc.state).thenReturn(const CategoriasLoaded([]));
      when(mockProductoBloc.state).thenReturn(ProductoInitial());

      await tester.pumpWidget(
        MaterialApp(
          home: MultiBlocProvider(
            providers: [
              BlocProvider<AlmacenBloc>.value(value: mockAlmacenBloc),
              BlocProvider<CategoriaBloc>.value(value: mockCategoriaBloc),
              BlocProvider<ProductoBloc>.value(value: mockProductoBloc),
            ],
            child: ProductoFormScreen(producto: testProducto),
          ),
        ),
      );

      await tester.pump();

      // Verify that the almacen precio selector is present
      expect(find.text('Almacenes y precios *'), findsOneWidget);
      
      // Verify edit mode info text
      expect(find.text('Puedes ver y editar los precios del producto en diferentes almacenes'), findsOneWidget);
    });
  });
}