import 'package:flutter_test/flutter_test.dart';
import 'package:supermercado_comparador/core/utils/formatters.dart';

void main() {
  group('Formatters', () {
    group('formatPrice', () {
      test('should format price with euro symbol', () {
        final result = Formatters.formatPrice(10.50);
        expect(result, contains('10,50'));
        expect(result, contains('€'));
      });

      test('should format zero price', () {
        final result = Formatters.formatPrice(0.0);
        expect(result, contains('0,00'));
        expect(result, contains('€'));
      });

      test('should format large price', () {
        final result = Formatters.formatPrice(1234.56);
        expect(result, contains('1.234,56'));
        expect(result, contains('€'));
      });
    });

    group('formatDate', () {
      test('should format date with time', () {
        final testDate = DateTime(2024, 1, 15, 14, 30);
        final result = Formatters.formatDate(testDate);
        expect(result, equals('15/01/2024 14:30'));
      });

      test('should format date with single digit day and month', () {
        final testDate = DateTime(2024, 3, 5, 9, 5);
        final result = Formatters.formatDate(testDate);
        expect(result, equals('05/03/2024 09:05'));
      });
    });

    group('formatDateOnly', () {
      test('should format date without time', () {
        final testDate = DateTime(2024, 1, 15, 14, 30);
        final result = Formatters.formatDateOnly(testDate);
        expect(result, equals('15/01/2024'));
      });

      test('should format date with single digit day and month', () {
        final testDate = DateTime(2024, 3, 5);
        final result = Formatters.formatDateOnly(testDate);
        expect(result, equals('05/03/2024'));
      });
    });

    group('formatWeight', () {
      test('should format weight in kg for values >= 1', () {
        final result = Formatters.formatWeight(1.5);
        expect(result, equals('1.50kg'));
      });

      test('should format weight in grams for values < 1', () {
        final result = Formatters.formatWeight(0.5);
        expect(result, equals('500g'));
      });

      test('should format weight in grams for small values', () {
        final result = Formatters.formatWeight(0.25);
        expect(result, equals('250g'));
      });

      test('should format exactly 1kg', () {
        final result = Formatters.formatWeight(1.0);
        expect(result, equals('1.00kg'));
      });

      test('should format large weight', () {
        final result = Formatters.formatWeight(10.75);
        expect(result, equals('10.75kg'));
      });
    });
  });
}