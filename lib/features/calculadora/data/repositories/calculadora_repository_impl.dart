import '../../domain/entities/lista_compra.dart';
import '../../domain/entities/item_calculadora.dart';
import '../../domain/repositories/calculadora_repository.dart';
import '../datasources/calculadora_local_data_source.dart';
import '../models/lista_compra_model.dart';
import '../models/item_calculadora_model.dart';

class CalculadoraRepositoryImpl implements CalculadoraRepository {
  final CalculadoraLocalDataSource _localDataSource;
  
  // In-memory storage for current active lista (temporary calculations)
  ListaCompra? _currentActiveLista;
  
  // In-memory storage for current active listas by almacen
  final Map<int, ListaCompra> _currentActiveListasByAlmacen = {};
  
  CalculadoraRepositoryImpl(this._localDataSource);
  
  @override
  Future<ListaCompra> createListaCompra(ListaCompra listaCompra) async {
    final model = ListaCompraModel.fromEntity(listaCompra);
    final result = await _localDataSource.createListaCompra(model);
    return result;
  }
  
  @override
  Future<List<ListaCompra>> getAllListasCompra() async {
    final models = await _localDataSource.getAllListasCompra();
    return models.cast<ListaCompra>();
  }
  
  @override
  Future<ListaCompra?> getListaCompraById(int id) async {
    final model = await _localDataSource.getListaCompraById(id);
    return model;
  }
  
  @override
  Future<ListaCompra> updateListaCompra(ListaCompra listaCompra) async {
    final model = ListaCompraModel.fromEntity(listaCompra);
    final result = await _localDataSource.updateListaCompra(model);
    return result;
  }
  
  @override
  Future<void> deleteListaCompra(int id) async {
    await _localDataSource.deleteListaCompra(id);
  }
  
  @override
  Future<ItemCalculadora> addItemToLista(int listaId, ItemCalculadora item) async {
    final model = ItemCalculadoraModel.fromEntity(item);
    final result = await _localDataSource.addItemToLista(listaId, model);
    return result;
  }
  
  @override
  Future<ItemCalculadora> updateItemInLista(ItemCalculadora item) async {
    final model = ItemCalculadoraModel.fromEntity(item);
    final result = await _localDataSource.updateItemInLista(model);
    return result;
  }
  
  @override
  Future<void> removeItemFromLista(int itemId) async {
    await _localDataSource.removeItemFromLista(itemId);
  }
  
  @override
  Future<List<ItemCalculadora>> getItemsForLista(int listaId) async {
    final models = await _localDataSource.getItemsForLista(listaId);
    return models.cast<ItemCalculadora>();
  }
  
  @override
  Future<ListaCompra?> getCurrentActiveLista() async {
    return _currentActiveLista;
  }
  
  @override
  Future<ListaCompra> saveCurrentActiveLista(ListaCompra listaCompra) async {
    _currentActiveLista = listaCompra;
    
    // If the lista has an ID, update it in the database
    if (listaCompra.id != null) {
      return await updateListaCompra(listaCompra);
    } else {
      // Create new lista in database
      return await createListaCompra(listaCompra);
    }
  }
  
  @override
  Future<void> clearCurrentActiveLista() async {
    _currentActiveLista = null;
  }

  @override
  Future<ListaCompra?> getCurrentActiveListaForAlmacen(int almacenId) async {
    return _currentActiveListasByAlmacen[almacenId];
  }

  @override
  Future<ListaCompra> saveCurrentActiveListaForAlmacen(ListaCompra listaCompra, int almacenId) async {
    // Set the almacen information in the lista
    final listaWithAlmacen = listaCompra.copyWith(
      almacenId: almacenId,
    );
    
    _currentActiveListasByAlmacen[almacenId] = listaWithAlmacen;
    
    // If the lista has an ID, update it in the database
    if (listaWithAlmacen.id != null) {
      return await updateListaCompra(listaWithAlmacen);
    } else {
      // For now, just return the in-memory lista (don't persist until saved)
      return listaWithAlmacen;
    }
  }

  @override
  Future<void> clearCurrentActiveListaForAlmacen(int almacenId) async {
    _currentActiveListasByAlmacen.remove(almacenId);
  }
}