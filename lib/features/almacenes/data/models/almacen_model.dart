import '../../domain/entities/almacen.dart';

class AlmacenModel extends Almacen {
  const AlmacenModel({
    super.id,
    required super.nombre,
    super.direccion,
    super.descripcion,
    required super.fechaCreacion,
    required super.fechaActualizacion,
  });

  factory AlmacenModel.fromJson(Map<String, dynamic> json) {
    return AlmacenModel(
      id: json['id'] as int?,
      nombre: json['nombre'] as String,
      direccion: json['direccion'] as String?,
      descripcion: json['descripcion'] as String?,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
      fechaActualizacion: DateTime.parse(json['fecha_actualizacion'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'direccion': direccion,
      'descripcion': descripcion,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_actualizacion': fechaActualizacion.toIso8601String(),
    };
  }

  factory AlmacenModel.fromEntity(Almacen almacen) {
    return AlmacenModel(
      id: almacen.id,
      nombre: almacen.nombre,
      direccion: almacen.direccion,
      descripcion: almacen.descripcion,
      fechaCreacion: almacen.fechaCreacion,
      fechaActualizacion: almacen.fechaActualizacion,
    );
  }

  /// Validates the almacen data
  String? validate() {
    if (nombre.trim().isEmpty) {
      return 'El nombre del almacén es obligatorio';
    }
    if (nombre.trim().length < 2) {
      return 'El nombre del almacén debe tener al menos 2 caracteres';
    }
    if (nombre.trim().length > 100) {
      return 'El nombre del almacén no puede exceder 100 caracteres';
    }
    if (direccion != null && direccion!.length > 200) {
      return 'La dirección no puede exceder 200 caracteres';
    }
    if (descripcion != null && descripcion!.length > 500) {
      return 'La descripción no puede exceder 500 caracteres';
    }
    return null;
  }

  @override
  AlmacenModel copyWith({
    int? id,
    String? nombre,
    String? direccion,
    String? descripcion,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return AlmacenModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      direccion: direccion ?? this.direccion,
      descripcion: descripcion ?? this.descripcion,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }
}