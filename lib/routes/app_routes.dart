/// 路由名称常量
/// 类似web的路由系统，定义所有路由路径
class AppRoutes {
  // 路由名称常量
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String settings = '/settings';

  // 路由映射表（可选，用于路由守卫或权限控制）
  static final Map<String, String> routeMap = {
    splash: '启动页',
    login: '登录页',
    register: '注册页',
    forgotPassword: '忘记密码',
    home: '首页',
    profile: '个人中心',
    settings: '设置',
  };

  /// 获取路由名称（用于显示）
  static String? getRouteName(String route) {
    return routeMap[route];
  }
}
















