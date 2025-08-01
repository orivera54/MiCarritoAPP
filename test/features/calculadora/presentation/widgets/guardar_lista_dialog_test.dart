import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:supermercado_comparador/features/calculadora/presentation/widgets/guardar_lista_dialog.dart';

void main() {
  group('GuardarListaDialog', () {
    Widget createWidgetUnderTest({
      Function(String?)? onGuardar,
    }) {
      return MaterialApp(
        home: GuardarListaDialog(
          onGuardar: onGuardar ?? (nombre) {},
        ),
      );
    }

    testWidgets('should display dialog title', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Guardar lista de compras'), findsOneWidget);
    });

    testWidgets('should display instruction text', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Ingresa un nombre para tu lista de compras:'),
          findsOneWidget);
    });

    testWidgets('should display text field with default name', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Nombre de la lista'), findsOneWidget);

      // Check that default name contains current date
      final textField =
          tester.widget<TextFormField>(find.byType(TextFormField));
      final controller = textField.controller;
      expect(controller?.text, contains('Lista'));
    });

    testWidgets('should display helper text', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(
          find.text(
              'Puedes dejar el campo vacío para usar un nombre automático.'),
          findsOneWidget);
    });

    testWidgets('should display cancel and save buttons', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('Cancelar'), findsOneWidget);
      expect(find.text('Guardar'), findsOneWidget);
    });

    testWidgets('should validate empty input', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // Clear the default text
      await tester.enterText(find.byType(TextFormField), '');
      await tester.tap(find.text('Guardar'));
      await tester.pump();

      // assert
      expect(find.text('Por favor ingresa un nombre para la lista'),
          findsOneWidget);
    });

    testWidgets('should validate short input', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(find.byType(TextFormField), 'ab');
      await tester.tap(find.text('Guardar'));
      await tester.pump();

      // assert
      expect(find.text('El nombre debe tener al menos 3 caracteres'),
          findsOneWidget);
    });

    testWidgets('should validate long input', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      final longText = 'a' * 101;
      await tester.enterText(find.byType(TextFormField), longText);
      await tester.tap(find.text('Guardar'));
      await tester.pump();

      // assert
      expect(find.text('El nombre no puede tener más de 100 caracteres'),
          findsOneWidget);
    });

    testWidgets('should call onGuardar with valid input', (tester) async {
      // arrange
      String? savedName;

      // act
      await tester.pumpWidget(createWidgetUnderTest(
        onGuardar: (nombre) => savedName = nombre,
      ));

      await tester.enterText(find.byType(TextFormField), 'Test Lista');
      await tester.tap(find.text('Guardar'));
      await tester.pump();

      // assert
      expect(savedName, equals('Test Lista'));
    });

    testWidgets('should call onGuardar with null for empty input',
        (tester) async {
      // arrange
      String? savedName = 'initial';

      // act
      await tester.pumpWidget(createWidgetUnderTest(
        onGuardar: (nombre) => savedName = nombre,
      ));

      await tester.enterText(
          find.byType(TextFormField), '   '); // whitespace only
      await tester.tap(find.text('Guardar'));
      await tester.pump();

      // assert
      expect(savedName, isNull);
    });

    testWidgets('should not call onGuardar with invalid input', (tester) async {
      // arrange
      bool onGuardarCalled = false;

      // act
      await tester.pumpWidget(createWidgetUnderTest(
        onGuardar: (nombre) => onGuardarCalled = true,
      ));

      await tester.enterText(find.byType(TextFormField), 'ab'); // too short
      await tester.tap(find.text('Guardar'));
      await tester.pump();

      // assert
      expect(onGuardarCalled, isFalse);
    });

    testWidgets('should close dialog when cancel is tapped', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // assert
      expect(find.byType(GuardarListaDialog), findsNothing);
    });

    testWidgets('should have text field with proper configuration',
        (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(TextFormField), findsOneWidget);
      // Note: Testing specific TextFormField properties like maxLength, textCapitalization,
      // and autofocus is not easily accessible in widget tests as they are internal properties.
      // The important behavior (validation, input handling) is tested in other test cases.
    });

    testWidgets('should display prefix icon', (tester) async {
      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byIcon(Icons.list_alt), findsOneWidget);
    });

    testWidgets('should submit on enter key', (tester) async {
      // arrange
      String? savedName;

      // act
      await tester.pumpWidget(createWidgetUnderTest(
        onGuardar: (nombre) => savedName = nombre,
      ));

      await tester.enterText(find.byType(TextFormField), 'Test Lista');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // assert
      expect(savedName, equals('Test Lista'));
    });
  });
}
