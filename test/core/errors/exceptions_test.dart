import 'package:flutter_test/flutter_test.dart';
import 'package:supermercado_comparador/core/errors/exceptions.dart';

void main() {
  group('Exceptions', () {
    group('AppException', () {
      test('should create exception with message', () {
        const exception = DatabaseException('Test error');
        expect(exception.message, equals('Test error'));
        expect(exception.code, isNull);
      });

      test('should create exception with message and code', () {
        const exception = DatabaseException('Test error', code: 'DB001');
        expect(exception.message, equals('Test error'));
        expect(exception.code, equals('DB001'));
      });

      test('should format toString correctly without code', () {
        const exception = DatabaseException('Test error');
        expect(exception.toString(), equals('AppException: Test error'));
      });

      test('should format toString correctly with code', () {
        const exception = DatabaseException('Test error', code: 'DB001');
        expect(exception.toString(), equals('AppException: Test error (Code: DB001)'));
      });
    });

    group('ValidationException', () {
      test('should create validation exception with field errors', () {
        const fieldErrors = {'name': 'Required', 'email': 'Invalid format'};
        const exception = ValidationException('Validation failed', fieldErrors: fieldErrors);
        
        expect(exception.message, equals('Validation failed'));
        expect(exception.fieldErrors, equals(fieldErrors));
      });

      test('should format toString correctly with field errors', () {
        const fieldErrors = {'name': 'Required'};
        const exception = ValidationException('Validation failed', fieldErrors: fieldErrors);
        
        final result = exception.toString();
        expect(result, contains('Validation failed'));
        expect(result, contains('Field errors:'));
        expect(result, contains('name'));
      });
    });

    group('Specific Exceptions', () {
      test('should create DatabaseException', () {
        const exception = DatabaseException('Database error');
        expect(exception, isA<AppException>());
        expect(exception.message, equals('Database error'));
      });

      test('should create NotFoundException', () {
        const exception = NotFoundException('Not found');
        expect(exception, isA<AppException>());
        expect(exception.message, equals('Not found'));
      });

      test('should create CameraException', () {
        const exception = CameraException('Camera error');
        expect(exception, isA<AppException>());
        expect(exception.message, equals('Camera error'));
      });

      test('should create QRFormatException', () {
        const exception = QRFormatException('Invalid QR');
        expect(exception, isA<AppException>());
        expect(exception.message, equals('Invalid QR'));
      });

      test('should create PermissionException', () {
        const exception = PermissionException('Permission denied');
        expect(exception, isA<AppException>());
        expect(exception.message, equals('Permission denied'));
      });

      test('should create DuplicateException', () {
        const exception = DuplicateException('Duplicate entry');
        expect(exception, isA<AppException>());
        expect(exception.message, equals('Duplicate entry'));
      });
    });
  });
}