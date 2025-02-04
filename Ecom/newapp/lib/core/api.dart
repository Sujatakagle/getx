import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

const String BASE_URL = "http://192.168.221.148:5000/api";
const Map<String, dynamic> DEFAULT_HEADERS = {
  "Content-Type": "application/json"
};

class Api {
  final Dio _dio = Dio();

  Api() {
    _dio.options.baseUrl = BASE_URL;
    _dio.options.headers = DEFAULT_HEADERS;
    _dio.interceptors.add(PrettyDioLogger(
        requestBody: true,
        requestHeader: true,
        responseBody: true,
        responseHeader: true
    ));
  }

  Dio get sendRequest => _dio;

  Future<ApiResponse> makeRequest(String path, {Map<String, dynamic>? data, String method = 'GET'}) async {
    try {
      Response response;
      if (method == 'POST') {
        response = await _dio.post(path, data: data);
      } else if (method == 'PUT') {
        response = await _dio.put(path, data: data);
      } else {
        response = await _dio.get(path);
      }
      return ApiResponse.fromResponse(response);
    } catch (e) {
      if (e is DioException) {
        // Handle DioException without exposing it to the user
        String errorMessage = _handleDioError(e);
        return ApiResponse(success: false, message: errorMessage);
      } else {
        // Handle unexpected errors
        return ApiResponse(success: false, message: "An unexpected error occurred. Please try again.");
      }
    }
  }

  String _handleDioError(DioException error) {
    // Customize error handling for the user
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return "Connection timeout occurred. Please check your internet connection.";
      case DioExceptionType.sendTimeout:
        return "The request timed out while sending. Please try again.";
      case DioExceptionType.receiveTimeout:
        return "The server took too long to respond. Please try again later.";
      case DioExceptionType.badResponse:
        return "Server error. Please try again later.";
      case DioExceptionType.cancel:
        return "Request was cancelled. Please try again.";
      default:
        return "An unexpected error occurred. Please try again later.";
    }
  }
}

class ApiResponse {
  bool success;
  dynamic data;
  String? message;

  ApiResponse({
    required this.success,
    this.data,
    this.message
  });

  factory ApiResponse.fromResponse(Response response) {
    final data = response.data as Map<String, dynamic>;
    return ApiResponse(
        success: data["success"],
        data: data["data"],
        message: data["message"] ?? "Unexpected error"
    );
  }
}