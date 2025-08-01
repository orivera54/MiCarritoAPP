import '../entities/almacen.dart';

abstract class AlmacenRepository {
  /// Get all almacenes
  Future<List<Almacen>> getAllAlmacenes();
  
  /// Get almacen by id
  Future<Almacen?> getAlmacenById(int id);
  
  /// Create new almacen
  Future<Almacen> createAlmacen(Almacen almacen);
  
  /// Update existing almacen
  Future<Almacen> updateAlmacen(Almacen almacen);
  
  /// Delete almacen by id
  Future<void> deleteAlmacen(int id);
  
  /// Check if almacen name exists (for validation)
  Future<bool> almacenNameExists(String nombre, {int? excludeId});
}