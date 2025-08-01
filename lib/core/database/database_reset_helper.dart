import 'database_helper.dart';

class DatabaseResetHelper {
  static Future<void> forceRecreateDatabase() async {
    final databaseHelper = DatabaseHelper();

    try {
      print('Iniciando recreación forzada de la base de datos...');

      // Forzar la recreación de la base de datos
      await databaseHelper.recreateDatabase();

      print('Base de datos recreada exitosamente');

      // Verificar que la base de datos se creó correctamente
      final db = await databaseHelper.database;

      // Verificar la estructura de la tabla productos
      final tableInfo = await db.rawQuery("PRAGMA table_info(productos)");
      print('Estructura de la tabla productos:');
      for (final column in tableInfo) {
        print(
            '  ${column['name']}: ${column['type']} ${column['notnull'] == 1 ? 'NOT NULL' : ''} ${column['pk'] == 1 ? 'PRIMARY KEY' : ''}');
      }

      // Verificar que el campo volumen existe
      final hasVolumeColumn =
          tableInfo.any((column) => column['name'] == 'volumen');
      if (hasVolumeColumn) {
        print('✅ Campo volumen encontrado en la tabla productos');
      } else {
        print('❌ Campo volumen NO encontrado en la tabla productos');
      }
    } catch (e) {
      print('Error durante la recreación de la base de datos: $e');
      rethrow;
    }
  }

  static Future<void> checkDatabaseStructure() async {
    final databaseHelper = DatabaseHelper();

    try {
      final db = await databaseHelper.database;

      print('=== VERIFICACIÓN DE ESTRUCTURA DE BASE DE DATOS ===');

      // Obtener versión de la base de datos
      final versionResult = await db.rawQuery('PRAGMA user_version');
      final version = versionResult.first['user_version'];
      print('Versión de la base de datos: $version');

      // Verificar tablas existentes
      final tables = await db
          .rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
      print('Tablas encontradas:');
      for (final table in tables) {
        print('  - ${table['name']}');
      }

      // Verificar estructura específica de la tabla productos
      final tableInfo = await db.rawQuery("PRAGMA table_info(productos)");
      print('\nEstructura de la tabla productos:');
      for (final column in tableInfo) {
        print(
            '  ${column['name']}: ${column['type']} ${column['notnull'] == 1 ? 'NOT NULL' : ''} ${column['pk'] == 1 ? 'PRIMARY KEY' : ''}');
      }

      // Verificar índices
      final indices = await db.rawQuery("PRAGMA index_list(productos)");
      print('\nÍndices de la tabla productos:');
      for (final index in indices) {
        print('  - ${index['name']} (unique: ${index['unique']})');
      }
    } catch (e) {
      print('Error durante la verificación: $e');
      rethrow;
    }
  }
}
