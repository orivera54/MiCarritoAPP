import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/usecases/create_categoria.dart';
import '../../domain/usecases/delete_categoria.dart';
import '../../domain/usecases/ensure_default_category.dart';
import '../../domain/usecases/get_all_categorias.dart';
import '../../domain/usecases/get_categoria_by_id.dart';
import '../../domain/usecases/update_categoria.dart';
import 'categoria_event.dart';
import 'categoria_state.dart';

class CategoriaBloc extends Bloc<CategoriaEvent, CategoriaState> {
  final GetAllCategorias getAllCategorias;
  final GetCategoriaById getCategoriaById;
  final CreateCategoria createCategoria;
  final UpdateCategoria updateCategoria;
  final DeleteCategoria deleteCategoria;
  final EnsureDefaultCategory ensureDefaultCategory;

  CategoriaBloc({
    required this.getAllCategorias,
    required this.getCategoriaById,
    required this.createCategoria,
    required this.updateCategoria,
    required this.deleteCategoria,
    required this.ensureDefaultCategory,
  }) : super(CategoriaInitial()) {
    on<LoadCategorias>(_onLoadCategorias);
    on<GetCategoriaByIdEvent>(_onGetCategoriaById);
    on<CreateCategoriaEvent>(_onCreateCategoria);
    on<UpdateCategoriaEvent>(_onUpdateCategoria);
    on<DeleteCategoriaEvent>(_onDeleteCategoria);
    on<EnsureDefaultCategoryEvent>(_onEnsureDefaultCategory);
  }

  Future<void> _onLoadCategorias(
    LoadCategorias event,
    Emitter<CategoriaState> emit,
  ) async {
    emit(CategoriaLoading());
    try {
      final categorias = await getAllCategorias();
      emit(CategoriasLoaded(categorias));
    } catch (e) {
      emit(CategoriaError(_getErrorMessage(e)));
    }
  }

  Future<void> _onGetCategoriaById(
    GetCategoriaByIdEvent event,
    Emitter<CategoriaState> emit,
  ) async {
    emit(CategoriaLoading());
    try {
      final categoria = await getCategoriaById(event.id);
      if (categoria != null) {
        emit(CategoriaLoaded(categoria));
      } else {
        emit(const CategoriaError('Categoría no encontrada'));
      }
    } catch (e) {
      emit(CategoriaError(_getErrorMessage(e)));
    }
  }

  Future<void> _onCreateCategoria(
    CreateCategoriaEvent event,
    Emitter<CategoriaState> emit,
  ) async {
    emit(CategoriaLoading());
    try {
      final createdCategoria = await createCategoria(event.categoria);
      emit(CategoriaCreated(createdCategoria));
    } catch (e) {
      emit(CategoriaError(_getErrorMessage(e)));
    }
  }

  Future<void> _onUpdateCategoria(
    UpdateCategoriaEvent event,
    Emitter<CategoriaState> emit,
  ) async {
    emit(CategoriaLoading());
    try {
      final updatedCategoria = await updateCategoria(event.categoria);
      emit(CategoriaUpdated(updatedCategoria));
    } catch (e) {
      emit(CategoriaError(_getErrorMessage(e)));
    }
  }

  Future<void> _onDeleteCategoria(
    DeleteCategoriaEvent event,
    Emitter<CategoriaState> emit,
  ) async {
    emit(CategoriaLoading());
    try {
      await deleteCategoria(event.id);
      emit(CategoriaDeleted());
    } catch (e) {
      emit(CategoriaError(_getErrorMessage(e)));
    }
  }

  Future<void> _onEnsureDefaultCategory(
    EnsureDefaultCategoryEvent event,
    Emitter<CategoriaState> emit,
  ) async {
    emit(CategoriaLoading());
    try {
      final defaultCategory = await ensureDefaultCategory();
      emit(DefaultCategoryEnsured(defaultCategory));
    } catch (e) {
      emit(CategoriaError(_getErrorMessage(e)));
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