import 'package:flutter/material.dart';

/// 通用的设置项 Cell，左侧为标题，右侧可插槽任意内容。
class YoCell extends StatelessWidget {
  final double leftWidth;
  final Color background;
  final Widget rightSlot;
  final String title;
  final double? height;
  final EdgeInsetsGeometry padding;
  final TextStyle? titleStyle;

  const YoCell({
    super.key,
    this.title = '',
    this.leftWidth = 100,
    this.background = const Color(0xFFFFFFFF),
    this.rightSlot = const SizedBox.shrink(),
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    final defaultTitleStyle = titleStyle ??
        const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1F1F1F),
        );

    return Container(
      height: height,
      width: double.infinity,
      color: background,
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: leftWidth,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(title, style: defaultTitleStyle),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: rightSlot,
            ),
          ),
        ],
      ),
    );
  }
}