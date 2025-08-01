import '../../domain/entities/resultado_comparacion.dart';
import 'producto_comparacion_model.dart';

class ResultadoComparacionModel extends ResultadoComparacion {
  const ResultadoComparacionModel({
    required super.terminoBusqueda,
    required super.productos,
    super.mejorPrecio,
    required super.fechaComparacion,
  });

  factory ResultadoComparacionModel.fromJson(Map<String, dynamic> json) {
    final productosJson = json['productos'] as List<dynamic>;
    final productos = productosJson
        .map((p) => ProductoComparacionModel.fromJson(p as Map<String, dynamic>))
        .toList();

    return ResultadoComparacionModel(
      terminoBusqueda: json['termino_busqueda'] as String,
      productos: productos,
      mejorPrecio: json['mejor_precio'] != null 
          ? (json['mejor_precio'] as num).toDouble() 
          : null,
      fechaComparacion: DateTime.parse(json['fecha_comparacion'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'termino_busqueda': terminoBusqueda,
      'productos': productos
          .map((p) => ProductoComparacionModel.fromEntity(p).toJson())
          .toList(),
      'mejor_precio': mejorPrecio,
      'fecha_comparacion': fechaComparacion.toIso8601String(),
    };
  }

  factory ResultadoComparacionModel.fromEntity(ResultadoComparacion entity) {
    return ResultadoComparacionModel(
      terminoBusqueda: entity.terminoBusqueda,
      productos: entity.productos,
      mejorPrecio: entity.mejorPrecio,
      fechaComparacion: entity.fechaComparacion,
    );
  }
}