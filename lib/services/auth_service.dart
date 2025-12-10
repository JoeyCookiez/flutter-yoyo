import '../models/user_model.dart';
import '../utils/http_client.dart';

/// 认证服务
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final HttpClient _httpClient = HttpClient();
  final String prefix = "/api/userInfo";
  /// 登录
  /// 注意：后端接口使用 @NotEmpty 参数（非 @RequestBody），需要将参数放在 URL query string 中
  Future<ApiResponse<UserModel>> login({
    required String email,
    required String password,
  }) async {
    final response = await _httpClient.post<UserModel>(
      '/userInfo/login',
      queryParameters: {
        'email': email,
        'password': password,
      },
      parser: (json) => UserModel.fromJson(json),
    );

    // 直接返回 HTTP 客户端已经解析好的业务响应
    return response;
  }

  /// 注册
  /// 注意：后端接口使用 @NotEmpty 参数（非 @RequestBody），需要将参数放在 URL query string 中
  /// 注意：注册接口还需要 checkCodeKey 和 checkCode 参数（验证码相关）
  Future<ApiResponse<UserModel>> register({
    required String email,
    required String password,
    String? name,
    String? checkCodeKey,
    String? checkCode,
  }) async {
    final queryParams = <String, String>{
      'email': email,
      'password': password,
      if (name != null) 'nickName': name,
      if (checkCodeKey != null) 'checkCodeKey': checkCodeKey,
      if (checkCode != null) 'checkCode': checkCode,
    };
    
    final response = await _httpClient.post<UserModel>(
      '/userInfo/register',
      queryParameters: queryParams,
      parser: (json) => UserModel.fromJson(json),
    );

    return response;
  }

  /// 退出登录
  Future<ApiResponse<void>> logout() async {
    final response = await _httpClient.get<void>(
      '/userInfo/logout',
    );

    return response;
  }
}









