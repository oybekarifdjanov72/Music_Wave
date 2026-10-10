import 'network_exceptions.dart';

/// A tiny `Either`-style wrapper so every repository method returns either
/// data or a typed [Failure] instead of throwing across layers. This keeps
/// cubits simple (`result.when(...)`) and keeps repository tests explicit
/// about every branch they need to cover.
sealed class Result<T> {
  const Result();

  const factory Result.success(T data) = ResultSuccess<T>;
  const factory Result.failure(Failure failure) = ResultFailureImpl<T>;

  bool get isSuccess => this is ResultSuccess<T>;
  bool get isFailure => this is ResultFailureImpl<T>;

  R when<R>({
    required R Function(T data) success,
    required R Function(Failure failure) failure,
  }) {
    final self = this;
    if (self is ResultSuccess<T>) return success(self.data);
    if (self is ResultFailureImpl<T>) return failure(self.failure);
    throw StateError('Unreachable Result subtype');
  }

  /// Returns the success value, or `null` if this is a failure.
  T? get dataOrNull {
    final self = this;
    return self is ResultSuccess<T> ? self.data : null;
  }
}

final class ResultSuccess<T> extends Result<T> {
  const ResultSuccess(this.data);
  final T data;
}

final class ResultFailureImpl<T> extends Result<T> {
  const ResultFailureImpl(this.failure);
  final Failure failure;
}
