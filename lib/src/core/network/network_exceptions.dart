import 'package:dio/dio.dart';

/// Typed, user-safe failures. Every [message] here is written to be shown
/// directly in a toast or an [ErrorView] — never a raw exception string.
sealed class Failure {
  const Failure(this.message);
  final String message;
}

final class NoInternetFailure extends Failure {
  const NoInternetFailure()
      : super('No internet connection. Check your network and try again.');
}

final class TimeoutFailure extends Failure {
  const TimeoutFailure()
      : super('This is taking longer than expected. Please try again.');
}

final class ServerFailure extends Failure {
  const ServerFailure([String? detail])
      : super(detail ?? 'Something went wrong on our end. Please try again.');
}

final class NotFoundFailure extends Failure {
  const NotFoundFailure() : super("We couldn't find what you're looking for.");
}

final class ParsingFailure extends Failure {
  const ParsingFailure()
      : super('We had trouble reading that response. Please try again.');
}

final class UnknownFailure extends Failure {
  const UnknownFailure([String? detail])
      : super(detail ?? 'Unexpected error. Please try again.');
}

final class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Maps any exception thrown by Dio (or otherwise) into a typed,
/// human-readable [Failure]. Centralising this means every service in the
/// app reports errors the exact same, friendly way.
Failure mapExceptionToFailure(Object error) {
  if (error is Failure) return error;

  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const TimeoutFailure();
      case DioExceptionType.transformTimeout:
        return const ParsingFailure();
      case DioExceptionType.connectionError:
        return const NoInternetFailure();
      case DioExceptionType.badCertificate:
        return const ServerFailure('A secure connection could not be established.');
      case DioExceptionType.cancel:
        return const UnknownFailure('Request was cancelled.');
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode ?? 0;
        if (status == 404) return const NotFoundFailure();
        if (status == 403 || status == 401) {
          return const ServerFailure('Unable to connect to music service right now. Please try again soon.');
        }
        if (status >= 500) {
          return const ServerFailure('Our music servers are temporarily busy. Please try again in a moment.');
        }
        return const ServerFailure('Unable to load music at the moment. Please check your network and try again.');
      case DioExceptionType.unknown:
        return const NoInternetFailure();
    }
  }

  if (error is FormatException || error is TypeError) {
    return const ParsingFailure();
  }

  return UnknownFailure(error.toString());
}
