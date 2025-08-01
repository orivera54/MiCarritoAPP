import '../entities/resultado_comparacion.dart';
import '../repositories/comparador_repository.dart';

class BuscarProductosPorQR {
  final ComparadorRepository repository;

  BuscarProductosPorQR(this.repository);

  Future<ResultadoComparacion> call(String codigoQR) async {
    if (codigoQR.trim().isEmpty) {
      return ResultadoComparacion(
        terminoBusqueda: codigoQR,
        productos: const [],
        fechaComparacion: DateTime.now(),
      );
    }

    return await repository.buscarProductosPorQR(codigoQR.trim());
  }
}