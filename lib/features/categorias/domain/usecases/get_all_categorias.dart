import '../entities/categoria.dart';
import '../repositories/categoria_repository.dart';

class GetAllCategorias {
  final CategoriaRepository repository;

  GetAllCategorias(this.repository);

  Future<List<Categoria>> call() async {
    return await repository.getAllCategorias();
  }
}