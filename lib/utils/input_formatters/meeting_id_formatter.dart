import 'dart:math';

import 'package:flutter/services.dart';

/// 输入会议号时自动插入空格的格式化器（例如 123 456 789）。
class MeetingIdInputFormatter extends TextInputFormatter {
  MeetingIdInputFormatter({
    this.groupSize = 3,
    this.maxDigits = 9,
  });

  /// 每组展示的数字个数。
  final int groupSize;

  /// 最多允许输入的数字数量（不含空格）。
  final int maxDigits;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    final limitedDigits = digitsOnly.substring(
      0,
      min(digitsOnly.length, maxDigits),
    );

    final buffer = StringBuffer();
    for (var i = 0; i < limitedDigits.length; i++) {
      buffer.write(limitedDigits[i]);
      final isEndOfGroup = (i + 1) % groupSize == 0 && i + 1 != limitedDigits.length;
      if (isEndOfGroup) {
        buffer.write(' ');
      }
    }

    final formatted = buffer.toString();
    // 简化处理：始终保持光标在末尾，避免复杂的 selection 计算。
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}












