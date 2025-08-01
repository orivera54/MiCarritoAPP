import 'package:flutter_test/flutter_test.dart';

import 'package:supermercado_comparador/core/error_handling/global_error_handler.dart';
import 'package:supermercado_comparador/core/errors/exceptions.dart';
import 'package:supermercado_comparador/core/errors/failures.dart';
import 'package:supermercado_comparador/core/widgets/enhanced_form_field.dart';

void main() {
  group('Simple Error Handling Tests', () {
    group('Global Error Handler Tests', () {
      test('should return correct error messages for different error types', () {
        // Test AppException
        const appException = ValidationException('Validation failed');
        expect(GlobalErrorHandler.getErrorMessage(appException), 'Validation failed');

        // Test Failure
        const failure = DatabaseFailure('Database error');
        expect(GlobalErrorHandler.getErrorMessage(failure), 'Database error');

        // Test generic error
        final genericError = Exception('Generic error');
        expect(GlobalErrorHandler.getErrorMessage(genericError), 'Ha ocurrido un error inesperado');
      });
    });

    group('Form Validation Tests', () {
      test('validateRequired should work correctly', () {
        expect(FormValidationHelper.validateRequired(null), 'Este campo es requerido');
        expect(FormValidationHelper.validateRequired(''), 'Este campo es requerido');
        expect(FormValidationHelper.validateRequired('   '), 'Este campo es requerido');
        expect(FormValidationHelper.validateRequired('valid'), null);
        expect(FormValidationHelper.validateRequired('valid', fieldName: 'Nombre'), null);
        expect(FormValidationHelper.validateRequired(null, fieldName: 'Nombre'), 'Nombre es requerido');
      });

      test('validateEmail should work correctly', () {
        expect(FormValidationHelper.validateEmail(null), null);
        expect(FormValidationHelper.validateEmail(''), null);
        expect(FormValidationHelper.validateEmail('invalid'), 'Ingresa un email válido');
        expect(FormValidationHelper.validateEmail('invalid@'), 'Ingresa un email válido');
        expect(FormValidationHelper.validateEmail('invalid@domain'), 'Ingresa un email válido');
        expect(FormValidationHelper.validateEmail('valid@domain.com'), null);
        expect(FormValidationHelper.validateEmail('user.name@domain.co.uk'), null);
      });

      test('validatePrice should work correctly', () {
        expect(FormValidationHelper.validatePrice(null), null);
        expect(FormValidationHelper.validatePrice(''), null);
        expect(FormValidationHelper.validatePrice('invalid'), 'Ingresa un precio válido');
        expect(FormValidationHelper.validatePrice('-1'), 'El precio no puede ser negativo');
        expect(FormValidationHelper.validatePrice('1000000'), 'El precio es demasiado alto');
        expect(FormValidationHelper.validatePrice('0'), null);
        expect(FormValidationHelper.validatePrice('10.50'), null);
        expect(FormValidationHelper.validatePrice('999999'), null);
      });

      test('validateWeight should work correctly', () {
        expect(FormValidationHelper.validateWeight(null), null);
        expect(FormValidationHelper.validateWeight(''), null);
        expect(FormValidationHelper.validateWeight('invalid'), 'Ingresa un peso válido');
        expect(FormValidationHelper.validateWeight('0'), 'El peso debe ser mayor a 0');
        expect(FormValidationHelper.validateWeight('-1'), 'El peso debe ser mayor a 0');
        expect(FormValidationHelper.validateWeight('1001'), 'El peso es demasiado alto');
        expect(FormValidationHelper.validateWeight('0.1'), null);
        expect(FormValidationHelper.validateWeight('500'), null);
        expect(FormValidationHelper.validateWeight('1000'), null);
      });

      test('validateQuantity should work correctly', () {
        expect(FormValidationHelper.validateQuantity(null), null);
        expect(FormValidationHelper.validateQuantity(''), null);
        expect(FormValidationHelper.validateQuantity('invalid'), 'Ingresa una cantidad válida');
        expect(FormValidationHelper.validateQuantity('0'), 'La cantidad debe ser mayor a 0');
        expect(FormValidationHelper.validateQuantity('-1'), 'La cantidad debe ser mayor a 0');
        expect(FormValidationHelper.validateQuantity('10000'), 'La cantidad es demasiado alta');
        expect(FormValidationHelper.validateQuantity('1'), null);
        expect(FormValidationHelper.validateQuantity('100'), null);
        expect(FormValidationHelper.validateQuantity('9999'), null);
      });

      test('validateLength should work correctly', () {
        expect(FormValidationHelper.validateLength(null), null);
        expect(FormValidationHelper.validateLength(''), null);
        expect(FormValidationHelper.validateLength('ab', minLength: 3), 'Debe tener al menos 3 caracteres');
        expect(FormValidationHelper.validateLength('abcdef', maxLength: 5), 'No puede tener más de 5 caracteres');
        expect(FormValidationHelper.validateLength('abc', minLength: 3, maxLength: 5), null);
        expect(FormValidationHelper.validateLength('abcde', minLength: 3, maxLength: 5), null);
      });

      test('combineValidators should work correctly', () {
        final validators = [
          (String? value) => FormValidationHelper.validateRequired(value),
          (String? value) => FormValidationHelper.validateLength(value, minLength: 3),
        ];

        expect(FormValidationHelper.combineValidators(null, validators), 'Este campo es requerido');
        expect(FormValidationHelper.combineValidators('ab', validators), 'Debe tener al menos 3 caracteres');
        expect(FormValidationHelper.combineValidators('abc', validators), null);
      });
    });

    group('Exception Handling Tests', () {
      test('should create proper exception messages', () {
        const dbException = DatabaseException('Database connection failed');
        expect(dbException.message, 'Database connection failed');
        expect(dbException.toString(), contains('Database connection failed'));

        const validationException = ValidationException('Field is required');
        expect(validationException.message, 'Field is required');
        expect(validationException.toString(), contains('Field is required'));

        const duplicateException = DuplicateException('Record already exists');
        expect(duplicateException.message, 'Record already exists');
        expect(duplicateException.toString(), contains('Record already exists'));

        const notFoundException = NotFoundException('Record not found');
        expect(notFoundException.message, 'Record not found');
        expect(notFoundException.toString(), contains('Record not found'));
      });
    });

    group('Failure Handling Tests', () {
      test('should create proper failure messages', () {
        const dbFailure = DatabaseFailure('Database operation failed');
        expect(dbFailure.message, 'Database operation failed');

        const validationFailure = ValidationFailure('Validation failed');
        expect(validationFailure.message, 'Validation failed');

        const networkFailure = NetworkFailure('Network connection failed');
        expect(networkFailure.message, 'Network connection failed');

        const cameraFailure = CameraFailure('Camera operation failed');
        expect(cameraFailure.message, 'Camera operation failed');
      });
    });
  });
}