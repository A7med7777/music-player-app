import 'package:equatable/equatable.dart';

sealed class Failure extends Equatable {
  const Failure(this.code, this.message);
  final String code;
  final String message;

  @override
  List<Object> get props => [code, message];
}

class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'No internet connection.'])
      : super('NETWORK', message);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'Not found.'])
      : super('NOT_FOUND', message);
}

class PermissionFailure extends Failure {
  const PermissionFailure([String message = 'Permission denied.'])
      : super('PERMISSION', message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super('VALIDATION', message);
}

class PlaybackFailure extends Failure {
  const PlaybackFailure([String message = 'Playback error.'])
      : super('PLAYBACK', message);
}

class IntegrationFailure extends Failure {
  const IntegrationFailure([String message = 'Service unavailable.'])
      : super('INTEGRATION', message);
}

class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'An unexpected error occurred.'])
      : super('UNKNOWN', message);
}
