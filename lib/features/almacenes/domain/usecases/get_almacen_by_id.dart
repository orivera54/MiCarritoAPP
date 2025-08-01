import '../entities/almacen.dart';
import '../repositories/almacen_repository.dart';

class GetAlmacenById {
  final AlmacenRepository repository;

  GetAlmacenById(this.repository);

  Future<Almacen?> call(int id) async {
    return await repository.getAlmacenById(id);
  }
}