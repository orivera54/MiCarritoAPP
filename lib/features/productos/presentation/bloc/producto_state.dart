import 'package:equatable/equatable.dart';
import '../../domain/entities/producto.dart';

abstract class ProductoState extends Equatable {
  const ProductoState();

  @override
  List<Object?> get props => [];
}

class ProductoInitial extends ProductoState {}

class ProductoLoading extends ProductoState {}

class ProductoLoaded extends ProductoState {
  final List<Producto> productos;

  const ProductoLoaded(this.productos);

  @override
  List<Object> get props => [productos];
}

class ProductoSelected extends ProductoState {
  final Producto producto;

  const ProductoSelected(this.producto);

  @override
  List<Object> get props => [producto];
}

class ProductoSearchResults extends ProductoState {
  final List<Producto> productos;
  final String searchTerm;

  const ProductoSearchResults(this.productos, this.searchTerm);

  @override
  List<Object> get props => [productos, searchTerm];
}

class ProductoQRResult extends ProductoState {
  final Producto? producto;
  final String codigoQR;

  const ProductoQRResult(this.producto, this.codigoQR);

  @override
  List<Object?> get props => [producto, codigoQR];
}

class ProductoFilteredResults extends ProductoState {
  final List<Producto> productos;
  final String? searchTerm;
  final int? almacenId;
  final int? categoriaId;
  final double? minPrice;
  final double? maxPrice;

  const ProductoFilteredResults(
    this.productos, {
    this.searchTerm,
    this.almacenId,
    this.categoriaId,
    this.minPrice,
    this.maxPrice,
  });

  @override
  List<Object?> get props => [productos, searchTerm, almacenId, categoriaId, minPrice, maxPrice];
}

class ProductoCreated extends ProductoState {
  final Producto producto;

  const ProductoCreated(this.producto);

  @override
  List<Object> get props => [producto];
}

class ProductoUpdated extends ProductoState {
  final Producto producto;

  const ProductoUpdated(this.producto);

  @override
  List<Object> get props => [producto];
}

class ProductoDeleted extends ProductoState {
  final int deletedId;

  const ProductoDeleted(this.deletedId);

  @override
  List<Object> get props => [deletedId];
}

class ProductoError extends ProductoState {
  final String message;

  const ProductoError(this.message);

  @override
  List<Object> get props => [message];
}