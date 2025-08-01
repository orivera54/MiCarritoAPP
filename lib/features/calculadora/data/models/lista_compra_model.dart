import '../../domain/entities/lista_compra.dart';
import '../../domain/entities/item_calculadora.dart';

class ListaCompraModel extends ListaCompra {
  const ListaCompraModel({
    super.id,
    super.nombre,
    required super.items,
    required super.total,
    required super.fechaCreacion,
  });

  factory ListaCompraModel.fromJson(Map<String, dynamic> json) {
    return ListaCompraModel(
      id: json['id'] as int?,
      nombre: json['nombre'] as String?,
      items: const [], // Items will be loaded separately
      total: (json['total'] as num).toDouble(),
      fechaCreacion: DateTime.parse(json['fecha_creacion'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'total': total,
      'fecha_creacion': fechaCreacion.toIso8601String(),
    };
  }

  factory ListaCompraModel.fromEntity(ListaCompra listaCompra) {
    return ListaCompraModel(
      id: listaCompra.id,
      nombre: listaCompra.nombre,
      items: listaCompra.items,
      total: listaCompra.total,
      fechaCreacion: listaCompra.fechaCreacion,
    );
  }

  ListaCompraModel copyWithItems(List<ItemCalculadora> items) {
    return ListaCompraModel(
      id: id,
      nombre: nombre,
      items: items,
      total: items.fold(0.0, (sum, item) => sum + item.subtotal),
      fechaCreacion: fechaCreacion,
    );
  }

  /// Validates the lista compra data
  String? validate() {
    if (nombre != null && nombre!.trim().isEmpty) {
      return 'El nombre de la lista no puede estar vacío si se proporciona';
    }
    if (nombre != null && nombre!.length > 100) {
      return 'El nombre de la lista no puede exceder 100 caracteres';
    }
    if (total < 0) {
      return 'El total no puede ser negativo';
    }
    // Allow empty lists for new listas - items can be added later
    return null;
  }
}