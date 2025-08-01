import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/buscar_productos_similares.dart';
import '../../domain/usecases/comparar_precios_producto.dart';
import '../../domain/usecases/buscar_productos_por_qr.dart';
import '../../domain/services/comparador_service.dart';
import 'comparador_event.dart';
import 'comparador_state.dart';

class ComparadorBloc extends Bloc<ComparadorEvent, ComparadorState> {
  final BuscarProductosSimilares _buscarProductosSimilares;
  final CompararPreciosProducto _compararPreciosProducto;
  final BuscarProductosPorQR _buscarProductosPorQR;
  final ComparadorService _comparadorService;

  ComparadorBloc({
    required BuscarProductosSimilares buscarProductosSimilares,
    required CompararPreciosProducto compararPreciosProducto,
    required BuscarProductosPorQR buscarProductosPorQR,
    required ComparadorService comparadorService,
  })  : _buscarProductosSimilares = buscarProductosSimilares,
        _compararPreciosProducto = compararPreciosProducto,
        _buscarProductosPorQR = buscarProductosPorQR,
        _comparadorService = comparadorService,
        super(const ComparadorInitial()) {
    on<BuscarProductosSimilaresEvent>(_onBuscarProductosSimilares);
    on<CompararPreciosProductoEvent>(_onCompararPreciosProducto);
    on<BuscarProductosPorQREvent>(_onBuscarProductosPorQR);
    on<LimpiarResultadosEvent>(_onLimpiarResultados);
    on<ObtenerAlmacenesProductoEvent>(_onObtenerAlmacenesProducto);
  }

  Future<void> _onBuscarProductosSimilares(
    BuscarProductosSimilaresEvent event,
    Emitter<ComparadorState> emit,
  ) async {
    emit(const ComparadorLoading());

    try {
      final resultado = await _buscarProductosSimilares(event.terminoBusqueda);
      
      if (resultado.tieneResultados) {
        emit(ComparadorLoaded(resultado));
      } else {
        emit(ComparadorEmpty(event.terminoBusqueda));
      }
    } catch (e) {
      emit(ComparadorError('Error al buscar productos similares: ${e.toString()}'));
    }
  }

  Future<void> _onCompararPreciosProducto(
    CompararPreciosProductoEvent event,
    Emitter<ComparadorState> emit,
  ) async {
    emit(const ComparadorLoading());

    try {
      final resultado = await _compararPreciosProducto(event.productoId);
      
      if (resultado.tieneResultados) {
        emit(ComparadorLoaded(resultado));
      } else {
        emit(const ComparadorEmpty('Producto no encontrado'));
      }
    } catch (e) {
      emit(ComparadorError('Error al comparar precios: ${e.toString()}'));
    }
  }

  Future<void> _onBuscarProductosPorQR(
    BuscarProductosPorQREvent event,
    Emitter<ComparadorState> emit,
  ) async {
    emit(const ComparadorLoading());

    try {
      final resultado = await _buscarProductosPorQR(event.codigoQR);
      
      if (resultado.tieneResultados) {
        emit(ComparadorLoaded(resultado));
      } else {
        emit(ComparadorEmpty(event.codigoQR));
      }
    } catch (e) {
      emit(ComparadorError('Error al buscar productos por QR: ${e.toString()}'));
    }
  }

  void _onLimpiarResultados(
    LimpiarResultadosEvent event,
    Emitter<ComparadorState> emit,
  ) {
    emit(const ComparadorInitial());
  }

  Future<void> _onObtenerAlmacenesProducto(
    ObtenerAlmacenesProductoEvent event,
    Emitter<ComparadorState> emit,
  ) async {
    emit(ComparadorAlmacenesLoading(event.nombreProducto));

    try {
      final almacenes = await _comparadorService.obtenerAlmacenesProducto(event.nombreProducto);
      
      emit(ComparadorAlmacenesLoaded(
        almacenes: almacenes,
        nombreProducto: event.nombreProducto,
      ));
    } catch (e) {
      emit(ComparadorAlmacenesError(
        message: e.toString(),
        nombreProducto: event.nombreProducto,
      ));
    }
  }
}