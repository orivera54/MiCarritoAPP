import '../entities/producto.dart';
import '../repositories/producto_repository.dart';

class UpdateProducto {
  final ProductoRepository repository;

  UpdateProducto(this.repository);

  Future<Producto> call(Producto producto) async {
    return await repository.updateProducto(producto);
  }
}