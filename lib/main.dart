import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Application',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // 隐藏右上角的 debug banner
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // 表单控制器
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  // 加载状态
  bool _isLoading = false;
  
  // 头像URL
  String avatar = "http://114.66.38.139:9092/file/TimBoll.jpg";
  
  // 后端接口URL（请根据实际情况修改）
  final String apiUrl = "http://114.66.38.139:9092/api/login"; // 请修改为你的实际登录接口

  // 登录方法
  Future<void> _handleLogin() async {
    // 获取输入值
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    
    // 简单验证
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入邮箱和密码')),
      );
      return;
    }
    
    // 设置加载状态
    setState(() {
      _isLoading = true;
    });
    
    try {
      // 构建请求体
      Map<String, String> payload = {
        'email': email,
        'password': password,
      };
      
      // 发送POST请求
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );
      
      // 处理响应
      if (response.statusCode == 200) {
        // 登录成功
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('登录成功')),
        );
        // 这里可以导航到主页
        // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        // 登录失败
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('登录失败: ${response.body}')),
        );
      }
    } catch (e) {
      // 网络错误
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('网络错误: $e')),
      );
    } finally {
      // 重置加载状态
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        // SafeArea 会自动处理系统状态栏和底部导航栏的遮挡问题
        child: Padding(
          // 将整个 Column 向下移动 20 像素
          padding: const EdgeInsets.only(top: 20),
          child: SingleChildScrollView(
            // 使用 SingleChildScrollView 防止键盘弹出时内容被遮挡
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  // YOYO 渐变色文字
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFE1BEE7), // 淡紫色
                        Color(0xFFBBDEFB), // 淡蓝色
                      ],
                    ).createShader(bounds),
                    child: const Text(
                      'YOYO',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // 头像
                  ClipOval(
                    child: Image.network(
                      avatar,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const SizedBox(
                          width: 100,
                          height: 100,
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          "assets/images/avatar.png",
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // 邮箱输入框
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: '邮箱',
                      hintText: '请输入邮箱',
                      prefixIcon: const Icon(Icons.email),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 密码输入框
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: '密码',
                      hintText: '请输入密码',
                      prefixIcon: const Icon(Icons.lock),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // 登录按钮
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF87CEEB), // 天蓝色
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              '登录',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // 注册和忘记密码按钮（并列一行）
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // 注册按钮
                      TextButton(
                        onPressed: () {
                          // TODO: 导航到注册页面
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('注册功能待实现')),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Text(
                          '注册',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      
                      // 忘记密码按钮
                      TextButton(
                        onPressed: () {
                          // TODO: 导航到忘记密码页面
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('忘记密码功能待实现')),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Text(
                          '忘记密码',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
