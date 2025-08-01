import 'lib/features/productos/domain/entities/almacen_precio.dart';

void main() {
  // Probar la entidad AlmacenPrecio
  const almacenPrecio = AlmacenPrecio(
    almacenId: 1,
    almacenNombre: 'Test Store',
    almacenDireccion: 'Test Address',
    precio: 10.50,
    isSelected: true,
  );

  print('Original: ${almacenPrecio.almacenNombre}, Precio: ${almacenPrecio.precio}');

  // Probar copyWith
  final updated = almacenPrecio.copyWith(precio: 15.75);
  print('Updated: ${updated.almacenNombre}, Precio: ${updated.precio}');

  // Probar copyWith con null
  final nullPrice = almacenPrecio.copyWith(precio: null);
  print('Null price: ${nullPrice.almacenNombre}, Precio: ${nullPrice.precio}');

  print('Test completado exitosamente!');
}