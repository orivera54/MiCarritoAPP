import 'package:equatable/equatable.dart';
import '../../domain/entities/lista_compra.dart';

abstract class CalculadoraState extends Equatable {
  const CalculadoraState();

  @override
  List<Object?> get props => [];
}

class CalculadoraInitial extends CalculadoraState {}

class CalculadoraLoading extends CalculadoraState {}

class CalculadoraLoaded extends CalculadoraState {
  final ListaCompra listaCompra;

  const CalculadoraLoaded({
    required this.listaCompra,
  });

  @override
  List<Object?> get props => [listaCompra];

  CalculadoraLoaded copyWith({
    ListaCompra? listaCompra,
  }) {
    return CalculadoraLoaded(
      listaCompra: listaCompra ?? this.listaCompra,
    );
  }
}

class CalculadoraError extends CalculadoraState {
  final String message;

  const CalculadoraError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

class CalculadoraListaGuardada extends CalculadoraState {
  final ListaCompra listaGuardada;

  const CalculadoraListaGuardada({
    required this.listaGuardada,
  });

  @override
  List<Object?> get props => [listaGuardada];
}