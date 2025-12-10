/// 环境配置管理
/// 用于区分开发环境和生产环境
enum Environment {
  development, // 开发环境
  production,  // 生产环境
}

class AppConfig {
  static Environment _environment = Environment.development;
  
  // 获取当前环境
  static Environment get environment => _environment;
  
  // 设置环境（通常在main.dart中调用）
  static void setEnvironment(Environment env) {
    _environment = env;
  }
  
  // 根据环境获取API基础URL
  static String get apiBaseUrl {
    switch (_environment) {
      case Environment.development:
        return 'http://114.66.38.139:9092';
      case Environment.production:
        return 'https://api.yourdomain.com';
    }
  }
  
  // 根据环境获取文件服务器URL
  static String get fileBaseUrl {
    switch (_environment) {
      case Environment.development:
        return 'http://114.66.38.139:9092/file';
      case Environment.production:
        return 'https://files.yourdomain.com';
    }
  }

  /// 根据信令环境获取 WebSocket 基础 URL
  /// 注意：这里的具体地址需要你根据桌面端 `ipc.js` 中的 `wsUrl` 填写
  /// 例如：ws://114.66.38.139:9093/ws?token=
  static String get wsBaseUrl {
    switch (_environment) {
      case Environment.development:
        return 'ws://114.66.38.139:6061/ws?token='; // TODO: 按实际信令地址修改
      case Environment.production:
        return 'wss://signal.yourdomain.com/ws?token='; // TODO: 按线上地址修改
    }
  }
  
  // 是否开启调试模式
  static bool get isDebugMode => _environment == Environment.development;
  
  // 是否开启日志
  static bool get enableLogging => _environment == Environment.development;
}









