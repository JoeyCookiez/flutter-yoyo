import 'dart:async';

import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../services/storage_service.dart';
import '../services/signal_service.dart';
import '../config/environment.dart';

/// 启动页
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  _navigateToHome() async {
    // 模拟启动延迟
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      // 检查是否已登录（是否有token）
      final isLoggedIn = await StorageService.instance.isLoggedIn();
      
      if (isLoggedIn) {
        // 已登录，跳转到首页
        // 同时尝试连接信令服务器（从存储中获取token）
        SignalService.instance.wsBaseUrl = AppConfig.wsBaseUrl;
        unawaited(SignalService.instance.connectFromStorage());
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        // 未登录，跳转到登录页
        Navigator.pushReplacementNamed(context, AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFE1BEE7),
                  Color(0xFFBBDEFB),
                ],
              ).createShader(bounds),
              child: const Text(
                'YOYO',
                style: TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}










