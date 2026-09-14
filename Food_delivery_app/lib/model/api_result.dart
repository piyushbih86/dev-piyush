class ApiResult<T> {
  const ApiResult._({
    required this.success,
    this.data,
    this.error,
  });

  final bool success;
  final T? data;
  final String? error;

  factory ApiResult.ok(T data) => ApiResult._(success: true, data: data);

  factory ApiResult.fail(String error) =>
      ApiResult._(success: false, error: error);
}
