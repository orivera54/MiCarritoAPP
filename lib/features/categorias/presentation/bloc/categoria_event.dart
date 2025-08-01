import 'package:equatable/equatable.dart';
import '../../domain/entities/categoria.dart';

abstract class CategoriaEvent extends Equatable {
  const CategoriaEvent();

  @override
  List<Object?> get props => [];
}

class LoadCategorias extends CategoriaEvent {}

class CreateCategoriaEvent extends CategoriaEvent {
  final Categoria categoria;

  const CreateCategoriaEvent(this.categoria);

  @override
  List<Object?> get props => [categoria];
}

class UpdateCategoriaEvent extends CategoriaEvent {
  final Categoria categoria;

  const UpdateCategoriaEvent(this.categoria);

  @override
  List<Object?> get props => [categoria];
}

class DeleteCategoriaEvent extends CategoriaEvent {
  final int id;

  const DeleteCategoriaEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class GetCategoriaByIdEvent extends CategoriaEvent {
  final int id;

  const GetCategoriaByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class EnsureDefaultCategoryEvent extends CategoriaEvent {}