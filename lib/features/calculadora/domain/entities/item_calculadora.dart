import 'package:equatable/equatable.dart';
import '../../../productos/domain/entities/producto.dart';
import '../services/mejor_precio_service.dart';

class ItemCalculadora extends Equatable {
  final int? id;
  final int productoId;
  final Producto? producto;
  final int cantidad;
  final double subtotal;
  final MejorPrecioInfo? mejorPrecio; // Información del mejor precio disponible

  const ItemCalculadora({
    this.id,
    required this.productoId,
    this.producto,
    required this.cantidad,
    required this.subtotal,
    this.mejorPrecio,
  });

  @override
  List<Object?> get props => [
        id,
        productoId,
        producto,
        cantidad,
        subtotal,
        mejorPrecio,
      ];

  ItemCalculadora copyWith({
    int? id,
    int? productoId,
    Producto? producto,
    int? cantidad,
    double? subtotal,
    MejorPrecioInfo? mejorPrecio,
  }) {
    return ItemCalculadora(
      id: id ?? this.id,
      productoId: productoId ?? this.productoId,
      producto: producto ?? this.producto,
      cantidad: cantidad ?? this.cantidad,
      subtotal: subtotal ?? this.subtotal,
      mejorPrecio: mejorPrecio ?? this.mejorPrecio,
    );
  }

  /// Calculate subtotal from producto price and cantidad
  double calculateSubtotal() {
    if (producto != null) {
      return producto!.precio * cantidad;
    }
    return subtotal;
  }
}