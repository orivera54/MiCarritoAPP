import '../../domain/entities/resultado_comparacion.dart';
import '../../domain/repositories/comparador_repository.dart';
import '../datasources/comparador_local_data_source.dart';
import '../models/resultado_comparacion_model.dart';

class ComparadorRepositoryImpl implements ComparadorRepository {
  final ComparadorLocalDataSource localDataSource;
  
  ComparadorRepositoryImpl({required this.localDataSource});
  
  @override
  Future<ResultadoComparacion> buscarProductosSimilares(String terminoBusqueda) async {
    final productos = await localDataSource.buscarProductosSimilares(terminoBusqueda);
    
    double? mejorPrecio;
    if (productos.isNotEmpty) {
      mejorPrecio = productos.map((p) => p.producto.precio).reduce((a, b) => a < b ? a : b);
    }
    
    return ResultadoComparacionModel(
      terminoBusqueda: terminoBusqueda,
      productos: productos,
      mejorPrecio: mejorPrecio,
      fechaComparacion: DateTime.now(),
    );
  }
  
  @override
  Future<ResultadoComparacion> compararPreciosProducto(int productoId) async {
    final productos = await localDataSource.compararPreciosProducto(productoId);
    
    double? mejorPrecio;
    String terminoBusqueda = '';
    
    if (productos.isNotEmpty) {
      mejorPrecio = productos.map((p) => p.producto.precio).reduce((a, b) => a < b ? a : b);
      terminoBusqueda = productos.first.producto.nombre;
    }
    
    return ResultadoComparacionModel(
      terminoBusqueda: terminoBusqueda,
      productos: productos,
      mejorPrecio: mejorPrecio,
      fechaComparacion: DateTime.now(),
    );
  }
  
  @override
  Future<ResultadoComparacion> buscarProductosPorQR(String codigoQR) async {
    final productos = await localDataSource.buscarProductosPorQR(codigoQR);
    
    double? mejorPrecio;
    String terminoBusqueda = '';
    
    if (productos.isNotEmpty) {
      mejorPrecio = productos.map((p) => p.producto.precio).reduce((a, b) => a < b ? a : b);
      terminoBusqueda = productos.first.producto.nombre;
    }
    
    return ResultadoComparacionModel(
      terminoBusqueda: terminoBusqueda.isNotEmpty ? terminoBusqueda : 'QR: $codigoQR',
      productos: productos,
      mejorPrecio: mejorPrecio,
      fechaComparacion: DateTime.now(),
    );
  }
  
  @override
  Future<List<Map<String, dynamic>>> obtenerProductosSimilares(String nombre) async {
    return await localDataSource.obtenerProductosSimilares(nombre);
  }
}