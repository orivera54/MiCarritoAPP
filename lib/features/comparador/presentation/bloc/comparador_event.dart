import 'package:equatable/equatable.dart';

abstract class ComparadorEvent extends Equatable {
  const ComparadorEvent();

  @override
  List<Object?> get props => [];
}

class BuscarProductosSimilaresEvent extends ComparadorEvent {
  final String terminoBusqueda;

  const BuscarProductosSimilaresEvent(this.terminoBusqueda);

  @override
  List<Object?> get props => [terminoBusqueda];
}

class CompararPreciosProductoEvent extends ComparadorEvent {
  final int productoId;

  const CompararPreciosProductoEvent(this.productoId);

  @override
  List<Object?> get props => [productoId];
}

class BuscarProductosPorQREvent extends ComparadorEvent {
  final String codigoQR;

  const BuscarProductosPorQREvent(this.codigoQR);

  @override
  List<Object?> get props => [codigoQR];
}

class LimpiarResultadosEvent extends ComparadorEvent {
  const LimpiarResultadosEvent();
}

class ObtenerAlmacenesProductoEvent extends ComparadorEvent {
  final String nombreProducto;

  const ObtenerAlmacenesProductoEvent(this.nombreProducto);

  @override
  List<Object?> get props => [nombreProducto];
}