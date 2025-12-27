import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// 本地存储服务
/// 用于持久化用户信息、token等数据
class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  static const String _keyUserInfo = 'user_info';
  static const String _keyToken = 'token';

  /// 保存用户信息
  Future<bool> saveUserInfo(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson());
      await prefs.setString(_keyUserInfo, userJson);
      // 同时单独保存token，方便快速访问
      if (user.token != null) {
        await prefs.setString(_keyToken, user.token!);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 获取用户信息
  Future<UserModel?> getUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_keyUserInfo);
      if (userJson == null) return null;
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userMap);
    } catch (e) {
      return null;
    }
  }

  /// 获取token（快速访问）
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_keyToken);
    } catch (e) {
      return null;
    }
  }

  /// 检查是否已登录（是否有token）
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// 清除用户信息（退出登录时调用）
  Future<bool> clearUserInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUserInfo);
      await prefs.remove(_keyToken);
      return true;
    } catch (e) {
      return false;
    }
  }
}









