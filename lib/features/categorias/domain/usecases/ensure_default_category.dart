import '../entities/categoria.dart';
import '../repositories/categoria_repository.dart';

class EnsureDefaultCategory {
  final CategoriaRepository repository;

  EnsureDefaultCategory(this.repository);

  Future<Categoria> call() async {
    return await repository.ensureDefaultCategory();
  }
}