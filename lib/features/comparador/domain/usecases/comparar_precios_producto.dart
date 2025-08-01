import '../entities/resultado_comparacion.dart';
import '../repositories/comparador_repository.dart';

class CompararPreciosProducto {
  final ComparadorRepository repository;

  CompararPreciosProducto(this.repository);

  Future<ResultadoComparacion> call(int productoId) async {
    if (productoId <= 0) {
      throw ArgumentError('El ID del producto debe ser mayor a 0');
    }

    return await repository.compararPreciosProducto(productoId);
  }
}