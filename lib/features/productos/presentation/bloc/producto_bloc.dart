import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/usecases/get_all_productos.dart';
import '../../domain/usecases/get_productos_by_almacen.dart';
import '../../domain/usecases/get_productos_by_categoria.dart';
import '../../domain/usecases/get_producto_by_id.dart';
import '../../domain/usecases/search_productos_by_name.dart' as usecases;
import '../../domain/usecases/get_producto_by_qr.dart';
import '../../domain/usecases/search_productos_with_filters.dart' as usecases;
import '../../domain/usecases/create_producto.dart' as usecases;
import '../../domain/usecases/update_producto.dart' as usecases;
import '../../domain/usecases/delete_producto.dart' as usecases;
import 'producto_event.dart';
import 'producto_state.dart';

class ProductoBloc extends Bloc<ProductoEvent, ProductoState> {
  final GetAllProductos getAllProductos;
  final GetProductosByAlmacen getProductosByAlmacen;
  final GetProductosByCategoria getProductosByCategoria;
  final GetProductoById getProductoById;
  final usecases.SearchProductosByName searchProductosByName;
  final GetProductoByQR getProductoByQR;
  final usecases.SearchProductosWithFilters searchProductosWithFilters;
  final usecases.CreateProducto createProducto;
  final usecases.UpdateProducto updateProducto;
  final usecases.DeleteProducto deleteProducto;

  ProductoBloc({
    required this.getAllProductos,
    required this.getProductosByAlmacen,
    required this.getProductosByCategoria,
    required this.getProductoById,
    required this.searchProductosByName,
    required this.getProductoByQR,
    required this.searchProductosWithFilters,
    required this.createProducto,
    required this.updateProducto,
    required this.deleteProducto,
  }) : super(ProductoInitial()) {
    on<LoadAllProductos>(_onLoadAllProductos);
    on<LoadProductosByAlmacen>(_onLoadProductosByAlmacen);
    on<LoadProductosByCategoria>(_onLoadProductosByCategoria);
    on<LoadProductoById>(_onLoadProductoById);
    on<SearchProductosByName>(_onSearchProductosByName);
    on<SearchProductoByQR>(_onSearchProductoByQR);
    on<SearchProductosWithFilters>(_onSearchProductosWithFilters);
    on<CreateProducto>(_onCreateProducto);
    on<UpdateProducto>(_onUpdateProducto);
    on<DeleteProducto>(_onDeleteProducto);
    on<ClearProductoSelection>(_onClearProductoSelection);
    on<ClearProductoSearch>(_onClearProductoSearch);
  }

  Future<void> _onLoadAllProductos(
    LoadAllProductos event,
    Emitter<ProductoState> emit,
  ) async {
    emit(ProductoLoading());
    try {
      final productos = await getAllProductos();
      emit(ProductoLoaded(productos));
    } catch (e) {
      emit(ProductoError(_getErrorMessage(e)));
    }
  }

  Future<void> _onLoadProductosByAlmacen(
    LoadProductosByAlmacen event,
    Emitter<ProductoState> emit,
  ) async {
    emit(ProductoLoading());
    try {
      final productos = await getProductosByAlmacen(event.almacenId);
      emit(ProductoLoaded(productos));
    } catch (e) {
      emit(ProductoError(_getErrorMessage(e)));
    }
  }

  Future<void> _onLoadProductosByCategoria(
    LoadProductosByCategoria event,
    Emitter<ProductoState> emit,
  ) async {
    emit(ProductoLoading());
    try {
      final productos = await getProductosByCategoria(event.categoriaId);
      emit(ProductoLoaded(productos));
    } catch (e) {
      emit(ProductoError(_getErrorMessage(e)));
    }
  }

  Future<void> _onLoadProductoById(
    LoadProductoById event,
    Emitter<ProductoState> emit,
  ) async {
    emit(ProductoLoading());
    try {
      final producto = await getProductoById(event.id);
      if (producto != null) {
        emit(ProductoSelected(producto));
      } else {
        emit(const ProductoError('Producto no encontrado'));
      }
    } catch (e) {
      emit(ProductoError(_getErrorMessage(e)));
    }
  }

  Future<void> _onSearchProductosByName(
    SearchProductosByName event,
    Emitter<ProductoState> emit,
  ) async {
    emit(ProductoLoading());
    try {
      final productos = await searchProductosByName(event.searchTerm);
      emit(ProductoSearchResults(productos, event.searchTerm));
    } catch (e) {
      emit(ProductoError(_getErrorMessage(e)));
    }
  }

  Future<void> _onSearchProductoByQR(
    SearchProductoByQR event,
    Emitter<ProductoState> emit,
  ) async {
    emit(ProductoLoading());
    try {
      final producto = await getProductoByQR(event.codigoQR);
      emit(ProductoQRResult(producto, event.codigoQR));
    } catch (e) {
      emit(ProductoError(_getErrorMessage(e)));
    }
  }

  Future<void> _onSearchProductosWithFilters(
    SearchProductosWithFilters event,
    Emitter<ProductoState> emit,
  ) async {
    emit(ProductoLoading());
    try {
      final productos = await searchProductosWithFilters(
        searchTerm: event.searchTerm,
        almacenId: event.almacenId,
        categoriaId: event.categoriaId,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
      );
      emit(ProductoFilteredResults(
        productos,
        searchTerm: event.searchTerm,
        almacenId: event.almacenId,
        categoriaId: event.categoriaId,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
      ));
    } catch (e) {
      emit(ProductoError(_getErrorMessage(e)));
    }
  }

  Future<void> _onCreateProducto(
    CreateProducto event,
    Emitter<ProductoState> emit,
  ) async {
    emit(ProductoLoading());
    try {
      final createdProducto = await createProducto(event.producto);
      emit(ProductoCreated(createdProducto));
    } catch (e) {
      emit(ProductoError(_getErrorMessage(e)));
    }
  }

  Future<void> _onUpdateProducto(
    UpdateProducto event,
    Emitter<ProductoState> emit,
  ) async {
    emit(ProductoLoading());
    try {
      final updatedProducto = await updateProducto(event.producto);
      emit(ProductoUpdated(updatedProducto));
    } catch (e) {
      emit(ProductoError(_getErrorMessage(e)));
    }
  }

  Future<void> _onDeleteProducto(
    DeleteProducto event,
    Emitter<ProductoState> emit,
  ) async {
    emit(ProductoLoading());
    try {
      await deleteProducto(event.id);
      emit(ProductoDeleted(event.id));
    } catch (e) {
      emit(ProductoError(_getErrorMessage(e)));
    }
  }

  Future<void> _onClearProductoSelection(
    ClearProductoSelection event,
    Emitter<ProductoState> emit,
  ) async {
    emit(ProductoInitial());
  }

  Future<void> _onClearProductoSearch(
    ClearProductoSearch event,
    Emitter<ProductoState> emit,
  ) async {
    emit(ProductoInitial());
  }

  String _getErrorMessage(dynamic error) {
    if (error is ValidationException) {
      return error.message;
    } else if (error is DuplicateException) {
      return error.message;
    } else if (error is NotFoundException) {
      return error.message;
    } else if (error is DatabaseException) {
      return 'Error de base de datos: ${error.message}';
    } else {
      return 'Error inesperado: ${error.toString()}';
    }
  }
}
