import 'package:flutter/material.dart';

/// Centralized Design System Spacing Tokens for Aloca
class AppSpacing {
  AppSpacing._();

  static const double xxs = 2.0;
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;

  // Normalized Standard Screen & Card Margins
  static const EdgeInsets screenPadding = EdgeInsets.all(lg);
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets cardPaddingCompact = EdgeInsets.all(md);
  static const EdgeInsets modalPadding =
      EdgeInsets.only(top: lg, left: xl, right: xl, bottom: xl);

  // Normalized CTA Button Height
  static const double buttonHeight = 48.0;
}
