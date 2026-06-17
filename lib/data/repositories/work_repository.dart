/// work_repository.dart
///
/// Provides all data access operations for [WorkModel] and [AttendanceModel].
/// All work data is stored in a single `app.json` file managed by [FileStorageService].
///
/// JSON structure of app.json:
/// ```json
/// {
///   "downloadDate": "2026-01-01T00:00:00.000",
///   "works": [ { ...WorkModel... }, ... ]
/// }
/// ```

import '../models/attendance_model.dart';
import '../models/work_model.dart';
import 'file_storage_service.dart';

/// Repository responsible for persisting and retrieving all work and attendance data.
class WorkRepository {
  /// Singleton storage service used for all file I/O.
  final FileStorageService _storage = FileStorageService.instance;

  // ──────────────────────────────────────────────────────────────────────────
  // App-level data helpers (private)
  // ──────────────────────────────────────────────────────────────────────────

  /// Default structure for a fresh `app.json`.
  static Map<String, dynamic> _defaultAppData() => {
        'downloadDate': DateTime.now().toIso8601String(),
        'works': <dynamic>[],
      };

  /// Reads `app.json` and returns its contents as a [Map].
  ///
  /// If the file does not exist or is corrupt, returns the default structure
  /// so callers always receive a usable map.
  Future<Map<String, dynamic>> _readAppData() async {
    try {
      final data = await _storage.readApp();
      if (data == null) return _defaultAppData();
      return data;
    } catch (_) {
      return _defaultAppData();
    }
  }

  /// Serializes [data] and writes it to `app.json`.
  Future<void> _writeAppData(Map<String, dynamic> data) async {
    try {
      await _storage.writeApp(data);
    } catch (e) {
      throw Exception('Khong the ghi du lieu ung dung: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Initialization
  // ──────────────────────────────────────────────────────────────────────────

  /// Creates `app.json` with the default structure if it does not already
  /// exist. Safe to call multiple times (idempotent).
  Future<void> initializeApp() async {
    try {
      final exists = await _storage.hasAppData();
      if (!exists) {
        await _writeAppData(_defaultAppData());
      }
    } catch (e) {
      throw Exception('Khong the khoi tao du lieu ung dung: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Works CRUD
  // ──────────────────────────────────────────────────────────────────────────

  /// Returns all [WorkModel] entries stored in `app.json`.
  Future<List<WorkModel>> getWorks() async {
    try {
      final appData = await _readAppData();
      final rawList = appData['works'] as List<dynamic>? ?? [];
      return rawList
          .map((e) => WorkModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Khong the tai danh sach cong viec: $e');
    }
  }

  /// Returns the [WorkModel] with the given [id], or `null` if not found.
  Future<WorkModel?> getWorkById(String id) async {
    try {
      final works = await getWorks();
      return works.where((w) => w.id == id).firstOrNull;
    } catch (_) {
      return null;
    }
  }

  /// Adds a new [WorkModel] or updates an existing one (matched by [WorkModel.id]).
  ///
  /// If a work with the same id already exists it is replaced in-place;
  /// otherwise [work] is appended to the list.
  Future<void> saveWork(WorkModel work) async {
    try {
      final appData = await _readAppData();
      final rawList = List<dynamic>.from(appData['works'] as List? ?? []);

      final idx = rawList.indexWhere(
        (e) => (e as Map<String, dynamic>)['id'] == work.id,
      );

      if (idx >= 0) {
        rawList[idx] = work.toJson();
      } else {
        rawList.add(work.toJson());
      }

      appData['works'] = rawList;
      await _writeAppData(appData);
    } catch (e) {
      throw Exception('Khong the luu cong viec: $e');
    }
  }

  /// Removes the work with the given [workId] (and all its attendance records)
  /// from `app.json`.
  ///
  /// No-ops silently if no work with that id is found.
  Future<void> deleteWork(String workId) async {
    try {
      final appData = await _readAppData();
      final rawList = List<dynamic>.from(appData['works'] as List? ?? []);

      rawList.removeWhere(
        (e) => (e as Map<String, dynamic>)['id'] == workId,
      );

      appData['works'] = rawList;
      await _writeAppData(appData);
    } catch (e) {
      throw Exception('Khong the xoa cong viec: $e');
    }
  }

  /// Sets [isMain] = `true` for the work identified by [workId] and
  /// [isMain] = `false` for all other works.
  ///
  /// Throws if no work with [workId] exists.
  Future<void> setMainWork(String workId) async {
    try {
      final appData = await _readAppData();
      final rawList = List<dynamic>.from(appData['works'] as List? ?? []);

      bool found = false;
      for (int i = 0; i < rawList.length; i++) {
        final entry = Map<String, dynamic>.from(
          rawList[i] as Map<String, dynamic>,
        );
        if (entry['id'] == workId) {
          entry['isMain'] = true;
          found = true;
        } else {
          entry['isMain'] = false;
        }
        rawList[i] = entry;
      }

      if (!found) {
        throw Exception('Khong tim thay cong viec voi id: $workId');
      }

      appData['works'] = rawList;
      await _writeAppData(appData);
    } catch (e) {
      throw Exception('Khong the dat cong viec chinh: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Attendance operations
  // ──────────────────────────────────────────────────────────────────────────

  /// Appends [attendance] to the attendance list of the work identified by
  /// [workId] and persists the change to `app.json`.
  ///
  /// If an attendance record with the same [AttendanceModel.id] already exists
  /// it will be updated instead of duplicated.
  Future<void> addAttendance(String workId, AttendanceModel attendance) async {
    try {
      final appData = await _readAppData();
      final rawList = List<dynamic>.from(appData['works'] as List? ?? []);

      final workIdx = rawList.indexWhere(
        (e) => (e as Map<String, dynamic>)['id'] == workId,
      );

      if (workIdx < 0) {
        throw Exception('Khong tim thay cong viec voi id: $workId');
      }

      final workMap = Map<String, dynamic>.from(
        rawList[workIdx] as Map<String, dynamic>,
      );
      final dataList = List<dynamic>.from(workMap['data'] as List? ?? []);

      // Guard against duplicate ids.
      final existingIdx = dataList.indexWhere(
        (e) => (e as Map<String, dynamic>)['id'] == attendance.id,
      );

      if (existingIdx >= 0) {
        dataList[existingIdx] = attendance.toJson();
      } else {
        dataList.add(attendance.toJson());
      }

      workMap['data'] = dataList;
      rawList[workIdx] = workMap;
      appData['works'] = rawList;
      await _writeAppData(appData);
    } catch (e) {
      throw Exception('Khong the them ban ghi cham cong: $e');
    }
  }

  /// Replaces the existing attendance record (matched by [AttendanceModel.id])
  /// in the specified work with the updated [attendance] object.
  ///
  /// Throws if the work or attendance record is not found.
  Future<void> updateAttendance(
    String workId,
    AttendanceModel attendance,
  ) async {
    try {
      final appData = await _readAppData();
      final rawList = List<dynamic>.from(appData['works'] as List? ?? []);

      final workIdx = rawList.indexWhere(
        (e) => (e as Map<String, dynamic>)['id'] == workId,
      );

      if (workIdx < 0) {
        throw Exception('Khong tim thay cong viec voi id: $workId');
      }

      final workMap = Map<String, dynamic>.from(
        rawList[workIdx] as Map<String, dynamic>,
      );
      final dataList = List<dynamic>.from(workMap['data'] as List? ?? []);

      final attIdx = dataList.indexWhere(
        (e) => (e as Map<String, dynamic>)['id'] == attendance.id,
      );

      if (attIdx < 0) {
        throw Exception('Khong tim thay ban ghi cham cong voi id: ${attendance.id}');
      }

      dataList[attIdx] = attendance.toJson();
      workMap['data'] = dataList;
      rawList[workIdx] = workMap;
      appData['works'] = rawList;
      await _writeAppData(appData);
    } catch (e) {
      throw Exception('Khong the cap nhat ban ghi cham cong: $e');
    }
  }

  /// Removes the attendance record identified by [attendanceId] from the
  /// specified work.
  ///
  /// No-ops silently if the attendance record is not found.
  Future<void> deleteAttendance(String workId, String attendanceId) async {
    try {
      final appData = await _readAppData();
      final rawList = List<dynamic>.from(appData['works'] as List? ?? []);

      final workIdx = rawList.indexWhere(
        (e) => (e as Map<String, dynamic>)['id'] == workId,
      );

      if (workIdx < 0) return; // Work not found — nothing to remove.

      final workMap = Map<String, dynamic>.from(
        rawList[workIdx] as Map<String, dynamic>,
      );
      final dataList = List<dynamic>.from(workMap['data'] as List? ?? []);

      dataList.removeWhere(
        (e) => (e as Map<String, dynamic>)['id'] == attendanceId,
      );

      workMap['data'] = dataList;
      rawList[workIdx] = workMap;
      appData['works'] = rawList;
      await _writeAppData(appData);
    } catch (e) {
      throw Exception('Khong the xoa ban ghi cham cong: $e');
    }
  }

  // ──────────────────────────────────────────────────────────────────────────
  // App meta
  // ──────────────────────────────────────────────────────────────────────────

  /// Returns the [DateTime] stored as `downloadDate` in `app.json`, or `null`
  /// if the field is missing / unparseable.
  Future<DateTime?> getDownloadDate() async {
    try {
      final appData = await _readAppData();
      final raw = appData['downloadDate'];
      if (raw == null) return null;
      return DateTime.tryParse(raw as String);
    } catch (_) {
      return null;
    }
  }
}
