import '../../../../core/errors/exceptions.dart';
import '../entities/almacen.dart';
import '../repositories/almacen_repository.dart';

class UpdateAlmacen {
  final AlmacenRepository repository;

  UpdateAlmacen(this.repository);

  Future<Almacen> call(Almacen almacen) async {
    // Validate that almacen has an ID
    if (almacen.id == null) {
      throw const ValidationException('No se puede actualizar un almacén sin ID');
    }

    // Validate required fields
    if (almacen.nombre.trim().isEmpty) {
      throw const ValidationException('El nombre del almacén es obligatorio');
    }

    // Validate that name doesn't already exist (excluding current almacen)
    final nameExists = await repository.almacenNameExists(
      almacen.nombre,
      excludeId: almacen.id,
    );
    if (nameExists) {
      throw const ValidationException('Ya existe un almacén con este nombre');
    }

    // Update almacen with current timestamp
    final almacenToUpdate = almacen.copyWith(
      fechaActualizacion: DateTime.now(),
    );

    return await repository.updateAlmacen(almacenToUpdate);
  }
}