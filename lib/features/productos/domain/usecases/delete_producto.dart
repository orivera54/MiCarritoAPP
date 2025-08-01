import '../repositories/producto_repository.dart';

class DeleteProducto {
  final ProductoRepository repository;

  DeleteProducto(this.repository);

  Future<void> call(int id) async {
    await repository.deleteProducto(id);
  }
}