import '../../../../core/database/database_helper.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/lista_compra_model.dart';
import '../models/item_calculadora_model.dart';
import '../../../productos/data/models/producto_model.dart';

abstract class CalculadoraLocalDataSource {
  /// Create a new lista de compra
  Future<ListaCompraModel> createListaCompra(ListaCompraModel listaCompra);

  /// Get all listas de compra
  Future<List<ListaCompraModel>> getAllListasCompra();

  /// Get lista de compra by id
  Future<ListaCompraModel?> getListaCompraById(int id);

  /// Update lista de compra
  Future<ListaCompraModel> updateListaCompra(ListaCompraModel listaCompra);

  /// Delete lista de compra
  Future<void> deleteListaCompra(int id);

  /// Add item to lista de compra
  Future<ItemCalculadoraModel> addItemToLista(
      int listaId, ItemCalculadoraModel item);

  /// Update item in lista de compra
  Future<ItemCalculadoraModel> updateItemInLista(ItemCalculadoraModel item);

  /// Remove item from lista de compra
  Future<void> removeItemFromLista(int itemId);

  /// Get items for a lista de compra
  Future<List<ItemCalculadoraModel>> getItemsForLista(int listaId);
}

class CalculadoraLocalDataSourceImpl implements CalculadoraLocalDataSource {
  final DatabaseHelper _databaseHelper;

  CalculadoraLocalDataSourceImpl(this._databaseHelper);

  @override
  Future<ListaCompraModel> createListaCompra(
      ListaCompraModel listaCompra) async {
    try {
      final db = await _databaseHelper.database;

      final validation = listaCompra.validate();
      if (validation != null) {
        throw ValidationException(validation);
      }

      final id = await db.insert(
        AppConstants.listasCompraTable,
        listaCompra.toJson(),
      );

      return ListaCompraModel(
        id: id,
        nombre: listaCompra.nombre,
        items: listaCompra.items,
        total: listaCompra.total,
        fechaCreacion: listaCompra.fechaCreacion,
      );
    } catch (e) {
      if (e is ValidationException) rethrow;
      throw DatabaseException(
          'Error creating lista de compra: ${e.toString()}');
    }
  }

  @override
  Future<List<ListaCompraModel>> getAllListasCompra() async {
    try {
      final db = await _databaseHelper.database;

      final maps = await db.query(
        AppConstants.listasCompraTable,
        orderBy: 'fecha_creacion DESC',
      );

      final listas = <ListaCompraModel>[];

      for (final map in maps) {
        final lista = ListaCompraModel.fromJson(map);
        final items = await getItemsForLista(lista.id!);
        listas.add(lista.copyWithItems(items));
      }

      return listas;
    } catch (e) {
      throw DatabaseException(
          'Error getting listas de compra: ${e.toString()}');
    }
  }

  @override
  Future<ListaCompraModel?> getListaCompraById(int id) async {
    try {
      final db = await _databaseHelper.database;

      final maps = await db.query(
        AppConstants.listasCompraTable,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) return null;

      final lista = ListaCompraModel.fromJson(maps.first);
      final items = await getItemsForLista(id);

      return lista.copyWithItems(items);
    } catch (e) {
      throw DatabaseException(
          'Error getting lista de compra by id: ${e.toString()}');
    }
  }

  @override
  Future<ListaCompraModel> updateListaCompra(
      ListaCompraModel listaCompra) async {
    try {
      final db = await _databaseHelper.database;

      if (listaCompra.id == null) {
        throw const ValidationException(
            'Lista de compra ID is required for update');
      }

      final validation = listaCompra.validate();
      if (validation != null) {
        throw ValidationException(validation);
      }

      final count = await db.update(
        AppConstants.listasCompraTable,
        listaCompra.toJson(),
        where: 'id = ?',
        whereArgs: [listaCompra.id],
      );

      if (count == 0) {
        throw const NotFoundException('Lista de compra not found');
      }

      return listaCompra;
    } catch (e) {
      if (e is ValidationException ||
          e is NotFoundException) {
        rethrow;
      }
      throw DatabaseException(
          'Error updating lista de compra: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteListaCompra(int id) async {
    try {
      final db = await _databaseHelper.database;

      // Delete items first (foreign key constraint)
      await db.delete(
        AppConstants.itemsCalculadoraTable,
        where: 'lista_compra_id = ?',
        whereArgs: [id],
      );

      // Delete lista
      final count = await db.delete(
        AppConstants.listasCompraTable,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (count == 0) {
        throw const NotFoundException('Lista de compra not found');
      }
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw DatabaseException(
          'Error deleting lista de compra: ${e.toString()}');
    }
  }

  @override
  Future<ItemCalculadoraModel> addItemToLista(
      int listaId, ItemCalculadoraModel item) async {
    try {
      final db = await _databaseHelper.database;

      final validation = item.validate();
      if (validation != null) {
        throw ValidationException(validation);
      }

      // Check if lista exists
      final listaExists = await db.query(
        AppConstants.listasCompraTable,
        where: 'id = ?',
        whereArgs: [listaId],
      );

      if (listaExists.isEmpty) {
        throw const NotFoundException('Lista de compra not found');
      }

      final itemData = item.toJson();
      itemData['lista_compra_id'] = listaId;

      final id = await db.insert(
        AppConstants.itemsCalculadoraTable,
        itemData,
      );

      // Update lista total
      await _updateListaTotal(listaId);

      return ItemCalculadoraModel(
        id: id,
        productoId: item.productoId,
        producto: item.producto,
        cantidad: item.cantidad,
        subtotal: item.subtotal,
      );
    } catch (e) {
      if (e is ValidationException ||
          e is NotFoundException) {
        rethrow;
      }
      throw DatabaseException(
          'Error adding item to lista: ${e.toString()}');
    }
  }

  @override
  Future<ItemCalculadoraModel> updateItemInLista(
      ItemCalculadoraModel item) async {
    try {
      final db = await _databaseHelper.database;

      if (item.id == null) {
        throw const ValidationException(
            'Item ID is required for update');
      }

      final validation = item.validate();
      if (validation != null) {
        throw ValidationException(validation);
      }

      // Get current item to find lista_compra_id
      final currentItem = await db.query(
        AppConstants.itemsCalculadoraTable,
        where: 'id = ?',
        whereArgs: [item.id],
      );

      if (currentItem.isEmpty) {
        throw const NotFoundException('Item not found');
      }

      final listaId = currentItem.first['lista_compra_id'] as int;

      final count = await db.update(
        AppConstants.itemsCalculadoraTable,
        item.toJson(),
        where: 'id = ?',
        whereArgs: [item.id],
      );

      if (count == 0) {
        throw const NotFoundException('Item not found');
      }

      // Update lista total
      await _updateListaTotal(listaId);

      return item;
    } catch (e) {
      if (e is ValidationException ||
          e is NotFoundException) {
        rethrow;
      }
      throw DatabaseException(
          'Error updating item: ${e.toString()}');
    }
  }

  @override
  Future<void> removeItemFromLista(int itemId) async {
    try {
      final db = await _databaseHelper.database;

      // Get item to find lista_compra_id before deleting
      final item = await db.query(
        AppConstants.itemsCalculadoraTable,
        where: 'id = ?',
        whereArgs: [itemId],
      );

      if (item.isEmpty) {
        throw const NotFoundException('Item not found');
      }

      final listaId = item.first['lista_compra_id'] as int;

      final count = await db.delete(
        AppConstants.itemsCalculadoraTable,
        where: 'id = ?',
        whereArgs: [itemId],
      );

      if (count == 0) {
        throw const NotFoundException('Item not found');
      }

      // Update lista total
      await _updateListaTotal(listaId);
    } catch (e) {
      if (e is NotFoundException) rethrow;
      throw DatabaseException(
          'Error removing item: ${e.toString()}');
    }
  }

  @override
  Future<List<ItemCalculadoraModel>> getItemsForLista(int listaId) async {
    try {
      final db = await _databaseHelper.database;

      final maps = await db.rawQuery('''
        SELECT 
          i.*,
          p.nombre as producto_nombre,
          p.precio as producto_precio,
          p.peso as producto_peso,
          p.tamano as producto_tamano,
          p.codigo_qr as producto_codigo_qr,
          p.categoria_id as producto_categoria_id,
          p.almacen_id as producto_almacen_id,
          p.fecha_creacion as producto_fecha_creacion,
          p.fecha_actualizacion as producto_fecha_actualizacion
        FROM ${AppConstants.itemsCalculadoraTable} i
        LEFT JOIN ${AppConstants.productosTable} p ON i.producto_id = p.id
        WHERE i.lista_compra_id = ?
        ORDER BY i.id
      ''', [listaId]);

      return maps.map((map) {
        final item = ItemCalculadoraModel.fromJson(map);

        // Create producto if data exists
        ProductoModel? producto;
        if (map['producto_nombre'] != null) {
          producto = ProductoModel(
            id: map['producto_id'] as int,
            nombre: map['producto_nombre'] as String,
            precio: (map['producto_precio'] as num).toDouble(),
            peso: map['producto_peso'] != null
                ? (map['producto_peso'] as num).toDouble()
                : null,
            tamano: map['producto_tamano'] as String?,
            codigoQR: map['producto_codigo_qr'] as String?,
            categoriaId: map['producto_categoria_id'] as int,
            almacenId: map['producto_almacen_id'] as int,
            fechaCreacion:
                DateTime.parse(map['producto_fecha_creacion'] as String),
            fechaActualizacion:
                DateTime.parse(map['producto_fecha_actualizacion'] as String),
          );
        }

        return producto != null ? item.copyWithProducto(producto) : item;
      }).toList();
    } catch (e) {
      throw DatabaseException(
          'Error getting items for lista: ${e.toString()}');
    }
  }

  /// Update the total of a lista de compra based on its items
  Future<void> _updateListaTotal(int listaId) async {
    try {
      final db = await _databaseHelper.database;

      final result = await db.rawQuery('''
        SELECT COALESCE(SUM(subtotal), 0) as total
        FROM ${AppConstants.itemsCalculadoraTable}
        WHERE lista_compra_id = ?
      ''', [listaId]);

      final total = (result.first['total'] as num).toDouble();

      await db.update(
        AppConstants.listasCompraTable,
        {'total': total},
        where: 'id = ?',
        whereArgs: [listaId],
      );
    } catch (e) {
      throw DatabaseException(
          'Error updating lista total: ${e.toString()}');
    }
  }
}