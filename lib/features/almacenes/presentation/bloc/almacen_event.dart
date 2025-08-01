import 'package:equatable/equatable.dart';
import '../../domain/entities/almacen.dart';

abstract class AlmacenEvent extends Equatable {
  const AlmacenEvent();

  @override
  List<Object?> get props => [];
}

class LoadAlmacenes extends AlmacenEvent {}

class CreateAlmacenEvent extends AlmacenEvent {
  final Almacen almacen;

  const CreateAlmacenEvent(this.almacen);

  @override
  List<Object?> get props => [almacen];
}

class UpdateAlmacenEvent extends AlmacenEvent {
  final Almacen almacen;

  const UpdateAlmacenEvent(this.almacen);

  @override
  List<Object?> get props => [almacen];
}

class DeleteAlmacenEvent extends AlmacenEvent {
  final int id;

  const DeleteAlmacenEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class GetAlmacenByIdEvent extends AlmacenEvent {
  final int id;

  const GetAlmacenByIdEvent(this.id);

  @override
  List<Object?> get props => [id];
}