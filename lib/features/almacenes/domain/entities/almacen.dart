import 'package:equatable/equatable.dart';

class Almacen extends Equatable {
  final int? id;
  final String nombre;
  final String? direccion;
  final String? descripcion;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;

  const Almacen({
    this.id,
    required this.nombre,
    this.direccion,
    this.descripcion,
    required this.fechaCreacion,
    required this.fechaActualizacion,
  });

  @override
  List<Object?> get props => [
        id,
        nombre,
        direccion,
        descripcion,
        fechaCreacion,
        fechaActualizacion,
      ];

  Almacen copyWith({
    int? id,
    String? nombre,
    String? direccion,
    String? descripcion,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return Almacen(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      descripcion: descripcion ?? this.descripcion,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }
}