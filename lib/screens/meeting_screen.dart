import 'package:flutter/material.dart';
import 'package:flutter_yoyo/services/storage_service.dart';
import '../models/user_model.dart';
import 'meeting_join_screen.dart';

/// 会议页面
class MeetingScreen extends StatefulWidget {
  const MeetingScreen({super.key});

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  // 模拟用户信息
  String _userName = '张三';
  String _userAvatar = '张';
  final bool _isLoggedInWindows = true; // 是否登录Windows端

  // 模拟会议列表数据（包含进行中的会议和预定会议）
  final List<Map<String, dynamic>> _meetings = [
    {
      'title': '项目进度讨论会',
      'time': '今天 14:00',
      'participants': 5,
      'status': '进行中',
    },
    {
      'title': '产品需求评审',
      'time': '明天 10:00',
      'participants': 8,
      'status': '预定会议',
    },
    {
      'title': '技术方案分享',
      'time': '后天 15:30',
      'participants': 12,
      'status': '预定会议',
    },
    {
      'title': '周例会',
      'time': '今天 16:00',
      'participants': 10,
      'status': '进行中',
    },
  ];
  @override
  void initState(){
    super.initState();

    _initializeData();      // 初始化数据
    _setupControllers();    // 设置控制器
    _loadInitialData();    // 加载初始数据
  }
  void _initializeData() {
    print('初始化数据...');
  }
  
  void _setupControllers() {
    print('设置控制器...');
  }
  
  void _loadInitialData() async {
    // 异步加载数据
    final UserModel? data = await StorageService.instance.getUserInfo();
    print("userInfo ${data?.toJson()}");
    setState(() {
      // 更新状态（做空值兜底）
      _userName = data?.nickName ?? 'Yo友';
      _userAvatar = data?.avatar ?? '';
    });
  }
  @override
  Widget build(BuildContext context) {
    // 获取系统状态栏高度
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final theme = Theme.of(context);

    return Scaffold(
      body: Column(
        children: [
          // 顶部主题色填充（系统状态栏高度）
          Container(
            height: statusBarHeight,
            color: theme.primaryColor,
          ),
          // 主要内容区域
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 第一行：用户头像和昵称（水平布局）
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: theme.primaryColor,
                        child: _userAvatar.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  _userAvatar,
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) {
                                    final initial =
                                        _userName.isNotEmpty ? _userName[0] : '友';
                                    return Text(
                                      initial,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                              )
                            : Text(
                                _userName.isNotEmpty ? _userName[0] : '友',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _userName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 第二行：显示用户是否登录Windows端
                  Text(
                    _isLoggedInWindows
                        ? '已登录Windows端'
                        : '未登录Windows端',
                    style: TextStyle(
                      fontSize: 14,
                      color: _isLoggedInWindows
                          ? Colors.green
                          : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 第三行：四个功能按钮（水平布局）
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildFunctionButton(
                        icon: Icons.login,
                        label: '加入会议',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const MeetingJoinScreen(),
                            ),
                          );
                        },
                      ),
                      _buildFunctionButton(
                        icon: Icons.video_call,
                        label: '快速会议',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('快速会议功能待实现')),
                          );
                        },
                      ),
                      _buildFunctionButton(
                        icon: Icons.event,
                        label: '预定会议',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('预定会议功能待实现')),
                          );
                        },
                      ),
                      _buildFunctionButton(
                        icon: Icons.screen_share,
                        label: '共享屏幕',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('共享屏幕功能待实现')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // 会议列表标题
                  const Text(
                    '所有会议',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // 会议列表
                  Expanded(
                    child: _meetings.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.event_note,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  '暂无会议',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _meetings.length,
                            itemBuilder: (context, index) {
                              final meeting = _meetings[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: CircleAvatar(
                                    backgroundColor:
                                        _getStatusColor(meeting['status']),
                                    child: const Icon(
                                      Icons.video_call,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    meeting['title'],
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            meeting['time'],
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.people,
                                            size: 16,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${meeting['participants']} 人参与',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(meeting['status'])
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      meeting['status'],
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            _getStatusColor(meeting['status']),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('进入会议: ${meeting['title']}'),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建功能按钮（logo在上，文字在下）
  Widget _buildFunctionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 32,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case '进行中':
        return Colors.green;
      case '预定会议':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}



