import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:supermercado_comparador/features/calculadora/presentation/pages/calculadora_screen.dart';
import 'package:supermercado_comparador/features/calculadora/presentation/bloc/calculadora_bloc.dart';
import 'package:supermercado_comparador/features/calculadora/presentation/bloc/calculadora_state.dart';
import 'package:supermercado_comparador/features/calculadora/domain/entities/lista_compra.dart';
import 'package:supermercado_comparador/features/calculadora/domain/entities/item_calculadora.dart';
import 'package:supermercado_comparador/features/productos/domain/entities/producto.dart';
import 'package:supermercado_comparador/features/productos/presentation/bloc/producto_bloc.dart';

import 'calculadora_screen_test.mocks.dart';

@GenerateMocks([CalculadoraBloc, ProductoBloc])
void main() {
  group('CalculadoraScreen', () {
    late MockCalculadoraBloc mockCalculadoraBloc;
    late MockProductoBloc mockProductoBloc;

    setUp(() {
      mockCalculadoraBloc = MockCalculadoraBloc();
      mockProductoBloc = MockProductoBloc();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: MultiBlocProvider(
          providers: [
            BlocProvider<CalculadoraBloc>.value(value: mockCalculadoraBloc),
            BlocProvider<ProductoBloc>.value(value: mockProductoBloc),
          ],
          child: const CalculadoraScreen(),
        ),
      );
    }

    testWidgets('should display loading indicator when state is loading', (tester) async {
      // arrange
      when(mockCalculadoraBloc.state).thenReturn(CalculadoraLoading());
      when(mockCalculadoraBloc.stream).thenAnswer((_) => Stream.value(CalculadoraLoading()));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display empty state when lista is empty', (tester) async {
      // arrange
      final emptyLista = ListaCompra(
        items: const [],
        total: 0.0,
        fechaCreacion: DateTime.now(),
      );
      when(mockCalculadoraBloc.state).thenReturn(CalculadoraLoaded(listaCompra: emptyLista));
      when(mockCalculadoraBloc.stream).thenAnswer((_) => Stream.value(CalculadoraLoaded(listaCompra: emptyLista)));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Tu lista está vacía'), findsOneWidget);
      expect(find.text('Agrega productos para comenzar a calcular'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    });

    testWidgets('should display lista with items when loaded', (tester) async {
      // arrange
      final producto = Producto(
        id: 1,
        nombre: 'Test Product',
        precio: 10.0,
        categoriaId: 1,
        almacenId: 1,
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
      );
      
      final item = ItemCalculadora(
        id: 1,
        productoId: 1,
        producto: producto,
        cantidad: 2,
        subtotal: 20.0,
      );
      
      final lista = ListaCompra(
        items: [item],
        total: 20.0,
        fechaCreacion: DateTime.now(),
      );
      
      when(mockCalculadoraBloc.state).thenReturn(CalculadoraLoaded(listaCompra: lista));
      when(mockCalculadoraBloc.stream).thenAnswer((_) => Stream.value(CalculadoraLoaded(listaCompra: lista)));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('€20.00'), findsAtLeastNWidgets(1)); // subtotal and total
    });

    testWidgets('should show snackbar when error occurs', (tester) async {
      // arrange
      when(mockCalculadoraBloc.state).thenReturn(const CalculadoraError(message: 'Test error'));
      when(mockCalculadoraBloc.stream).thenAnswer((_) => Stream.value(const CalculadoraError(message: 'Test error')));

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Allow snackbar to show

      // assert
      expect(find.text('Test error'), findsOneWidget);
    });

    testWidgets('should show snackbar when lista is saved', (tester) async {
      // arrange
      final lista = ListaCompra(
        id: 1,
        nombre: 'Test Lista',
        items: const [],
        total: 0.0,
        fechaCreacion: DateTime.now(),
      );
      
      when(mockCalculadoraBloc.state).thenReturn(CalculadoraListaGuardada(listaGuardada: lista));
      when(mockCalculadoraBloc.stream).thenAnswer((_) => Stream.value(CalculadoraListaGuardada(listaGuardada: lista)));

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Allow snackbar to show

      // assert
      expect(find.text('Lista guardada exitosamente'), findsOneWidget);
    });

    testWidgets('should add CargarListaActual event on init', (tester) async {
      // arrange
      when(mockCalculadoraBloc.state).thenReturn(CalculadoraInitial());
      when(mockCalculadoraBloc.stream).thenAnswer((_) => Stream.value(CalculadoraInitial()));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      verify(mockCalculadoraBloc.add(any)).called(1);
    });

    testWidgets('should show floating action button', (tester) async {
      // arrange
      final emptyLista = ListaCompra(
        items: const [],
        total: 0.0,
        fechaCreacion: DateTime.now(),
      );
      when(mockCalculadoraBloc.state).thenReturn(CalculadoraLoaded(listaCompra: emptyLista));
      when(mockCalculadoraBloc.stream).thenAnswer((_) => Stream.value(CalculadoraLoaded(listaCompra: emptyLista)));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsAtLeastNWidgets(1));
    });

    testWidgets('should show app bar with title and menu', (tester) async {
      // arrange
      final emptyLista = ListaCompra(
        items: const [],
        total: 0.0,
        fechaCreacion: DateTime.now(),
      );
      when(mockCalculadoraBloc.state).thenReturn(CalculadoraLoaded(listaCompra: emptyLista));
      when(mockCalculadoraBloc.stream).thenAnswer((_) => Stream.value(CalculadoraLoaded(listaCompra: emptyLista)));

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Calculadora de Compras'), findsOneWidget);
      expect(find.byType(PopupMenuButton<String>), findsOneWidget);
    });
  });
}