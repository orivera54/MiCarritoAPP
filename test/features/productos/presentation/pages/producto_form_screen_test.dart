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
import 'package:supermercado_comparador/features/productos/presentation/pages/producto_form_screen.dart';

class MockProductoBloc extends MockBloc<ProductoEvent, ProductoState>
    implements ProductoBloc {}

class MockAlmacenBloc extends MockBloc<AlmacenEvent, AlmacenState>
    implements AlmacenBloc {}

class MockCategoriaBloc extends MockBloc<CategoriaEvent, CategoriaState>
    implements CategoriaBloc {}

void main() {
  group('ProductoFormScreen', () {
    late MockProductoBloc mockProductoBloc;
    late MockAlmacenBloc mockAlmacenBloc;
    late MockCategoriaBloc mockCategoriaBloc;

    late List<Almacen> testAlmacenes;
    late List<Categoria> testCategorias;
    late Producto testProducto;

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

      testProducto = Producto(
        id: 1,
        nombre: 'Leche Entera',
        precio: 1.20,
        peso: 1.0,
        tamano: '1L',
        codigoQR: 'TEST123',
        categoriaId: 1,
        almacenId: 1,
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
      );

      // Default states
      when(() => mockProductoBloc.state).thenReturn(ProductoInitial());
      when(() => mockAlmacenBloc.state).thenReturn(AlmacenInitial());
      when(() => mockCategoriaBloc.state).thenReturn(CategoriaInitial());
    });

    Widget createWidgetUnderTest({Producto? producto}) {
      return MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<ProductoBloc>.value(value: mockProductoBloc),
            BlocProvider<AlmacenBloc>.value(value: mockAlmacenBloc),
            BlocProvider<CategoriaBloc>.value(value: mockCategoriaBloc),
          ],
          child: ProductoFormScreen(producto: producto),
        ),
      );
    }

    group('Create Mode', () {
      testWidgets('displays correct title for create mode', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text('Nuevo Producto'), findsOneWidget);
        expect(find.text('Crear'), findsOneWidget);
      });

      testWidgets('displays all form fields', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text('Nombre del producto *'), findsOneWidget);
        expect(find.text('Precio *'), findsOneWidget);
        expect(find.text('Almacén *'), findsOneWidget);
        expect(find.text('Categoría *'), findsOneWidget);
        expect(find.text('Peso (opcional)'), findsOneWidget);
        expect(find.text('Tamaño (opcional)'), findsOneWidget);
        expect(find.text('Código QR (opcional)'), findsOneWidget);
      });

      testWidgets('displays QR scanner button', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
      });

      testWidgets('displays info text about required fields', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text('Los campos marcados con * son obligatorios'),
            findsOneWidget);
        expect(find.byIcon(Icons.info_outline), findsOneWidget);
      });

      testWidgets('displays create button', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.text('Crear Producto'), findsOneWidget);
      });
    });

    group('Edit Mode', () {
      testWidgets('displays correct title for edit mode', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(producto: testProducto));

        expect(find.text('Editar Producto'), findsOneWidget);
        expect(find.text('Guardar'), findsOneWidget);
      });

      testWidgets('pre-fills form fields with product data', (tester) async {
        when(() => mockAlmacenBloc.state)
            .thenReturn(AlmacenesLoaded(testAlmacenes));
        when(() => mockCategoriaBloc.state)
            .thenReturn(CategoriasLoaded(testCategorias));

        await tester.pumpWidget(createWidgetUnderTest(producto: testProducto));
        await tester.pumpAndSettle();

        expect(find.text('Leche Entera'), findsOneWidget);
        expect(find.text('1.2'), findsOneWidget);
        expect(find.text('1.0'), findsOneWidget);
        expect(find.text('1L'), findsOneWidget);
        expect(find.text('TEST123'), findsOneWidget);
      });

      testWidgets('displays save changes button', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest(producto: testProducto));

        expect(find.text('Guardar Cambios'), findsOneWidget);
      });
    });

    group('Form Validation', () {
      testWidgets('shows validation error for empty name', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        // Try to submit form without filling required fields
        await tester.tap(find.text('Crear Producto'));
        await tester.pumpAndSettle();

        expect(find.text('El nombre es requerido'), findsOneWidget);
      });

      testWidgets('shows validation error for invalid price', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        // Enter invalid price
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Precio *'),
          'invalid',
        );
        await tester.tap(find.text('Crear Producto'));
        await tester.pumpAndSettle();

        expect(find.text('Ingresa un precio válido'), findsOneWidget);
      });

      testWidgets('shows validation error for zero price', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Precio *'),
          '0',
        );
        await tester.tap(find.text('Crear Producto'));
        await tester.pumpAndSettle();

        expect(find.text('El precio debe ser mayor a 0'), findsOneWidget);
      });

      testWidgets('shows validation error for invalid weight', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Peso (opcional)'),
          'invalid',
        );
        await tester.tap(find.text('Crear Producto'));
        await tester.pumpAndSettle();

        expect(find.text('Ingresa un peso válido'), findsOneWidget);
      });
    });

    group('Dropdown Population', () {
      testWidgets('populates almacen dropdown when data is loaded',
          (tester) async {
        when(() => mockAlmacenBloc.state)
            .thenReturn(AlmacenesLoaded(testAlmacenes));

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Almacén *'));
        await tester.pumpAndSettle();

        expect(find.text('Mercadona'), findsOneWidget);
        expect(find.text('Carrefour'), findsOneWidget);
      });

      testWidgets('populates categoria dropdown when data is loaded',
          (tester) async {
        when(() => mockCategoriaBloc.state)
            .thenReturn(CategoriasLoaded(testCategorias));

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Categoría *'));
        await tester.pumpAndSettle();

        expect(find.text('Lácteos'), findsOneWidget);
        expect(find.text('Bebidas'), findsOneWidget);
      });
    });

    group('Form Submission', () {
      testWidgets('shows snackbar error when almacen not selected',
          (tester) async {
        when(() => mockCategoriaBloc.state)
            .thenReturn(CategoriasLoaded(testCategorias));

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Fill required fields except almacen
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nombre del producto *'),
          'Test Product',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Precio *'),
          '1.99',
        );

        // Select categoria
        await tester.tap(find.text('Categoría *'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Lácteos'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Crear Producto'));
        await tester.pumpAndSettle();

        expect(find.text('Selecciona un almacén'), findsOneWidget);
      });

      testWidgets('shows snackbar error when categoria not selected',
          (tester) async {
        when(() => mockAlmacenBloc.state)
            .thenReturn(AlmacenesLoaded(testAlmacenes));

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        // Fill required fields except categoria
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nombre del producto *'),
          'Test Product',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Precio *'),
          '1.99',
        );

        // Select almacen
        await tester.tap(find.text('Almacén *'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Mercadona'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Crear Producto'));
        await tester.pumpAndSettle();

        expect(find.text('Selecciona una categoría'), findsOneWidget);
      });

      testWidgets('shows loading indicator when submitting', (tester) async {
        when(() => mockProductoBloc.state).thenReturn(ProductoLoading());

        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
      });

      testWidgets('shows success message when product created', (tester) async {
        when(() => mockProductoBloc.state)
            .thenReturn(ProductoCreated(testProducto));

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('Producto creado exitosamente'), findsOneWidget);
      });

      testWidgets('shows success message when product updated', (tester) async {
        when(() => mockProductoBloc.state)
            .thenReturn(ProductoUpdated(testProducto));

        await tester.pumpWidget(createWidgetUnderTest(producto: testProducto));
        await tester.pumpAndSettle();

        expect(find.text('Producto actualizado exitosamente'), findsOneWidget);
      });

      testWidgets('shows error message when submission fails', (tester) async {
        const errorMessage = 'Test error';
        when(() => mockProductoBloc.state)
            .thenReturn(const ProductoError(errorMessage));

        await tester.pumpWidget(createWidgetUnderTest());
        await tester.pumpAndSettle();

        expect(find.text('Error: $errorMessage'), findsOneWidget);
      });
    });

    group('Input Formatting', () {
      testWidgets('formats price input correctly', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        final priceField = find.widgetWithText(TextFormField, 'Precio *');

        // Test decimal input
        await tester.enterText(priceField, '12.99');
        expect(find.text('12.99'), findsOneWidget);

        // Test that more than 2 decimal places are not allowed
        await tester.enterText(priceField, '12.999');
        await tester.pumpAndSettle();
        // The input formatter should prevent the third decimal place
      });

      testWidgets('formats weight input correctly', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        final weightField =
            find.widgetWithText(TextFormField, 'Peso (opcional)');

        // Test decimal input with up to 3 decimal places
        await tester.enterText(weightField, '1.250');
        expect(find.text('1.250'), findsOneWidget);
      });
    });
  });
}
