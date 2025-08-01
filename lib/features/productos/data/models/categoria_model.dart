import '../../domain/entities/categoria.dart';

class CategoriaModel extends Categoria {
  const CategoriaModel({
    super.id,
    required super.nombre,
    super.descripcion,
    required super.fechaCreacion,
  });

  factory CategoriaModel.fromJson(Map<String, dynamic> json) {
    return CategoriaModel(
      id: json['id'] as int?,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String?,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'descripcion': descripcion,
      'fecha_creacion': fechaCreacion.toIso8601String(),
    };
  }

  factory CategoriaModel.fromEntity(Categoria categoria) {
    return CategoriaModel(
      id: categoria.id,
      nombre: categoria.nombre,
      descripcion: categoria.descripcion,
      fechaCreacion: categoria.fechaCreacion,
    );
  }

  /// Validates the categoria data
  String? validate() {
    if (nombre.trim().isEmpty) {
      return 'El nombre de la categoría es obligatorio';
    }
    if (nombre.trim().length < 2) {
      return 'El nombre de la categoría debe tener al menos 2 caracteres';
    }
    if (nombre.trim().length > 50) {
      return 'El nombre de la categoría no puede exceder 50 caracteres';
    }
    if (descripcion != null && descripcion!.length > 200) {
      return 'La descripción no puede exceder 200 caracteres';
    }
    return null;
  }
}