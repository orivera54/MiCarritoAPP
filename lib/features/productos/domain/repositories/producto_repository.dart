import '../entities/producto.dart';

abstract class ProductoRepository {
  /// Get all productos
  Future<List<Producto>> getAllProductos();
  
  /// Get productos by almacen id
  Future<List<Producto>> getProductosByAlmacen(int almacenId);
  
  /// Get productos by categoria id
  Future<List<Producto>> getProductosByCategoria(int categoriaId);
  
  /// Get producto by id
  Future<Producto?> getProductoById(int id);
  
  /// Search productos by name
  Future<List<Producto>> searchProductosByName(String searchTerm);
  
  /// Search producto by QR code
  Future<Producto?> getProductoByQR(String codigoQR);
  
  /// Create new producto
  Future<Producto> createProducto(Producto producto);
  
  /// Update existing producto
  Future<Producto> updateProducto(Producto producto);
  
  /// Delete producto by id
  Future<void> deleteProducto(int id);
  
  /// Check if QR code exists in specific almacen (for validation)
  Future<bool> qrExistsInAlmacen(String codigoQR, int almacenId, {int? excludeId});
  
  /// Get productos with detailed information (including almacen and categoria names)
  Future<List<Map<String, dynamic>>> getProductosWithDetails();
  
  /// Search productos with multiple filters
  Future<List<Producto>> searchProductosWithFilters({
    String? searchTerm,
    int? almacenId,
    int? categoriaId,
    double? minPrice,
    double? maxPrice,
  });
}