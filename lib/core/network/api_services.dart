import 'dart:io';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../exceptions/exceptions.dart';

/// Base API service class that handles all HTTP requests using Dio
class ApiService {
  static final Dio _dio =
      Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 30),
            receiveTimeout: const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 30),
            contentType: Headers.jsonContentType,
            responseType: ResponseType.json,
          ),
        )
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (options, handler) async {
              if (!options.headers.containsKey(
                HttpHeaders.authorizationHeader,
              )) {
                try {
                  final prefs = await SharedPreferences.getInstance();
                  final token = prefs.getString('access_token');
                  if (token != null && token.isNotEmpty) {
                    options.headers[HttpHeaders.authorizationHeader] =
                        'Bearer $token';
                  }
                } catch (_) {
                  // Ignore preference reading issues in interceptor
                }
              }
              return handler.next(options);
            },
          ),
        );

  /// Configure base URL, interceptors, and HTTP client adapter
  static void configure({
    String? baseUrl,
    List<Interceptor>? interceptors,
    HttpClientAdapter? adapter,
  }) {
    if (baseUrl != null) {
      _dio.options.baseUrl = baseUrl;
    }

    if (interceptors != null) {
      _dio.interceptors.addAll(interceptors);
    }

    if (adapter != null) {
      _dio.httpClientAdapter = adapter;
    }
  }

  /// Make HTTP request with proper error handling
  static Future<Map<String, dynamic>> request({
    required String method,
    required String url,
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParameters,
    String? accessToken,
    Duration? timeout,
  }) async {
    try {
      final options = Options(
        method: method.toUpperCase(),
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
          if (accessToken != null && accessToken.isNotEmpty)
            HttpHeaders.authorizationHeader: 'Bearer $accessToken',
        },
        sendTimeout: timeout,
        receiveTimeout: timeout,
      );

      final response = await _dio.request(
        url,
        data: body,
        queryParameters: queryParameters,
        options: options,
      );

      if (response.data is Map<String, dynamic>) {
        final data = Map<String, dynamic>.from(response.data as Map);
        data['statusCode'] = response.statusCode;
        return data;
      } else {
        return {'data': response.data, "statusCode": response.statusCode};
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Network error: ${e.toString()}');
    }
  }

  /// Upload files with form data
  static Future<Map<String, dynamic>> uploadFiles({
    required String method,
    required String url,
    required Map<String, String> fields,
    required Map<String, String> files,
    String? accessToken,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final formData = FormData();

      // Add fields
      fields.forEach((key, value) {
        formData.fields.add(MapEntry(key, value));
      });

      // Add files
      for (var entry in files.entries) {
        formData.files.add(
          MapEntry(
            entry.key,
            await MultipartFile.fromFile(
              entry.value,
              filename: entry.value.split("/").last,
            ),
          ),
        );
      }

      final options = Options(
        method: method.toUpperCase(),
        contentType: Headers.multipartFormDataContentType,
        headers: {
          HttpHeaders.acceptHeader: 'application/json',
          if (accessToken != null && accessToken.isNotEmpty)
            HttpHeaders.authorizationHeader: 'Bearer $accessToken',
        },
      );

      final response = await _dio.request(
        url,
        data: formData,
        options: options,
        onSendProgress: onSendProgress,
      );

      if (response.data is Map<String, dynamic>) {
        final data = Map<String, dynamic>.from(response.data as Map);
        data['statusCode'] = response.statusCode;
        return data;
      } else {
        return {'data': response.data, "statusCode": response.statusCode};
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('File upload error: ${e.toString()}');
    }
  }

  /// GET request helper
  static Future<Map<String, dynamic>> get(
    String url, {
    Map<String, dynamic>? queryParameters,
    String? accessToken,
  }) async {
    return request(
      method: 'GET',
      url: url,
      queryParameters: queryParameters,
      accessToken: accessToken,
    );
  }

  /// POST request helper
  static Future<Map<String, dynamic>> post(
    String url, {
    Map<String, dynamic>? body,
    String? accessToken,
  }) async {
    return request(
      method: 'POST',
      url: url,
      body: body,
      accessToken: accessToken,
    );
  }

  /// PUT request helper
  static Future<Map<String, dynamic>> put(
    String url, {
    Map<String, dynamic>? body,
    String? accessToken,
  }) async {
    return request(
      method: 'PUT',
      url: url,
      body: body,
      accessToken: accessToken,
    );
  }

  /// DELETE request helper
  static Future<Map<String, dynamic>> delete(
    String url, {
    Map<String, dynamic>? queryParameters,
    String? accessToken,
  }) async {
    return request(
      method: 'DELETE',
      url: url,
      queryParameters: queryParameters,
      accessToken: accessToken,
    );
  }

  /// Handle Dio errors and convert to ApiException
  static Failure _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Failure(
          'Connection timeout. Please check your internet connection.',
        );

      case DioExceptionType.badResponse:
        String? message;
        final data = error.response?.data;

        if (data is Map<String, dynamic>) {
          if (data.containsKey('errors') && data['errors'] is Map) {
            final errors = data['errors'] as Map;
            final List<String> messages = [];
            for (final value in errors.values) {
              if (value is List && value.isNotEmpty) {
                messages.add(value.first.toString());
              } else if (value is String) {
                messages.add(value);
              }
            }
            if (messages.isNotEmpty) {
              message = messages.join('\n');
            }
          }
          message ??= data['message']?.toString();
        }
        message ??= error.response?.statusMessage ?? 'Server error';
        return Failure(message);

      case DioExceptionType.cancel:
        return Failure('Request cancelled');

      case DioExceptionType.connectionError:
        return Failure('No internet connection. Please check your network.');

      case DioExceptionType.badCertificate:
        return Failure('Invalid SSL certificate');

      case DioExceptionType.unknown:
        return Failure('Network error: ${error.message}');
      default:
        return Failure('Network error: ${error.message}');
    }
  }
}
