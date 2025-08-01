import '../entities/producto.dart';
import '../repositories/producto_repository.dart';

class GetProductosByAlmacen {
  final ProductoRepository repository;

  GetProductosByAlmacen(this.repository);

  Future<List<Producto>> call(int almacenId) async {
    return await repository.getProductosByAlmacen(almacenId);
  }
}