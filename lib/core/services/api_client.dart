import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../exceptions/app_exception.dart';
import 'token_storage.dart';

class ApiClient {
  static ApiClient? _instance;
  late final Dio _dio;
  late final TokenStorage _tokenStorage;

  ApiClient._();

  static Future<ApiClient> getInstance() async {
    if (_instance == null) {
      _instance = ApiClient._();
      _instance!._tokenStorage = await TokenStorage.getInstance();
      _instance!._dio = Dio(BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.connectTimeout,
        receiveTimeout: AppConfig.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ));
      _instance!._dio.interceptors.add(_instance!._authInterceptor());
    }
    return _instance!;
  }

  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = _tokenStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          handler.reject(DioException(
            requestOptions: error.requestOptions,
            error: const UnauthorizedException(),
            type: DioExceptionType.badResponse,
            response: error.response,
          ));
          return;
        }
        handler.next(error);
      },
    );
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.post(path, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.patch(path, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Map<String, dynamic>> delete(String path) async {
    try {
      final response = await _dio.delete(path);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  AppException _mapError(DioException e) {
    if (e.error is AppException) return e.error as AppException;
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const NetworkException();
    }
    final statusCode = e.response?.statusCode;
    final message = (e.response?.data as Map<String, dynamic>?)?['message']
            as String? ??
        e.message ??
        '오류가 발생했습니다.';
    return AppException(message, statusCode: statusCode);
  }
}
