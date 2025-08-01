import '../../../../core/errors/exceptions.dart';
import '../repositories/almacen_repository.dart';

class DeleteAlmacen {
  final AlmacenRepository repository;

  DeleteAlmacen(this.repository);

  Future<void> call(int id) async {
    // Validate that almacen exists before deleting
    final almacen = await repository.getAlmacenById(id);
    if (almacen == null) {
      throw const NotFoundException('Almacén no encontrado');
    }

    await repository.deleteAlmacen(id);
  }
}