import '../entities/lista_compra.dart';
import '../repositories/calculadora_repository.dart';

class EliminarItemCalculadora {
  final CalculadoraRepository _repository;

  EliminarItemCalculadora(this._repository);

  Future<ListaCompra> call({
    required int productoId,
  }) async {
    // Get current active lista
    ListaCompra? currentLista = await _repository.getCurrentActiveLista();

    if (currentLista == null) {
      throw StateError('No hay lista activa para modificar');
    }

    // Find and remove the item
    final updatedItems = currentLista.items
        .where((item) => item.productoId != productoId)
        .toList();

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
