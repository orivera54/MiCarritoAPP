import '../entities/producto.dart';
import '../repositories/producto_repository.dart';

class GetAllProductos {
  final ProductoRepository repository;

  GetAllProductos(this.repository);

  Future<List<Producto>> call() async {
    return await repository.getAllProductos();
  }
}