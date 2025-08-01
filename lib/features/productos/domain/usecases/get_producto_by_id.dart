import '../entities/producto.dart';
import '../repositories/producto_repository.dart';

class GetProductoById {
  final ProductoRepository repository;

  GetProductoById(this.repository);

  Future<Producto?> call(int id) async {
    return await repository.getProductoById(id);
  }
}