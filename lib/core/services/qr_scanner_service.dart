import 'dart:async';

import 'package:permission_handler/permission_handler.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../errors/exceptions.dart' as app_exceptions;

/// Service for handling QR code scanning operations
class QRScannerService {
  MobileScannerController? _controller;
  StreamSubscription<BarcodeCapture>? _scanSubscription;
  
  /// Requests camera permission and returns true if granted
  Future<bool> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      return status == PermissionStatus.granted;
    } catch (e) {
      throw app_exceptions.PermissionException(
        'Error requesting camera permission: ${e.toString()}',
        code: 'PERMISSION_REQUEST_ERROR',
      );
    }
  }
  
  /// Checks if camera permission is granted
  Future<bool> hasCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      return status == PermissionStatus.granted;
    } catch (e) {
      throw app_exceptions.PermissionException(
        'Error checking camera permission: ${e.toString()}',
        code: 'PERMISSION_CHECK_ERROR',
      );
    }
  }
  
  /// Initializes the QR scanner
  Future<void> initializeScanner() async {
    try {
      // Check if camera permission is granted
      if (!await hasCameraPermission()) {
        throw const app_exceptions.PermissionException(
          'Camera permission is required for QR scanning',
          code: 'CAMERA_PERMISSION_DENIED',
        );
      }
      
      _controller = MobileScannerController();
    } catch (e) {
      if (e is app_exceptions.PermissionException) {
        rethrow;
      }
      throw app_exceptions.CameraException(
        'Failed to initialize QR scanner: ${e.toString()}',
        code: 'SCANNER_INIT_ERROR',
      );
    }
  }
  
  /// Starts listening for QR code scans
  Stream<String> startScanning() {
    if (_controller == null) {
      throw const app_exceptions.CameraException(
        'QR scanner not initialized. Call initializeScanner first.',
        code: 'SCANNER_NOT_INITIALIZED',
      );
    }
    
    final controller = StreamController<String>();
    
    _scanSubscription = _controller!.barcodes.listen(
      (barcodeCapture) {
        final barcodes = barcodeCapture.barcodes;
        for (final barcode in barcodes) {
          if (barcode.rawValue != null && barcode.rawValue!.isNotEmpty) {
            try {
              final qrCode = _validateQRCode(barcode.rawValue!);
              controller.add(qrCode);
              break; // Only process the first valid barcode
            } catch (e) {
              controller.addError(e);
            }
          }
        }
      },
      onError: (error) {
        controller.addError(app_exceptions.CameraException(
          'Error during QR scanning: ${error.toString()}',
          code: 'SCAN_ERROR',
        ));
      },
    );
    
    return controller.stream;
  }
  
  /// Validates the scanned QR code format
  String _validateQRCode(String qrCode) {
    // Basic validation - ensure it's not empty and has reasonable length
    if (qrCode.trim().isEmpty) {
      throw const app_exceptions.QRFormatException(
        'QR code cannot be empty',
        code: 'EMPTY_QR_CODE',
      );
    }
    
    // Check for reasonable length (most QR codes are under 4000 characters)
    if (qrCode.length > 4000) {
      throw const app_exceptions.QRFormatException(
        'QR code is too long',
        code: 'QR_CODE_TOO_LONG',
      );
    }
    
    // Remove any leading/trailing whitespace
    return qrCode.trim();
  }
  
  /// Starts the camera
  Future<void> startCamera() async {
    try {
      await _controller?.start();
    } catch (e) {
      throw app_exceptions.CameraException(
        'Failed to start camera: ${e.toString()}',
        code: 'CAMERA_START_ERROR',
      );
    }
  }
  
  /// Stops the camera
  Future<void> stopCamera() async {
    try {
      await _controller?.stop();
    } catch (e) {
      throw app_exceptions.CameraException(
        'Failed to stop camera: ${e.toString()}',
        code: 'CAMERA_STOP_ERROR',
      );
    }
  }
  
  /// Toggles the camera flash
  Future<void> toggleFlash() async {
    try {
      await _controller?.toggleTorch();
    } catch (e) {
      throw app_exceptions.CameraException(
        'Failed to toggle flash: ${e.toString()}',
        code: 'FLASH_TOGGLE_ERROR',
      );
    }
  }
  
  /// Switches between front and back camera
  Future<void> switchCamera() async {
    try {
      await _controller?.switchCamera();
    } catch (e) {
      throw app_exceptions.CameraException(
        'Failed to switch camera: ${e.toString()}',
        code: 'CAMERA_SWITCH_ERROR',
      );
    }
  }
  
  /// Gets the mobile scanner controller
  MobileScannerController? get controller => _controller;
  
  /// Disposes of the scanner resources
  void dispose() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    _controller?.dispose();
    _controller = null;
  }
}