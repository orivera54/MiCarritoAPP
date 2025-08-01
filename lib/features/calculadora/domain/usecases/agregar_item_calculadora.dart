import '../entities/item_calculadora.dart';
import '../entities/lista_compra.dart';
import '../repositories/calculadora_repository.dart';
import '../services/mejor_precio_service.dart';
import '../../../productos/domain/entities/producto.dart';

class AgregarItemCalculadora {
  final CalculadoraRepository _repository;
  
  AgregarItemCalculadora(this._repository);
  
  Future<ListaCompra> call({
    required Producto producto,
    int cantidad = 1,
    MejorPrecioInfo? mejorPrecio,
    int? almacenId,
  }) async {
    // Get current active lista or create new one
    ListaCompra? currentLista;
    
    if (almacenId != null) {
      currentLista = await _repository.getCurrentActiveListaForAlmacen(almacenId);
    } else {
      currentLista = await _repository.getCurrentActiveLista();
    }
    
    currentLista ??= ListaCompra(
        nombre: null,
        items: const [],
        total: 0.0,
        fechaCreacion: DateTime.now(),
      );
    
    // Check if product already exists in the lista
    final existingItemIndex = currentLista.items.indexWhere(
      (item) => item.productoId == producto.id,
    );
    
    List<ItemCalculadora> updatedItems = List.from(currentLista.items);
    
    if (existingItemIndex != -1) {
      // Update existing item quantity
      final existingItem = updatedItems[existingItemIndex];
      final newCantidad = existingItem.cantidad + cantidad;
      final newSubtotal = producto.precio * newCantidad;
      
      updatedItems[existingItemIndex] = existingItem.copyWith(
        cantidad: newCantidad,
        subtotal: newSubtotal,
        mejorPrecio: mejorPrecio,
      );
    } else {
      // Add new item
      final newItem = ItemCalculadora(
        productoId: producto.id!,
        producto: producto,
        cantidad: cantidad,
        subtotal: producto.precio * cantidad,
        mejorPrecio: mejorPrecio,
      );
      updatedItems.add(newItem);
    }
    
    // Calculate new total
    final newTotal = updatedItems.fold(0.0, (sum, item) => sum + item.subtotal);
    
    final updatedLista = currentLista.copyWith(
      items: updatedItems,
      total: newTotal,
    );
    
    // Save updated lista
    if (almacenId != null) {
      return await _repository.saveCurrentActiveListaForAlmacen(updatedLista, almacenId);
    } else {
      return await _repository.saveCurrentActiveLista(updatedLista);
    }
  }
}