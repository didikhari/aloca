import 'package:flutter/material.dart';

/// Centralized Design System Corner Radii Tokens for Aloca
class AppRadius {
  AppRadius._();

  static const double handle = 2.0;
  static const double sm = 6.0;
  static const double md = 10.0;
  static const double lg = 12.0;
  static const double card = 16.0;
  static const double sheet = 20.0;

  static const BorderRadius radiusSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius radiusMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius radiusLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius radiusCard =
      BorderRadius.all(Radius.circular(card));
  static const BorderRadius radiusSheet =
      BorderRadius.vertical(top: Radius.circular(sheet));
}
