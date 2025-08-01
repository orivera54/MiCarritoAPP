import '../entities/categoria.dart';
import '../repositories/categoria_repository.dart';

class GetCategoriaById {
  final CategoriaRepository repository;

  GetCategoriaById(this.repository);

  Future<Categoria?> call(int id) async {
    return await repository.getCategoriaById(id);
  }
}