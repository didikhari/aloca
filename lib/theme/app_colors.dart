import 'package:flutter/material.dart';

/// Centralized Design System Color Tokens for Aloca
class AppColors {
  AppColors._();

  // Brand Colors
  static const Color brandPrimary = Color(0xFF00A884);
  static const Color brandDark = Color(0xFF008B74);
  static const Color brandTint = Color(0x1A00A884);

  // Backgrounds & Surfaces
  static const Color pageBackground = Color(0xFFF8FAFC);
  static const Color surfaceWhite = Colors.white;
  static const Color cardSubSurface = Color(0xFFF8FAFC);
  static const Color inputFill = Color(0xFFF8FAFC);
  static const Color chipSubSurface = Color(0xFFF1F5F9);
  static const Color dividerBorder = Color(0xFFE2E8F0);

  // Text Hierarchy
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color textInverse = Colors.white;

  // Semantic Feedback: Expense / Error
  static const Color expenseRed = Color(0xFFEF4444);
  static const Color expenseRedDark = Color(0xFFDC2626);
  static const Color expenseBgLight = Color(0xFFFEF2F2);
  static const Color statusOverBudgetBg = Color(0xFFFCE8E6);
  static const Color statusOverBudgetFg = Color(0xFFC5221F);

  // Semantic Feedback: Income / Success
  static const Color incomeGreen = Color(0xFF10B981);
  static const Color successBgLight = Color(0xFFDCFCE7);
  static const Color paidTileBg = Color(0xFFF0FDF4);
  static const Color statusUnderBudgetBg = Color(0xFFE6F4EA);
  static const Color statusUnderBudgetFg = Color(0xFF137333);

  // Semantic Feedback: Warning / Overrun
  static const Color warningAmber = Color(0xFFF59E0B);
  static const Color warningAmberDark = Color(0xFFD97706);
  static const Color warningBgLight = Color(0xFFFFFBEB);
  static const Color warningBadgeBg = Color(0xFFFEF3C7);

  // Semantic Feedback: Info / Allocation
  static const Color infoBlue = Color(0xFF3B82F6);
  static const Color infoBlueDark = Color(0xFF2563EB);
  static const Color infoBgLight = Color(0xFFEFF6FF);
  static const Color statusOnBudgetBg = Color(0xFFE8F0FE);
  static const Color statusOnBudgetFg = Color(0xFF1A73E8);

  // Shadow Token
  static Color get cardShadow => Colors.black.withOpacity(0.04);
}
