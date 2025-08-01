import 'package:flutter_test/flutter_test.dart';
import 'package:supermercado_comparador/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateRequired', () {
      test('should return null for valid string', () {
        final result = Validators.validateRequired('Valid text');
        expect(result, isNull);
      });

      test('should return error for null value', () {
        final result = Validators.validateRequired(null);
        expect(result, equals('Campo es obligatorio'));
      });

      test('should return error for empty string', () {
        final result = Validators.validateRequired('');
        expect(result, equals('Campo es obligatorio'));
      });

      test('should return error for whitespace only', () {
        final result = Validators.validateRequired('   ');
        expect(result, equals('Campo es obligatorio'));
      });

      test('should return error for string shorter than minLength', () {
        final result = Validators.validateRequired('A', minLength: 2);
        expect(result, equals('Campo debe tener al menos 2 caracteres'));
      });

      test('should use custom field name', () {
        final result = Validators.validateRequired(null, fieldName: 'Nombre');
        expect(result, equals('Nombre es obligatorio'));
      });
    });

    group('validateLength', () {
      test('should return null for valid length', () {
        final result =
            Validators.validateLength('Valid', maxLength: 10, minLength: 2);
        expect(result, isNull);
      });

      test('should return null for null value', () {
        final result = Validators.validateLength(null, maxLength: 10);
        expect(result, isNull);
      });

      test('should return error for string too short', () {
        final result = Validators.validateLength('A', minLength: 2);
        expect(result, equals('Campo debe tener al menos 2 caracteres'));
      });

      test('should return error for string too long', () {
        final result = Validators.validateLength('Too long text', maxLength: 5);
        expect(result, equals('Campo no puede exceder 5 caracteres'));
      });
    });

    group('validatePrice', () {
      test('should return null for valid price', () {
        final result = Validators.validatePrice('10.50');
        expect(result, isNull);
      });

      test('should return error for null price', () {
        final result = Validators.validatePrice(null);
        expect(result, equals('Precio es obligatorio'));
      });

      test('should return error for zero price', () {
        final result = Validators.validatePrice('0');
        expect(result, equals('Precio debe ser mayor a 0'));
      });

      test('should return error for negative price', () {
        final result = Validators.validatePrice('-1');
        expect(result, equals('Precio debe ser mayor a 0'));
      });

      test('should return error for price too high', () {
        final result = Validators.validatePrice('1000000');
        expect(result, equals('Precio no puede exceder 999,999.99'));
      });
    });

    group('validateWeight', () {
      test('should return null for valid weight', () {
        final result = Validators.validateWeight(1.5);
        expect(result, isNull);
      });

      test('should return null for null weight', () {
        final result = Validators.validateWeight(null);
        expect(result, isNull);
      });

      test('should return error for zero weight', () {
        final result = Validators.validateWeight(0);
        expect(result, equals('Peso debe ser mayor a 0'));
      });

      test('should return error for negative weight', () {
        final result = Validators.validateWeight(-1);
        expect(result, equals('Peso debe ser mayor a 0'));
      });

      test('should return error for weight too high', () {
        final result = Validators.validateWeight(100000);
        expect(result, equals('Peso no puede exceder 99,999.99'));
      });
    });

    group('validateQuantity', () {
      test('should return null for valid quantity', () {
        final result = Validators.validateQuantity(5);
        expect(result, isNull);
      });

      test('should return error for null quantity', () {
        final result = Validators.validateQuantity(null);
        expect(result, equals('Cantidad es obligatorio'));
      });

      test('should return error for zero quantity', () {
        final result = Validators.validateQuantity(0);
        expect(result, equals('Cantidad debe ser mayor a 0'));
      });

      test('should return error for negative quantity', () {
        final result = Validators.validateQuantity(-1);
        expect(result, equals('Cantidad debe ser mayor a 0'));
      });

      test('should return error for quantity too high', () {
        final result = Validators.validateQuantity(100000);
        expect(result, equals('Cantidad no puede exceder 99,999'));
      });
    });

    group('validateQRCode', () {
      test('should return null for valid QR code', () {
        final result = Validators.validateQRCode('QR123456');
        expect(result, isNull);
      });

      test('should return null for null QR code', () {
        final result = Validators.validateQRCode(null);
        expect(result, isNull);
      });

      test('should return error for empty QR code', () {
        final result = Validators.validateQRCode('');
        expect(
            result, equals('Código QR no puede estar vacío si se proporciona'));
      });

      test('should return error for QR code too long', () {
        final result = Validators.validateQRCode('A' * 101);
        expect(result, equals('Código QR no puede exceder 100 caracteres'));
      });

      test('should return error for QR code with invalid characters', () {
        final result = Validators.validateQRCode('QR<123>');
        expect(result, equals('Código QR contiene caracteres no válidos'));
      });
    });

    group('validateEmail', () {
      test('should return null for valid email', () {
        final result = Validators.validateEmail('test@example.com');
        expect(result, isNull);
      });

      test('should return error for null email', () {
        final result = Validators.validateEmail(null);
        expect(result, equals('Email es obligatorio'));
      });

      test('should return error for invalid email format', () {
        final result = Validators.validateEmail('invalid-email');
        expect(result, equals('Email no tiene un formato válido'));
      });
    });

    group('validatePhone', () {
      test('should return null for valid phone', () {
        final result = Validators.validatePhone('+34 123 456 789');
        expect(result, isNull);
      });

      test('should return error for null phone', () {
        final result = Validators.validatePhone(null);
        expect(result, equals('Teléfono es obligatorio'));
      });

      test('should return error for invalid phone format', () {
        final result = Validators.validatePhone('abc123');
        expect(result, equals('Teléfono no tiene un formato válido'));
      });
    });

    group('combineValidations', () {
      test('should return null when all validations pass', () {
        final result = Validators.combineValidations([
          () => Validators.validateRequired('Valid'),
          () => Validators.validateLength('Valid', maxLength: 10),
        ]);
        expect(result, isNull);
      });

      test('should return first error when validation fails', () {
        final result = Validators.combineValidations([
          () => Validators.validateRequired(''),
          () => Validators.validateLength('Valid', maxLength: 2),
        ]);
        expect(result, equals('Campo es obligatorio'));
      });
    });
  });
}
