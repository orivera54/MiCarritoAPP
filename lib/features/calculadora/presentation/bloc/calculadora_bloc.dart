import 'package:flutter_bloc/flutter_bloc.dart';
import 'calculadora_event.dart';
import 'calculadora_state.dart';
import '../../domain/usecases/agregar_item_calculadora.dart';
import '../../domain/usecases/modificar_cantidad_item.dart';
import '../../domain/usecases/eliminar_item_calculadora.dart';
import '../../domain/usecases/obtener_lista_actual.dart';
import '../../domain/usecases/guardar_lista_compra.dart';
import '../../domain/usecases/limpiar_lista_actual.dart';
import '../../domain/services/mejor_precio_service.dart';

class CalculadoraBloc extends Bloc<CalculadoraEvent, CalculadoraState> {
  final AgregarItemCalculadora _agregarItemCalculadora;
  final ModificarCantidadItem _modificarCantidadItem;
  final EliminarItemCalculadora _eliminarItemCalculadora;
  final ObtenerListaActual _obtenerListaActual;
  final GuardarListaCompra _guardarListaCompra;
  final LimpiarListaActual _limpiarListaActual;
  final MejorPrecioService _mejorPrecioService;

  CalculadoraBloc({
    required AgregarItemCalculadora agregarItemCalculadora,
    required ModificarCantidadItem modificarCantidadItem,
    required EliminarItemCalculadora eliminarItemCalculadora,
    required ObtenerListaActual obtenerListaActual,
    required GuardarListaCompra guardarListaCompra,
    required LimpiarListaActual limpiarListaActual,
    required MejorPrecioService mejorPrecioService,
  })  : _agregarItemCalculadora = agregarItemCalculadora,
        _modificarCantidadItem = modificarCantidadItem,
        _eliminarItemCalculadora = eliminarItemCalculadora,
        _obtenerListaActual = obtenerListaActual,
        _guardarListaCompra = guardarListaCompra,
        _limpiarListaActual = limpiarListaActual,
        _mejorPrecioService = mejorPrecioService,
        super(CalculadoraInitial()) {
    on<CargarListaActual>(_onCargarListaActual);
    on<AgregarProducto>(_onAgregarProducto);
    on<ModificarCantidad>(_onModificarCantidad);
    on<EliminarProducto>(_onEliminarProducto);
    on<GuardarLista>(_onGuardarLista);
    on<LimpiarLista>(_onLimpiarLista);
  }

  Future<void> _onCargarListaActual(
    CargarListaActual event,
    Emitter<CalculadoraState> emit,
  ) async {
    emit(CalculadoraLoading());
    
    try {
      final listaCompra = await _obtenerListaActual();
      emit(CalculadoraLoaded(listaCompra: listaCompra));
    } catch (e) {
      emit(CalculadoraError(message: 'Error al cargar la lista: ${e.toString()}'));
    }
  }

  Future<void> _onAgregarProducto(
    AgregarProducto event,
    Emitter<CalculadoraState> emit,
  ) async {
    if (state is! CalculadoraLoaded) {
      emit(const CalculadoraError(message: 'Lista no cargada'));
      return;
    }

    try {
      // Obtener información del mejor precio para este producto
      final mejorPrecio = await _mejorPrecioService.obtenerMejorPrecio(event.producto.nombre);
      
      final updatedLista = await _agregarItemCalculadora(
        producto: event.producto,
        cantidad: event.cantidad,
        mejorPrecio: mejorPrecio,
        almacenId: event.almacenId,
      );
      
      emit(CalculadoraLoaded(listaCompra: updatedLista));
    } catch (e) {
      emit(CalculadoraError(message: 'Error al agregar producto: ${e.toString()}'));
      
      // Restore previous state after showing error
      if (state is CalculadoraError) {
        try {
          final listaCompra = await _obtenerListaActual();
          emit(CalculadoraLoaded(listaCompra: listaCompra));
        } catch (_) {
          // Keep error state if we can't restore
        }
      }
    }
  }

  Future<void> _onModificarCantidad(
    ModificarCantidad event,
    Emitter<CalculadoraState> emit,
  ) async {
    if (state is! CalculadoraLoaded) {
      emit(const CalculadoraError(message: 'Lista no cargada'));
      return;
    }

    try {
      final updatedLista = await _modificarCantidadItem(
        productoId: event.productoId,
        nuevaCantidad: event.nuevaCantidad,
      );
      
      emit(CalculadoraLoaded(listaCompra: updatedLista));
    } catch (e) {
      emit(CalculadoraError(message: 'Error al modificar cantidad: ${e.toString()}'));
      
      // Restore previous state after showing error
      if (state is CalculadoraError) {
        try {
          final listaCompra = await _obtenerListaActual();
          emit(CalculadoraLoaded(listaCompra: listaCompra));
        } catch (_) {
          // Keep error state if we can't restore
        }
      }
    }
  }

  Future<void> _onEliminarProducto(
    EliminarProducto event,
    Emitter<CalculadoraState> emit,
  ) async {
    if (state is! CalculadoraLoaded) {
      emit(const CalculadoraError(message: 'Lista no cargada'));
      return;
    }

    try {
      final updatedLista = await _eliminarItemCalculadora(
        productoId: event.productoId,
      );
      
      emit(CalculadoraLoaded(listaCompra: updatedLista));
    } catch (e) {
      emit(CalculadoraError(message: 'Error al eliminar producto: ${e.toString()}'));
      
      // Restore previous state after showing error
      if (state is CalculadoraError) {
        try {
          final listaCompra = await _obtenerListaActual();
          emit(CalculadoraLoaded(listaCompra: listaCompra));
        } catch (_) {
          // Keep error state if we can't restore
        }
      }
    }
  }

  Future<void> _onGuardarLista(
    GuardarLista event,
    Emitter<CalculadoraState> emit,
  ) async {
    if (state is! CalculadoraLoaded) {
      emit(const CalculadoraError(message: 'Lista no cargada'));
      return;
    }

    try {
      final listaGuardada = await _guardarListaCompra(
        nombre: event.nombre,
      );
      
      emit(CalculadoraListaGuardada(listaGuardada: listaGuardada));
      
      // Load new empty lista after saving
      final nuevaLista = await _obtenerListaActual();
      emit(CalculadoraLoaded(listaCompra: nuevaLista));
    } catch (e) {
      emit(CalculadoraError(message: 'Error al guardar lista: ${e.toString()}'));
      
      // Restore previous state after showing error
      if (state is CalculadoraError) {
        try {
          final listaCompra = await _obtenerListaActual();
          emit(CalculadoraLoaded(listaCompra: listaCompra));
        } catch (_) {
          // Keep error state if we can't restore
        }
      }
    }
  }

  Future<void> _onLimpiarLista(
    LimpiarLista event,
    Emitter<CalculadoraState> emit,
  ) async {
    try {
      final nuevaLista = await _limpiarListaActual();
      emit(CalculadoraLoaded(listaCompra: nuevaLista));
    } catch (e) {
      emit(CalculadoraError(message: 'Error al limpiar lista: ${e.toString()}'));
    }
  }
}