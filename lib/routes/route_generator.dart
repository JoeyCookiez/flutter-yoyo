import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/splash_screen.dart';
import 'app_routes.dart';

/// 路由生成器
/// 类似web的路由系统，集中管理所有路由和页面的对应关系
class RouteGenerator {
  /// 生成路由
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final String routeName = settings.name ?? AppRoutes.splash;
    final Object? arguments = settings.arguments;

    switch (routeName) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
          settings: settings,
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
          settings: settings,
        );

      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
          settings: settings,
        );

      // 默认路由（404页面）
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('页面未找到')),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('路由 "$routeName" 不存在'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(_).pushReplacementNamed(AppRoutes.home);
                    },
                    child: const Text('返回首页'),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }

  /// 路由守卫（可选，用于权限控制）
  static bool canAccess(String routeName) {
    // 这里可以实现权限检查逻辑
    // 例如：检查用户是否登录、是否有权限访问某个页面等
    
    // 示例：登录相关的路由不需要权限检查
    if ([AppRoutes.login, AppRoutes.register, AppRoutes.forgotPassword].contains(routeName)) {
      return true;
    }

    // 其他路由需要登录
    // final isLoggedIn = AuthService().isLoggedIn();
    // return isLoggedIn;

    return true; // 暂时全部允许访问
  }
}

















