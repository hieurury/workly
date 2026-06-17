/// Danh sách 10 icon được phép chọn cho công việc
/// Key = tên icon (lưu vào JSON), Value = IconData thực tế
class AppIcons {
  AppIcons._();

  static const Map<String, String> workIconNames = {
    'work': 'work',
    'store': 'store',
    'cafe': 'local_cafe',
    'school': 'school',
    'computer': 'computer',
    'favorite': 'favorite',
    'car': 'directions_car',
    'fitness': 'fitness_center',
    'brush': 'brush',
    'music': 'music_note',
  };

  static const List<String> allWorkIconKeys = [
    'work',
    'store',
    'cafe',
    'school',
    'computer',
    'favorite',
    'car',
    'fitness',
    'brush',
    'music',
  ];
}
