import 'package:flutter/material.dart';
import 'meeting_screen.dart';
import 'contacts_screen.dart';
import 'profile_screen.dart';

/// 主页面（包含底部TabBar）
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // 三个页面
  final List<Widget> _pages = [
    const MeetingScreen(),
    const ContactsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed, // 固定显示所有标签
        selectedItemColor: Colors.blue, // 选中颜色
        unselectedItemColor: Colors.grey, // 未选中颜色
        selectedFontSize: 14,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.video_call),
            activeIcon: Icon(Icons.video_call),
            label: '会议',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contacts),
            activeIcon: Icon(Icons.contacts),
            label: '通讯录',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            activeIcon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      ),
    );
  }
}

