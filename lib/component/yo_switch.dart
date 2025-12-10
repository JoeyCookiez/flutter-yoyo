import 'package:flutter/material.dart';

class YoSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final double width;
  final double height;
  final double gap;
  final Color activeColor;
  final Color inactiveColor;
  final Color thumbColor;
  final Duration duration;

  const YoSwitch({
    super.key,
    this.value = false,
    this.onChanged,
    this.width = 72.0*0.6,
    this.height = 42.0*0.6,
    this.gap = 2.0,
    this.activeColor = const Color(0xFF64B5F6),
    this.inactiveColor = const Color(0xFFE0E0E0),
    this.thumbColor = Colors.white,
    this.duration = const Duration(milliseconds: 100),
  });

  @override
  State<YoSwitch> createState() => _YoSwitchState();
}

class _YoSwitchState extends State<YoSwitch> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _positionAnimation;
  late Animation<Color?> _colorAnimation;
  
  // 添加内部状态跟踪
  bool _currentValue = false;

  @override
  void initState() {
    super.initState();
    
    // 初始化内部状态
    _currentValue = widget.value;
    
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    
    _positionAnimation = Tween<double>(
      begin: 0.0,
      end: widget.width -  widget.height+widget.gap,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _colorAnimation = ColorTween(
      begin: widget.inactiveColor,
      end: widget.activeColor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    // 根据初始值设置动画状态
    if (_currentValue) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(YoSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 只有当外部值真正改变时才更新
    if (widget.value != _currentValue) {
      _currentValue = widget.value;
      _updateAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    // 切换内部状态
    _currentValue = !_currentValue;
    
    // 执行动画
    _updateAnimation();
    
    // 通知父组件状态改变
    widget.onChanged?.call(_currentValue);
  }

  void _updateAnimation() {
    if (_currentValue) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              color: _colorAnimation.value,
              borderRadius: BorderRadius.circular(widget.height / 2),
            ),
            child: Stack(
              children: [
                // 圆形按钮
                Positioned(
                  left: _positionAnimation.value,
                  top: widget.gap,
                  child: Container(
                    width: widget.height - widget.gap * 2,
                    height: widget.height - widget.gap * 2,
                    decoration: BoxDecoration(
                      color: widget.thumbColor,
                      borderRadius: BorderRadius.circular((widget.height - widget.gap * 2) / 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}