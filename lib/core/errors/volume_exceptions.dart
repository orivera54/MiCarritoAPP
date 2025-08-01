import 'exceptions.dart';

/// Excepción para errores relacionados con volumen
class InvalidVolumeException extends ValidationException {
  final double? attemptedVolume;
  final String? inputValue;

  InvalidVolumeException(
    String message, {
    this.attemptedVolume,
    this.inputValue,
  }) : super(message);

  @override
  String toString() {
    if (inputValue != null) {
      return 'InvalidVolumeException: $message (Entrada: "$inputValue")';
    } else if (attemptedVolume != null) {
      return 'InvalidVolumeException: $message (Volumen: $attemptedVolume ml)';
    }
    return 'InvalidVolumeException: $message';
  }
}

/// Excepción para productos duplicados
class DuplicateProductoException extends AppException {
  final String productName;
  final String almacenName;
  final int? existingProductId;
  final Map<String, dynamic>? existingProductData;

  DuplicateProductoException(
    this.productName,
    this.almacenName, {
    this.existingProductId,
    this.existingProductData,
  }) : super('Ya existe un producto "$productName" en $almacenName');

  /// Crea una excepción con datos del producto existente
  factory DuplicateProductoException.withExistingProduct(
    String productName,
    String almacenName,
    Map<String, dynamic> existingProduct,
  ) {
    return DuplicateProductoException(
      productName,
      almacenName,
      existingProductId: existingProduct['id'] as int?,
      existingProductData: existingProduct,
    );
  }

  /// Obtiene información detallada del producto existente
  String get existingProductInfo {
    if (existingProductData == null) return '';
    
    final buffer = StringBuffer();
    buffer.writeln('Producto existente:');
    buffer.writeln('- ID: ${existingProductData!['id']}');
    buffer.writeln('- Precio: \$${existingProductData!['precio']}');
    
    if (existingProductData!['peso'] != null) {
      buffer.writeln('- Peso: ${existingProductData!['peso']}kg');
    }
    
    if (existingProductData!['volumen'] != null) {
      buffer.writeln('- Volumen: ${existingProductData!['volumen']}ml');
    }
    
    if (existingProductData!['tamano'] != null) {
      buffer.writeln('- Tamaño: ${existingProductData!['tamano']}');
    }
    
    buffer.writeln('- Última actualización: ${existingProductData!['fecha_actualizacion']}');
    
    return buffer.toString();
  }

  @override
  String toString() {
    return 'DuplicateProductoException: $message\n$existingProductInfo';
  }
}

/// Excepción para errores de consolidación de productos
class ProductConsolidationException extends AppException {
  final List<int> affectedProductIds;
  final String operation;

  ProductConsolidationException(
    String message,
    this.operation, {
    this.affectedProductIds = const [],
  }) : super(message);

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.writeln('ProductConsolidationException: $message');
    buffer.writeln('Operación: $operation');
    
    if (affectedProductIds.isNotEmpty) {
      buffer.writeln('Productos afectados: ${affectedProductIds.join(', ')}');
    }
    
    return buffer.toString();
  }
}

/// Excepción para errores de migración de base de datos
class DatabaseMigrationException extends AppException {
  final int fromVersion;
  final int toVersion;
  final String migrationStep;

  DatabaseMigrationException(
    String message,
    this.fromVersion,
    this.toVersion,
    this.migrationStep,
  ) : super(message);

  @override
  String toString() {
    return 'DatabaseMigrationException: $message\n'
           'Migración: v$fromVersion -> v$toVersion\n'
           'Paso: $migrationStep';
  }
}