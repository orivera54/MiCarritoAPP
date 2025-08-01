import '../entities/almacen.dart';
import '../repositories/almacen_repository.dart';

class GetAllAlmacenes {
  final AlmacenRepository repository;

  GetAllAlmacenes(this.repository);

  Future<List<Almacen>> call() async {
    return await repository.getAllAlmacenes();
  }
}