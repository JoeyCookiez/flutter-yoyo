import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/signal_service.dart';

/// 我的页面（个人中心）
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 用户信息卡片
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue[300]!,
                    Colors.blue[500]!,
                  ],
                ),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '用户名',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'user@example.com',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('编辑资料功能待实现')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                    ),
                    child: const Text('编辑资料'),
                  ),
                ],
              ),
            ),
            // 功能列表
            _buildSection(
              context,
              title: '账户',
              items: [
                _MenuItem(
                  icon: Icons.account_circle,
                  title: '个人信息',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('个人信息功能待实现')),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.lock,
                  title: '账户安全',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('账户安全功能待实现')),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.payment,
                  title: '支付设置',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('支付设置功能待实现')),
                    );
                  },
                ),
              ],
            ),
            _buildSection(
              context,
              title: '通用',
              items: [
                _MenuItem(
                  icon: Icons.notifications,
                  title: '通知设置',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('通知设置功能待实现')),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.language,
                  title: '语言设置',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('语言设置功能待实现')),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.dark_mode,
                  title: '主题设置',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('主题设置功能待实现')),
                    );
                  },
                ),
              ],
            ),
            _buildSection(
              context,
              title: '其他',
              items: [
                _MenuItem(
                  icon: Icons.help,
                  title: '帮助中心',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('帮助中心功能待实现')),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.feedback,
                  title: '意见反馈',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('意见反馈功能待实现')),
                    );
                  },
                ),
                _MenuItem(
                  icon: Icons.info,
                  title: '关于我们',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'YOYO',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(Icons.apps, size: 48),
                    );
                  },
                ),
              ],
            ),
            // 退出登录按钮
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    '退出登录',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<_MenuItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        ...items.map((item) => ListTile(
              leading: Icon(item.icon, color: Colors.blue),
              title: Text(item.title),
              trailing: const Icon(Icons.chevron_right),
              onTap: item.onTap,
            )),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('退出登录'),
        content: const Text('确定要退出登录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // 先关闭对话框

              // 调用后端退出登录
              final res = await AuthService().logout();
              print('logout json: ${res}');
              // 清理本地存储的用户信息和 token
              await StorageService.instance.clearUserInfo();
              // 断开信令连接
              await SignalService.instance.disconnect();
              // 跳转到登录页（清空路由栈，避免回退）
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (route) => false,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      res.isSuccess
                          ? '已退出登录'
                          : (res.message.isNotEmpty ? res.message : '退出登录失败'),
                    ),
                  ),
                );
              }
            },
            child: const Text(
              '确定',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _MenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}










