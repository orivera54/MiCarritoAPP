import 'package:equatable/equatable.dart';

/// Abstract failure class for error handling in the domain layer
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  
  const Failure(this.message, {this.code});
  
  @override
  List<Object?> get props => [message, code];
}

/// Database related failures
class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, {super.code});
}

/// Validation related failures
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;
  
  const ValidationFailure(super.message, {super.code, this.fieldErrors});
  
  @override
  List<Object?> get props => [message, code, fieldErrors];
}

/// Entity not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.code});
}

/// Camera related failures
class CameraFailure extends Failure {
  const CameraFailure(super.message, {super.code});
}

/// QR Format related failures
class QRFormatFailure extends Failure {
  const QRFormatFailure(super.message, {super.code});
}

/// Permission related failures
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.code});
}

/// Duplicate entry failures
class DuplicateFailure extends Failure {
  const DuplicateFailure(super.message, {super.code});
}

/// Network related failures (for future use)
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

/// Server related failures (for future use)
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}