import '../entities/resultado_comparacion.dart';

abstract class ComparadorRepository {
  /// Busca productos similares por nombre en todos los almacenes
  Future<ResultadoComparacion> buscarProductosSimilares(String terminoBusqueda);
  
  /// Compara precios de un producto específico entre almacenes
  Future<ResultadoComparacion> compararPreciosProducto(int productoId);
  
  /// Busca productos por código QR en todos los almacenes
  Future<ResultadoComparacion> buscarProductosPorQR(String codigoQR);
  
  /// Obtiene productos similares basado en algoritmo de matching
  Future<List<Map<String, dynamic>>> obtenerProductosSimilares(String nombre);
}