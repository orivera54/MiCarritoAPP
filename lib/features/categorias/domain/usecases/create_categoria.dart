import '../../../../core/errors/exceptions.dart';
import '../entities/categoria.dart';
import '../repositories/categoria_repository.dart';

class CreateCategoria {
  final CategoriaRepository repository;

  CreateCategoria(this.repository);

  Future<Categoria> call(Categoria categoria) async {
    // Validate required fields first
    if (categoria.nombre.trim().isEmpty) {
      throw const ValidationException('El nombre de la categoría es obligatorio');
    }

    // Validate that name doesn't already exist
    final nameExists = await repository.categoriaNameExists(categoria.nombre);
    if (nameExists) {
      throw const ValidationException('Ya existe una categoría con este nombre');
    }

    // Create categoria with current timestamp
    final now = DateTime.now();
    final categoriaToCreate = categoria.copyWith(
      fechaCreacion: now,
    );

    return await repository.createCategoria(categoriaToCreate);
  }
}