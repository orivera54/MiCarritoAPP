import 'dart:math' as math;
import '../entities/producto_comparacion.dart';
import '../entities/resultado_comparacion.dart';
import '../entities/producto_comparacion_almacen.dart';
import '../../../productos/domain/repositories/producto_repository.dart';
import '../../../almacenes/domain/repositories/almacen_repository.dart';

class ComparadorService {
  final ProductoRepository _productoRepository;
  final AlmacenRepository _almacenRepository;

  ComparadorService({
    required ProductoRepository productoRepository,
    required AlmacenRepository almacenRepository,
  })  : _productoRepository = productoRepository,
        _almacenRepository = almacenRepository;
  /// Identifica el mejor precio entre una lista de productos
  static ProductoComparacion? identificarMejorPrecio(List<ProductoComparacion> productos) {
    if (productos.isEmpty) return null;
    
    return productos.reduce((current, next) => 
        current.producto.precio < next.producto.precio ? current : next);
  }

  /// Calcula el precio mínimo de una lista de productos
  static double? calcularPrecioMinimo(List<ProductoComparacion> productos) {
    if (productos.isEmpty) return null;
    
    return productos.map((p) => p.producto.precio).reduce((a, b) => a < b ? a : b);
  }

  /// Calcula el precio máximo de una lista de productos
  static double? calcularPrecioMaximo(List<ProductoComparacion> productos) {
    if (productos.isEmpty) return null;
    
    return productos.map((p) => p.producto.precio).reduce((a, b) => a > b ? a : b);
  }

  /// Calcula el precio promedio de una lista de productos
  static double? calcularPrecioPromedio(List<ProductoComparacion> productos) {
    if (productos.isEmpty) return null;
    
    final suma = productos.map((p) => p.producto.precio).reduce((a, b) => a + b);
    return suma / productos.length;
  }

  /// Calcula el ahorro potencial comparado con el precio más alto
  static double calcularAhorroPotencial(List<ProductoComparacion> productos) {
    if (productos.length < 2) return 0.0;
    
    final precioMinimo = calcularPrecioMinimo(productos);
    final precioMaximo = calcularPrecioMaximo(productos);
    
    if (precioMinimo == null || precioMaximo == null) return 0.0;
    
    return precioMaximo - precioMinimo;
  }

  /// Calcula el porcentaje de ahorro comparado con el precio más alto
  static double calcularPorcentajeAhorro(List<ProductoComparacion> productos) {
    if (productos.length < 2) return 0.0;
    
    final precioMinimo = calcularPrecioMinimo(productos);
    final precioMaximo = calcularPrecioMaximo(productos);
    
    if (precioMinimo == null || precioMaximo == null || precioMaximo == 0) return 0.0;
    
    return ((precioMaximo - precioMinimo) / precioMaximo) * 100;
  }

  /// Ordena productos por precio (ascendente por defecto)
  static List<ProductoComparacion> ordenarPorPrecio(
    List<ProductoComparacion> productos, {
    bool ascendente = true,
  }) {
    final productosOrdenados = List<ProductoComparacion>.from(productos);
    
    productosOrdenados.sort((a, b) {
      final comparacion = a.producto.precio.compareTo(b.producto.precio);
      return ascendente ? comparacion : -comparacion;
    });
    
    return productosOrdenados;
  }

  /// Filtra productos por rango de precio
  static List<ProductoComparacion> filtrarPorRangoPrecio(
    List<ProductoComparacion> productos,
    double precioMinimo,
    double precioMaximo,
  ) {
    return productos.where((p) => 
        p.producto.precio >= precioMinimo && p.producto.precio <= precioMaximo
    ).toList();
  }

  /// Agrupa productos por almacén
  static Map<String, List<ProductoComparacion>> agruparPorAlmacen(
    List<ProductoComparacion> productos,
  ) {
    final Map<String, List<ProductoComparacion>> grupos = {};
    
    for (final producto in productos) {
      final nombreAlmacen = producto.almacen.nombre;
      grupos.putIfAbsent(nombreAlmacen, () => []).add(producto);
    }
    
    return grupos;
  }

  /// Enriquece el resultado de comparación con estadísticas adicionales
  static ResultadoComparacion enriquecerResultado(ResultadoComparacion resultado) {
    if (resultado.productos.isEmpty) return resultado;
    
    final mejorPrecio = calcularPrecioMinimo(resultado.productos);
    
    return resultado.copyWith(
      mejorPrecio: mejorPrecio,
    );
  }

  /// Obtiene todos los almacenes donde está disponible un producto específico
  /// ordenados por precio de menor a mayor, marcando los mejores precios
  Future<List<ProductoComparacionAlmacen>> obtenerAlmacenesProducto(String nombreProducto) async {
    try {
      // Buscar todos los productos con el nombre especificado
      final productos = await _productoRepository.searchProductosByName(nombreProducto);
      
      if (productos.isEmpty) {
        return [];
      }

      // Obtener todos los almacenes para el lookup
      final almacenes = await _almacenRepository.getAllAlmacenes();
      final almacenesMap = {for (var a in almacenes) a.id!: a};

      // Encontrar el precio mínimo
      final precioMinimo = productos.map((p) => p.precio).reduce(math.min);

      // Crear lista de comparación
      final List<ProductoComparacionAlmacen> resultado = productos.map((producto) {
        final almacen = almacenesMap[producto.almacenId];
        if (almacen == null) {
          throw Exception('Almacén no encontrado para producto ${producto.id}');
        }

        return ProductoComparacionAlmacen(
          almacenId: producto.almacenId,
          almacenNombre: almacen.nombre,
          precio: producto.precio,
          esMejorPrecio: producto.precio == precioMinimo,
          producto: producto,
        );
      }).toList();

      // Ordenar por precio de menor a mayor
      resultado.sort((a, b) => a.precio.compareTo(b.precio));

      return resultado;
    } catch (e) {
      throw Exception('Error al obtener almacenes del producto: $e');
    }
  }
}