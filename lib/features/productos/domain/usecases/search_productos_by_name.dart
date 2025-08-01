import '../entities/producto.dart';
import '../repositories/producto_repository.dart';

class SearchProductosByName {
  final ProductoRepository repository;

  SearchProductosByName(this.repository);

  Future<List<Producto>> call(String searchTerm) async {
    if (searchTerm.trim().isEmpty) {
      return [];
    }
    return await repository.searchProductosByName(searchTerm.trim());
  }
}