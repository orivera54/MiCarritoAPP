import '../../domain/entities/producto_comparacion.dart';
import '../../../productos/data/models/producto_model.dart';
import '../../../almacenes/data/models/almacen_model.dart';

class ProductoComparacionModel extends ProductoComparacion {
  const ProductoComparacionModel({
    required super.producto,
    required super.almacen,
    required super.esMejorPrecio,
  });

  factory ProductoComparacionModel.fromJson(Map<String, dynamic> json) {
    return ProductoComparacionModel(
      producto: ProductoModel.fromJson({
        'id': json['producto_id'],
        'nombre': json['producto_nombre'],
        'precio': json['producto_precio'],
        'peso': json['producto_peso'],
        'tamano': json['producto_tamano'],
        'codigo_qr': json['producto_codigo_qr'],
        'categoria_id': json['categoria_id'],
        'almacen_id': json['almacen_id'],
        'fecha_creacion': json['producto_fecha_creacion'],
        'fecha_actualizacion': json['producto_fecha_actualizacion'],
      }),
      almacen: AlmacenModel.fromJson({
        'id': json['almacen_id'],
        'nombre': json['almacen_nombre'],
        'direccion': json['almacen_direccion'],
        'descripcion': json['almacen_descripcion'],
        'fecha_creacion': json['almacen_fecha_creacion'],
        'fecha_actualizacion': json['almacen_fecha_actualizacion'],
      }),
      esMejorPrecio: json['es_mejor_precio'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'producto_id': producto.id,
      'producto_nombre': producto.nombre,
      'producto_precio': producto.precio,
      'producto_peso': producto.peso,
      'producto_tamano': producto.tamano,
      'producto_codigo_qr': producto.codigoQR,
      'categoria_id': producto.categoriaId,
      'almacen_id': almacen.id,
      'almacen_nombre': almacen.nombre,
      'almacen_direccion': almacen.direccion,
      'almacen_descripcion': almacen.descripcion,
      'producto_fecha_creacion': producto.fechaCreacion.toIso8601String(),
      'producto_fecha_actualizacion': producto.fechaActualizacion.toIso8601String(),
      'almacen_fecha_creacion': almacen.fechaCreacion.toIso8601String(),
      'almacen_fecha_actualizacion': almacen.fechaActualizacion.toIso8601String(),
      'es_mejor_precio': esMejorPrecio ? 1 : 0,
    };
  }

  factory ProductoComparacionModel.fromEntity(ProductoComparacion entity) {
    return ProductoComparacionModel(
      producto: entity.producto,
      almacen: entity.almacen,
      esMejorPrecio: entity.esMejorPrecio,
    );
  }
}