import 'package:equatable/equatable.dart';
import '../../domain/entities/categoria.dart';

abstract class CategoriaState extends Equatable {
  const CategoriaState();

  @override
  List<Object?> get props => [];
}

class CategoriaInitial extends CategoriaState {}

class CategoriaLoading extends CategoriaState {}

class CategoriasLoaded extends CategoriaState {
  final List<Categoria> categorias;

  const CategoriasLoaded(this.categorias);

  @override
  List<Object?> get props => [categorias];
}

class CategoriaLoaded extends CategoriaState {
  final Categoria categoria;

  const CategoriaLoaded(this.categoria);

  @override
  List<Object?> get props => [categoria];
}

class CategoriaCreated extends CategoriaState {
  final Categoria categoria;

  const CategoriaCreated(this.categoria);

  @override
  List<Object?> get props => [categoria];
}

class CategoriaUpdated extends CategoriaState {
  final Categoria categoria;

  const CategoriaUpdated(this.categoria);

  @override
  List<Object?> get props => [categoria];
}

class CategoriaDeleted extends CategoriaState {}

class DefaultCategoryEnsured extends CategoriaState {
  final Categoria categoria;

  const DefaultCategoryEnsured(this.categoria);

  @override
  List<Object?> get props => [categoria];
}

class CategoriaError extends CategoriaState {
  final String message;

  const CategoriaError(this.message);

  @override
  List<Object?> get props => [message];
}