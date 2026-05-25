import 'package:flutter/material.dart';

/// Кофейная палитра Grind & Go.
abstract final class AppColors {
  // Основной — насыщенный кофейный/коричневый
  static const coffee = Color(0xFF5C3D2E);
  static const coffeeDark = Color(0xFF3E2723);
  static const coffeeLight = Color(0xFF8D6E63);

  // Акцент — тёплый бежевый / карамель
  static const accent = Color(0xFFD4A574);
  static const accentLight = Color(0xFFE8C9A0);
  static const accentDark = Color(0xFFB8864E);

  // Фон — светлый, «молочный»
  static const background = Color(0xFFFAF6F1);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF0EBE3);

  // Текст
  static const textPrimary = Color(0xFF2C1810);
  static const textSecondary = Color(0xFF6B5B4F);
  static const textMuted = Color(0xFF9E8E82);
  static const textOnPrimary = Color(0xFFFFFFFF);
  static const textOnAccent = Color(0xFF2C1810);

  // Служебные
  static const error = Color(0xFFC0392B);
  static const success = Color(0xFF6B8E4E);
  static const divider = Color(0xFFE0D5C8);
}
