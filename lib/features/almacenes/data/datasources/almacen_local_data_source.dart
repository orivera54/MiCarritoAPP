import 'package:sqflite/sqflite.dart' hide DatabaseException;
import '../../../../core/database/database_helper.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/almacen_model.dart';

abstract class AlmacenLocalDataSource {
  /// Get all almacenes from local database
  Future<List<AlmacenModel>> getAllAlmacenes();
  
  /// Get almacen by id from local database
  Future<AlmacenModel?> getAlmacenById(int id);
  
  /// Insert new almacen into local database
  Future<AlmacenModel> insertAlmacen(AlmacenModel almacen);
  
  /// Update existing almacen in local database
  Future<AlmacenModel> updateAlmacen(AlmacenModel almacen);
  
  /// Delete almacen from local database
  Future<void> deleteAlmacen(int id);
  
  /// Check if almacen name exists in local database
  Future<bool> almacenNameExists(String nombre, {int? excludeId});
}

class AlmacenLocalDataSourceImpl implements AlmacenLocalDataSource {
  final DatabaseHelper databaseHelper;
  
  AlmacenLocalDataSourceImpl({required this.databaseHelper});
  
  @override
  Future<List<AlmacenModel>> getAllAlmacenes() async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.almacenesTable,
        orderBy: 'fecha_creacion DESC',
      );
      
      return List.generate(maps.length, (i) {
        return AlmacenModel.fromJson(maps[i]);
      });
    } catch (e) {
      throw DatabaseException('Error al obtener almacenes: ${e.toString()}');
    }
  }
  
  @override
  Future<AlmacenModel?> getAlmacenById(int id) async {
    try {
      final db = await databaseHelper.database;
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.almacenesTable,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (maps.isNotEmpty) {
        return AlmacenModel.fromJson(maps.first);
      }
      return null;
    } catch (e) {
      throw DatabaseException('Error al obtener almacén: ${e.toString()}');
    }
  }
  
  @override
  Future<AlmacenModel> insertAlmacen(AlmacenModel almacen) async {
    try {
      final db = await databaseHelper.database;
      
      // Validate the almacen data
      final validationError = almacen.validate();
      if (validationError != null) {
        throw ValidationException(validationError);
      }
      
      // Check if name already exists
      final nameExists = await almacenNameExists(almacen.nombre);
      if (nameExists) {
        throw const ValidationException('Ya existe un almacén con ese nombre');
      }
      
      final now = DateTime.now();
      final almacenToInsert = AlmacenModel(
        nombre: almacen.nombre,
        direccion: almacen.direccion,
        descripcion: almacen.descripcion,
        fechaCreacion: now,
        fechaActualizacion: now,
      );
      
      final id = await db.insert(
        AppConstants.almacenesTable,
        almacenToInsert.toJson()..remove('id'),
      );
      
      return almacenToInsert.copyWith(id: id);
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw DatabaseException('Error al crear almacén: ${e.toString()}');
    }
  }
  
  @override
  Future<AlmacenModel> updateAlmacen(AlmacenModel almacen) async {
    try {
      if (almacen.id == null) {
        throw const ValidationException('ID del almacén es requerido para actualizar');
      }
      
      final db = await databaseHelper.database;
      
      // Validate the almacen data
      final validationError = almacen.validate();
      if (validationError != null) {
        throw ValidationException(validationError);
      }
      
      // Check if name already exists (excluding current almacen)
      final nameExists = await almacenNameExists(almacen.nombre, excludeId: almacen.id);
      if (nameExists) {
        throw const ValidationException('Ya existe un almacén con ese nombre');
      }
      
      final almacenToUpdate = almacen.copyWith(
        fechaActualizacion: DateTime.now(),
      );
      
      final count = await db.update(
        AppConstants.almacenesTable,
        almacenToUpdate.toJson()..remove('id'),
        where: 'id = ?',
        whereArgs: [almacen.id],
      );
      
      if (count == 0) {
        throw const DatabaseException('Almacén no encontrado');
      }
      
      return almacenToUpdate;
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw DatabaseException('Error al actualizar almacén: ${e.toString()}');
    }
  }
  
  @override
  Future<void> deleteAlmacen(int id) async {
    try {
      final db = await databaseHelper.database;
      
      // Check if almacen has associated products
      final productCount = Sqflite.firstIntValue(await db.rawQuery(
        'SELECT COUNT(*) FROM ${AppConstants.productosTable} WHERE almacen_id = ?',
        [id],
      )) ?? 0;
      
      if (productCount > 0) {
        throw const ValidationException(
          'No se puede eliminar el almacén porque tiene productos asociados'
        );
      }
      
      final count = await db.delete(
        AppConstants.almacenesTable,
        where: 'id = ?',
        whereArgs: [id],
      );
      
      if (count == 0) {
        throw const DatabaseException('Almacén no encontrado');
      }
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw DatabaseException('Error al eliminar almacén: ${e.toString()}');
    }
  }
  
  @override
  Future<bool> almacenNameExists(String nombre, {int? excludeId}) async {
    try {
      final db = await databaseHelper.database;
      
      String whereClause = 'LOWER(nombre) = LOWER(?)';
      List<dynamic> whereArgs = [nombre];
      
      if (excludeId != null) {
        whereClause += ' AND id != ?';
        whereArgs.add(excludeId);
      }
      
      final List<Map<String, dynamic>> maps = await db.query(
        AppConstants.almacenesTable,
        where: whereClause,
        whereArgs: whereArgs,
      );
      
      return maps.isNotEmpty;
    } catch (e) {
      throw DatabaseException('Error al verificar nombre del almacén: ${e.toString()}');
    }
  }
}