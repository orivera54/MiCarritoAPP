import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:supermercado_comparador/features/calculadora/presentation/widgets/agregar_producto_dialog.dart';
import 'package:supermercado_comparador/features/productos/presentation/bloc/producto_bloc.dart';
import 'package:supermercado_comparador/features/productos/presentation/bloc/producto_state.dart';
import 'package:supermercado_comparador/features/productos/domain/entities/producto.dart';

import 'agregar_producto_dialog_test.mocks.dart';

@GenerateMocks([ProductoBloc])
void main() {
  group('AgregarProductoDialog', () {
    late MockProductoBloc mockProductoBloc;
    late List<Producto> testProductos;

    setUp(() {
      mockProductoBloc = MockProductoBloc();
      testProductos = [
        Producto(
          id: 1,
          nombre: 'Product 1',
          precio: 10.0,
          peso: 0.5,
          tamano: 'Small',
          categoriaId: 1,
          almacenId: 1,
          fechaCreacion: DateTime.now(),
          fechaActualizacion: DateTime.now(),
        ),
        Producto(
          id: 2,
          nombre: 'Product 2',
          precio: 20.0,
          categoriaId: 1,
          almacenId: 1,
          fechaCreacion: DateTime.now(),
          fechaActualizacion: DateTime.now(),
        ),
      ];
    });

    Widget createWidgetUnderTest({
      Function(Producto, int)? onProductoSeleccionado,
    }) {
      return MaterialApp(
        home: BlocProvider<ProductoBloc>.value(
          value: mockProductoBloc,
          child: AgregarProductoDialog(
            onProductoSeleccionado:
                onProductoSeleccionado ?? (producto, cantidad) {},
          ),
        ),
      );
    }

    testWidgets('should display dialog title and close button', (tester) async {
      // arrange
      when(mockProductoBloc.state).thenReturn(ProductoLoaded(testProductos));
      when(mockProductoBloc.stream)
          .thenAnswer((_) => Stream.value(ProductoLoaded(testProductos)));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Agregar producto'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should display search field', (tester) async {
      // arrange
      when(mockProductoBloc.state).thenReturn(ProductoLoaded(testProductos));
      when(mockProductoBloc.stream)
          .thenAnswer((_) => Stream.value(ProductoLoaded(testProductos)));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(TextField), findsAtLeastNWidgets(1));
      expect(find.text('Buscar productos...'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('should load all products on init', (tester) async {
      // arrange
      when(mockProductoBloc.state).thenReturn(ProductoLoaded(testProductos));
      when(mockProductoBloc.stream)
          .thenAnswer((_) => Stream.value(ProductoLoaded(testProductos)));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      verify(mockProductoBloc.add(any)).called(1);
    });

    testWidgets('should display loading indicator when loading',
        (tester) async {
      // arrange
      when(mockProductoBloc.state).thenReturn(ProductoLoading());
      when(mockProductoBloc.stream)
          .thenAnswer((_) => Stream.value(ProductoLoading()));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display error message when error occurs',
        (tester) async {
      // arrange
      when(mockProductoBloc.state)
          .thenReturn(const ProductoError('Test error'));
      when(mockProductoBloc.stream)
          .thenAnswer((_) => Stream.value(const ProductoError('Test error')));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Error al cargar productos'), findsOneWidget);
      expect(find.text('Test error'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should display products list when loaded', (tester) async {
      // arrange
      when(mockProductoBloc.state).thenReturn(ProductoLoaded(testProductos));
      when(mockProductoBloc.stream)
          .thenAnswer((_) => Stream.value(ProductoLoaded(testProductos)));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Product 1'), findsOneWidget);
      expect(find.text('Product 2'), findsOneWidget);
      expect(find.text('€10.00'), findsOneWidget);
      expect(find.text('€20.00'), findsOneWidget);
    });

    testWidgets('should display empty state when no products found',
        (tester) async {
      // arrange
      when(mockProductoBloc.state).thenReturn(const ProductoLoaded([]));
      when(mockProductoBloc.stream)
          .thenAnswer((_) => Stream.value(const ProductoLoaded([])));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('No se encontraron productos'), findsOneWidget);
      expect(find.byIcon(Icons.inventory_2_outlined), findsOneWidget);
    });

    testWidgets('should select product when tapped', (tester) async {
      // arrange
      when(mockProductoBloc.state).thenReturn(ProductoLoaded(testProductos));
      when(mockProductoBloc.stream)
          .thenAnswer((_) => Stream.value(ProductoLoaded(testProductos)));

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Product 1'));
      await tester.pump();

      // assert
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should show cantidad controls when product is selected',
        (tester) async {
      // arrange
      when(mockProductoBloc.state).thenReturn(ProductoLoaded(testProductos));
      when(mockProductoBloc.stream)
          .thenAnswer((_) => Stream.value(ProductoLoaded(testProductos)));

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Product 1'));
      await tester.pump();

      // assert
      expect(find.text('Cantidad:'), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.add), findsAtLeastNWidgets(1));
      expect(find.text('Subtotal: €10.00'), findsOneWidget);
    });

    testWidgets('should enable agregar button when product is selected',
        (tester) async {
      // arrange
      when(mockProductoBloc.state).thenReturn(ProductoLoaded(testProductos));
      when(mockProductoBloc.stream)
          .thenAnswer((_) => Stream.value(ProductoLoaded(testProductos)));

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Product 1'));
      await tester.pump();

      // assert
      final agregarButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Agregar'),
      );
      expect(agregarButton.onPressed, isNotNull);
    });

    testWidgets('should disable agregar button when no product is selected',
        (tester) async {
      // arrange
      when(mockProductoBloc.state).thenReturn(ProductoLoaded(testProductos));
      when(mockProductoBloc.stream)
          .thenAnswer((_) => Stream.value(ProductoLoaded(testProductos)));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      final agregarButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Agregar'),
      );
      expect(agregarButton.onPressed, isNull);
    });

    testWidgets('should call onProductoSeleccionado when agregar is tapped',
        (tester) async {
      // arrange
      Producto? selectedProducto;
      int? selectedCantidad;

      when(mockProductoBloc.state).thenReturn(ProductoLoaded(testProductos));
      when(mockProductoBloc.stream)
          .thenAnswer((_) => Stream.value(ProductoLoaded(testProductos)));

      // act
      await tester.pumpWidget(createWidgetUnderTest(
        onProductoSeleccionado: (producto, cantidad) {
          selectedProducto = producto;
          selectedCantidad = cantidad;
        },
      ));

      await tester.tap(find.text('Product 1'));
      await tester.pump();
      await tester.tap(find.text('Agregar'));
      await tester.pump();

      // assert
      expect(selectedProducto?.id, equals(1));
      expect(selectedCantidad, equals(1));
    });

    testWidgets('should update cantidad when add/remove buttons are tapped',
        (tester) async {
      // arrange
      when(mockProductoBloc.state).thenReturn(ProductoLoaded(testProductos));
      when(mockProductoBloc.stream)
          .thenAnswer((_) => Stream.value(ProductoLoaded(testProductos)));

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Product 1'));
      await tester.pump();

      // Find the add button in the cantidad controls (not in the product list)
      final addButtons = find.byIcon(Icons.add);
      await tester.tap(addButtons.last);
      await tester.pump();

      // assert
      expect(find.text('Subtotal: €20.00'), findsOneWidget);
    });

    testWidgets('should search products when search text changes',
        (tester) async {
      // arrange
      when(mockProductoBloc.state).thenReturn(ProductoLoaded(testProductos));
      when(mockProductoBloc.stream)
          .thenAnswer((_) => Stream.value(ProductoLoaded(testProductos)));

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(find.byType(TextField).first, 'search term');
      await tester.pump();

      // assert
      verify(mockProductoBloc.add(any)).called(greaterThan(1));
    });

    testWidgets('should display cancel button', (tester) async {
      // arrange
      when(mockProductoBloc.state).thenReturn(ProductoLoaded(testProductos));
      when(mockProductoBloc.stream)
          .thenAnswer((_) => Stream.value(ProductoLoaded(testProductos)));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Cancelar'), findsOneWidget);
    });
  });
}
