import '../../domain/entities/item_calculadora.dart';
import '../../../productos/domain/entities/producto.dart';

class ItemCalculadoraModel extends ItemCalculadora {
  const ItemCalculadoraModel({
    super.id,
    required super.productoId,
    super.producto,
    required super.cantidad,
    required super.subtotal,
  });

  factory ItemCalculadoraModel.fromJson(Map<String, dynamic> json) {
    return ItemCalculadoraModel(
      id: json['id'] as int?,
      productoId: json['producto_id'] as int,
      cantidad: json['cantidad'] as int,
      subtotal: (json['subtotal'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'producto_id': productoId,
      'cantidad': cantidad,
      'subtotal': subtotal,
    };
  }

  factory ItemCalculadoraModel.fromEntity(ItemCalculadora item) {
    return ItemCalculadoraModel(
      id: item.id,
      productoId: item.productoId,
      producto: item.producto,
      cantidad: item.cantidad,
      subtotal: item.subtotal,
    );
  }

  ItemCalculadoraModel copyWithProducto(Producto producto) {
    return ItemCalculadoraModel(
      id: id,
      productoId: productoId,
      producto: producto,
      cantidad: cantidad,
      subtotal: subtotal,
    );
  }

  /// Validates the item calculadora data
  String? validate() {
    if (cantidad <= 0) {
      return 'La cantidad debe ser mayor a 0';
    }
    if (cantidad > 9999) {
      return 'La cantidad no puede exceder 9,999';
    }
    if (subtotal < 0) {
      return 'El subtotal no puede ser negativo';
    }
    if (subtotal > 9999999.99) {
      return 'El subtotal no puede exceder 9,999,999.99';
    }
    return null;
  }
}