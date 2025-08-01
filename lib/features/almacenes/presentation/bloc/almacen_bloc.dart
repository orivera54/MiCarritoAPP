import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/usecases/create_almacen.dart';
import '../../domain/usecases/delete_almacen.dart';
import '../../domain/usecases/get_all_almacenes.dart';
import '../../domain/usecases/get_almacen_by_id.dart';
import '../../domain/usecases/update_almacen.dart';
import 'almacen_event.dart';
import 'almacen_state.dart';

class AlmacenBloc extends Bloc<AlmacenEvent, AlmacenState> {
  final GetAllAlmacenes getAllAlmacenes;
  final GetAlmacenById getAlmacenById;
  final CreateAlmacen createAlmacen;
  final UpdateAlmacen updateAlmacen;
  final DeleteAlmacen deleteAlmacen;

  AlmacenBloc({
    required this.getAllAlmacenes,
    required this.getAlmacenById,
    required this.createAlmacen,
    required this.updateAlmacen,
    required this.deleteAlmacen,
  }) : super(AlmacenInitial()) {
    on<LoadAlmacenes>(_onLoadAlmacenes);
    on<GetAlmacenByIdEvent>(_onGetAlmacenById);
    on<CreateAlmacenEvent>(_onCreateAlmacen);
    on<UpdateAlmacenEvent>(_onUpdateAlmacen);
    on<DeleteAlmacenEvent>(_onDeleteAlmacen);
  }

  Future<void> _onLoadAlmacenes(
    LoadAlmacenes event,
    Emitter<AlmacenState> emit,
  ) async {
    emit(AlmacenLoading());
    try {
      final almacenes = await getAllAlmacenes();
      emit(AlmacenesLoaded(almacenes));
    } catch (e) {
      emit(AlmacenError(_getErrorMessage(e)));
    }
  }

  Future<void> _onGetAlmacenById(
    GetAlmacenByIdEvent event,
    Emitter<AlmacenState> emit,
  ) async {
    emit(AlmacenLoading());
    try {
      final almacen = await getAlmacenById(event.id);
      if (almacen != null) {
        emit(AlmacenLoaded(almacen));
      } else {
        emit(const AlmacenError('Almacén no encontrado'));
      }
    } catch (e) {
      emit(AlmacenError(_getErrorMessage(e)));
    }
  }

  Future<void> _onCreateAlmacen(
    CreateAlmacenEvent event,
    Emitter<AlmacenState> emit,
  ) async {
    emit(AlmacenLoading());
    try {
      final createdAlmacen = await createAlmacen(event.almacen);
      emit(AlmacenCreated(createdAlmacen));
    } catch (e) {
      emit(AlmacenError(_getErrorMessage(e)));
    }
  }

  Future<void> _onUpdateAlmacen(
    UpdateAlmacenEvent event,
    Emitter<AlmacenState> emit,
  ) async {
    emit(AlmacenLoading());
    try {
      final updatedAlmacen = await updateAlmacen(event.almacen);
      emit(AlmacenUpdated(updatedAlmacen));
    } catch (e) {
      emit(AlmacenError(_getErrorMessage(e)));
    }
  }

  Future<void> _onDeleteAlmacen(
    DeleteAlmacenEvent event,
    Emitter<AlmacenState> emit,
  ) async {
    emit(AlmacenLoading());
    try {
      await deleteAlmacen(event.id);
      emit(AlmacenDeleted());
    } catch (e) {
      emit(AlmacenError(_getErrorMessage(e)));
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error is ValidationException) {
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