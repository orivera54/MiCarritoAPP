import 'package:equatable/equatable.dart';
import '../../../productos/domain/entities/producto.dart';

class ProductoComparacionAlmacen extends Equatable {
  final int almacenId;
  final String almacenNombre;
  final double precio;
  final bool esMejorPrecio;
  final Producto producto;

  const ProductoComparacionAlmacen({
    required this.almacenId,
    required this.almacenNombre,
    required this.precio,
    required this.esMejorPrecio,
    required this.producto,
  });

  ProductoComparacionAlmacen copyWith({
    int? almacenId,
    String? almacenNombre,
    double? precio,
    bool? esMejorPrecio,
    Producto? producto,
  }) {
    return ProductoComparacionAlmacen(
      almacenId: almacenId ?? this.almacenId,
      almacenNombre: almacenNombre ?? this.almacenNombre,
      precio: precio ?? this.precio,
      esMejorPrecio: esMejorPrecio ?? this.esMejorPrecio,
      producto: producto ?? this.producto,
    );
  }

  @override
  List<Object?> get props => [
        almacenId,
        almacenNombre,
        precio,
        esMejorPrecio,
        producto,
      ];

  @override
  String toString() {
    return 'ProductoComparacionAlmacen('
        'almacenId: $almacenId, '
        'almacenNombre: $almacenNombre, '
        'precio: $precio, '
        'esMejorPrecio: $esMejorPrecio, '
        'producto: $producto)';
  }
}