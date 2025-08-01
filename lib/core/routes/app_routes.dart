import 'package:flutter/material.dart';
import '../../features/splash/presentation/pages/splash_screen.dart';
import '../../features/onboarding/presentation/pages/onboarding_screen.dart';
import '../../features/almacenes/presentation/pages/almacenes_list_screen.dart';
import '../../features/almacenes/presentation/pages/almacen_form_screen.dart';
import '../../features/productos/presentation/pages/productos_list_screen.dart';
import '../../features/productos/presentation/pages/producto_form_screen.dart';
import '../../features/productos/presentation/pages/qr_scanner_screen.dart';
import '../../features/calculadora/presentation/pages/calculadora_screen.dart';
import '../../features/comparador/presentation/pages/comparador_screen.dart';
import '../../main_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String main = '/main';
  static const String almacenes = '/almacenes';
  static const String almacenForm = '/almacen-form';
  static const String productos = '/productos';
  static const String productoForm = '/producto-form';
  static const String qrScanner = '/qr-scanner';
  static const String calculadora = '/calculadora';
  static const String comparador = '/comparador';

  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        onboarding: (context) => const OnboardingScreen(),
        main: (context) => const MainScreen(),
        almacenes: (context) => const AlmacenesListScreen(),
        almacenForm: (context) => const AlmacenFormScreen(),
        productos: (context) => const ProductosListScreen(),
        productoForm: (context) => const ProductoFormScreen(),
        qrScanner: (context) => const QRScannerScreen(),
        calculadora: (context) => const CalculadoraScreen(),
        comparador: (context) => const ComparadorScreen(),
      };

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          builder: (context) => const SplashScreen(),
          settings: settings,
        );
      case onboarding:
        return MaterialPageRoute(
          builder: (context) => const OnboardingScreen(),
          settings: settings,
        );
      case main:
        return MaterialPageRoute(
          builder: (context) => const MainScreen(),
          settings: settings,
        );
      case almacenes:
        return MaterialPageRoute(
          builder: (context) => const AlmacenesListScreen(),
          settings: settings,
        );
      case almacenForm:
        final almacen = settings.arguments as dynamic;
        return MaterialPageRoute(
          builder: (context) => AlmacenFormScreen(almacen: almacen),
          settings: settings,
        );
      case productos:
        return MaterialPageRoute(
          builder: (context) => const ProductosListScreen(),
          settings: settings,
        );
      case productoForm:
        final producto = settings.arguments as dynamic;
        return MaterialPageRoute(
          builder: (context) => ProductoFormScreen(producto: producto),
          settings: settings,
        );
      case qrScanner:
        return MaterialPageRoute(
          builder: (context) => const QRScannerScreen(),
          settings: settings,
        );
      case calculadora:
        return MaterialPageRoute(
          builder: (context) => const CalculadoraScreen(),
          settings: settings,
        );
      case comparador:
        return MaterialPageRoute(
          builder: (context) => const ComparadorScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (context) => const SplashScreen(),
          settings: settings,
        );
    }
  }
}
