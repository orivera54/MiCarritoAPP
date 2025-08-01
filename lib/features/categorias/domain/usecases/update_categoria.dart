import '../../../../core/errors/exceptions.dart';
import '../entities/categoria.dart';
import '../repositories/categoria_repository.dart';

class UpdateCategoria {
  final CategoriaRepository repository;

  UpdateCategoria(this.repository);

  Future<Categoria> call(Categoria categoria) async {
    // Validate that id is provided
    if (categoria.id == null) {
      throw const ValidationException('ID de la categoría es requerido para actualizar');
    }

    // Validate required fields
    if (categoria.nombre.trim().isEmpty) {
      throw const ValidationException('El nombre de la categoría es obligatorio');
    }

    // Validate that name doesn't already exist (excluding current categoria)
    final nameExists = await repository.categoriaNameExists(
      categoria.nombre,
      excludeId: categoria.id!,
    );
    if (nameExists) {
      throw const ValidationException('Ya existe una categoría con este nombre');
    }

    return await repository.updateCategoria(categoria);
  }
}