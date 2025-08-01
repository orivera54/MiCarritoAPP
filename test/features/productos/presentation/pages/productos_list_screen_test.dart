import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supermercado_comparador/features/almacenes/domain/entities/almacen.dart';
import 'package:supermercado_comparador/features/almacenes/presentation/bloc/almacen_bloc.dart';
import 'package:supermercado_comparador/features/almacenes/presentation/bloc/almacen_event.dart';
import 'package:supermercado_comparador/features/almacenes/presentation/bloc/almacen_state.dart';
import 'package:supermercado_comparador/features/categorias/domain/entities/categoria.dart';
import 'package:supermercado_comparador/features/categorias/presentation/bloc/categoria_bloc.dart';
import 'package:supermercado_comparador/features/categorias/presentation/bloc/categoria_event.dart';
import 'package:supermercado_comparador/features/categorias/presentation/bloc/categoria_state.dart';
import 'package:supermercado_comparador/features/productos/domain/entities/producto.dart';
import 'package:supermercado_comparador/features/productos/presentation/bloc/producto_bloc.dart';
import 'package:supermercado_comparador/features/productos/presentation/bloc/producto_event.dart';
import 'package:supermercado_comparador/features/productos/presentation/bloc/producto_state.dart';
import 'package:supermercado_comparador/features/productos/presentation/pages/productos_list_screen.dart';

class MockProductoBloc extends MockBloc<ProductoEvent, ProductoState>
    implements ProductoBloc {}

class MockAlmacenBloc extends MockBloc<AlmacenEvent, AlmacenState>
    implements AlmacenBloc {}

class MockCategoriaBloc extends MockBloc<CategoriaEvent, CategoriaState>
    implements CategoriaBloc {}

void main() {
  group('ProductosListScreen', () {
    late MockProductoBloc mockProductoBloc;
    late MockAlmacenBloc mockAlmacenBloc;
    late MockCategoriaBloc mockCategoriaBloc;

    late List<Producto> testProductos;
    late List<Almacen> testAlmacenes;
    late List<Categoria> testCategorias;

    setUp(() {
      mockProductoBloc = MockProductoBloc();
      mockAlmacenBloc = MockAlmacenBloc();
      mockCategoriaBloc = MockCategoriaBloc();

      testAlmacenes = [
        Almacen(
          id: 1,
          nombre: 'Mercadona',
          fechaCreacion: DateTime.now(),
          fechaActualizacion: DateTime.now(),
        ),
        Almacen(
          id: 2,
          nombre: 'Carrefour',
          fechaCreacion: DateTime.now(),
          fechaActualizacion: DateTime.now(),
        ),
      ];

      testCategorias = [
        Categoria(
          id: 1,
          nombre: 'Lácteos',
          fechaCreacion: DateTime.now(),
        ),
        Categoria(
          id: 2,
          nombre: 'Bebidas',
          fechaCreacion: DateTime.now(),
        ),
      ];

      testProductos = [
        Producto(
          id: 1,
          nombre: 'Leche Entera',
          precio: 1.20,
          categoriaId: 1,
          almacenId: 1,
          fechaCreacion: DateTime.now(),
          fechaActualizacion: DateTime.now(),
        ),
        Producto(
          id: 2,
          nombre: 'Agua Mineral',
          precio: 0.80,
          categoriaId: 2,
          almacenId: 2,
          fechaCreacion: DateTime.now(),
          fechaActualizacion: DateTime.now(),
        ),
      ];

      // Default states
      when(() => mockProductoBloc.state).thenReturn(ProductoInitial());
      when(() => mockAlmacenBloc.state).thenReturn(AlmacenInitial());
      when(() => mockCategoriaBloc.state).thenReturn(CategoriaInitial());
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<ProductoBloc>.value(value: mockProductoBloc),
            BlocProvider<AlmacenBloc>.value(value: mockAlmacenBloc),
            BlocProvider<CategoriaBloc>.value(value: mockCategoriaBloc),
          ],
          child: const ProductosListScreen(),
        ),
      );
    }

    testWidgets('displays app bar with correct title and actions',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Productos'), findsOneWidget);
      expect(find.byIcon(Icons.filter_list_off), findsOneWidget);
      expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
    });

    testWidgets('displays search field', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Buscar productos...'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('displays floating action button', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('shows loading indicator when ProductoLoading', (tester) async {
      when(() => mockProductoBloc.state).thenReturn(ProductoLoading());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message when ProductoError', (tester) async {
      const errorMessage = 'Test error message';
      when(() => mockProductoBloc.state)
          .thenReturn(const ProductoError(errorMessage));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Error: $errorMessage'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('displays products when ProductoLoaded', (tester) async {
      when(() => mockProductoBloc.state)
          .thenReturn(ProductoLoaded(testProductos));
      when(() => mockAlmacenBloc.state)
          .thenReturn(AlmacenesLoaded(testAlmacenes));
      when(() => mockCategoriaBloc.state)
          .thenReturn(CategoriasLoaded(testCategorias));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Leche Entera'), findsOneWidget);
      expect(find.text('Agua Mineral'), findsOneWidget);
    });

    testWidgets('shows empty state when no products', (tester) async {
      when(() => mockProductoBloc.state).thenReturn(const ProductoLoaded([]));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('No hay productos registrados'), findsOneWidget);
      expect(find.text('Agrega tu primer producto usando el botón +'),
          findsOneWidget);
      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    });

    testWidgets('displays search results with info', (tester) async {
      const searchTerm = 'leche';
      when(() => mockProductoBloc.state).thenReturn(
        ProductoSearchResults([testProductos.first], searchTerm),
      );
      when(() => mockAlmacenBloc.state)
          .thenReturn(AlmacenesLoaded(testAlmacenes));
      when(() => mockCategoriaBloc.state)
          .thenReturn(CategoriasLoaded(testCategorias));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Resultados para: "$searchTerm"'), findsOneWidget);
      expect(find.text('Leche Entera'), findsOneWidget);
    });

    testWidgets('displays QR result with info', (tester) async {
      const qrCode = 'TEST123';
      when(() => mockProductoBloc.state).thenReturn(
        ProductoQRResult(testProductos.first, qrCode),
      );
      when(() => mockAlmacenBloc.state)
          .thenReturn(AlmacenesLoaded(testAlmacenes));
      when(() => mockCategoriaBloc.state)
          .thenReturn(CategoriasLoaded(testCategorias));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Producto encontrado por QR: $qrCode'), findsOneWidget);
      expect(find.text('Leche Entera'), findsOneWidget);
    });

    testWidgets('displays QR not found message', (tester) async {
      const qrCode = 'NOTFOUND';
      when(() => mockProductoBloc.state).thenReturn(
        const ProductoQRResult(null, qrCode),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(
          find.text('No se encontró producto con QR: $qrCode'), findsOneWidget);
    });

    testWidgets('toggles filters visibility', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Initially filters should not be visible
      expect(find.text('Filtros'), findsNothing);

      // Tap filter button
      await tester.tap(find.byIcon(Icons.filter_list_off));
      await tester.pumpAndSettle();

      // Filters should now be visible
      expect(find.text('Filtros'), findsOneWidget);
      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });

    testWidgets('shows filters section when enabled', (tester) async {
      when(() => mockAlmacenBloc.state)
          .thenReturn(AlmacenesLoaded(testAlmacenes));
      when(() => mockCategoriaBloc.state)
          .thenReturn(CategoriasLoaded(testCategorias));

      await tester.pumpWidget(createWidgetUnderTest());

      // Enable filters
      await tester.tap(find.byIcon(Icons.filter_list_off));
      await tester.pumpAndSettle();

      expect(find.text('Filtros'), findsOneWidget);
      expect(find.text('Limpiar'), findsOneWidget);
      expect(find.text('Almacén'), findsOneWidget);
      expect(find.text('Categoría'), findsOneWidget);
      expect(find.text('Precio mín.'), findsOneWidget);
      expect(find.text('Precio máx.'), findsOneWidget);
    });

    testWidgets('clears search when clear button is tapped', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter search text
      await tester.enterText(find.byType(TextField), 'test search');
      await tester.pumpAndSettle();

      // Clear button should appear
      expect(find.byIcon(Icons.clear), findsOneWidget);

      // Tap clear button
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pumpAndSettle();

      // Text field should be empty
      expect(find.text('test search'), findsNothing);
    });

    testWidgets('performs search when text is entered', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextField), 'leche');
      await tester.pumpAndSettle();

      // Wait for debounce
      await tester.pump(const Duration(milliseconds: 600));

      verify(() =>
              mockProductoBloc.add(any(that: isA<SearchProductosByName>())))
          .called(1);
    });

    testWidgets('shows delete confirmation dialog', (tester) async {
      when(() => mockProductoBloc.state)
          .thenReturn(ProductoLoaded(testProductos));
      when(() => mockAlmacenBloc.state)
          .thenReturn(AlmacenesLoaded(testAlmacenes));
      when(() => mockCategoriaBloc.state)
          .thenReturn(CategoriasLoaded(testCategorias));

      await tester.pumpWidget(createWidgetUnderTest());

      // Find and tap delete button on first product card
      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();

      expect(find.text('Eliminar producto'), findsOneWidget);
      expect(find.text('¿Estás seguro de que quieres eliminar "Leche Entera"?'),
          findsOneWidget);
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Eliminar'), findsOneWidget);
    });
  });
}
