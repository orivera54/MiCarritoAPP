import 'package:equatable/equatable.dart';
import 'producto_comparacion.dart';

class ResultadoComparacion extends Equatable {
  final String terminoBusqueda;
  final List<ProductoComparacion> productos;
  final double? mejorPrecio;
  final DateTime fechaComparacion;

  const ResultadoComparacion({
    required this.terminoBusqueda,
    required this.productos,
    this.mejorPrecio,
    required this.fechaComparacion,
  });

  @override
  List<Object?> get props => [terminoBusqueda, productos, mejorPrecio, fechaComparacion];

  bool get tieneResultados => productos.isNotEmpty;

  int get cantidadAlmacenes => productos.map((p) => p.almacen.id).toSet().length;

  ProductoComparacion? get productoMejorPrecio {
    if (productos.isEmpty) return null;
    return productos.firstWhere((p) => p.esMejorPrecio);
  }

  ResultadoComparacion copyWith({
    String? terminoBusqueda,
    List<ProductoComparacion>? productos,
    double? mejorPrecio,
    DateTime? fechaComparacion,
  }) {
    return ResultadoComparacion(
      terminoBusqueda: terminoBusqueda ?? this.terminoBusqueda,
      productos: productos ?? this.productos,
      mejorPrecio: mejorPrecio ?? this.mejorPrecio,
      fechaComparacion: fechaComparacion ?? this.fechaComparacion,
    );
  }
}