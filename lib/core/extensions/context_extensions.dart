import 'package:flutter/material.dart';

extension ContextExtensions on BuildContext {
  Color get scaffoldBackgroundColor => Theme.of(this).scaffoldBackgroundColor;
  Color get cardColor => Theme.of(this).cardColor;
  Color get primaryColor => Theme.of(this).primaryColor;

  Color get textPrimaryColor =>
      Theme.of(this).textTheme.bodyLarge?.color ?? Colors.black;
  Color get textSecondaryColor =>
      Theme.of(this).textTheme.bodyMedium?.color ?? Colors.black87;
  Color get textTertiaryColor =>
      Theme.of(this).textTheme.bodySmall?.color ?? Colors.grey;

  Color get iconColor => Theme.of(this).iconTheme.color ?? Colors.black;

  Color get fillColor =>
      Theme.of(this).inputDecorationTheme.fillColor ?? Colors.grey;

  Color get primaryGreen => const Color(0xFF3d4e3c);

  Color get black => Theme.of(this).textTheme.bodyLarge?.color ?? Colors.black;

  Color get white => Theme.of(this).cardColor;

  Color get grey => Theme.of(this).textTheme.bodySmall?.color ?? Colors.grey;

  Color get dividerColor => Theme.of(this).dividerColor;

  Color get blackWithOpacity => black.withOpacity(0.1);
  Color get whiteWithOpacity => white.withOpacity(0.1);
}
