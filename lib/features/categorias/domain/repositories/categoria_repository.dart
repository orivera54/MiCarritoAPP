import '../entities/categoria.dart';

abstract class CategoriaRepository {
  /// Get all categorias
  Future<List<Categoria>> getAllCategorias();
  
  /// Get categoria by id
  Future<Categoria?> getCategoriaById(int id);
  
  /// Get categoria by name
  Future<Categoria?> getCategoriaByName(String nombre);
  
  /// Create new categoria
  Future<Categoria> createCategoria(Categoria categoria);
  
  /// Update existing categoria
  Future<Categoria> updateCategoria(Categoria categoria);
  
  /// Delete categoria by id
  Future<void> deleteCategoria(int id);
  
  /// Check if categoria name exists (for validation)
  Future<bool> categoriaNameExists(String nombre, {int? excludeId});
  
  /// Ensure default "General" category exists
  Future<Categoria> ensureDefaultCategory();
}