import '../entities/item_calculadora.dart';
import '../entities/lista_compra.dart';
import '../repositories/calculadora_repository.dart';

class ModificarCantidadItem {
  final CalculadoraRepository _repository;
  
  ModificarCantidadItem(this._repository);
  
  Future<ListaCompra> call({
    required int productoId,
    required int nuevaCantidad,
  }) async {
    if (nuevaCantidad < 0) {
      throw ArgumentError('La cantidad no puede ser negativa');
    }
    
    // Get current active lista
    ListaCompra? currentLista = await _repository.getCurrentActiveLista();
    
    if (currentLista == null) {
      throw StateError('No hay lista activa para modificar');
    }
    
    // Find the item to modify
    final itemIndex = currentLista.items.indexWhere(
      (item) => item.productoId == productoId,
    );
    
    if (itemIndex == -1) {
      throw ArgumentError('Producto no encontrado en la lista');
    }
    
    List<ItemCalculadora> updatedItems = List.from(currentLista.items);
    
    if (nuevaCantidad == 0) {
      // Remove item if quantity is 0
      updatedItems.removeAt(itemIndex);
    } else {
      // Update item quantity and subtotal
      final item = updatedItems[itemIndex];
      final newSubtotal = item.producto!.precio * nuevaCantidad;
      
      updatedItems[itemIndex] = item.copyWith(
        cantidad: nuevaCantidad,
        subtotal: newSubtotal,
      );
    }
    
    // Calculate new total
    final newTotal = updatedItems.fold(0.0, (sum, item) => sum + item.subtotal);
    
    final updatedLista = currentLista.copyWith(
      items: updatedItems,
      total: newTotal,
    );
    
    // Save updated lista
    return await _repository.saveCurrentActiveLista(updatedLista);
  }
}