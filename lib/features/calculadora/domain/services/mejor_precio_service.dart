import '../../../productos/domain/entities/producto.dart';
import '../../../productos/domain/repositories/producto_repository.dart';
import '../../../almacenes/domain/entities/almacen.dart';
import '../../../almacenes/domain/repositories/almacen_repository.dart';

class MejorPrecioInfo {
  final Producto producto;
  final Almacen almacen;
  final double precio;

  const MejorPrecioInfo({
    required this.producto,
    required this.almacen,
    required this.precio,
  });
}

class MejorPrecioService {
  final ProductoRepository _productoRepository;
  final AlmacenRepository _almacenRepository;

  MejorPrecioService({
    required ProductoRepository productoRepository,
    required AlmacenRepository almacenRepository,
  })  : _productoRepository = productoRepository,
        _almacenRepository = almacenRepository;

  /// Encuentra el mejor precio para un producto específico por nombre
  Future<MejorPrecioInfo?> obtenerMejorPrecio(String nombreProducto) async {
    try {
      // Buscar todos los productos con nombre similar
      final productos = await _productoRepository.searchProductosByName(nombreProducto);
      
      if (productos.isEmpty) {
        return null;
      }

      // Encontrar el producto con el precio más bajo
      Producto? mejorProducto;
      double mejorPrecio = double.infinity;

      for (final producto in productos) {
        if (producto.precio < mejorPrecio) {
          mejorPrecio = producto.precio;
          mejorProducto = producto;
        }
      }

      if (mejorProducto == null) {
        return null;
      }

      // Obtener información del almacén
      final almacenes = await _almacenRepository.getAllAlmacenes();
      final almacen = almacenes.firstWhere(
        (a) => a.id == mejorProducto!.almacenId,
        orElse: () => Almacen(
          nombre: 'Desconocido',
          fechaCreacion: DateTime.now(),
          fechaActualizacion: DateTime.now(),
        ),
      );

      return MejorPrecioInfo(
        producto: mejorProducto,
        almacen: almacen,
        precio: mejorPrecio,
      );
    } catch (e) {
      return null;
    }
  }
}