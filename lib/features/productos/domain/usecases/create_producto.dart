import '../entities/producto.dart';
import '../repositories/producto_repository.dart';

class CreateProducto {
  final ProductoRepository repository;

  CreateProducto(this.repository);

  Future<Producto> call(Producto producto) async {
    return await repository.createProducto(producto);
  }
}