class ApiResponse<T> {
  final T? data;
  final bool success;
  final String? error;
  final int? statusCode;

  ApiResponse({
    this.data,
    required this.success,
    this.error,
    this.statusCode,
  });

  factory ApiResponse.success(T data) {
    return ApiResponse(
      data: data,
      success: true,
    );
  }

  factory ApiResponse.error(String error, {int? statusCode}) {
    return ApiResponse(
      success: false,
      error: error,
      statusCode: statusCode,
    );
  }
}