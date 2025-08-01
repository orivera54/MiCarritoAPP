import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/categoria.dart';
import '../../domain/repositories/categoria_repository.dart';
import '../datasources/categoria_local_data_source.dart';
import '../models/categoria_model.dart';

class CategoriaRepositoryImpl implements CategoriaRepository {
  final CategoriaLocalDataSource localDataSource;
  
  CategoriaRepositoryImpl({required this.localDataSource});
  
  @override
  Future<List<Categoria>> getAllCategorias() async {
    final categoriaModels = await localDataSource.getAllCategorias();
    return categoriaModels.cast<Categoria>();
  }
  
  @override
  Future<Categoria?> getCategoriaById(int id) async {
    final categoriaModel = await localDataSource.getCategoriaById(id);
    return categoriaModel;
  }
  
  @override
  Future<Categoria?> getCategoriaByName(String nombre) async {
    final categoriaModel = await localDataSource.getCategoriaByName(nombre);
    return categoriaModel;
  }
  
  @override
  Future<Categoria> createCategoria(Categoria categoria) async {
    final categoriaModel = CategoriaModel.fromEntity(categoria);
    final createdCategoria = await localDataSource.insertCategoria(categoriaModel);
    return createdCategoria;
  }
  
  @override
  Future<Categoria> updateCategoria(Categoria categoria) async {
    final categoriaModel = CategoriaModel.fromEntity(categoria);
    final updatedCategoria = await localDataSource.updateCategoria(categoriaModel);
    return updatedCategoria;
  }
  
  @override
  Future<void> deleteCategoria(int id) async {
    await localDataSource.deleteCategoria(id);
  }
  
  @override
  Future<bool> categoriaNameExists(String nombre, {int? excludeId}) async {
    return await localDataSource.categoriaNameExists(nombre, excludeId: excludeId);
  }
  
  @override
  Future<Categoria> ensureDefaultCategory() async {
    // Check if default category already exists
    final existingCategory = await getCategoriaByName(AppConstants.defaultCategory);
    
    if (existingCategory != null) {
      return existingCategory;
    }
    
    // Create default category if it doesn't exist
    final defaultCategory = Categoria(
      nombre: AppConstants.defaultCategory,
      descripcion: 'Categoría por defecto para productos sin categoría específica',
      fechaCreacion: DateTime.now(),
    );
    
    return await createCategoria(defaultCategory);
  }
}