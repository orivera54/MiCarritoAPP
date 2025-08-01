import '../../domain/entities/producto.dart';
import '../../domain/repositories/producto_repository.dart';
import '../datasources/producto_local_data_source.dart';
import '../models/producto_model.dart';

class ProductoRepositoryImpl implements ProductoRepository {
  final ProductoLocalDataSource localDataSource;
  
  ProductoRepositoryImpl({required this.localDataSource});
  
  @override
  Future<List<Producto>> getAllProductos() async {
    final productoModels = await localDataSource.getAllProductos();
    return productoModels.cast<Producto>();
  }
  
  @override
  Future<List<Producto>> getProductosByAlmacen(int almacenId) async {
    final productoModels = await localDataSource.getProductosByAlmacen(almacenId);
    return productoModels.cast<Producto>();
  }
  
  @override
  Future<List<Producto>> getProductosByCategoria(int categoriaId) async {
    final productoModels = await localDataSource.getProductosByCategoria(categoriaId);
    return productoModels.cast<Producto>();
  }
  
  @override
  Future<Producto?> getProductoById(int id) async {
    final productoModel = await localDataSource.getProductoById(id);
    return productoModel;
  }
  
  @override
  Future<List<Producto>> searchProductosByName(String searchTerm) async {
    final productoModels = await localDataSource.searchProductosByName(searchTerm);
    return productoModels.cast<Producto>();
  }
  
  @override
  Future<Producto?> getProductoByQR(String codigoQR) async {
    final productoModel = await localDataSource.getProductoByQR(codigoQR);
    return productoModel;
  }
  
  @override
  Future<Producto> createProducto(Producto producto) async {
    final productoModel = ProductoModel.fromEntity(producto);
    final createdProducto = await localDataSource.insertProducto(productoModel);
    return createdProducto;
  }
  
  @override
  Future<Producto> updateProducto(Producto producto) async {
    final productoModel = ProductoModel.fromEntity(producto);
    final updatedProducto = await localDataSource.updateProducto(productoModel);
    return updatedProducto;
  }
  
  @override
  Future<void> deleteProducto(int id) async {
    await localDataSource.deleteProducto(id);
  }
  
  @override
  Future<bool> qrExistsInAlmacen(String codigoQR, int almacenId, {int? excludeId}) async {
    return await localDataSource.qrExistsInAlmacen(codigoQR, almacenId, excludeId: excludeId);
  }
  
  @override
  Future<List<Map<String, dynamic>>> getProductosWithDetails() async {
    return await localDataSource.getProductosWithDetails();
  }
  
  @override
  Future<List<Producto>> searchProductosWithFilters({
    String? searchTerm,
    int? almacenId,
    int? categoriaId,
    double? minPrice,
    double? maxPrice,
  }) async {
    final productoModels = await localDataSource.searchProductosWithFilters(
      searchTerm: searchTerm,
      almacenId: almacenId,
      categoriaId: categoriaId,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
    return productoModels.cast<Producto>();
  }
}