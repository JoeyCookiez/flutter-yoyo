import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/environment.dart';
import '../services/storage_service.dart';

/// HTTP响应结果封装（与后端 ApiResponse 保持一致：code / message / data / timestamp）
class ApiResponse<T> {
  /// 业务状态码：200 表示成功，其它表示失败
  final int code;

  /// 提示信息
  final String message;

  /// 业务数据
  final T? data;

  /// 接口返回的时间戳（如果后端有返回）
  final int? timestamp;

  /// HTTP 状态码（可选，仅用于调试）
  final int? statusCode;

  const ApiResponse({
    required this.code,
    required this.message,
    this.data,
    this.timestamp,
    this.statusCode,
  });

  /// 判断业务是否成功（与后端约定：code == 200 即成功）
  bool get isSuccess => code == 200;

  /// 构造一个业务成功的响应
  factory ApiResponse.success({
    required int code,
    required String message,
    T? data,
    int? timestamp,
    int? statusCode,
  }) {
    return ApiResponse(
      code: code,
      message: message,
      data: data,
      timestamp: timestamp,
      statusCode: statusCode,
    );
  }

  /// 构造一个业务失败的响应
  factory ApiResponse.error({
    required int code,
    required String message,
    T? data,
    int? timestamp,
    int? statusCode,
  }) {
    return ApiResponse(
      code: code,
      message: message,
      data: data,
      timestamp: timestamp,
      statusCode: statusCode,
    );
  }
}

/// HTTP客户端封装
class HttpClient {
  static final HttpClient _instance = HttpClient._internal();
  factory HttpClient() => _instance;
  HttpClient._internal();

  // 基础URL
  String get baseUrl => AppConfig.apiBaseUrl+'/api';

  // 获取请求头
  Future<Map<String, String>> _getHeaders({Map<String, String>? extraHeaders}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // 从本地存储中获取 token，如果存在则添加到 Authorization header
    // 与桌面端保持一致：Authorization = token（不是 Bearer token）
    try {
      final token = await StorageService.instance.getToken();
      if (token != null && token.isNotEmpty) {
        // 先添加默认的 Authorization（如果 extraHeaders 中有，后面会覆盖）
        headers['Authorization'] = token;
      }
    } catch (e) {
      // 如果获取 token 失败，忽略错误，继续执行
      if (AppConfig.enableLogging) {
        print('获取 token 失败: $e');
      }
    }

    // 合并额外的 headers（如果 extraHeaders 中有 Authorization，会覆盖上面添加的）
    // 与桌面端逻辑一致：允许调用方覆盖默认的 Authorization
    if (extraHeaders != null) {
      headers.addAll(extraHeaders);
    }

    return headers;
  }

  /// GET请求
  Future<ApiResponse<T>> get<T>(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? parser,
  }) async {
    try {
      Uri uri = Uri.parse('$baseUrl$endpoint');
      if (queryParameters != null && queryParameters.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParameters);
      }

      if (AppConfig.enableLogging) {
        print('GET: $uri');
      }

      final response = await http.get(
        uri,
        headers: await _getHeaders(extraHeaders: headers),
      );

      return _handleResponse<T>(response, parser: parser);
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('GET Error: $e');
      }
      // 网络异常时约定使用 code = -1
      return ApiResponse.error(
        code: -1,
        message: '网络请求失败: $e',
      );
    }
  }

  /// POST请求
  /// 
  /// 支持两种参数传递方式：
  /// 1. queryParameters: 参数放在 URL query string 中（用于后端 @RequestParam/@NotEmpty 参数）
  /// 2. body: 参数放在 JSON body 中（用于后端 @RequestBody 参数）
  /// 
  /// 注意：如果 endpoint 已经包含 query string（包含 '?'），则不会发送 body
  /// 如果提供了 queryParameters，则不会发送 body
  Future<ApiResponse<T>> post<T>(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? parser,
  }) async {
    try {
      Uri uri = Uri.parse('$baseUrl$endpoint');
      
      // 如果 endpoint 已经包含 query string，或者提供了 queryParameters，则拼接到 URL 中
      final hasQueryInEndpoint = endpoint.contains('?');
      if (queryParameters != null && queryParameters.isNotEmpty) {
        // 如果 endpoint 已经有 query string，需要合并
        if (hasQueryInEndpoint) {
          final existingQuery = uri.queryParameters;
          existingQuery.addAll(queryParameters);
          uri = uri.replace(queryParameters: existingQuery);
        } else {
          uri = uri.replace(queryParameters: queryParameters);
        }
      }

      // 判断是否需要发送 body
      // 如果 endpoint 包含 '?' 或提供了 queryParameters，则不发送 body
      final shouldSendBody = !hasQueryInEndpoint && 
                             (queryParameters == null || queryParameters.isEmpty) &&
                             body != null;

      if (AppConfig.enableLogging) {
        print('POST: $uri');
        if (shouldSendBody) {
          print('Body: $body');
        } else if (queryParameters != null) {
          print('Query Parameters: $queryParameters');
        }
      }

      final response = await http.post(
        uri,
        headers: await _getHeaders(extraHeaders: headers),
        body: shouldSendBody ? jsonEncode(body) : null,
      );

      return _handleResponse<T>(response, parser: parser);
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('POST Error: $e');
      }
      return ApiResponse.error(
        code: -1,
        message: '网络请求失败: $e',
      );
    }
  }

  /// PUT请求
  Future<ApiResponse<T>> put<T>(
    String endpoint, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? parser,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      if (AppConfig.enableLogging) {
        print('PUT: $uri');
        print('Body: $body');
      }

      final response = await http.put(
        uri,
        headers: await _getHeaders(extraHeaders: headers),
        body: body != null ? jsonEncode(body) : null,
      );

      return _handleResponse<T>(response, parser: parser);
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('PUT Error: $e');
      }
      return ApiResponse.error(
        code: -1,
        message: '网络请求失败: $e',
      );
    }
  }

  /// DELETE请求
  Future<ApiResponse<T>> delete<T>(
    String endpoint, {
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? parser,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');

      if (AppConfig.enableLogging) {
        print('DELETE: $uri');
      }

      final response = await http.delete(
        uri,
        headers: await _getHeaders(extraHeaders: headers),
      );

      return _handleResponse<T>(response, parser: parser);
    } catch (e) {
      if (AppConfig.enableLogging) {
        print('DELETE Error: $e');
      }
      return ApiResponse.error(
        code: -1,
        message: '网络请求失败: $e',
      );
    }
  }

  /// 处理响应
  ApiResponse<T> _handleResponse<T>(
    http.Response response, {
    T Function(Map<String, dynamic>)? parser,
  }) {
    if (AppConfig.enableLogging) {
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${utf8.decode(response.body.runes.toList())}');
    }

    try {
      // 先解析为 JSON
      final dynamic raw = response.body.isNotEmpty
          ? jsonDecode(utf8.decode(response.body.runes.toList()))
          : null;

      if (raw is! Map<String, dynamic>) {
        // 返回格式异常时，构造一个失败的业务响应
        return ApiResponse.error(
          code: -1,
          message: '响应格式错误',
          statusCode: response.statusCode,
        );
      }

      final map = raw;
      final int code = (map['code'] ?? -1) as int;
      final String message = (map['message'] ?? '请求失败').toString();
      final int? timestamp =
          map['timestamp'] != null ? int.tryParse(map['timestamp'].toString()) : null;
      final dynamic dataJson = map['data'];

      if (code == 200) {
        // 业务成功，按需解析 data
        T? parsedData;
        if (parser != null && dataJson is Map<String, dynamic>) {
          parsedData = parser(dataJson);
        } else if (dataJson is T) {
          parsedData = dataJson;
        }

        return ApiResponse.success(
          code: code,
          message: message,
          data: parsedData,
          timestamp: timestamp,
          statusCode: response.statusCode,
        );
      } else {
        // 业务失败
        return ApiResponse.error(
          code: code,
          message: message,
          timestamp: timestamp,
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      // JSON 解析或其他异常
      return ApiResponse.error(
        code: -1,
        message: '响应解析失败: $e',
        statusCode: response.statusCode,
      );
    }
  }
}









