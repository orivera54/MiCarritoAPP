import 'package:flutter/foundation.dart';
import '../di/service_locator.dart';
import '../database/database_helper.dart';
import '../../features/categorias/domain/usecases/ensure_default_category.dart';
import '../../features/almacenes/domain/usecases/get_all_almacenes.dart';
import '../../features/categorias/domain/usecases/get_all_categorias.dart';
import 'app_initialization_result.dart';

class AppInitializationService {
  final EnsureDefaultCategory _ensureDefaultCategory;
  final GetAllAlmacenes _getAllAlmacenes;
  final GetAllCategorias _getAllCategorias;
  final DatabaseHelper _databaseHelper;

  AppInitializationService({
    EnsureDefaultCategory? ensureDefaultCategory,
    GetAllAlmacenes? getAllAlmacenes,
    GetAllCategorias? getAllCategorias,
    DatabaseHelper? databaseHelper,
  }) : _ensureDefaultCategory = ensureDefaultCategory ?? sl<EnsureDefaultCategory>(),
        _getAllAlmacenes = getAllAlmacenes ?? sl<GetAllAlmacenes>(),
        _getAllCategorias = getAllCategorias ?? sl<GetAllCategorias>(),
        _databaseHelper = databaseHelper ?? sl<DatabaseHelper>();

  static Future<AppInitializationResult> initialize({
    EnsureDefaultCategory? ensureDefaultCategory,
    GetAllAlmacenes? getAllAlmacenes,
    GetAllCategorias? getAllCategorias,
    DatabaseHelper? databaseHelper,
  }) async {
    final service = AppInitializationService(
      ensureDefaultCategory: ensureDefaultCategory,
      getAllAlmacenes: getAllAlmacenes,
      getAllCategorias: getAllCategorias,
      databaseHelper: databaseHelper,
    );
    return service._initialize();
  }

  Future<AppInitializationResult> _initialize() async {
    try {
      final startTime = DateTime.now();
      
      if (kDebugMode) {
        print('Starting app initialization...');
      }

      // TEMPORAL: Forzar recreación de base de datos para agregar campo volumen
      if (kDebugMode) {
        print('Checking database structure...');
        await _checkAndFixDatabaseStructure();
      }

      // Initialize database
      await _databaseHelper.database;
      
      // Ensure default category exists
      final defaultCategory = await _ensureDefaultCategory();
      
      // Get all categories and almacenes for metadata
      final categorias = await _getAllCategorias();
      final almacenes = await _getAllAlmacenes();
      
      final hasAlmacenes = almacenes.isNotEmpty;
      final endTime = DateTime.now();
      final initializationTime = endTime.difference(startTime);

      final metadata = {
        'initializationTime': initializationTime.inMilliseconds,
        'defaultCategoryId': defaultCategory.id,
        'totalCategorias': categorias.length,
        'totalAlmacenes': almacenes.length,
        'databaseInitialized': true,
        'timestamp': DateTime.now().toIso8601String(),
      };

      if (kDebugMode) {
        print('App initialization completed in ${initializationTime.inMilliseconds}ms');
        print('Found ${almacenes.length} almacenes and ${categorias.length} categorias');
      }

      return AppInitializationResult(
        isFirstRun: !hasAlmacenes,
        needsOnboarding: !hasAlmacenes,
        success: true,
        metadata: metadata,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error during app initialization: $e');
      }
      return AppInitializationResult(
        isFirstRun: false,
        needsOnboarding: false,
        success: false,
        error: e.toString(),
        metadata: {
          'error': e.toString(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    }
  }

  Future<void> _checkAndFixDatabaseStructure() async {
    try {
      final db = await _databaseHelper.database;
      
      // Verificar si el campo volumen existe
      final tableInfo = await db.rawQuery("PRAGMA table_info(productos)");
      final hasVolumeColumn = tableInfo.any((column) => column['name'] == 'volumen');
      
      if (!hasVolumeColumn) {
        print('Campo volumen no encontrado. Recreando base de datos...');
        await _databaseHelper.recreateDatabase();
        print('Base de datos recreada exitosamente');
      } else {
        print('Campo volumen encontrado. Base de datos OK.');
      }
      
      // Verificar estructura final
      final newDb = await _databaseHelper.database;
      final newTableInfo = await newDb.rawQuery("PRAGMA table_info(productos)");
      print('Estructura actual de la tabla productos:');
      for (final column in newTableInfo) {
        print('  ${column['name']}: ${column['type']}');
      }
      
    } catch (e) {
      print('Error verificando estructura de base de datos: $e');
      // Si hay error, forzar recreación
      print('Forzando recreación de base de datos...');
      await _databaseHelper.recreateDatabase();
    }
  }
}