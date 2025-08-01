import 'package:sqflite/sqflite.dart' hide DatabaseException;
import '../../../../core/database/database_helper.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/categoria_model.dart';

abstract class CategoriaLocalDataSource {
  /// Get all categorias from local database
  Future<List<CategoriaModel>> getAllCategorias();
  
  /// Get categoria by id from local database
  Future<CategoriaModel?> getCategoriaById(int id);
  
  /// Get categoria by name from local database
  Future<CategoriaModel?> getCategoriaByName(String nombre);
  
  /// Insert new categoria into local database
  Future<CategoriaModel> insertCategoria(CategoriaModel categoria);
  
  /// Update existing categoria in local database
  Future<CategoriaModel> updateCategoria(CategoriaModel categoria);
  
  /// Delete categoria from local database
  Future<void> deleteCategoria(int id);
  
  /// Check if categoria name exists in local database
  Future<bool> categoriaNameExists(String nombre, {int? excludeId});
}

class CategoriaLocalDataSourceImpl implements CategoriaLocalDataSource {
  final DatabaseHelper databaseHelper;
  
  CategoriaLocalDataSourceImpl({required this.databaseHelper});
  
  @override
  Future<List<CategoriaModel>> getAllCategorias() async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.categoriasTable,
        orderBy: 'nombre ASC',
      );
      
      return List.generate(maps.length, (i) {
        return CategoriaModel.fromJson(maps[i]);
      });
    } catch (e) {
      throw DatabaseException('Error al obtener categorías: ${e.toString()}');
    }
  }
  
  @override
  Future<CategoriaModel?> getCategoriaById(int id) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.categoriasTable,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (maps.isNotEmpty) {
        return CategoriaModel.fromJson(maps.first);
      }
      return null;
    } catch (e) {
      throw DatabaseException('Error al obtener categoría: ${e.toString()}');
    }
  }
  
  @override
  Future<CategoriaModel?> getCategoriaByName(String nombre) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.categoriasTable,
        where: 'LOWER(nombre) = LOWER(?)',
        whereArgs: [nombre],
      );
      
      if (maps.isNotEmpty) {
        return CategoriaModel.fromJson(maps.first);
      }
      return null;
    } catch (e) {
      throw DatabaseException('Error al obtener categoría por nombre: ${e.toString()}');
    }
  }
  
  @override
  Future<CategoriaModel> insertCategoria(CategoriaModel categoria) async {
    try {
      final db = await databaseHelper.database;
      
      // Validate the categoria data
      final validationError = categoria.validate();
      if (validationError != null) {
        throw ValidationException(validationError);
      }
      
      // Check if name already exists
      final nameExists = await categoriaNameExists(categoria.nombre);
      if (nameExists) {
        throw const ValidationException('Ya existe una categoría con ese nombre');
      }
      
      final now = DateTime.now();
      final categoriaToInsert = CategoriaModel(
        nombre: categoria.nombre.trim(),
        descripcion: categoria.descripcion?.trim(),
        fechaCreacion: now,
      );
      
      final id = await db.insert(
        AppConstants.categoriasTable,
        categoriaToInsert.toJson()..remove('id'),
      );
      
      return categoriaToInsert.copyWith(id: id);
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw DatabaseException('Error al crear categoría: ${e.toString()}');
    }
  }
  
  @override
  Future<CategoriaModel> updateCategoria(CategoriaModel categoria) async {
    try {
      if (categoria.id == null) {
        throw const ValidationException('ID de la categoría es requerido para actualizar');
      }
      
      final db = await databaseHelper.database;
      
      // Validate the categoria data
      final validationError = categoria.validate();
      if (validationError != null) {
        throw ValidationException(validationError);
      }
      
      // Check if name already exists (excluding current categoria)
      final nameExists = await categoriaNameExists(categoria.nombre, excludeId: categoria.id);
      if (nameExists) {
        throw const ValidationException('Ya existe una categoría con ese nombre');
      }
      
      final categoriaToUpdate = categoria.copyWith(
        nombre: categoria.nombre.trim(),
        descripcion: categoria.descripcion?.trim(),
      );
      
      final count = await db.update(
        AppConstants.categoriasTable,
        categoriaToUpdate.toJson()..remove('id'),
        where: 'id = ?',
        whereArgs: [categoria.id],
      );
      
      if (count == 0) {
        throw const DatabaseException('Categoría no encontrada');
      }
      
      return categoriaToUpdate;
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw DatabaseException('Error al actualizar categoría: ${e.toString()}');
    }
  }
  
  @override
  Future<void> deleteCategoria(int id) async {
    try {
      final db = await databaseHelper.database;
      
      // Check if categoria has associated products
      final productCount = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM ${AppConstants.productosTable} WHERE categoria_id = ?',
        [id],
      )) ?? 0;
      
      if (productCount > 0) {
        throw const ValidationException(
          'No se puede eliminar la categoría porque tiene productos asociados'
        );
      }
      
      // Check if it's the default category
      final categoria = await getCategoriaById(id);
      if (categoria != null && categoria.nombre.toLowerCase() == AppConstants.defaultCategory.toLowerCase()) {
        throw const ValidationException(
          'No se puede eliminar la categoría por defecto "${AppConstants.defaultCategory}"'
        );
      }
      
      final count = await db.delete(
        AppConstants.categoriasTable,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (count == 0) {
        throw const DatabaseException('Categoría no encontrada');
      }
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw DatabaseException('Error al eliminar categoría: ${e.toString()}');
    }
  }
  
  @override
  Future<bool> categoriaNameExists(String nombre, {int? excludeId}) async {
    try {
      final db = await databaseHelper.database;
      
      String whereClause = 'LOWER(nombre) = LOWER(?)';
      List<dynamic> whereArgs = [nombre.trim()];
      
      if (excludeId != null) {
        whereClause += ' AND id != ?';
        whereArgs.add(excludeId);
      }
      
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.categoriasTable,
        where: whereClause,
        whereArgs: whereArgs,
      );
      
      return maps.isNotEmpty;
    } catch (e) {
      throw DatabaseException('Error al verificar nombre de la categoría: ${e.toString()}');
    }
  }
}