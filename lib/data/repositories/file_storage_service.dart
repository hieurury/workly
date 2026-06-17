import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Service xử lý đọc/ghi dữ liệu JSON trên hệ thống file cục bộ.
/// Cấu trúc thư mục:
///   App Root/
///     data/
///       user.json
///       app/
///         app.json
///     public/
///       (uploaded images)
class FileStorageService {
  static FileStorageService? _instance;
  static FileStorageService get instance => _instance ??= FileStorageService._();
  FileStorageService._();

  String? _rootPath;

  /// Khởi tạo và lấy đường dẫn gốc của app
  Future<String> get rootPath async {
    if (_rootPath != null) return _rootPath!;
    final dir = await getApplicationDocumentsDirectory();
    _rootPath = '${dir.path}/workly';
    return _rootPath!;
  }

  // ============================================================
  // PATH HELPERS
  // ============================================================

  Future<String> get dataDir async => '${await rootPath}/data';
  Future<String> get appDir async => '${await dataDir}/app';
  Future<String> get publicDir async => '${await rootPath}/public';
  Future<String> get userJsonPath async => '${await dataDir}/user.json';
  Future<String> get appJsonPath async => '${await appDir}/app.json';

  // ============================================================
  // INITIALIZATION
  // ============================================================

  /// Tạo cấu trúc thư mục nếu chưa tồn tại
  Future<void> initialize() async {
    final root = await rootPath;
    await Directory('$root/data/app').create(recursive: true);
    await Directory('$root/public').create(recursive: true);
  }

  // ============================================================
  // USER DATA
  // ============================================================

  /// Đọc dữ liệu user từ user.json, trả về null nếu chưa tồn tại
  Future<Map<String, dynamic>?> readUser() async {
    try {
      final path = await userJsonPath;
      final file = File(path);
      if (!await file.exists()) return null;
      final content = await file.readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Ghi dữ liệu user vào user.json
  Future<void> writeUser(Map<String, dynamic> data) async {
    final path = await userJsonPath;
    final file = File(path);
    await file.writeAsString(jsonEncode(data), flush: true);
  }

  /// Kiểm tra đã có user.json chưa (để biết onboarding đã hoàn thành chưa)
  Future<bool> hasUser() async {
    final path = await userJsonPath;
    return File(path).exists();
  }

  // ============================================================
  // APP DATA (works + streak)
  // ============================================================

  /// Đọc dữ liệu app từ app.json
  Future<Map<String, dynamic>?> readApp() async {
    try {
      final path = await appJsonPath;
      final file = File(path);
      if (!await file.exists()) return null;
      final content = await file.readAsString();
      return jsonDecode(content) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Ghi dữ liệu app vào app.json
  Future<void> writeApp(Map<String, dynamic> data) async {
    final path = await appJsonPath;
    final file = File(path);
    await file.writeAsString(jsonEncode(data), flush: true);
  }

  /// Kiểm tra đã có app.json chưa
  Future<bool> hasAppData() async {
    final path = await appJsonPath;
    return File(path).exists();
  }

  // ============================================================
  // IMAGE / PUBLIC FILES
  // ============================================================

  /// Lưu file ảnh vào /public với tên file mới
  /// Trả về path tương đối từ root (để lưu vào JSON)
  Future<String> saveImage(String sourcePath, String fileName) async {
    final pubDir = await publicDir;
    final destPath = '$pubDir/$fileName';
    await File(sourcePath).copy(destPath);
    return 'public/$fileName';
  }

  /// Lấy đường dẫn đầy đủ từ đường dẫn tương đối
  Future<String> getFullPath(String relativePath) async {
    final root = await rootPath;
    return '$root/$relativePath';
  }

  /// Xoá file ảnh khỏi /public
  Future<void> deleteImage(String relativePath) async {
    try {
      final fullPath = await getFullPath(relativePath);
      final file = File(fullPath);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  // ============================================================
  // UTILITY
  // ============================================================

  /// Lấy toàn bộ kích thước folder data (bytes)
  Future<int> getDataSize() async {
    try {
      final dir = Directory(await dataDir);
      int size = 0;
      await for (final entity in dir.list(recursive: true)) {
        if (entity is File) {
          size += await entity.length();
        }
      }
      return size;
    } catch (_) {
      return 0;
    }
  }
}
