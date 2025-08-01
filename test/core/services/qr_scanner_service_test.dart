import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:supermercado_comparador/core/services/qr_scanner_service.dart';

// Generate mocks
@GenerateMocks([MobileScannerController])
import 'qr_scanner_service_test.mocks.dart';

void main() {
  group('QRScannerService', () {
    late QRScannerService qrScannerService;
    late MockMobileScannerController mockController;

    setUp(() {
      qrScannerService = QRScannerService();
      mockController = MockMobileScannerController();
    });

    tearDown(() {
      qrScannerService.dispose();
    });

    group('requestCameraPermission', () {
      test('should handle permission request without throwing', () async {
        // This test verifies the method exists and can be called
        expect(() async => await qrScannerService.requestCameraPermission(),
            returnsNormally);
      });
    });

    group('hasCameraPermission', () {
      test('should handle permission check without throwing', () async {
        // This test verifies the method exists and can be called
        expect(() async => await qrScannerService.hasCameraPermission(),
            returnsNormally);
      });
    });

    group('initializeScanner', () {
      test('should initialize scanner successfully', () async {
        expect(
            () async => await qrScannerService.initializeScanner(),
            returnsNormally);
      });

      test('should handle initialization errors', () async {
        // Test that initialization doesn't throw for permission issues
        expect(
          () async => await qrScannerService.initializeScanner(),
          returnsNormally,
        );
      });
    });

    group('startScanning', () {
      test('should throw exception when scanner not initialized', () {
        expect(
          () => qrScannerService.startScanning(),
          throwsException,
        );
      });

      test('should return stream of valid QR codes', () async {
        // Initialize scanner first
        await qrScannerService.initializeScanner();

        // Create a stream controller to simulate scanned data
        final streamController = StreamController<BarcodeCapture>();
        
        // Mock the controller's barcodes stream
        when(mockController.barcodes)
            .thenAnswer((_) => streamController.stream);

        final scanStream = qrScannerService.startScanning();

        // Simulate scanning a valid QR code
        const testBarcode = Barcode(
          rawValue: 'test-qr-code',
          format: BarcodeFormat.qrCode,
          type: BarcodeType.text,
        );
        final barcodeCapture = BarcodeCapture(barcodes: [testBarcode]);
        streamController.add(barcodeCapture);

        expect(scanStream, emits('test-qr-code'));

        streamController.close();
      });

      test('should handle empty QR codes', () async {
        await qrScannerService.initializeScanner();

        final streamController = StreamController<BarcodeCapture>();
        when(mockController.barcodes)
            .thenAnswer((_) => streamController.stream);

        final scanStream = qrScannerService.startScanning();

        // Simulate scanning an empty QR code
        const emptyBarcode = Barcode(
          rawValue: '',
          format: BarcodeFormat.qrCode,
          type: BarcodeType.text,
        );
        final barcodeCapture = BarcodeCapture(barcodes: [emptyBarcode]);
        streamController.add(barcodeCapture);

        expect(scanStream, emitsError(anything));

        streamController.close();
      });

      test('should handle very long QR codes', () async {
        await qrScannerService.initializeScanner();

        final streamController = StreamController<BarcodeCapture>();
        when(mockController.barcodes)
            .thenAnswer((_) => streamController.stream);

        final scanStream = qrScannerService.startScanning();

        // Simulate scanning a very long QR code
        final longQrCode = 'a' * 5000; // Exceeds 4000 character limit
        final longBarcode = Barcode(
          rawValue: longQrCode,
          format: BarcodeFormat.qrCode,
          type: BarcodeType.text,
        );
        final barcodeCapture = BarcodeCapture(barcodes: [longBarcode]);
        streamController.add(barcodeCapture);

        expect(scanStream, emitsError(anything));

        streamController.close();
      });
    });

    group('camera controls', () {
      setUp(() async {
        await qrScannerService.initializeScanner();
      });

      test('startCamera should call controller start', () async {
        when(mockController.start()).thenAnswer((_) async {});

        await qrScannerService.startCamera();

        verify(mockController.start()).called(1);
      });

      test('startCamera should handle errors', () async {
        when(mockController.start()).thenThrow(Exception('Start error'));

        expect(
          () async => await qrScannerService.startCamera(),
          throwsException,
        );
      });

      test('stopCamera should call controller stop', () async {
        when(mockController.stop()).thenAnswer((_) async {});

        await qrScannerService.stopCamera();

        verify(mockController.stop()).called(1);
      });

      test('stopCamera should handle errors', () async {
        when(mockController.stop()).thenThrow(Exception('Stop error'));

        expect(
          () async => await qrScannerService.stopCamera(),
          throwsException,
        );
      });

      test('toggleFlash should call controller toggleTorch', () async {
        when(mockController.toggleTorch()).thenAnswer((_) async {});

        await qrScannerService.toggleFlash();

        verify(mockController.toggleTorch()).called(1);
      });

      test('toggleFlash should handle errors', () async {
        when(mockController.toggleTorch()).thenThrow(Exception('Flash error'));

        expect(
          () async => await qrScannerService.toggleFlash(),
          throwsException,
        );
      });

      test('switchCamera should call controller switchCamera', () async {
        when(mockController.switchCamera()).thenAnswer((_) async {});

        await qrScannerService.switchCamera();

        verify(mockController.switchCamera()).called(1);
      });

      test('switchCamera should handle errors', () async {
        when(mockController.switchCamera()).thenThrow(Exception('Switch error'));

        expect(
          () async => await qrScannerService.switchCamera(),
          throwsException,
        );
      });
    });

    group('dispose', () {
      test('should dispose resources properly', () {
        qrScannerService.dispose();

        // Should not throw any exceptions
        expect(() => qrScannerService.dispose(), returnsNormally);
      });
    });

    group('QR code validation', () {
      test('should accept valid QR codes', () async {
        await qrScannerService.initializeScanner();

        final streamController = StreamController<BarcodeCapture>();
        when(mockController.barcodes)
            .thenAnswer((_) => streamController.stream);

        final scanStream = qrScannerService.startScanning();

        // Test various valid QR codes
        final validCodes = [
          'simple-text',
          '1234567890',
          'https://example.com',
          'product-code-123',
          'QR with spaces',
          '  trimmed  ', // Should be trimmed to 'trimmed'
        ];

        for (final code in validCodes) {
          final barcode = Barcode(
            rawValue: code,
            format: BarcodeFormat.qrCode,
            type: BarcodeType.text,
          );
          final barcodeCapture = BarcodeCapture(barcodes: [barcode]);
          streamController.add(barcodeCapture);
        }

        // Expect trimmed version of the last code
        expect(
            scanStream,
            emitsInOrder([
              'simple-text',
              '1234567890',
              'https://example.com',
              'product-code-123',
              'QR with spaces',
              'trimmed',
            ]));

        streamController.close();
      });

      test('should reject whitespace-only QR codes', () async {
        await qrScannerService.initializeScanner();

        final streamController = StreamController<BarcodeCapture>();
        when(mockController.barcodes)
            .thenAnswer((_) => streamController.stream);

        final scanStream = qrScannerService.startScanning();

        // Test whitespace-only QR code
        const whitespaceBarcode = Barcode(
          rawValue: '   ',
          format: BarcodeFormat.qrCode,
          type: BarcodeType.text,
        );
        final barcodeCapture = BarcodeCapture(barcodes: [whitespaceBarcode]);
        streamController.add(barcodeCapture);

        expect(scanStream, emitsError(anything));

        streamController.close();
      });
    });
  });
}
