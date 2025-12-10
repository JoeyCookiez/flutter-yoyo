import 'package:flutter/material.dart';
import 'config/environment.dart';
import 'routes/app_routes.dart';
import 'routes/route_generator.dart';

void main() {
  // 设置环境（开发环境或生产环境）
  // 可以通过编译时参数或配置文件来切换
  // 例如：flutter run --dart-define=ENV=production
  AppConfig.setEnvironment(Environment.development);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YOYO Flutter Application',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // 隐藏右上角的 debug banner（生产环境）
      debugShowCheckedModeBanner: AppConfig.isDebugMode,
      // 使用路由生成器，类似web的路由系统
      initialRoute: AppRoutes.splash,
      onGenerateRoute: RouteGenerator.generateRoute,
      // 路由未找到时的处理
      onUnknownRoute: (settings) {
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            appBar: AppBar(title: const Text('页面未找到')),
            body: Center(
              child: Text('路由 "${settings.name}" 不存在'),
            ),
          ),
        );
      },
    );
  }
}
