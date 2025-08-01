/// Validation utilities for the application
class Validators {
  /// Validates if a string is not empty and has minimum length
  static String? validateRequired(String? value, {String? fieldName, int minLength = 1}) {
    fieldName ??= 'Campo';
    
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio';
    }
    
    if (value.trim().length < minLength) {
      return '$fieldName debe tener al menos $minLength caracteres';
    }
    
    return null;
  }
  
  /// Validates string length
  static String? validateLength(String? value, {String? fieldName, int? maxLength, int? minLength}) {
    fieldName ??= 'Campo';
    
    if (value == null) return null;
    
    if (minLength != null && value.length < minLength) {
      return '$fieldName debe tener al menos $minLength caracteres';
    }
    
    if (maxLength != null && value.length > maxLength) {
      return '$fieldName no puede exceder $maxLength caracteres';
    }
    
    return null;
  }
  
  /// Validates product name
  static String? validateProductName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El nombre es requerido';
    }
    
    if (value.trim().length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    
    if (value.length > 100) {
      return 'El nombre no puede exceder 100 caracteres';
    }
    
    return null;
  }
  
  /// Validates price string input
  static String? validatePrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El precio es requerido';
    }
    
    final price = double.tryParse(value);
    if (price == null) {
      return 'Ingresa un precio válido';
    }
    
    if (price <= 0) {
      return 'El precio debe ser mayor a 0';
    }
    
    if (price > 999999.99) {
      return 'El precio no puede exceder 999,999.99';
    }
    
    return null;
  }
  
  /// Validates price double value
  static String? validatePriceValue(double? value, {String? fieldName}) {
    fieldName ??= 'Precio';
    
    if (value == null) {
      return '$fieldName es obligatorio';
    }
    
    if (value <= 0) {
      return '$fieldName debe ser mayor a 0';
    }
    
    if (value > 999999.99) {
      return '$fieldName no puede exceder 999,999.99';
    }
    
    return null;
  }
  
  /// Validates weight values
  static String? validateWeight(double? value, {String? fieldName}) {
    fieldName ??= 'Peso';
    
    if (value == null) return null; // Weight is optional
    
    if (value <= 0) {
      return '$fieldName debe ser mayor a 0';
    }
    
    if (value > 99999.99) {
      return '$fieldName no puede exceder 99,999.99';
    }
    
    return null;
  }
  
  /// Validates quantity values
  static String? validateQuantity(int? value, {String? fieldName}) {
    fieldName ??= 'Cantidad';
    
    if (value == null) {
      return '$fieldName es obligatorio';
    }
    
    if (value <= 0) {
      return '$fieldName debe ser mayor a 0';
    }
    
    if (value > 99999) {
      return '$fieldName no puede exceder 99,999';
    }
    
    return null;
  }
  
  /// Validates QR code format (basic validation)
  static String? validateQRCode(String? value, {String? fieldName}) {
    fieldName ??= 'Código QR';
    
    if (value == null) return null; // QR is optional
    
    if (value.trim().isEmpty) {
      return '$fieldName no puede estar vacío si se proporciona';
    }
    
    if (value.length > 100) {
      return '$fieldName no puede exceder 100 caracteres';
    }
    
    // Basic format validation - can be extended based on QR standards
    if (value.contains(RegExp(r'[<>"\x27;]'))) {
      return '$fieldName contiene caracteres no válidos';
    }
    
    return null;
  }
  
  /// Validates email format (for future use)
  static String? validateEmail(String? value, {String? fieldName}) {
    fieldName ??= 'Email';
    
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio';
    }
    
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    
    if (!emailRegex.hasMatch(value)) {
      return '$fieldName no tiene un formato válido';
    }
    
    return null;
  }
  
  /// Validates phone number format (for future use)
  static String? validatePhone(String? value, {String? fieldName}) {
    fieldName ??= 'Teléfono';
    
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio';
    }
    
    // Basic phone validation - can be extended for specific formats
    final phoneRegex = RegExp(r'^\+?[0-9\s\-\(\)]{9,15}$');
    
    if (!phoneRegex.hasMatch(value)) {
      return '$fieldName no tiene un formato válido';
    }
    
    return null;
  }

  /// Combines multiple validation results
  static String? combineValidations(List<String? Function()> validators) {
    for (final validator in validators) {
      final result = validator();
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}