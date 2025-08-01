import '../entities/resultado_comparacion.dart';
import '../repositories/comparador_repository.dart';

class BuscarProductosSimilares {
  final ComparadorRepository repository;

  BuscarProductosSimilares(this.repository);

  Future<ResultadoComparacion> call(String terminoBusqueda) async {
    if (terminoBusqueda.trim().isEmpty) {
      return ResultadoComparacion(
        terminoBusqueda: terminoBusqueda,
        productos: const [],
        fechaComparacion: DateTime.now(),
      );
    }

    return await repository.buscarProductosSimilares(terminoBusqueda.trim());
  }
}