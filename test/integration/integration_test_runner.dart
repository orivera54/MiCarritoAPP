import 'package:flutter_test/flutter_test.dart';

// Import all integration test files
import 'almacenes_integration_test.dart' as almacenes_tests;
import 'productos_search_qr_integration_test.dart' as productos_tests;
import 'calculadora_integration_test.dart' as calculadora_tests;
import 'comparador_integration_test.dart' as comparador_tests;

void main() {
  group('All Integration Tests', () {
    // Run all integration test suites
    almacenes_tests.main();
    productos_tests.main();
    calculadora_tests.main();
    comparador_tests.main();
  });
}