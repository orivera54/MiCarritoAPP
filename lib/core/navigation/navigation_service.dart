import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static BuildContext? get context => navigatorKey.currentContext;

  // Navigation to main screens
  static Future<void> navigateToAlmacenes() async {
    await navigatorKey.currentState?.pushNamed(AppRoutes.almacenes);
  }

  static Future<void> navigateToProductos() async {
    await navigatorKey.currentState?.pushNamed(AppRoutes.productos);
  }

  static Future<void> navigateToCalculadora() async {
    await navigatorKey.currentState?.pushNamed(AppRoutes.calculadora);
  }

  static Future<void> navigateToComparador() async {
    await navigatorKey.currentState?.pushNamed(AppRoutes.comparador);
  }

  // Navigation to form screens
  static Future<T?> navigateToAlmacenForm<T>([dynamic almacen]) async {
    return await navigatorKey.currentState?.pushNamed(
      AppRoutes.almacenForm,
      arguments: almacen,
    );
  }

  static Future<T?> navigateToProductoForm<T>([dynamic producto]) async {
    return await navigatorKey.currentState?.pushNamed(
      AppRoutes.productoForm,
      arguments: producto,
    );
  }

  static Future<T?> navigateToQRScanner<T>() async {
    return await navigatorKey.currentState?.pushNamed(AppRoutes.qrScanner);
  }

  // Contextual navigation methods for feature integration
  static Future<void> navigateToCalculadoraWithProduct(dynamic producto) async {
    // Navigate to calculadora and pass product data
    await navigatorKey.currentState?.pushNamed(
      AppRoutes.calculadora,
      arguments: {'addProduct': producto},
    );
  }

  static Future<void> navigateToComparadorWithProduct(dynamic producto) async {
    // Navigate to comparador with specific product for comparison
    await navigatorKey.currentState?.pushNamed(
      AppRoutes.comparador,
      arguments: {'searchProduct': producto.nombre},
    );
  }

  static Future<void> navigateToProductosWithQR(String qrCode) async {
    // Navigate to productos with QR code for search
    await navigatorKey.currentState?.pushNamed(
      AppRoutes.productos,
      arguments: {'qrCode': qrCode},
    );
  }

  // Utility navigation methods
  static void goBack([dynamic result]) {
    navigatorKey.currentState?.pop(result);
  }

  static void goBackToMain() {
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.main,
      (route) => false,
    );
  }

  static Future<void> pushReplacement(String routeName, [dynamic arguments]) async {
    await navigatorKey.currentState?.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  static Future<void> pushAndRemoveUntil(
    String routeName,
    bool Function(Route<dynamic>) predicate, [
    dynamic arguments,
  ]) async {
    await navigatorKey.currentState?.pushNamedAndRemoveUntil(
      routeName,
      predicate,
      arguments: arguments,
    );
  }

  // Navigation to splash and onboarding
  static Future<void> navigateToSplash() async {
    await navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.splash,
      (route) => false,
    );
  }

  static Future<void> navigateToOnboarding() async {
    await navigatorKey.currentState?.pushNamedAndRemoveUntil(
      AppRoutes.onboarding,
      (route) => false,
    );
  }
}