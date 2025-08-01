import 'package:sqflite/sqflite.dart' hide DatabaseException;
import '../../../../core/database/database_helper.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/producto_model.dart';

abstract class ProductoLocalDataSource {
  /// Get all productos from local database
  Future<List<ProductoModel>> getAllProductos();
  
  /// Get productos by almacen id from local database
  Future<List<ProductoModel>> getProductosByAlmacen(int almacenId);
  
  /// Get productos by categoria id from local database
  Future<List<ProductoModel>> getProductosByCategoria(int categoriaId);
  
  /// Get producto by id from local database
  Future<ProductoModel?> getProductoById(int id);
  
  /// Search productos by name with optimized SQL query
  Future<List<ProductoModel>> searchProductosByName(String searchTerm);
  
  /// Search productos by QR code
  Future<ProductoModel?> getProductoByQR(String codigoQR);
  
  /// Insert new producto into local database
  Future<ProductoModel> insertProducto(ProductoModel producto);
  
  /// Update existing producto in local database
  Future<ProductoModel> updateProducto(ProductoModel producto);
  
  /// Delete producto from local database
  Future<void> deleteProducto(int id);
  
  /// Check if QR code exists in specific almacen
  Future<bool> qrExistsInAlmacen(String codigoQR, int almacenId, {int? excludeId});
  
  /// Get productos with detailed information (including almacen and categoria names)
  Future<List<Map<String, dynamic>>> getProductosWithDetails();
  
  /// Search productos with filters
  Future<List<ProductoModel>> searchProductosWithFilters({
    String? searchTerm,
    int? almacenId,
    int? categoriaId,
    double? minPrice,
    double? maxPrice,
    double? minVolume,
    double? maxVolume,
  });
  
  /// Get productos with pagination support
  Future<Map<String, dynamic>> getProductosPaginated({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
    int? categoriaId,
    int? almacenId,
  });
  
  /// Search productos by volume range
  Future<List<ProductoModel>> getProductosByVolumeRange(double minVolume, double maxVolume);
  
  /// Check if a product with the same name exists in the same almacen
  Future<bool> productExistsInAlmacen(String nombre, int almacenId, {int? excludeId});
}

class ProductoLocalDataSourceImpl implements ProductoLocalDataSource {
  final DatabaseHelper databaseHelper;
  
  ProductoLocalDataSourceImpl({required this.databaseHelper});
  
  @override
  Future<List<ProductoModel>> getAllProductos() async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.productosTable,
        orderBy: 'fecha_creacion DESC',
      );
      
      return List.generate(maps.length, (i) {
        return ProductoModel.fromJson(maps[i]);
      });
    } catch (e) {
      throw DatabaseException('Error al obtener productos: ${e.toString()}');
    }
  }
  
  @override
  Future<List<ProductoModel>> getProductosByAlmacen(int almacenId) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.productosTable,
        where: 'almacen_id = ?',
        whereArgs: [almacenId],
        orderBy: 'nombre ASC',
      );
      
      return List.generate(maps.length, (i) {
        return ProductoModel.fromJson(maps[i]);
      });
    } catch (e) {
      throw DatabaseException('Error al obtener productos por almacén: ${e.toString()}');
    }
  }
  
  @override
  Future<List<ProductoModel>> getProductosByCategoria(int categoriaId) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.productosTable,
        where: 'categoria_id = ?',
        whereArgs: [categoriaId],
        orderBy: 'nombre ASC',
      );
      
      return List.generate(maps.length, (i) {
        return ProductoModel.fromJson(maps[i]);
      });
    } catch (e) {
      throw DatabaseException('Error al obtener productos por categoría: ${e.toString()}');
    }
  }
  
  @override
  Future<ProductoModel?> getProductoById(int id) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.productosTable,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (maps.isNotEmpty) {
        return ProductoModel.fromJson(maps.first);
      }
      return null;
    } catch (e) {
      throw DatabaseException('Error al obtener producto: ${e.toString()}');
    }
  }
  
  @override
  Future<List<ProductoModel>> searchProductosByName(String searchTerm) async {
    try {
      final db = await databaseHelper.database;
      
      // Optimized SQL query with LIKE and proper indexing
      // Use rawQuery to handle complex ORDER BY with parameters
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT * FROM ${AppConstants.productosTable}
        WHERE LOWER(nombre) LIKE LOWER(?)
        ORDER BY 
          CASE 
            WHEN LOWER(nombre) = LOWER(?) THEN 1
            WHEN LOWER(nombre) LIKE LOWER(?) THEN 2
            ELSE 3
          END, nombre ASC
      ''', ['%$searchTerm%', searchTerm, '$searchTerm%']);
      
      return List.generate(maps.length, (i) {
        return ProductoModel.fromJson(maps[i]);
      });
    } catch (e) {
      throw DatabaseException('Error al buscar productos: ${e.toString()}');
    }
  }
  
  @override
  Future<ProductoModel?> getProductoByQR(String codigoQR) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.productosTable,
        where: 'codigo_qr = ?',
        whereArgs: [codigoQR],
      );
      
      if (maps.isNotEmpty) {
        return ProductoModel.fromJson(maps.first);
      }
      return null;
    } catch (e) {
      throw DatabaseException('Error al buscar producto por QR: ${e.toString()}');
    }
  }
  
  @override
  Future<ProductoModel> insertProducto(ProductoModel producto) async {
    try {
      final db = await databaseHelper.database;
      
      // Validate the producto data
      final validationError = producto.validate();
      if (validationError != null) {
        throw ValidationException(validationError);
      }
      
      // Check if QR code already exists in the same almacen
      if (producto.codigoQR != null && producto.codigoQR!.isNotEmpty) {
        final qrExists = await qrExistsInAlmacen(producto.codigoQR!, producto.almacenId);
        if (qrExists) {
          throw const DuplicateException('Ya existe un producto con ese código QR en este almacén');
        }
      }
      
      final now = DateTime.now();
      final productoToInsert = ProductoModel(
        nombre: producto.nombre,
        precio: producto.precio,
        peso: producto.peso,
        volumen: producto.volumen,
        tamano: producto.tamano,
        codigoQR: producto.codigoQR,
        categoriaId: producto.categoriaId,
        almacenId: producto.almacenId,
        fechaCreacion: now,
        fechaActualizacion: now,
      );
      
      final id = await db.insert(
        AppConstants.productosTable,
        productoToInsert.toJson()..remove('id'),
      );
      
      return ProductoModel(
        id: id,
        nombre: productoToInsert.nombre,
        precio: productoToInsert.precio,
        peso: productoToInsert.peso,
        volumen: productoToInsert.volumen,
        tamano: productoToInsert.tamano,
        codigoQR: productoToInsert.codigoQR,
        categoriaId: productoToInsert.categoriaId,
        almacenId: productoToInsert.almacenId,
        fechaCreacion: productoToInsert.fechaCreacion,
        fechaActualizacion: productoToInsert.fechaActualizacion,
      );
    } catch (e) {
      if (e is ValidationException || e is DuplicateException) rethrow;
      throw DatabaseException('Error al crear producto: ${e.toString()}');
    }
  }
  
  @override
  Future<ProductoModel> updateProducto(ProductoModel producto) async {
    try {
      if (producto.id == null) {
        throw const ValidationException('ID del producto es requerido para actualizar');
      }
      
      final db = await databaseHelper.database;
      
      // Validate the producto data
      final validationError = producto.validate();
      if (validationError != null) {
        throw ValidationException(validationError);
      }
      
      // Check if QR code already exists in the same almacen (excluding current producto)
      if (producto.codigoQR != null && producto.codigoQR!.isNotEmpty) {
        final qrExists = await qrExistsInAlmacen(
          producto.codigoQR!, 
          producto.almacenId, 
          excludeId: producto.id
        );
        if (qrExists) {
          throw const DuplicateException('Ya existe un producto con ese código QR en este almacén');
        }
      }
      
      final now = DateTime.now();
      final productoToUpdate = ProductoModel(
        id: producto.id,
        nombre: producto.nombre,
        precio: producto.precio,
        peso: producto.peso,
        volumen: producto.volumen,
        tamano: producto.tamano,
        codigoQR: producto.codigoQR,
        categoriaId: producto.categoriaId,
        almacenId: producto.almacenId,
        fechaCreacion: producto.fechaCreacion,
        fechaActualizacion: now,
      );
      
      final count = await db.update(
        AppConstants.productosTable,
        productoToUpdate.toJson()..remove('id'),
        where: 'id = ?',
        whereArgs: [producto.id],
      );
      
      if (count == 0) {
        throw const NotFoundException('Producto no encontrado');
      }
      
      return productoToUpdate;
    } catch (e) {
      if (e is ValidationException || e is DuplicateException || e is NotFoundException) rethrow;
      throw DatabaseException('Error al actualizar producto: ${e.toString()}');
    }
  }
  
  @override
  Future<void> deleteProducto(int id) async {
    try {
      final db = await databaseHelper.database;
      
      // Check if producto is used in calculadora items
      final itemCount = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM ${AppConstants.itemsCalculadoraTable} WHERE producto_id = ?',
        [id],
      )) ?? 0;
      
      if (itemCount > 0) {
        throw const ValidationException(
          'No se puede eliminar el producto porque está siendo usado en listas de compra'
        );
      }
      
      final count = await db.delete(
        AppConstants.productosTable,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (count == 0) {
        throw const NotFoundException('Producto no encontrado');
      }
    } catch (e) {
      if (e is ValidationException || e is NotFoundException) rethrow;
      throw DatabaseException('Error al eliminar producto: ${e.toString()}');
    }
  }
  
  @override
  Future<bool> qrExistsInAlmacen(String codigoQR, int almacenId, {int? excludeId}) async {
    try {
      final db = await databaseHelper.database;
      
      String whereClause = 'codigo_qr = ? AND almacen_id = ?';
      List<dynamic> whereArgs = [codigoQR, almacenId];
      
      if (excludeId != null) {
        whereClause += ' AND id != ?';
        whereArgs.add(excludeId);
      }
      
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.productosTable,
        where: whereClause,
        whereArgs: whereArgs,
      );
      
      return maps.isNotEmpty;
    } catch (e) {
      throw DatabaseException('Error al verificar código QR: ${e.toString()}');
    }
  }
  
  @override
  Future<List<Map<String, dynamic>>> getProductosWithDetails() async {
    try {
      final db = await databaseHelper.database;
      
      // Join query to get producto with almacen and categoria names
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT 
          p.*,
          a.nombre as almacen_nombre,
          c.nombre as categoria_nombre
        FROM ${AppConstants.productosTable} p
        LEFT JOIN ${AppConstants.almacenesTable} a ON p.almacen_id = a.id
        LEFT JOIN ${AppConstants.categoriasTable} c ON p.categoria_id = c.id
        ORDER BY p.fecha_creacion DESC
      ''');
      
      return maps;
    } catch (e) {
      throw DatabaseException('Error al obtener productos con detalles: ${e.toString()}');
    }
  }
  
  @override
  Future<List<ProductoModel>> searchProductosWithFilters({
    String? searchTerm,
    int? almacenId,
    int? categoriaId,
    double? minPrice,
    double? maxPrice,
    double? minVolume,
    double? maxVolume,
  }) async {
    try {
      final db = await databaseHelper.database;
      
      List<String> whereConditions = [];
      List<dynamic> whereArgs = [];
      
      // Add search term condition
      if (searchTerm != null && searchTerm.isNotEmpty) {
        whereConditions.add('LOWER(nombre) LIKE LOWER(?)');
        whereArgs.add('%$searchTerm%');
      }
      
      // Add almacen filter
      if (almacenId != null) {
        whereConditions.add('almacen_id = ?');
        whereArgs.add(almacenId);
      }
      
      // Add categoria filter
      if (categoriaId != null) {
        whereConditions.add('categoria_id = ?');
        whereArgs.add(categoriaId);
      }
      
      // Add price range filters
      if (minPrice != null) {
        whereConditions.add('precio >= ?');
        whereArgs.add(minPrice);
      }
      
      if (maxPrice != null) {
        whereConditions.add('precio <= ?');
        whereArgs.add(maxPrice);
      }
      
      // Add volume range filters
      if (minVolume != null) {
        whereConditions.add('volumen >= ?');
        whereArgs.add(minVolume);
      }
      
      if (maxVolume != null) {
        whereConditions.add('volumen <= ?');
        whereArgs.add(maxVolume);
      }
      
      String whereClause = whereConditions.isNotEmpty 
          ? whereConditions.join(' AND ')
          : '';
      
      // Build the complete SQL query
      String sql = 'SELECT * FROM ${AppConstants.productosTable}';
      List<dynamic> queryArgs = [];
      
      if (whereClause.isNotEmpty) {
        sql += ' WHERE $whereClause';
        queryArgs.addAll(whereArgs);
      }
      
      // Add ORDER BY clause
      if (searchTerm != null && searchTerm.isNotEmpty) {
        sql += '''
          ORDER BY 
            CASE 
              WHEN LOWER(nombre) = LOWER(?) THEN 1
              WHEN LOWER(nombre) LIKE LOWER(?) THEN 2
              ELSE 3
            END, nombre ASC
        ''';
        queryArgs.addAll([searchTerm, '$searchTerm%']);
      } else {
        sql += ' ORDER BY nombre ASC';
      }
      
      final List<Map<String, dynamic>> maps = await db.rawQuery(sql, queryArgs);
      
      return List.generate(maps.length, (i) {
        return ProductoModel.fromJson(maps[i]);
      });
    } catch (e) {
      throw DatabaseException('Error al buscar productos con filtros: ${e.toString()}');
    }
  }
  
  @override
  Future<Map<String, dynamic>> getProductosPaginated({
    int page = 1,
    int pageSize = 20,
    String? searchQuery,
    int? categoriaId,
    int? almacenId,
  }) async {
    try {
      final db = await databaseHelper.database;
      
      // Build WHERE clause
      List<String> whereConditions = [];
      List<dynamic> whereArgs = [];
      
      if (searchQuery != null && searchQuery.isNotEmpty) {
        whereConditions.add('LOWER(p.nombre) LIKE LOWER(?)');
        whereArgs.add('%$searchQuery%');
      }
      
      if (categoriaId != null) {
        whereConditions.add('p.categoria_id = ?');
        whereArgs.add(categoriaId);
      }
      
      if (almacenId != null) {
        whereConditions.add('p.almacen_id = ?');
        whereArgs.add(almacenId);
      }
      
      final whereClause = whereConditions.isNotEmpty 
          ? 'WHERE ${whereConditions.join(' AND ')}'
          : '';
      
      // Get total count
      final countResult = await db.rawQuery('''
        SELECT COUNT(*) as total
        FROM ${AppConstants.productosTable} p
        LEFT JOIN ${AppConstants.categoriasTable} c ON p.categoria_id = c.id
        LEFT JOIN ${AppConstants.almacenesTable} a ON p.almacen_id = a.id
        $whereClause
      ''', whereArgs);
      
      final totalItems = countResult.first['total'] as int;
      
      // Get paginated results
      final offset = (page - 1) * pageSize;
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT 
          p.*,
          c.nombre as categoria_nombre,
          a.nombre as almacen_nombre
        FROM ${AppConstants.productosTable} p
        LEFT JOIN ${AppConstants.categoriasTable} c ON p.categoria_id = c.id
        LEFT JOIN ${AppConstants.almacenesTable} a ON p.almacen_id = a.id
        $whereClause
        ORDER BY p.nombre ASC
        LIMIT ? OFFSET ?
      ''', [...whereArgs, pageSize, offset]);
      
      final productos = List.generate(maps.length, (i) {
        return ProductoModel.fromJson(maps[i]);
      });
      
      return {
        'productos': productos,
        'totalItems': totalItems,
        'currentPage': page,
        'pageSize': pageSize,
        'totalPages': (totalItems / pageSize).ceil(),
        'hasNext': page < (totalItems / pageSize).ceil(),
        'hasPrevious': page > 1,
      };
    } catch (e) {
      throw DatabaseException('Error al obtener productos paginados: ${e.toString()}');
    }
  }

  @override
  Future<List<ProductoModel>> getProductosByVolumeRange(double minVolume, double maxVolume) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.productosTable,
        where: 'volumen >= ? AND volumen <= ?',
        whereArgs: [minVolume, maxVolume],
        orderBy: 'volumen ASC',
      );
      
      return List.generate(maps.length, (i) {
        return ProductoModel.fromJson(maps[i]);
      });
    } catch (e) {
      throw DatabaseException('Error al obtener productos por rango de volumen: ${e.toString()}');
    }
  }

  @override
  Future<bool> productExistsInAlmacen(String nombre, int almacenId, {int? excludeId}) async {
    try {
      final db = await databaseHelper.database;
      
      String whereClause = 'LOWER(TRIM(nombre)) = LOWER(TRIM(?)) AND almacen_id = ?';
      List<dynamic> whereArgs = [nombre, almacenId];
      
      if (excludeId != null) {
        whereClause += ' AND id != ?';
        whereArgs.add(excludeId);
      }
      
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.productosTable,
        where: whereClause,
        whereArgs: whereArgs,
      );
      
      return maps.isNotEmpty;
    } catch (e) {
      throw DatabaseException('Error al verificar existencia de producto: ${e.toString()}');
    }
  }
}