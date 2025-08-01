import '../entities/producto.dart';
import '../repositories/producto_repository.dart';

class GetProductoByQR {
  final ProductoRepository repository;

  GetProductoByQR(this.repository);

  Future<Producto?> call(String codigoQR) async {
    if (codigoQR.trim().isEmpty) {
      return null;
    }
    return await repository.getProductoByQR(codigoQR.trim());
  }
}