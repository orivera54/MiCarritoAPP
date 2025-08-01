import '../../../../core/errors/exceptions.dart';
import '../entities/almacen.dart';
import '../repositories/almacen_repository.dart';

class CreateAlmacen {
  final AlmacenRepository repository;

  CreateAlmacen(this.repository);

  Future<Almacen> call(Almacen almacen) async {
    // Validate required fields first
    if (almacen.nombre.trim().isEmpty) {
      throw const ValidationException('El nombre del almacén es obligatorio');
    }

    // Validate that name doesn't already exist
    final nameExists = await repository.almacenNameExists(almacen.nombre);
    if (nameExists) {
      throw const ValidationException('Ya existe un almacén con este nombre');
    }

    // Create almacen with current timestamps
    final now = DateTime.now();
    final almacenToCreate = almacen.copyWith(
      fechaCreacion: now,
      fechaActualizacion: now,
    );

    return await repository.createAlmacen(almacenToCreate);
  }
}