import 'package:sqflite/sqflite.dart';
import '../constants/app_constants.dart';

class DuplicateConsolidationService {
  /// Consolida productos duplicados durante la migración de base de datos
  static Future<void> consolidateDuplicateProductos(Database db) async {
    try {
      // Encontrar productos duplicados (mismo nombre normalizado + almacén)
      final duplicates = await db.rawQuery('''
        SELECT 
          LOWER(TRIM(nombre)) as nombre_normalizado,
          almacen_id,
          COUNT(*) as count,
          GROUP_CONCAT(id) as ids,
          GROUP_CONCAT(fecha_actualizacion) as fechas
        FROM ${AppConstants.productosTable}
        GROUP BY LOWER(TRIM(nombre)), almacen_id
        HAVING COUNT(*) > 1
      ''');

      if (duplicates.isEmpty) {
        print('No se encontraron productos duplicados');
        return;
      }

      print('Encontrados ${duplicates.length} grupos de productos duplicados');

      // Procesar cada grupo de duplicados
      for (final duplicate in duplicates) {
        final ids = (duplicate['ids'] as String).split(',').map(int.parse).toList();
        final fechas = (duplicate['fechas'] as String).split(',');
        
        // Encontrar el producto más reciente
        int mostRecentIndex = 0;
        DateTime mostRecentDate = DateTime.parse(fechas[0]);
        
        for (int i = 1; i < fechas.length; i++) {
          final currentDate = DateTime.parse(fechas[i]);
          if (currentDate.isAfter(mostRecentDate)) {
            mostRecentDate = currentDate;
            mostRecentIndex = i;
          }
        }
        
        final keepId = ids[mostRecentIndex];
        final removeIds = ids.where((id) => id != keepId).toList();
        
        print('Consolidando productos: manteniendo ID $keepId, eliminando ${removeIds.join(', ')}');
        
        // Actualizar referencias en items_calculadora
        for (final removeId in removeIds) {
          await db.update(
            AppConstants.itemsCalculadoraTable,
            {'producto_id': keepId},
            where: 'producto_id = ?',
            whereArgs: [removeId],
          );
        }
        
        // Eliminar productos duplicados
        for (final removeId in removeIds) {
          await db.delete(
            AppConstants.productosTable,
            where: 'id = ?',
            whereArgs: [removeId],
          );
        }
      }
      
      print('Consolidación de productos duplicados completada');
    } catch (e) {
      print('Error durante la consolidación de duplicados: $e');
      rethrow;
    }
  }

  /// Verifica si existen productos duplicados
  static Future<bool> hasDuplicateProductos(Database db) async {
    final result = await db.rawQuery('''
      SELECT COUNT(*) as count
      FROM (
        SELECT 
          LOWER(TRIM(nombre)) as nombre_normalizado,
          almacen_id,
          COUNT(*) as group_count
        FROM ${AppConstants.productosTable}
        GROUP BY LOWER(TRIM(nombre)), almacen_id
        HAVING COUNT(*) > 1
      )
    ''');
    
    final count = result.first['count'] as int;
    return count > 0;
  }

  /// Obtiene información sobre productos duplicados
  static Future<List<Map<String, dynamic>>> getDuplicateProductosInfo(Database db) async {
    return await db.rawQuery('''
      SELECT 
        LOWER(TRIM(nombre)) as nombre_normalizado,
        almacen_id,
        COUNT(*) as count,
        GROUP_CONCAT(id) as ids,
        GROUP_CONCAT(nombre) as nombres_originales,
        GROUP_CONCAT(precio) as precios,
        GROUP_CONCAT(fecha_actualizacion) as fechas
      FROM ${AppConstants.productosTable}
      GROUP BY LOWER(TRIM(nombre)), almacen_id
      HAVING COUNT(*) > 1
      ORDER BY count DESC
    ''');
  }
}