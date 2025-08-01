import 'package:equatable/equatable.dart';

class Categoria extends Equatable {
  final int? id;
  final String nombre;
  final String? descripcion;
  final DateTime fechaCreacion;

  const Categoria({
    this.id,
    required this.nombre,
    this.descripcion,
    required this.fechaCreacion,
  });

  @override
  List<Object?> get props => [
        id,
        nombre,
        descripcion,
        fechaCreacion,
      ];

  Categoria copyWith({
    int? id,
    String? nombre,
    String? descripcion,
    DateTime? fechaCreacion,
  }) {
    return Categoria(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }
}