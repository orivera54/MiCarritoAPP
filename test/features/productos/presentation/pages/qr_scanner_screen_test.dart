import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:supermercado_comparador/features/productos/presentation/pages/qr_scanner_screen.dart';

void main() {
  group('QRScannerScreen', () {
    setUp(() {
      // Setup for future tests that might need mocks
    });

    Widget createWidgetUnderTest() {
      return const MaterialApp(
        home: QRScannerScreen(),
      );
    }

    testWidgets('displays correct app bar', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Escanear Código QR'), findsOneWidget);
      expect(find.byIcon(Icons.flash_off), findsOneWidget);
      expect(find.byIcon(Icons.flip_camera_ios), findsOneWidget);
    });

    testWidgets('displays QR scanner view', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(MobileScanner), findsOneWidget);
    });

    testWidgets('displays instructions overlay', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Apunta la cámara hacia el código QR'), findsOneWidget);
      expect(
          find.text(
              'El código se escaneará automáticamente cuando esté en el marco'),
          findsOneWidget);
      expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
    });

    testWidgets('displays control buttons in overlay', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Flash'), findsOneWidget);
      expect(find.text('Cambiar'), findsOneWidget);
    });

    testWidgets('flash button shows correct icon when off', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Should show flash_off icon initially
      expect(find.byIcon(Icons.flash_off), findsAtLeastNWidgets(1));
    });

    testWidgets('has dark app bar styling', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, equals(Colors.black));
      expect(appBar.foregroundColor, equals(Colors.white));
    });

    testWidgets('displays QR scanner overlay with correct properties',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Check that CustomPaint widget exists (our custom overlay)
      expect(find.byType(CustomPaint), findsOneWidget);
    });

    testWidgets('instructions container has correct styling', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(Positioned),
              matching: find.byType(Container),
            )
            .first,
      );

      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, equals(Colors.black.withOpacity(0.8)));
      expect(
          decoration.borderRadius,
          equals(const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          )));
    });

    testWidgets('control buttons have correct styling', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final flashButton = tester.widget<IconButton>(
        find.descendant(
          of: find.widgetWithText(Column, 'Flash'),
          matching: find.byType(IconButton),
        ),
      );

      expect(flashButton.iconSize, equals(28));
    });

    group('Widget Structure', () {
      testWidgets('has correct widget hierarchy', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.byType(Scaffold), findsOneWidget);
        expect(find.byType(AppBar), findsOneWidget);
        expect(find.byType(Stack), findsOneWidget);
        expect(find.byType(MobileScanner), findsOneWidget);
        expect(find.byType(Positioned), findsOneWidget);
      });

      testWidgets('positioned overlay is at bottom', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        final positioned = tester.widget<Positioned>(find.byType(Positioned));
        expect(positioned.bottom, equals(0));
        expect(positioned.left, equals(0));
        expect(positioned.right, equals(0));
      });
    });

    group('Text Content', () {
      testWidgets('displays all instruction text', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        expect(
            find.text('Apunta la cámara hacia el código QR'), findsOneWidget);
        expect(
            find.text(
                'El código se escaneará automáticamente cuando esté en el marco'),
            findsOneWidget);
        expect(find.text('Flash'), findsOneWidget);
        expect(find.text('Cambiar'), findsOneWidget);
      });

      testWidgets('instruction text has correct styling', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        final titleText = tester.widget<Text>(
          find.text('Apunta la cámara hacia el código QR'),
        );
        expect(titleText.style?.color, equals(Colors.white));
        expect(titleText.style?.fontSize, equals(18));
        expect(titleText.style?.fontWeight, equals(FontWeight.bold));

        final subtitleText = tester.widget<Text>(
          find.text(
              'El código se escaneará automáticamente cuando esté en el marco'),
        );
        expect(subtitleText.style?.color, equals(Colors.white70));
        expect(subtitleText.style?.fontSize, equals(14));
      });
    });

    group('Icons', () {
      testWidgets('displays all required icons', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        expect(find.byIcon(Icons.qr_code_scanner), findsOneWidget);
        expect(find.byIcon(Icons.flash_off), findsAtLeastNWidgets(1));
        expect(find.byIcon(Icons.flip_camera_ios), findsAtLeastNWidgets(1));
      });

      testWidgets('scanner icon has correct properties', (tester) async {
        await tester.pumpWidget(createWidgetUnderTest());

        final scannerIcon = tester.widget<Icon>(
          find.byIcon(Icons.qr_code_scanner),
        );
        expect(scannerIcon.color, equals(Colors.white));
        expect(scannerIcon.size, equals(32));
      });
    });
  });
}
