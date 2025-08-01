import '../../../../core/database/database_helper.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/producto_comparacion_model.dart';

abstract class ComparadorLocalDataSource {
  Future<List<ProductoComparacionModel>> buscarProductosSimilares(String terminoBusqueda);
  Future<List<ProductoComparacionModel>> compararPreciosProducto(int productoId);
  Future<List<ProductoComparacionModel>> buscarProductosPorQR(String codigoQR);
  Future<List<Map<String, dynamic>>> obtenerProductosSimilares(String nombre);
}

class ComparadorLocalDataSourceImpl implements ComparadorLocalDataSource {
  final DatabaseHelper databaseHelper;
  
  ComparadorLocalDataSourceImpl({required this.databaseHelper});
  
  @override
  Future<List<ProductoComparacionModel>> buscarProductosSimilares(String terminoBusqueda) async {
    final db = await databaseHelper.database;
    
    // Query para buscar productos similares con información de almacén
    const query = '''
      SELECT 
        p.id as producto_id,
        p.nombre as producto_nombre,
        p.precio as producto_precio,
        p.peso as producto_peso,
        p.tamano as producto_tamano,
        p.codigo_qr as producto_codigo_qr,
        p.categoria_id,
        p.almacen_id,
        p.fecha_creacion as producto_fecha_creacion,
        p.fecha_actualizacion as producto_fecha_actualizacion,
        a.nombre as almacen_nombre,
        a.direccion as almacen_direccion,
        a.descripcion as almacen_descripcion,
        a.fecha_creacion as almacen_fecha_creacion,
        a.fecha_actualizacion as almacen_fecha_actualizacion,
        CASE WHEN p.precio = min_precio.precio_minimo THEN 1 ELSE 0 END as es_mejor_precio
      FROM ${AppConstants.productosTable} p
      INNER JOIN ${AppConstants.almacenesTable} a ON p.almacen_id = a.id
      CROSS JOIN (
        SELECT MIN(precio) as precio_minimo
        FROM ${AppConstants.productosTable}
        WHERE LOWER(nombre) LIKE LOWER(?)
      ) min_precio
      WHERE LOWER(p.nombre) LIKE LOWER(?)
      ORDER BY p.precio ASC, a.nombre ASC
    ''';
    
    final searchPattern = '%$terminoBusqueda%';
    final result = await db.rawQuery(query, [searchPattern, searchPattern]);
    
    return result.map((row) => ProductoComparacionModel.fromJson(row)).toList();
  }
  
  @override
  Future<List<ProductoComparacionModel>> compararPreciosProducto(int productoId) async {
    final db = await databaseHelper.database;
    
    // Primero obtenemos el producto base para buscar similares
    final productoBase = await db.query(
      AppConstants.productosTable,
      where: 'id = ?',
      whereArgs: [productoId],
      limit: 1,
    );
    
    if (productoBase.isEmpty) {
      return [];
    }
    
    final nombreProducto = productoBase.first['nombre'] as String;
    
    // Buscar productos con el mismo nombre en otros almacenes
    const query = '''
      SELECT 
        p.id as producto_id,
        p.nombre as producto_nombre,
        p.precio as producto_precio,
        p.peso as producto_peso,
        p.tamano as producto_tamano,
        p.codigo_qr as producto_codigo_qr,
        p.categoria_id,
        p.almacen_id,
        p.fecha_creacion as producto_fecha_creacion,
        p.fecha_actualizacion as producto_fecha_actualizacion,
        a.nombre as almacen_nombre,
        a.direccion as almacen_direccion,
        a.descripcion as almacen_descripcion,
        a.fecha_creacion as almacen_fecha_creacion,
        a.fecha_actualizacion as almacen_fecha_actualizacion,
        CASE WHEN p.precio = min_precio.precio_minimo THEN 1 ELSE 0 END as es_mejor_precio
      FROM ${AppConstants.productosTable} p
      INNER JOIN ${AppConstants.almacenesTable} a ON p.almacen_id = a.id
      CROSS JOIN (
        SELECT MIN(precio) as precio_minimo
        FROM ${AppConstants.productosTable}
        WHERE LOWER(nombre) = LOWER(?)
      ) min_precio
      WHERE LOWER(p.nombre) = LOWER(?)
      ORDER BY p.precio ASC, a.nombre ASC
    ''';
    
    final result = await db.rawQuery(query, [nombreProducto, nombreProducto]);
    
    return result.map((row) => ProductoComparacionModel.fromJson(row)).toList();
  }
  
  @override
  Future<List<ProductoComparacionModel>> buscarProductosPorQR(String codigoQR) async {
    final db = await databaseHelper.database;
    
    const query = '''
      SELECT 
        p.id as producto_id,
        p.nombre as producto_nombre,
        p.precio as producto_precio,
        p.peso as producto_peso,
        p.tamano as producto_tamano,
        p.codigo_qr as producto_codigo_qr,
        p.categoria_id,
        p.almacen_id,
        p.fecha_creacion as producto_fecha_creacion,
        p.fecha_actualizacion as producto_fecha_actualizacion,
        a.nombre as almacen_nombre,
        a.direccion as almacen_direccion,
        a.descripcion as almacen_descripcion,
        a.fecha_creacion as almacen_fecha_creacion,
        a.fecha_actualizacion as almacen_fecha_actualizacion,
        CASE WHEN p.precio = min_precio.precio_minimo THEN 1 ELSE 0 END as es_mejor_precio
      FROM ${AppConstants.productosTable} p
      INNER JOIN ${AppConstants.almacenesTable} a ON p.almacen_id = a.id
      CROSS JOIN (
        SELECT MIN(precio) as precio_minimo
        FROM ${AppConstants.productosTable}
        WHERE codigo_qr = ?
      ) min_precio
      WHERE p.codigo_qr = ?
      ORDER BY p.precio ASC, a.nombre ASC
    ''';
    
    final result = await db.rawQuery(query, [codigoQR, codigoQR]);
    
    return result.map((row) => ProductoComparacionModel.fromJson(row)).toList();
  }
  
  @override
  Future<List<Map<String, dynamic>>> obtenerProductosSimilares(String nombre) async {
    final db = await databaseHelper.database;
    
    // Algoritmo de matching por similitud de nombres
    // Busca productos que contengan palabras similares
    final palabras = nombre.toLowerCase().split(' ').where((p) => p.length > 2).toList();
    
    if (palabras.isEmpty) {
      return [];
    }
    
    // Construir query dinámico para buscar productos que contengan cualquiera de las palabras
    final whereConditions = palabras.map((_) => 'LOWER(p.nombre) LIKE ?').join(' OR ');
    final searchPatterns = palabras.map((palabra) => '%$palabra%').toList();
    
    final query = '''
      SELECT 
        p.id,
        p.nombre,
        p.precio,
        p.almacen_id,
        a.nombre as almacen_nombre,
        COUNT(*) as coincidencias
      FROM ${AppConstants.productosTable} p
      INNER JOIN ${AppConstants.almacenesTable} a ON p.almacen_id = a.id
      WHERE $whereConditions
      GROUP BY p.id, p.nombre, p.precio, p.almacen_id, a.nombre
      ORDER BY coincidencias DESC, p.precio ASC
      LIMIT 50
    ''';
    
    final result = await db.rawQuery(query, searchPatterns);
    
    return result;
  }
  

}