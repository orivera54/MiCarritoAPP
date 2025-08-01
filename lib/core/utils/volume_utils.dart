
class VolumeUtils {
  /// Formatea el volumen en ml a una representación legible
  static String formatVolume(double volumeInMl) {
    if (volumeInMl <= 0) return '';
    
    // Si es mayor o igual a 1000ml, mostrar en litros
    if (volumeInMl >= 1000) {
      final liters = volumeInMl / 1000;
      // Si es un número entero de litros, no mostrar decimales
      if (liters == liters.floor()) {
        return '${liters.toInt()}L';
      } else {
        // Mostrar hasta 2 decimales, eliminando ceros innecesarios
        return '${_removeTrailingZeros(liters.toStringAsFixed(2))}L';
      }
    } else {
      // Mostrar en ml
      if (volumeInMl == volumeInMl.floor()) {
        return '${volumeInMl.toInt()}ml';
      } else {
        return '${_removeTrailingZeros(volumeInMl.toStringAsFixed(1))}ml';
      }
    }
  }

  /// Parsea una entrada de texto a volumen en ml
  static double? parseVolume(String input) {
    if (input.trim().isEmpty) return null;
    
    final cleanInput = input.trim().toLowerCase();
    
    // Expresión regular para capturar número y unidad
    final regex = RegExp(r'^(\d+(?:\.\d+)?)\s*(ml|l|litros?|mililitros?)?$');
    final match = regex.firstMatch(cleanInput);
    
    if (match == null) return null;
    
    final numberStr = match.group(1);
    final unit = match.group(2) ?? '';
    
    final number = double.tryParse(numberStr!);
    if (number == null || number <= 0) return null;
    
    // Convertir a ml según la unidad
    switch (unit) {
      case 'l':
      case 'litro':
      case 'litros':
        return number * 1000;
      case 'ml':
      case 'mililitro':
      case 'mililitros':
      case '':
        return number;
      default:
        return number; // Por defecto asumir ml
    }
  }

  /// Valida que el volumen sea válido
  static bool isValidVolume(double? volume) {
    return volume != null && volume > 0 && volume <= 1000000; // Máximo 1000L
  }

  /// Obtiene sugerencias de volúmenes comunes
  static List<String> getVolumeSuggestions() {
    return [
      '250ml',
      '330ml',
      '500ml',
      '750ml',
      '1L',
      '1.5L',
      '2L',
      '3L',
      '5L',
    ];
  }

  /// Obtiene sugerencias de unidades
  static List<String> getUnitSuggestions() {
    return ['ml', 'L'];
  }

  /// Calcula el precio por ml
  static double? calculatePricePerMl(double price, double? volumeInMl) {
    if (volumeInMl == null || volumeInMl <= 0) return null;
    return price / volumeInMl;
  }

  /// Formatea el precio por ml
  static String formatPricePerMl(double pricePerMl, String currencySymbol) {
    if (pricePerMl < 0.01) {
      // Para precios muy pequeños, mostrar por 100ml
      final pricePer100ml = pricePerMl * 100;
      return '$currencySymbol${_removeTrailingZeros(pricePer100ml.toStringAsFixed(2))}/100ml';
    } else if (pricePerMl < 1) {
      // Para precios pequeños, mostrar con más decimales
      return '$currencySymbol${_removeTrailingZeros(pricePerMl.toStringAsFixed(3))}/ml';
    } else {
      // Para precios normales
      return '$currencySymbol${_removeTrailingZeros(pricePerMl.toStringAsFixed(2))}/ml';
    }
  }

  /// Convierte volumen a la unidad más apropiada para comparación
  static String getVolumeForComparison(double volumeInMl) {
    if (volumeInMl >= 1000) {
      return '${(volumeInMl / 1000).toStringAsFixed(2)}L';
    } else {
      return '${volumeInMl.toStringAsFixed(0)}ml';
    }
  }

  /// Valida el formato de entrada de volumen
  static String? validateVolumeInput(String? input) {
    if (input == null || input.trim().isEmpty) {
      return null; // Campo opcional
    }
    
    final volume = parseVolume(input);
    if (volume == null) {
      return 'Formato inválido. Use: 500ml, 1.5L, etc.';
    }
    
    if (!isValidVolume(volume)) {
      return 'El volumen debe estar entre 1ml y 1000L';
    }
    
    return null;
  }

  /// Normaliza el volumen para almacenamiento (siempre en ml)
  static double normalizeVolume(double volumeInMl) {
    // Redondear a 1 decimal para evitar problemas de precisión
    return (volumeInMl * 10).round() / 10;
  }

  /// Compara dos volúmenes con tolerancia para errores de precisión
  static bool areVolumesEqual(double? volume1, double? volume2, {double tolerance = 0.1}) {
    if (volume1 == null && volume2 == null) return true;
    if (volume1 == null || volume2 == null) return false;
    
    return (volume1 - volume2).abs() <= tolerance;
  }

  /// Elimina ceros innecesarios al final de un string numérico
  static String _removeTrailingZeros(String numberStr) {
    if (!numberStr.contains('.')) return numberStr;
    
    return numberStr.replaceAll(RegExp(r'\.?0+$'), '');
  }

  /// Obtiene el rango de volumen para filtros
  static List<Map<String, dynamic>> getVolumeRanges() {
    return [
      {'label': 'Pequeño (< 500ml)', 'min': 0.0, 'max': 500.0},
      {'label': 'Mediano (500ml - 1L)', 'min': 500.0, 'max': 1000.0},
      {'label': 'Grande (1L - 3L)', 'min': 1000.0, 'max': 3000.0},
      {'label': 'Extra Grande (> 3L)', 'min': 3000.0, 'max': double.infinity},
    ];
  }

  /// Determina la categoría de tamaño basada en el volumen
  static String getVolumeSizeCategory(double volumeInMl) {
    if (volumeInMl < 500) return 'Pequeño';
    if (volumeInMl < 1000) return 'Mediano';
    if (volumeInMl < 3000) return 'Grande';
    return 'Extra Grande';
  }
}