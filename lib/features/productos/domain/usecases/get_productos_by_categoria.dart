import '../entities/producto.dart';
import '../repositories/producto_repository.dart';

class GetProductosByCategoria {
  final ProductoRepository repository;

  GetProductosByCategoria(this.repository);

  Future<List<Producto>> call(int categoriaId) async {
    return await repository.getProductosByCategoria(categoriaId);
  }
}