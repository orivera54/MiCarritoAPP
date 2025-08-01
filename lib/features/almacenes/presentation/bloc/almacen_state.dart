import 'package:equatable/equatable.dart';
import '../../domain/entities/almacen.dart';

abstract class AlmacenState extends Equatable {
  const AlmacenState();

  @override
  List<Object?> get props => [];
}

class AlmacenInitial extends AlmacenState {}

class AlmacenLoading extends AlmacenState {}

class AlmacenesLoaded extends AlmacenState {
  final List<Almacen> almacenes;

  const AlmacenesLoaded(this.almacenes);

  @override
  List<Object?> get props => [almacenes];
}

class AlmacenLoaded extends AlmacenState {
  final Almacen almacen;

  const AlmacenLoaded(this.almacen);

  @override
  List<Object?> get props => [almacen];
}

class AlmacenCreated extends AlmacenState {
  final Almacen almacen;

  const AlmacenCreated(this.almacen);

  @override
  List<Object?> get props => [almacen];
}

class AlmacenUpdated extends AlmacenState {
  final Almacen almacen;

  const AlmacenUpdated(this.almacen);

  @override
  List<Object?> get props => [almacen];
}

class AlmacenDeleted extends AlmacenState {}

class AlmacenError extends AlmacenState {
  final String message;

  const AlmacenError(this.message);

  @override
  List<Object?> get props => [message];
}