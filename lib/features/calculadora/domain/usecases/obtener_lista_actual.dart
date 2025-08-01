import '../entities/lista_compra.dart';
import '../repositories/calculadora_repository.dart';

class ObtenerListaActual {
  final CalculadoraRepository _repository;
  
  ObtenerListaActual(this._repository);
  
  Future<ListaCompra> call() async {
    // Get current active lista or create empty one
    ListaCompra? currentLista = await _repository.getCurrentActiveLista();
    
    if (currentLista == null) {
      currentLista = ListaCompra(
        nombre: null,
        items: const [],
        total: 0.0,
        fechaCreacion: DateTime.now(),
      );
      
      // Save the new empty lista as current
      await _repository.saveCurrentActiveLista(currentLista);
    }
    
    return currentLista;
  }
}