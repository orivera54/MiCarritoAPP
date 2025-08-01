import 'package:equatable/equatable.dart';

class AlmacenPrecio extends Equatable {
  final int almacenId;
  final String almacenNombre;
  final String? almacenDireccion;
  final double? precio;
  final bool isSelected;

  const AlmacenPrecio({
    required this.almacenId,
    required this.almacenNombre,
    this.almacenDireccion,
    this.precio,
    this.isSelected = false,
  });

  @override
  List<Object?> get props => [
        almacenId,
        almacenNombre,
        almacenDireccion,
        precio,
        isSelected,
      ];

  AlmacenPrecio copyWith({
    int? almacenId,
    String? almacenNombre,
    String? almacenDireccion,
    double? precio,
    bool? isSelected,
    bool clearPrecio = false,
  }) {
    return AlmacenPrecio(
      almacenId: almacenId ?? this.almacenId,
      almacenNombre: almacenNombre ?? this.almacenNombre,
      almacenDireccion: almacenDireccion ?? this.almacenDireccion,
      precio: clearPrecio ? null : (precio ?? this.precio),
      isSelected: isSelected ?? this.isSelected,
    );
  }

  bool get hasValidPrice => precio != null && precio! > 0;
}