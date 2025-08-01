import 'package:equatable/equatable.dart';
import '../../../productos/domain/entities/producto.dart';

abstract class CalculadoraEvent extends Equatable {
  const CalculadoraEvent();

  @override
  List<Object?> get props => [];
}

class CargarListaActual extends CalculadoraEvent {}

class AgregarProducto extends CalculadoraEvent {
  final Producto producto;
  final int cantidad;
  final int? almacenId;

  const AgregarProducto({
    required this.producto,
    this.cantidad = 1,
    this.almacenId,
  });

  @override
  List<Object?> get props => [producto, cantidad, almacenId];
}

class ModificarCantidad extends CalculadoraEvent {
  final int productoId;
  final int nuevaCantidad;

  const ModificarCantidad({
    required this.productoId,
    required this.nuevaCantidad,
  });

  @override
  List<Object?> get props => [productoId, nuevaCantidad];
}

class EliminarProducto extends CalculadoraEvent {
  final int productoId;

  const EliminarProducto({
    required this.productoId,
  });

  @override
  List<Object?> get props => [productoId];
}

class GuardarLista extends CalculadoraEvent {
  final String? nombre;

  const GuardarLista({
    this.nombre,
  });

  @override
  List<Object?> get props => [nombre];
}

class LimpiarLista extends CalculadoraEvent {}