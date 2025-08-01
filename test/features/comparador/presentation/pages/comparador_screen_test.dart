import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:supermercado_comparador/features/comparador/presentation/pages/comparador_screen.dart';
import 'package:supermercado_comparador/features/comparador/presentation/bloc/comparador_bloc.dart';
import 'package:supermercado_comparador/features/comparador/presentation/bloc/comparador_state.dart';
import 'package:supermercado_comparador/features/comparador/presentation/bloc/comparador_event.dart';
import 'package:supermercado_comparador/features/comparador/domain/entities/resultado_comparacion.dart';
import 'package:supermercado_comparador/features/comparador/domain/entities/producto_comparacion.dart';
import 'package:supermercado_comparador/features/productos/domain/entities/producto.dart';
import 'package:supermercado_comparador/features/almacenes/domain/entities/almacen.dart';

class MockComparadorBloc extends MockBloc<ComparadorEvent, ComparadorState>
    implements ComparadorBloc {}

void main() {
  group('ComparadorScreen', () {
    late MockComparadorBloc mockComparadorBloc;

    setUp(() {
      mockComparadorBloc = MockComparadorBloc();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: BlocProvider<ComparadorBloc>.value(
          value: mockComparadorBloc,
          child: const ComparadorScreen(),
        ),
      );
    }

    testWidgets('should display initial state correctly', (tester) async {
      // Arrange
      when(() => mockComparadorBloc.state).thenReturn(const ComparadorInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Comparador de Precios'), findsOneWidget);
      expect(find.text('Busca un producto para comparar precios'), findsOneWidget);
      expect(find.text('Puedes buscar por nombre o escanear un código QR'), findsOneWidget);
      expect(find.byIcon(Icons.compare_arrows), findsOneWidget);
    });

    testWidgets('should display loading state correctly', (tester) async {
      // Arrange
      when(() => mockComparadorBloc.state).thenReturn(const ComparadorLoading());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Buscando productos...'), findsOneWidget);
    });

    testWidgets('should display error state correctly', (tester) async {
      // Arrange
      const errorMessage = 'Error de prueba';
      when(() => mockComparadorBloc.state).thenReturn(const ComparadorError(errorMessage));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Error'), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should display empty state correctly', (tester) async {
      // Arrange
      const terminoBusqueda = 'producto inexistente';
      when(() => mockComparadorBloc.state).thenReturn(const ComparadorEmpty(terminoBusqueda));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('No se encontraron productos'), findsOneWidget);
      expect(find.text('No hay productos que coincidan con "$terminoBusqueda"'), findsOneWidget);
      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets('should display loaded state with results correctly', (tester) async {
      // Arrange
      final almacen1 = Almacen(
        id: 1,
        nombre: 'Almacén 1',
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
      );

      final almacen2 = Almacen(
        id: 2,
        nombre: 'Almacén 2',
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
      );

      final producto1 = Producto(
        id: 1,
        nombre: 'Leche',
        precio: 1.50,
        categoriaId: 1,
        almacenId: 1,
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
      );

      final producto2 = Producto(
        id: 2,
        nombre: 'Leche',
        precio: 1.20,
        categoriaId: 1,
        almacenId: 2,
        fechaCreacion: DateTime.now(),
        fechaActualizacion: DateTime.now(),
      );

      final productos = [
        ProductoComparacion(
          producto: producto1,
          almacen: almacen1,
          esMejorPrecio: false,
        ),
        ProductoComparacion(
          producto: producto2,
          almacen: almacen2,
          esMejorPrecio: true,
        ),
      ];

      final resultado = ResultadoComparacion(
        terminoBusqueda: 'leche',
        productos: productos,
        mejorPrecio: 1.20,
        fechaComparacion: DateTime.now(),
      );

      when(() => mockComparadorBloc.state).thenReturn(ComparadorLoaded(resultado));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.text('Resultados para: "leche"'), findsOneWidget);
      expect(find.text('2 productos encontrados en 2 almacenes'), findsOneWidget);
      expect(find.textContaining('Mejor precio:'), findsOneWidget);
      expect(find.text('Producto'), findsOneWidget); // Table header
      expect(find.text('Almacén'), findsOneWidget); // Table header
      expect(find.text('Precio'), findsOneWidget); // Table header
    });

    testWidgets('should trigger search when search button is pressed', (tester) async {
      // Arrange
      when(() => mockComparadorBloc.state).thenReturn(const ComparadorInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(find.byType(TextField), 'leche');
      await tester.tap(find.text('Buscar'));

      // Assert
      verify(() => mockComparadorBloc.add(const BuscarProductosSimilaresEvent('leche'))).called(1);
    });

    testWidgets('should trigger search when text field is submitted', (tester) async {
      // Arrange
      when(() => mockComparadorBloc.state).thenReturn(const ComparadorInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(find.byType(TextField), 'leche');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      // Assert
      verify(() => mockComparadorBloc.add(const BuscarProductosSimilaresEvent('leche'))).called(1);
    });

    testWidgets('should clear results when clear button is pressed', (tester) async {
      // Arrange
      when(() => mockComparadorBloc.state).thenReturn(const ComparadorInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(find.byType(TextField), 'leche');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.clear));

      // Assert
      verify(() => mockComparadorBloc.add(const LimpiarResultadosEvent())).called(1);
    });

    testWidgets('should show QR scan dialog when QR button is pressed', (tester) async {
      // Arrange
      when(() => mockComparadorBloc.state).thenReturn(const ComparadorInitial());

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Escanear QR'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Escanear QR'), findsNWidgets(2)); // Button and dialog title
      expect(find.text('Funcionalidad de escaneo QR'), findsOneWidget);
      expect(find.text('Código QR (simulado)'), findsOneWidget);
    });
  });
}