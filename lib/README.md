# Flutter 项目结构说明

## 📁 标准项目目录结构

```
lib/
├── main.dart                 # 应用入口文件
├── config/                   # 配置文件
│   └── environment.dart      # 环境配置（开发/生产环境）
├── models/                   # 数据模型
│   └── user_model.dart       # 用户模型示例
├── services/                 # 业务服务层
│   └── auth_service.dart     # 认证服务示例
├── screens/                  # 页面/屏幕
│   ├── splash_screen.dart    # 启动页
│   ├── login_screen.dart     # 登录页
│   └── home_screen.dart      # 首页
├── routes/                   # 路由管理
│   ├── app_routes.dart       # 路由常量定义
│   └── route_generator.dart  # 路由生成器
└── utils/                    # 工具类
    └── http_client.dart      # HTTP客户端封装
```

## 🔧 各目录说明

### 1. config/ - 配置管理
- **environment.dart**: 管理开发环境和生产环境的配置
- 通过 `AppConfig.setEnvironment()` 切换环境
- 自动根据环境返回不同的API地址、文件服务器地址等

### 2. models/ - 数据模型
- 定义应用的数据结构
- 包含 `fromJson` 和 `toJson` 方法用于序列化/反序列化
- 示例：`UserModel`

### 3. services/ - 业务服务层
- 封装业务逻辑
- 调用 `HttpClient` 进行网络请求
- 处理业务数据转换
- 示例：`AuthService`（登录、注册等）

### 4. screens/ - 页面
- 所有UI页面放在这里
- 每个页面一个文件
- 页面只负责UI展示和用户交互

### 5. routes/ - 路由管理
- **app_routes.dart**: 定义所有路由名称常量（类似web的路由路径）
- **route_generator.dart**: 路由生成器，建立路由名称和页面的对应关系
- 支持路由守卫、参数传递等功能

### 6. utils/ - 工具类
- 通用工具函数和类
- HTTP客户端封装
- 其他通用工具

## 🌍 环境配置

### 开发环境 vs 生产环境

在 `main.dart` 中设置环境：

```dart
// 开发环境
AppConfig.setEnvironment(Environment.development);

// 生产环境
AppConfig.setEnvironment(Environment.production);
```

### 环境切换方式

1. **代码中切换**（当前方式）
   ```dart
   AppConfig.setEnvironment(Environment.development);
   ```

2. **编译时参数**（推荐）
   ```bash
   # 开发环境
   flutter run --dart-define=ENV=development
   
   # 生产环境
   flutter run --dart-define=ENV=production
   ```

3. **配置文件**（高级）
   - 使用 `flutter_dotenv` 包
   - 创建 `.env.development` 和 `.env.production` 文件

## 🌐 网络请求封装

### HttpClient 使用示例

```dart
final httpClient = HttpClient();

// GET请求
final response = await httpClient.get<Map<String, dynamic>>(
  '/api/users',
  queryParameters: {'page': '1'},
  parser: (json) => json, // 可选的数据解析器
);

// POST请求
final response = await httpClient.post<Map<String, dynamic>>(
  '/api/login',
  body: {
    'email': 'user@example.com',
    'password': 'password123',
  },
);
```

### 特性
- ✅ 统一的错误处理
- ✅ 自动添加请求头
- ✅ 支持Token认证（可扩展）
- ✅ 环境相关的API地址
- ✅ 日志记录（开发环境）

## 🛣️ 路由管理

### 路由定义（app_routes.dart）

```dart
class AppRoutes {
  static const String login = '/login';
  static const String home = '/home';
  // ...
}
```

### 路由使用

```dart
// 导航到登录页
Navigator.pushNamed(context, AppRoutes.login);

// 带参数导航
Navigator.pushNamed(
  context,
  AppRoutes.profile,
  arguments: {'userId': '123'},
);

// 替换当前路由
Navigator.pushReplacementNamed(context, AppRoutes.home);
```

### 路由和页面的对应关系

在 `route_generator.dart` 中定义：

```dart
switch (routeName) {
  case AppRoutes.login:
    return MaterialPageRoute(
      builder: (_) => const LoginScreen(),
    );
  // ...
}
```

**类似web的路由系统**：
- ✅ 路由名称常量化
- ✅ 集中管理路由映射
- ✅ 支持路由守卫
- ✅ 支持404页面
- ✅ 支持参数传递

## 📝 最佳实践

1. **分层架构**
   - UI层（screens/）：只负责展示
   - 业务层（services/）：处理业务逻辑
   - 数据层（models/）：定义数据结构
   - 工具层（utils/）：通用工具

2. **单一职责原则**
   - 每个文件只做一件事
   - 服务类只处理业务逻辑
   - 模型类只定义数据结构

3. **依赖注入**
   - 使用单例模式（如 `HttpClient`、`AuthService`）
   - 便于测试和维护

4. **错误处理**
   - 统一的错误处理机制
   - 用户友好的错误提示

5. **代码复用**
   - 公共组件提取到 `widgets/` 目录
   - 公共工具函数提取到 `utils/` 目录

## 🚀 扩展建议

### 可以添加的目录

- `widgets/` - 可复用的Widget组件
- `constants/` - 常量定义
- `providers/` - 状态管理（如Provider、Riverpod）
- `repositories/` - 数据仓库层
- `local_storage/` - 本地存储服务
- `theme/` - 主题配置


















