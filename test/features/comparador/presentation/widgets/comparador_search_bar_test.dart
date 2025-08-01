import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:supermercado_comparador/features/comparador/presentation/widgets/comparador_search_bar.dart';

void main() {
  group('ComparadorSearchBar', () {
    late TextEditingController controller;
    late bool searchCalled;
    late bool qrScanCalled;
    late bool clearCalled;
    late String lastSearchQuery;
    late String lastQRCode;

    setUp(() {
      controller = TextEditingController();
      searchCalled = false;
      qrScanCalled = false;
      clearCalled = false;
      lastSearchQuery = '';
      lastQRCode = '';
    });

    tearDown(() {
      controller.dispose();
    });

    Widget createWidgetUnderTest() {
      return MaterialApp(
        home: Scaffold(
          body: ComparadorSearchBar(
            controller: controller,
            onSearch: (query) {
              searchCalled = true;
              lastSearchQuery = query;
            },
            onQRScan: (qrCode) {
              qrScanCalled = true;
              lastQRCode = qrCode;
            },
            onClear: () {
              clearCalled = true;
            },
          ),
        ),
      );
    }

    testWidgets('should display search field and buttons correctly', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Buscar producto...'), findsOneWidget);
      expect(find.text('Buscar'), findsOneWidget);
      expect(find.text('Escanear QR'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsNWidgets(2)); // Prefix icon and button icon
      expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
    });

    testWidgets('should not show clear button when text field is empty', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());

      // Assert
      expect(find.byIcon(Icons.clear), findsNothing);
    });

    testWidgets('should show clear button when text field has content', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(find.byType(TextField), 'leche');
      await tester.pump();

      // Assert
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('should call onSearch when search button is pressed', (tester) async {
      // Arrange
      const searchQuery = 'leche';

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(find.byType(TextField), searchQuery);
      await tester.tap(find.text('Buscar'));

      // Assert
      expect(searchCalled, isTrue);
      expect(lastSearchQuery, equals(searchQuery));
    });

    testWidgets('should call onSearch when text field is submitted', (tester) async {
      // Arrange
      const searchQuery = 'leche';

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(find.byType(TextField), searchQuery);
      await tester.testTextInput.receiveAction(TextInputAction.done);

      // Assert
      expect(searchCalled, isTrue);
      expect(lastSearchQuery, equals(searchQuery));
    });

    testWidgets('should not call onSearch when search button is pressed with empty text', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Buscar'));

      // Assert
      expect(searchCalled, isFalse);
    });

    testWidgets('should call onClear when clear button is pressed', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(find.byType(TextField), 'leche');
      await tester.pump();
      await tester.tap(find.byIcon(Icons.clear));

      // Assert
      expect(clearCalled, isTrue);
    });

    testWidgets('should show QR scan dialog when QR button is pressed', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Escanear QR'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Escanear QR'), findsNWidgets(2)); // Button and dialog title
      expect(find.text('Funcionalidad de escaneo QR'), findsOneWidget);
      expect(find.text('Código QR (simulado)'), findsOneWidget);
      expect(find.byIcon(Icons.qr_code_scanner), findsNWidgets(2)); // Button and dialog icon
    });

    testWidgets('should call onQRScan when QR code is submitted in dialog', (tester) async {
      // Arrange
      const qrCode = '1234567890';

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Escanear QR'));
      await tester.pumpAndSettle();
      
      final qrTextField = find.byType(TextField).last;
      await tester.enterText(qrTextField, qrCode);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Assert
      expect(qrScanCalled, isTrue);
      expect(lastQRCode, equals(qrCode));
      expect(find.byType(AlertDialog), findsNothing); // Dialog should be closed
    });

    testWidgets('should close dialog when cancel button is pressed', (tester) async {
      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Escanear QR'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(AlertDialog), findsNothing);
      expect(qrScanCalled, isFalse);
    });

    testWidgets('should trim whitespace from search query', (tester) async {
      // Arrange
      const searchQuery = '  leche  ';
      const expectedQuery = 'leche';

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(find.byType(TextField), searchQuery);
      await tester.tap(find.text('Buscar'));

      // Assert
      expect(searchCalled, isTrue);
      expect(lastSearchQuery, equals(expectedQuery));
    });

    testWidgets('should trim whitespace from QR code', (tester) async {
      // Arrange
      const qrCode = '  1234567890  ';
      const expectedQRCode = '1234567890';

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.text('Escanear QR'));
      await tester.pumpAndSettle();
      
      final qrTextField = find.byType(TextField).last;
      await tester.enterText(qrTextField, qrCode);
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Assert
      expect(qrScanCalled, isTrue);
      expect(lastQRCode, equals(expectedQRCode));
    });
  });
}