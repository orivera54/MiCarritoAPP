import '../entities/lista_compra.dart';
import '../entities/item_calculadora.dart';

abstract class CalculadoraRepository {
  /// Create a new lista de compra
  Future<ListaCompra> createListaCompra(ListaCompra listaCompra);
  
  /// Get all listas de compra
  Future<List<ListaCompra>> getAllListasCompra();
  
  /// Get lista de compra by id
  Future<ListaCompra?> getListaCompraById(int id);
  
  /// Update lista de compra
  Future<ListaCompra> updateListaCompra(ListaCompra listaCompra);
  
  /// Delete lista de compra
  Future<void> deleteListaCompra(int id);
  
  /// Add item to lista de compra
  Future<ItemCalculadora> addItemToLista(int listaId, ItemCalculadora item);
  
  /// Update item in lista de compra
  Future<ItemCalculadora> updateItemInLista(ItemCalculadora item);
  
  /// Remove item from lista de compra
  Future<void> removeItemFromLista(int itemId);
  
  /// Get items for a lista de compra
  Future<List<ItemCalculadora>> getItemsForLista(int listaId);
  
  /// Get current active lista (temporary lista for calculations)
  Future<ListaCompra?> getCurrentActiveLista();
  
  /// Save current active lista
  Future<ListaCompra> saveCurrentActiveLista(ListaCompra listaCompra);
  
  /// Clear current active lista
  Future<void> clearCurrentActiveLista();
  
  /// Get current active lista for specific almacen
  Future<ListaCompra?> getCurrentActiveListaForAlmacen(int almacenId);
  
  /// Save current active lista for specific almacen
  Future<ListaCompra> saveCurrentActiveListaForAlmacen(ListaCompra listaCompra, int almacenId);
  
  /// Clear current active lista for specific almacen
  Future<void> clearCurrentActiveListaForAlmacen(int almacenId);
}