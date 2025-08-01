/// Custom exceptions for the application
abstract class AppException implements Exception {
  final String message;
  final String? code;
  
  const AppException(this.message, {this.code});
  
  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Database related exceptions
class DatabaseException extends AppException {
  const DatabaseException(super.message, {super.code});
}

/// Validation related exceptions
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;
  
  const ValidationException(super.message, {super.code, this.fieldErrors});
  
  @override
  String toString() {
    String base = super.toString();
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      base += '\nField errors: ${fieldErrors.toString()}';
    }
    return base;
  }
}

/// Entity not found exceptions
class NotFoundException extends AppException {
  const NotFoundException(super.message, {super.code});
}

/// Camera related exceptions
class CameraException extends AppException {
  const CameraException(super.message, {super.code});
}

/// QR Format related exceptions
class QRFormatException extends AppException {
  const QRFormatException(super.message, {super.code});
}

/// Permission related exceptions
class PermissionException extends AppException {
  const PermissionException(super.message, {super.code});
}

/// Duplicate entry exceptions
class DuplicateException extends AppException {
  const DuplicateException(super.message, {super.code});
}