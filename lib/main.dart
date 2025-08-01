import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/di/service_locator.dart' as di;
import 'core/routes/app_routes.dart';
import 'core/navigation/navigation_service.dart';
import 'core/error_handling/global_error_handler.dart';
import 'features/almacenes/presentation/bloc/almacen_bloc.dart';
import 'features/productos/presentation/bloc/producto_bloc.dart';
import 'features/calculadora/presentation/bloc/calculadora_bloc.dart';
import 'features/comparador/presentation/bloc/comparador_bloc.dart';
import 'features/categorias/presentation/bloc/categoria_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize global error handler
  GlobalErrorHandler.initialize();
  
  // Initialize sqflite for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  
  await di.init();
  runApp(const SupermercadoComparadorApp());
}

class SupermercadoComparadorApp extends StatelessWidget {
  const SupermercadoComparadorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ErrorBoundary(
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AlmacenBloc>(
            create: (context) => di.sl<AlmacenBloc>(),
          ),
          BlocProvider<ProductoBloc>(
            create: (context) => di.sl<ProductoBloc>(),
          ),
          BlocProvider<CalculadoraBloc>(
            create: (context) => di.sl<CalculadoraBloc>(),
          ),
          BlocProvider<ComparadorBloc>(
            create: (context) => di.sl<ComparadorBloc>(),
          ),
          BlocProvider<CategoriaBloc>(
            create: (context) => di.sl<CategoriaBloc>(),
          ),
        ],
        child: MaterialApp(
          title: 'Supermercado Comparador',
          navigatorKey: NavigationService.navigatorKey,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          initialRoute: AppRoutes.splash,
          routes: AppRoutes.routes,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        ),
      ),
    );
  }
}