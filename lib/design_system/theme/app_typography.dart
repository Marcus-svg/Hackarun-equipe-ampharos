import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppTypography {
  static const TextStyle h1 = TextStyle(
    fontSize: 30,
    height: 1.15,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 22,
    height: 1.2,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle labelGold = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    letterSpacing: 1.3,
    color: AppColors.goldText,
  );

  static const TextStyle body = TextStyle(
    fontSize: 13,
    height: 1.4,
    color: AppColors.textSecondary,
  );
}
