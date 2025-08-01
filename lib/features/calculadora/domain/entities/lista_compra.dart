import 'package:equatable/equatable.dart';
import 'item_calculadora.dart';

class ListaCompra extends Equatable {
  final int? id;
  final String? nombre;
  final int? almacenId; // Nuevo campo para almacén específico
  final String? almacenNombre; // Nombre del almacén para mostrar
  final List<ItemCalculadora> items;
  final double total;
  final DateTime fechaCreacion;

  const ListaCompra({
    this.id,
    this.nombre,
    this.almacenId,
    this.almacenNombre,
    required this.items,
    required this.total,
    required this.fechaCreacion,
  });

  @override
  List<Object?> get props => [
        id,
        nombre,
        almacenId,
        almacenNombre,
        items,
        total,
        fechaCreacion,
      ];

  ListaCompra copyWith({
    int? id,
    String? nombre,
    int? almacenId,
    String? almacenNombre,
    List<ItemCalculadora>? items,
    double? total,
    DateTime? fechaCreacion,
  }) {
    return ListaCompra(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      almacenId: almacenId ?? this.almacenId,
      almacenNombre: almacenNombre ?? this.almacenNombre,
      items: items ?? this.items,
      total: total ?? this.total,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
    );
  }

  /// Calculate total from items
  double calculateTotal() {
    return items.fold(0.0, (sum, item) => sum + item.subtotal);
  }
}