import '../entities/producto.dart';
import '../repositories/producto_repository.dart';

class SearchProductosWithFilters {
  final ProductoRepository repository;

  SearchProductosWithFilters(this.repository);

  Future<List<Producto>> call({
    String? searchTerm,
    int? almacenId,
    int? categoriaId,
    double? minPrice,
    double? maxPrice,
  }) async {
    return await repository.searchProductosWithFilters(
      searchTerm: searchTerm?.trim().isEmpty == true ? null : searchTerm?.trim(),
      almacenId: almacenId,
      categoriaId: categoriaId,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }
}