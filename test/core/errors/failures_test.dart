import 'package:flutter_test/flutter_test.dart';
import 'package:supermercado_comparador/core/errors/failures.dart';

void main() {
  group('Failures', () {
    group('Failure', () {
      test('should create failure with message', () {
        const failure = DatabaseFailure('Test error');
        expect(failure.message, equals('Test error'));
        expect(failure.code, isNull);
      });

      test('should create failure with message and code', () {
        const failure = DatabaseFailure('Test error', code: 'DB001');
        expect(failure.message, equals('Test error'));
        expect(failure.code, equals('DB001'));
      });

      test('should be equatable', () {
        const failure1 = DatabaseFailure('Test error', code: 'DB001');
        const failure2 = DatabaseFailure('Test error', code: 'DB001');
        const failure3 = DatabaseFailure('Different error', code: 'DB001');

        expect(failure1, equals(failure2));
        expect(failure1, isNot(equals(failure3)));
      });
    });

    group('ValidationFailure', () {
      test('should create validation failure with field errors', () {
        const fieldErrors = {'name': 'Required', 'email': 'Invalid format'};
        const failure = ValidationFailure('Validation failed', fieldErrors: fieldErrors);
        
        expect(failure.message, equals('Validation failed'));
        expect(failure.fieldErrors, equals(fieldErrors));
      });

      test('should be equatable with field errors', () {
        const fieldErrors = {'name': 'Required'};
        const failure1 = ValidationFailure('Validation failed', fieldErrors: fieldErrors);
        const failure2 = ValidationFailure('Validation failed', fieldErrors: fieldErrors);
        const failure3 = ValidationFailure('Validation failed', fieldErrors: {'name': 'Different'});

        expect(failure1, equals(failure2));
        expect(failure1, isNot(equals(failure3)));
      });
    });

    group('Specific Failures', () {
      test('should create DatabaseFailure', () {
        const failure = DatabaseFailure('Database error');
        expect(failure, isA<Failure>());
        expect(failure.message, equals('Database error'));
      });

      test('should create NotFoundFailure', () {
        const failure = NotFoundFailure('Not found');
        expect(failure, isA<Failure>());
        expect(failure.message, equals('Not found'));
      });

      test('should create CameraFailure', () {
        const failure = CameraFailure('Camera error');
        expect(failure, isA<Failure>());
        expect(failure.message, equals('Camera error'));
      });

      test('should create QRFormatFailure', () {
        const failure = QRFormatFailure('Invalid QR');
        expect(failure, isA<Failure>());
        expect(failure.message, equals('Invalid QR'));
      });

      test('should create PermissionFailure', () {
        const failure = PermissionFailure('Permission denied');
        expect(failure, isA<Failure>());
        expect(failure.message, equals('Permission denied'));
      });

      test('should create DuplicateFailure', () {
        const failure = DuplicateFailure('Duplicate entry');
        expect(failure, isA<Failure>());
        expect(failure.message, equals('Duplicate entry'));
      });

      test('should create NetworkFailure', () {
        const failure = NetworkFailure('Network error');
        expect(failure, isA<Failure>());
        expect(failure.message, equals('Network error'));
      });

      test('should create ServerFailure', () {
        const failure = ServerFailure('Server error');
        expect(failure, isA<Failure>());
        expect(failure.message, equals('Server error'));
      });
    });
  });
}