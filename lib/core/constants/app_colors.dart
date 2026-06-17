import 'package:flutter/material.dart';

/// Bảng màu chủ đạo của Workly
/// Màu sắc theo phong cách đen-trắng-xám hiện đại
class AppColors {
  AppColors._();

  // === PRIMARY PALETTE (Light) ===
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF7F7F7);
  static const Color surfaceVariantLight = Color(0xFFEEEEEE);
  static const Color borderLight = Color(0xFFE0E0E0);

  static const Color textPrimaryLight = Color(0xFF0A0A0A);
  static const Color textSecondaryLight = Color(0xFF5A5A5A);
  static const Color textTertiaryLight = Color(0xFF9E9E9E);

  // === PRIMARY PALETTE (Dark) ===
  static const Color backgroundDark = Color(0xFF0A0A0A);
  static const Color surfaceDark = Color(0xFF161616);
  static const Color surfaceVariantDark = Color(0xFF1F1F1F);
  static const Color borderDark = Color(0xFF2A2A2A);

  static const Color textPrimaryDark = Color(0xFFF5F5F5);
  static const Color textSecondaryDark = Color(0xFFAAAAAA);
  static const Color textTertiaryDark = Color(0xFF6A6A6A);

  // === SEMANTIC COLORS ===
  static const Color success = Color(0xFF22C55E);
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);

  // === ACCENT ===
  static const Color accent = Color(0xFF1A1A1A);
  static const Color accentDark = Color(0xFFF0F0F0);

  // === WORK COLORS (10 màu cho công việc) ===
  static const Map<String, Color> workColors = {
    'orange': Color(0xFFFF6B35),
    'blue': Color(0xFF3B82F6),
    'green': Color(0xFF22C55E),
    'purple': Color(0xFF8B5CF6),
    'red': Color(0xFFEF4444),
    'teal': Color(0xFF14B8A6),
    'pink': Color(0xFFEC4899),
    'amber': Color(0xFFF59E0B),
    'indigo': Color(0xFF6366F1),
    'cyan': Color(0xFF06B6D4),
  };

  static Color getWorkColor(String colorName) {
    return workColors[colorName] ?? workColors['orange']!;
  }

  static Color getWorkColorLight(String colorName) {
    final base = getWorkColor(colorName);
    return base.withOpacity(0.12);
  }

  // === SHADOW ===
  static List<BoxShadow> cardShadowLight = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> cardShadowDark = [
    BoxShadow(
      color: Colors.black.withOpacity(0.3),
      blurRadius: 12,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> elevatedShadowLight = [
    BoxShadow(
      color: Colors.black.withOpacity(0.10),
      blurRadius: 24,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> elevatedShadowDark = [
    BoxShadow(
      color: Colors.black.withOpacity(0.5),
      blurRadius: 24,
      offset: const Offset(0, 4),
    ),
  ];
}
