import 'package:get_it/get_it.dart';
import '../database/database_helper.dart';
import '../navigation/navigation_state.dart';
import '../services/configuration_service.dart';

// Data Sources
import '../../features/almacenes/data/datasources/almacen_local_data_source.dart';
import '../../features/productos/data/datasources/producto_local_data_source.dart';
import '../../features/calculadora/data/datasources/calculadora_local_data_source.dart';
import '../../features/comparador/data/datasources/comparador_local_data_source.dart';
import '../../features/categorias/data/datasources/categoria_local_data_source.dart';

// Repositories
import '../../features/almacenes/data/repositories/almacen_repository_impl.dart';
import '../../features/almacenes/domain/repositories/almacen_repository.dart';
import '../../features/productos/data/repositories/producto_repository_impl.dart';
import '../../features/productos/domain/repositories/producto_repository.dart';
import '../../features/calculadora/data/repositories/calculadora_repository_impl.dart';
import '../../features/calculadora/domain/repositories/calculadora_repository.dart';
import '../../features/comparador/data/repositories/comparador_repository_impl.dart';
import '../../features/comparador/domain/repositories/comparador_repository.dart';
import '../../features/categorias/data/repositories/categoria_repository_impl.dart';
import '../../features/categorias/domain/repositories/categoria_repository.dart';

// Use Cases - Almacenes
import '../../features/almacenes/domain/usecases/get_all_almacenes.dart';
import '../../features/almacenes/domain/usecases/get_almacen_by_id.dart';
import '../../features/almacenes/domain/usecases/create_almacen.dart';
import '../../features/almacenes/domain/usecases/update_almacen.dart';
import '../../features/almacenes/domain/usecases/delete_almacen.dart';

// Use Cases - Productos
import '../../features/productos/domain/usecases/get_all_productos.dart';
import '../../features/productos/domain/usecases/get_productos_by_almacen.dart';
import '../../features/productos/domain/usecases/get_productos_by_categoria.dart';
import '../../features/productos/domain/usecases/get_producto_by_id.dart';
import '../../features/productos/domain/usecases/search_productos_by_name.dart';
import '../../features/productos/domain/usecases/get_producto_by_qr.dart';
import '../../features/productos/domain/usecases/search_productos_with_filters.dart';
import '../../features/productos/domain/usecases/create_producto.dart';
import '../../features/productos/domain/usecases/update_producto.dart';
import '../../features/productos/domain/usecases/delete_producto.dart';

// Use Cases - Calculadora
import '../../features/calculadora/domain/usecases/agregar_item_calculadora.dart';
import '../../features/calculadora/domain/usecases/modificar_cantidad_item.dart';
import '../../features/calculadora/domain/usecases/eliminar_item_calculadora.dart';
import '../../features/calculadora/domain/usecases/obtener_lista_actual.dart';
import '../../features/calculadora/domain/usecases/guardar_lista_compra.dart';
import '../../features/calculadora/domain/usecases/limpiar_lista_actual.dart';

// Use Cases - Comparador
import '../../features/comparador/domain/usecases/buscar_productos_similares.dart';
import '../../features/comparador/domain/usecases/comparar_precios_producto.dart';
import '../../features/comparador/domain/usecases/buscar_productos_por_qr.dart';

// Use Cases - Categorias
import '../../features/categorias/domain/usecases/get_all_categorias.dart';
import '../../features/categorias/domain/usecases/get_categoria_by_id.dart';
import '../../features/categorias/domain/usecases/create_categoria.dart';
import '../../features/categorias/domain/usecases/update_categoria.dart';
import '../../features/categorias/domain/usecases/delete_categoria.dart';
import '../../features/categorias/domain/usecases/ensure_default_category.dart';

// Services
import '../../features/calculadora/domain/services/mejor_precio_service.dart';
import '../../features/comparador/domain/services/comparador_service.dart';

// BLoCs
import '../../features/almacenes/presentation/bloc/almacen_bloc.dart';
import '../../features/productos/presentation/bloc/producto_bloc.dart';
import '../../features/calculadora/presentation/bloc/calculadora_bloc.dart';
import '../../features/comparador/presentation/bloc/comparador_bloc.dart';
import '../../features/categorias/presentation/bloc/categoria_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
  sl.registerLazySingleton<NavigationState>(() => NavigationState());
  sl.registerLazySingleton<ConfigurationService>(() => ConfigurationService());

  // Data sources
  sl.registerLazySingleton<AlmacenLocalDataSource>(
    () => AlmacenLocalDataSourceImpl(databaseHelper: sl()),
  );
  sl.registerLazySingleton<ProductoLocalDataSource>(
    () => ProductoLocalDataSourceImpl(databaseHelper: sl()),
  );
  sl.registerLazySingleton<CalculadoraLocalDataSource>(
    () => CalculadoraLocalDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<ComparadorLocalDataSource>(
    () => ComparadorLocalDataSourceImpl(databaseHelper: sl()),
  );
  sl.registerLazySingleton<CategoriaLocalDataSource>(
    () => CategoriaLocalDataSourceImpl(databaseHelper: sl()),
  );

  // Repositories
  sl.registerLazySingleton<AlmacenRepository>(
    () => AlmacenRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<ProductoRepository>(
    () => ProductoRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<CalculadoraRepository>(
    () => CalculadoraRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ComparadorRepository>(
    () => ComparadorRepositoryImpl(localDataSource: sl()),
  );
  sl.registerLazySingleton<CategoriaRepository>(
    () => CategoriaRepositoryImpl(localDataSource: sl()),
  );

  // Use cases - Almacenes
  sl.registerLazySingleton(() => GetAllAlmacenes(sl()));
  sl.registerLazySingleton(() => GetAlmacenById(sl()));
  sl.registerLazySingleton(() => CreateAlmacen(sl()));
  sl.registerLazySingleton(() => UpdateAlmacen(sl()));
  sl.registerLazySingleton(() => DeleteAlmacen(sl()));

  // Use cases - Productos
  sl.registerLazySingleton(() => GetAllProductos(sl()));
  sl.registerLazySingleton(() => GetProductosByAlmacen(sl()));
  sl.registerLazySingleton(() => GetProductosByCategoria(sl()));
  sl.registerLazySingleton(() => GetProductoById(sl()));
  sl.registerLazySingleton(() => SearchProductosByName(sl()));
  sl.registerLazySingleton(() => GetProductoByQR(sl()));
  sl.registerLazySingleton(() => SearchProductosWithFilters(sl()));
  sl.registerLazySingleton(() => CreateProducto(sl()));
  sl.registerLazySingleton(() => UpdateProducto(sl()));
  sl.registerLazySingleton(() => DeleteProducto(sl()));

  // Use cases - Calculadora
  sl.registerLazySingleton(() => AgregarItemCalculadora(sl()));
  sl.registerLazySingleton(() => ModificarCantidadItem(sl()));
  sl.registerLazySingleton(() => EliminarItemCalculadora(sl()));
  sl.registerLazySingleton(() => ObtenerListaActual(sl()));
  sl.registerLazySingleton(() => GuardarListaCompra(sl()));
  sl.registerLazySingleton(() => LimpiarListaActual(sl()));

  // Use cases - Comparador
  sl.registerLazySingleton(() => BuscarProductosSimilares(sl()));
  sl.registerLazySingleton(() => CompararPreciosProducto(sl()));
  sl.registerLazySingleton(() => BuscarProductosPorQR(sl()));

  // Use cases - Categorias
  sl.registerLazySingleton(() => GetAllCategorias(sl()));
  sl.registerLazySingleton(() => GetCategoriaById(sl()));
  sl.registerLazySingleton(() => CreateCategoria(sl()));
  sl.registerLazySingleton(() => UpdateCategoria(sl()));
  sl.registerLazySingleton(() => DeleteCategoria(sl()));
  sl.registerLazySingleton(() => EnsureDefaultCategory(sl()));

  // Services
  sl.registerLazySingleton(() => MejorPrecioService(
        productoRepository: sl(),
        almacenRepository: sl(),
      ));
  
  sl.registerLazySingleton(() => ComparadorService(
        productoRepository: sl(),
        almacenRepository: sl(),
      ));

  // BLoCs
  sl.registerFactory(() => AlmacenBloc(
        getAllAlmacenes: sl(),
        getAlmacenById: sl(),
        createAlmacen: sl(),
        updateAlmacen: sl(),
        deleteAlmacen: sl(),
      ));

  sl.registerFactory(() => ProductoBloc(
        getAllProductos: sl(),
        getProductosByAlmacen: sl(),
        getProductosByCategoria: sl(),
        getProductoById: sl(),
        searchProductosByName: sl(),
        getProductoByQR: sl(),
        searchProductosWithFilters: sl(),
        createProducto: sl(),
        updateProducto: sl(),
        deleteProducto: sl(),
      ));

  sl.registerFactory(() => CalculadoraBloc(
        agregarItemCalculadora: sl(),
        modificarCantidadItem: sl(),
        eliminarItemCalculadora: sl(),
        obtenerListaActual: sl(),
        guardarListaCompra: sl(),
        limpiarListaActual: sl(),
        mejorPrecioService: sl(),
      ));

  sl.registerFactory(() => ComparadorBloc(
        buscarProductosSimilares: sl(),
        compararPreciosProducto: sl(),
        buscarProductosPorQR: sl(),
        comparadorService: sl(),
      ));

  sl.registerFactory(() => CategoriaBloc(
        getAllCategorias: sl(),
        getCategoriaById: sl(),
        createCategoria: sl(),
        updateCategoria: sl(),
        deleteCategoria: sl(),
        ensureDefaultCategory: sl(),
      ));
}
