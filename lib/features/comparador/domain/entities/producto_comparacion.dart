import 'package:equatable/equatable.dart';
import '../../../productos/domain/entities/producto.dart';
import '../../../almacenes/domain/entities/almacen.dart';

class ProductoComparacion extends Equatable {
  final Producto producto;
  final Almacen almacen;
  final bool esMejorPrecio;

  const ProductoComparacion({
    required this.producto,
    required this.almacen,
    required this.esMejorPrecio,
  });

  @override
  List<Object?> get props => [producto, almacen, esMejorPrecio];

  ProductoComparacion copyWith({
    Producto? producto,
    Almacen? almacen,
    bool? esMejorPrecio,
  }) {
    return ProductoComparacion(
      producto: producto ?? this.producto,
      almacen: almacen ?? this.almacen,
      esMejorPrecio: esMejorPrecio ?? this.esMejorPrecio,
    );
  }
}