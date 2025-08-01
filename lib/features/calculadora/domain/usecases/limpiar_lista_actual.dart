import '../entities/lista_compra.dart';
import '../repositories/calculadora_repository.dart';

class LimpiarListaActual {
  final CalculadoraRepository _repository;
  
  LimpiarListaActual(this._repository);
  
  Future<ListaCompra> call() async {
    // Clear current active lista
    await _repository.clearCurrentActiveLista();
    
    // Create new empty lista
    final newLista = ListaCompra(
      nombre: null,
      items: const [],
      total: 0.0,
      fechaCreacion: DateTime.now(),
    );
    
    // Save as current active lista
    return await _repository.saveCurrentActiveLista(newLista);
  }
}