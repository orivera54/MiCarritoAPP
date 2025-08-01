import 'package:equatable/equatable.dart';
import '../../../../core/utils/volume_utils.dart';

class Producto extends Equatable {
  final int? id;
  final String nombre;
  final double precio;
  final double? peso;
  final double? volumen; // Volumen en ml
  final String? tamano;
  final String? codigoQR;
  final int categoriaId;
  final int almacenId;
  final DateTime fechaCreacion;
  final DateTime fechaActualizacion;

  const Producto({
    this.id,
    required this.nombre,
    required this.precio,
    this.peso,
    this.volumen,
    this.tamano,
    this.codigoQR,
    required this.categoriaId,
    required this.almacenId,
    required this.fechaCreacion,
    required this.fechaActualizacion,
  });

  /// Calcula el precio por ml si el volumen está disponible
  double? get precioPorMl => VolumeUtils.calculatePricePerMl(precio, volumen);

  /// Obtiene el volumen formateado para mostrar
  String get volumenDisplay => volumen != null ? VolumeUtils.formatVolume(volumen!) : '';

  /// Verifica si el producto tiene volumen especificado
  bool get hasVolumen => volumen != null && volumen! > 0;

  /// Obtiene información de medidas del producto
  String get medidasInfo {
    final medidas = <String>[];
    
    if (hasVolumen) {
      medidas.add(volumenDisplay);
    }
    
    if (peso != null && peso! > 0) {
      medidas.add('${peso}kg');
    }
    
    if (tamano != null && tamano!.isNotEmpty) {
      medidas.add(tamano!);
    }
    
    return medidas.join(' • ');
  }

  /// Obtiene el tipo de medida principal (volumen o peso)
  String get tipoMedidaPrincipal {
    if (hasVolumen) return 'Volumen';
    if (peso != null && peso! > 0) return 'Peso';
    return 'Tamaño';
  }

  @override
  List<Object?> get props => [
        id,
        nombre,
        precio,
        peso,
        volumen,
        tamano,
        codigoQR,
        categoriaId,
        almacenId,
        fechaCreacion,
        fechaActualizacion,
      ];

  Producto copyWith({
    int? id,
    String? nombre,
    double? precio,
    double? peso,
    double? volumen,
    String? tamano,
    String? codigoQR,
    int? categoriaId,
    int? almacenId,
    DateTime? fechaCreacion,
    DateTime? fechaActualizacion,
  }) {
    return Producto(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      precio: precio ?? this.precio,
      peso: peso ?? this.peso,
      volumen: volumen ?? this.volumen,
      tamano: tamano ?? this.tamano,
      codigoQR: codigoQR ?? this.codigoQR,
      categoriaId: categoriaId ?? this.categoriaId,
      almacenId: almacenId ?? this.almacenId,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      fechaActualizacion: fechaActualizacion ?? this.fechaActualizacion,
    );
  }
}