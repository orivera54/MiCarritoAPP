import 'package:equatable/equatable.dart';
import '../../domain/entities/producto.dart';

abstract class ProductoEvent extends Equatable {
  const ProductoEvent();

  @override
  List<Object?> get props => [];
}

class LoadAllProductos extends ProductoEvent {}

class LoadProductosByAlmacen extends ProductoEvent {
  final int almacenId;

  const LoadProductosByAlmacen(this.almacenId);

  @override
  List<Object> get props => [almacenId];
}

class LoadProductosByCategoria extends ProductoEvent {
  final int categoriaId;

  const LoadProductosByCategoria(this.categoriaId);

  @override
  List<Object> get props => [categoriaId];
}

class LoadProductoById extends ProductoEvent {
  final int id;

  const LoadProductoById(this.id);

  @override
  List<Object> get props => [id];
}

class SearchProductosByName extends ProductoEvent {
  final String searchTerm;

  const SearchProductosByName(this.searchTerm);

  @override
  List<Object> get props => [searchTerm];
}

class SearchProductoByQR extends ProductoEvent {
  final String codigoQR;

  const SearchProductoByQR(this.codigoQR);

  @override
  List<Object> get props => [codigoQR];
}

class SearchProductosWithFilters extends ProductoEvent {
  final String? searchTerm;
  final int? almacenId;
  final int? categoriaId;
  final double? minPrice;
  final double? maxPrice;

  const SearchProductosWithFilters({
    this.searchTerm,
    this.almacenId,
    this.categoriaId,
    this.minPrice,
    this.maxPrice,
  });

  @override
  List<Object?> get props => [searchTerm, almacenId, categoriaId, minPrice, maxPrice];
}

class CreateProducto extends ProductoEvent {
  final Producto producto;

  const CreateProducto(this.producto);

  @override
  List<Object> get props => [producto];
}

class UpdateProducto extends ProductoEvent {
  final Producto producto;

  const UpdateProducto(this.producto);

  @override
  List<Object> get props => [producto];
}

class DeleteProducto extends ProductoEvent {
  final int id;

  const DeleteProducto(this.id);

  @override
  List<Object> get props => [id];
}

class ClearProductoSelection extends ProductoEvent {}

class ClearProductoSearch extends ProductoEvent {}