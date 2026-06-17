import 'package:flutter/material.dart';
import '../constants/app_icons.dart';

/// Helper widget để hiển thị icon công việc từ tên icon dạng string
class WorkIcon extends StatelessWidget {
  final String iconName;
  final double size;
  final Color? color;

  const WorkIcon({
    super.key,
    required this.iconName,
    this.size = 24,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      _getIconData(iconName),
      size: size,
      color: color,
    );
  }

  static IconData _getIconData(String name) {
    switch (name) {
      case 'work':
        return Icons.work_rounded;
      case 'store':
        return Icons.store_rounded;
      case 'cafe':
        return Icons.local_cafe_rounded;
      case 'school':
        return Icons.school_rounded;
      case 'computer':
        return Icons.computer_rounded;
      case 'favorite':
        return Icons.favorite_rounded;
      case 'car':
        return Icons.directions_car_rounded;
      case 'fitness':
        return Icons.fitness_center_rounded;
      case 'brush':
        return Icons.brush_rounded;
      case 'music':
        return Icons.music_note_rounded;
      default:
        return Icons.work_rounded;
    }
  }

  /// Lấy IconData từ tên icon
  static IconData fromName(String name) => _getIconData(name);

  /// Lấy tất cả icon với label hiển thị
  static Map<String, IconData> get allIcons => {
    for (final key in AppIcons.allWorkIconKeys)
      key: _getIconData(key),
  };
}
