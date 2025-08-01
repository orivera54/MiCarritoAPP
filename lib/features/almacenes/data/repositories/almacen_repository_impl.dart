import '../../domain/entities/almacen.dart';
import '../../domain/repositories/almacen_repository.dart';
import '../datasources/almacen_local_data_source.dart';
import '../models/almacen_model.dart';

class AlmacenRepositoryImpl implements AlmacenRepository {
  final AlmacenLocalDataSource localDataSource;
  
  AlmacenRepositoryImpl({required this.localDataSource});
  
  @override
  Future<List<Almacen>> getAllAlmacenes() async {
    final almacenModels = await localDataSource.getAllAlmacenes();
    return almacenModels.cast<Almacen>();
  }
  
  @override
  Future<Almacen?> getAlmacenById(int id) async {
    final almacenModel = await localDataSource.getAlmacenById(id);
    return almacenModel;
  }
  
  @override
  Future<Almacen> createAlmacen(Almacen almacen) async {
    final almacenModel = AlmacenModel.fromEntity(almacen);
    final createdAlmacen = await localDataSource.insertAlmacen(almacenModel);
    return createdAlmacen;
  }
  
  @override
  Future<Almacen> updateAlmacen(Almacen almacen) async {
    final almacenModel = AlmacenModel.fromEntity(almacen);
    final updatedAlmacen = await localDataSource.updateAlmacen(almacenModel);
    return updatedAlmacen;
  }
  
  @override
  Future<void> deleteAlmacen(int id) async {
    await localDataSource.deleteAlmacen(id);
  }
  
  @override
  Future<bool> almacenNameExists(String nombre, {int? excludeId}) async {
    return await localDataSource.almacenNameExists(nombre, excludeId: excludeId);
  }
}