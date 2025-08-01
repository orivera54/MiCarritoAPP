import '../entities/lista_compra.dart';
import '../repositories/calculadora_repository.dart';

class GuardarListaCompra {
  final CalculadoraRepository _repository;
  
  GuardarListaCompra(this._repository);
  
  Future<ListaCompra> call({
    String? nombre,
  }) async {
    // Get current active lista
    ListaCompra? currentLista = await _repository.getCurrentActiveLista();
    
    if (currentLista == null || currentLista.items.isEmpty) {
      throw StateError('No hay lista activa o la lista está vacía');
    }
    
    // Create a new lista with name for permanent storage
    final listaToSave = currentLista.copyWith(
      nombre: nombre ?? 'Lista ${DateTime.now().toString().substring(0, 16)}',
    );
    
    // Save to database
    final savedLista = await _repository.createListaCompra(listaToSave);
    
    // Clear current active lista after saving
    await _repository.clearCurrentActiveLista();
    
    return savedLista;
  }
}