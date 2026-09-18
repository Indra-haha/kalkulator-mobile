import 'package:flutter/material.dart';

import 'app_theme.dart';

class QuizStatus {
  QuizStatus._();

  static const all = ['waiting', 'open', 'in-Game', 'ended', 'quarantine'];

  static String labelOf(String status) {
    if (status.isEmpty) return status;
    return '${status[0].toUpperCase()}${status.substring(1)}';
  }

  static Color dotColor(String status) {
    switch (status) {
      case 'waiting':
        return AppColors.brandDeep;
      case 'open':
        return AppColors.warning;
      case 'in-Game':
        return AppColors.success;
      case 'ended':
        return AppColors.neutral;
      default:
        return AppColors.brandDeep;
    }
  }
}
