import '../../../../core/errors/exceptions.dart';
import '../repositories/categoria_repository.dart';

class DeleteCategoria {
  final CategoriaRepository repository;

  DeleteCategoria(this.repository);

  Future<void> call(int id) async {
    // Validate that id is provided
    if (id <= 0) {
      throw const ValidationException('ID de la categoría es requerido');
    }

    await repository.deleteCategoria(id);
  }
}