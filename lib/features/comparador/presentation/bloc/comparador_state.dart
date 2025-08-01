import 'package:equatable/equatable.dart';
import '../../domain/entities/resultado_comparacion.dart';
import '../../domain/entities/producto_comparacion.dart';
import '../../domain/entities/producto_comparacion_almacen.dart';

abstract class ComparadorState extends Equatable {
  const ComparadorState();

  @override
  List<Object?> get props => [];
}

class ComparadorInitial extends ComparadorState {
  const ComparadorInitial();
}

class ComparadorLoading extends ComparadorState {
  const ComparadorLoading();
}

class ComparadorLoaded extends ComparadorState {
  final ResultadoComparacion resultado;

  const ComparadorLoaded(this.resultado);

  @override
  List<Object?> get props => [resultado];

  bool get tieneResultados => resultado.tieneResultados;
  
  List<ProductoComparacion> get productos => resultado.productos;
  
  ProductoComparacion? get mejorPrecio => resultado.productoMejorPrecio;
  
  int get cantidadAlmacenes => resultado.cantidadAlmacenes;
  
  String get terminoBusqueda => resultado.terminoBusqueda;
}

class ComparadorError extends ComparadorState {
  final String message;

  const ComparadorError(this.message);

  @override
  List<Object?> get props => [message];
}

class ComparadorEmpty extends ComparadorState {
  final String terminoBusqueda;

  const ComparadorEmpty(this.terminoBusqueda);

  @override
  List<Object?> get props => [terminoBusqueda];
}

class ComparadorAlmacenesLoading extends ComparadorState {
  final String nombreProducto;

  const ComparadorAlmacenesLoading(this.nombreProducto);

  @override
  List<Object?> get props => [nombreProducto];
}

class ComparadorAlmacenesLoaded extends ComparadorState {
  final List<ProductoComparacionAlmacen> almacenes;
  final String nombreProducto;

  const ComparadorAlmacenesLoaded({
    required this.almacenes,
    required this.nombreProducto,
  });

  @override
  List<Object?> get props => [almacenes, nombreProducto];

  bool get tieneAlmacenes => almacenes.isNotEmpty;
  
  int get cantidadAlmacenes => almacenes.length;
  
  List<ProductoComparacionAlmacen> get almacenesMejorPrecio => 
      almacenes.where((a) => a.esMejorPrecio).toList();
  
  double? get precioMinimo => almacenes.isNotEmpty 
      ? almacenes.map((a) => a.precio).reduce((a, b) => a < b ? a : b)
      : null;
}

class ComparadorAlmacenesError extends ComparadorState {
  final String message;
  final String nombreProducto;

  const ComparadorAlmacenesError({
    required this.message,
    required this.nombreProducto,
  });

  @override
  List<Object?> get props => [message, nombreProducto];
}