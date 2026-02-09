import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import 'package:restaurant_finder/data/errors/api_exception.dart';
import 'package:restaurant_finder/data/network/api_client.dart';

class DioApiClient implements ApiClient {
  DioApiClient({required Dio dio}) : _dio = dio;

  final Dio _dio;

  @override
  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _dio.get<Object?>(
      path,
      queryParameters: queryParameters,
    );
    final data = response.data;
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw ApiException(
      message: 'Unexpected JSON structure',
      type: ApiExceptionType.parsing,
    );
  }
}

class ApiExceptionInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiException = _mapException(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: apiException,
        message: err.message,
      ),
    );
  }

  ApiException _mapException(DioException err) {
    final existing = err.error;
    if (existing is ApiException) {
      return existing;
    }

    if (existing is FormatException) {
      return ApiException(
        message: 'Invalid JSON response',
        type: ApiExceptionType.parsing,
        error: existing,
      );
    }

    if (err.type == DioExceptionType.badResponse) {
      return ApiException(
        message: 'Unexpected status code',
        type: ApiExceptionType.network,
        statusCode: err.response?.statusCode,
        error: err.error,
      );
    }

    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      return ApiException(
        message: 'Request timed out',
        type: ApiExceptionType.timeout,
        error: err.error,
      );
    }

    if (err.type == DioExceptionType.connectionError) {
      return ApiException(
        message: 'Network request failed',
        type: ApiExceptionType.network,
        error: err.error,
      );
    }

    return ApiException(
      message: 'Unexpected error',
      type: ApiExceptionType.unexpected,
      error: err.error,
    );
  }
}

LogInterceptor buildLoggingInterceptor() {
  return LogInterceptor(
    requestBody: false,
    responseBody: false,
    responseUrl: false,
    requestHeader: false,
    responseHeader: false,
    logPrint: (message) {
      developer.log(message.toString(), name: 'HTTP');
    },
  );
}
