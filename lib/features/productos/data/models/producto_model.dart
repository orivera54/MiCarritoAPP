import '../../domain/entities/producto.dart';
import '../../../../core/utils/volume_utils.dart';

class ProductoModel extends Producto {
  const ProductoModel({
    super.id,
    required super.nombre,
    required super.precio,
    super.peso,
    super.volumen,
    super.tamano,
    super.codigoQR,
    required super.categoriaId,
    required super.almacenId,
    required super.fechaCreacion,
    required super.fechaActualizacion,
  });

  factory ProductoModel.fromJson(Map<String, dynamic> json) {
    return ProductoModel(
      id: json['id'] as int?,
      nombre: json['nombre'] as String,
      precio: (json['precio'] as num).toDouble(),
      peso: json['peso'] != null ? (json['peso'] as num).toDouble() : null,
      volumen: json['volumen'] != null ? (json['volumen'] as num).toDouble() : null,
      tamano: json['tamano'] as String?,
      codigoQR: json['codigo_qr'] as String?,
      categoriaId: json['categoria_id'] as int,
      almacenId: json['almacen_id'] as int,
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
      fechaActualizacion: DateTime.parse(json['fecha_actualizacion'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'precio': precio,
      'peso': peso,
      'volumen': volumen,
      'tamano': tamano,
      'codigo_qr': codigoQR,
      'categoria_id': categoriaId,
      'almacen_id': almacenId,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'fecha_actualizacion': fechaActualizacion.toIso8601String(),
    };
  }

  factory ProductoModel.fromEntity(Producto producto) {
    return ProductoModel(
      id: producto.id,
      nombre: producto.nombre,
      precio: producto.precio,
      peso: producto.peso,
      volumen: producto.volumen,
      tamano: producto.tamano,
      codigoQR: producto.codigoQR,
      categoriaId: producto.categoriaId,
      almacenId: producto.almacenId,
      fechaCreacion: producto.fechaCreacion,
      fechaActualizacion: producto.fechaActualizacion,
    );
  }

  /// Validates the producto data
  String? validate() {
    if (nombre.trim().isEmpty) {
      return 'El nombre del producto es obligatorio';
    }
    if (nombre.trim().length < 2) {
      return 'El nombre del producto debe tener al menos 2 caracteres';
    }
    if (nombre.trim().length > 100) {
      return 'El nombre del producto no puede exceder 100 caracteres';
    }
    if (precio <= 0) {
      return 'El precio debe ser mayor a 0';
    }
    if (precio > 999999.99) {
      return 'El precio no puede exceder 999,999.99';
    }
    if (peso != null && peso! <= 0) {
      return 'El peso debe ser mayor a 0';
    }
    if (peso != null && peso! > 99999.99) {
      return 'El peso no puede exceder 99,999.99';
    }
    if (volumen != null && !VolumeUtils.isValidVolume(volumen)) {
      return 'El volumen debe estar entre 1ml y 1000L';
    }
    if (tamano != null && tamano!.length > 50) {
      return 'El tamano no puede exceder 50 caracteres';
    }
    if (codigoQR != null && codigoQR!.trim().isEmpty) {
      return 'El codigo QR no puede estar vacio si se proporciona';
    }
    if (codigoQR != null && codigoQR!.length > 100) {
      return 'El codigo QR no puede exceder 100 caracteres';
    }
    return null;
  }

  /// Crea una copia del modelo con campos actualizados
  @override
  ProductoModel copyWith({
    int? id,
    String? nombre,
    double? precio,
    double? peso,
    double? volumen,
    String? tamano,
    String? codigoQR,
    int? categoriaId,
    int? almacenId,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return ProductoModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      precio: precio ?? this.precio,
      peso: peso ?? this.peso,
      volumen: volumen ?? this.volumen,
      tamano: tamano ?? this.tamano,
      codigoQR: codigoQR ?? this.codigoQR,
      categoriaId: categoriaId ?? this.categoriaId,
      almacenId: almacenId ?? this.almacenId,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }

  /// Normaliza el nombre para comparaciones de unicidad
  String get nombreNormalizado => nombre.trim().toLowerCase();

  /// Obtiene la clave única para el producto (nombre + almacén)
  String get uniqueKey => '${nombreNormalizado}_$almacenId';
}