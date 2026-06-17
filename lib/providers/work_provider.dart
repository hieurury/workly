import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/models/work_model.dart';
import '../data/models/attendance_model.dart';
import '../data/repositories/work_repository.dart';
import '../core/utils/date_utils.dart';
import '../core/utils/salary_calculator.dart';

class WorkProvider extends ChangeNotifier {
  List<WorkModel> _works = [];
  bool _isLoading = false;
  String? _error;

  List<WorkModel> get works => _works;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Computed properties
  List<WorkModel> get activeWorks => _works.where((w) => w.isActived).toList();
  List<WorkModel> get frozenWorks => _works.where((w) => !w.isActived).toList();
  WorkModel? get mainWork {
    try {
      return _works.firstWhere((w) => w.isMain && w.isActived);
    } catch (_) {
      return null;
    }
  }

  // Works that need attendance today (active works without today's attendance)
  List<WorkModel> get worksPendingAttendanceToday {
    final today = DateTime.now();
    return activeWorks.where((w) {
      final todayAttendance = w.attendanceForDate(today);
      return todayAttendance == null;
    }).toList();
  }

  final WorkRepository _repo = WorkRepository();

  Future<void> initialize() async {
    await loadWorks();
  }

  Future<void> loadWorks() async {
    _setLoading(true);
    try {
      await _repo.initializeApp();
      _works = await _repo.getWorks();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addWork(WorkModel work) async {
    _setLoading(true);
    try {
      await _repo.saveWork(work);
      _works.add(work);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateWork(WorkModel work) async {
    _setLoading(true);
    try {
      await _repo.saveWork(work);
      final index = _works.indexWhere((w) => w.id == work.id);
      if (index != -1) {
        _works[index] = work;
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteWork(String workId) async {
    _setLoading(true);
    try {
      await _repo.deleteWork(workId);
      _works.removeWhere((w) => w.id == workId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> setMainWork(String workId) async {
    _setLoading(true);
    try {
      await _repo.setMainWork(workId);
      _works = _works.map((w) => w.copyWith(isMain: w.id == workId)).toList();
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> toggleFreeze(String workId) async {
    final idx = _works.indexWhere((w) => w.id == workId);
    if (idx < 0) return;
    final updated = _works[idx].copyWith(isActived: !_works[idx].isActived);
    await updateWork(updated);
  }

  Future<void> duplicateWork(WorkModel work) async {
    _setLoading(true);
    try {
      final newId = const Uuid().v4();
      
      String baseTitle = work.title;
      final regExp = RegExp(r'\s*\(\d+\)$');
      if (regExp.hasMatch(baseTitle)) {
        baseTitle = baseTitle.replaceFirst(regExp, '').trim();
      }
      
      int counter = 2;
      String newTitle = '$baseTitle ($counter)';
      while (_works.any((w) => w.title == newTitle)) {
        counter++;
        newTitle = '$baseTitle ($counter)';
      }

      // Bắt đầu chu kỳ mới bằng ngày kết thúc của chu kỳ cũ + 1
      final originalCycle = SalaryCalculator.getSalaryCycle(work, DateTime.now());
      final nextCycleStart = originalCycle.end.add(const Duration(days: 1));

      final tempWork = WorkModel(
        id: newId,
        title: newTitle,
        description: work.description,
        icon: work.icon,
        color: work.color,
        config: work.config,
        data: const [],
        createdAt: nextCycleStart,
      );

      final newCycle = SalaryCalculator.getSalaryCycle(tempWork, nextCycleStart);
      
      int workingDays = 0;
      DateTime current = newCycle.start;
      while (!current.isAfter(newCycle.end)) {
        if (!WorklyDateUtils.isWeekend(current, work.config.weekend)) {
          workingDays++;
        }
        current = current.add(const Duration(days: 1));
      }

      final newConfig = work.config.copyWith(numberOfDayWork: workingDays > 0 ? workingDays : 1).withRecalculatedHourSalary();

      final newWork = tempWork.copyWith(
        config: newConfig,
        isMain: false,
      );

      await _repo.saveWork(newWork);
      _works.add(newWork);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addAttendance(String workId, AttendanceModel attendance) async {
    _setLoading(true);
    try {
      await _repo.addAttendance(workId, attendance);
      final index = _works.indexWhere((w) => w.id == workId);
      if (index != -1) {
        final work = _works[index];
        final newData = List<AttendanceModel>.from(work.data)..add(attendance);
        _works[index] = work.copyWith(data: newData);
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateAttendance(String workId, AttendanceModel attendance) async {
    _setLoading(true);
    try {
      await _repo.updateAttendance(workId, attendance);
      final index = _works.indexWhere((w) => w.id == workId);
      if (index != -1) {
        final work = _works[index];
        final attIndex = work.data.indexWhere((a) => a.id == attendance.id);
        if (attIndex != -1) {
          final newData = List<AttendanceModel>.from(work.data);
          newData[attIndex] = attendance;
          _works[index] = work.copyWith(data: newData);
        }
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteAttendance(String workId, String attendanceId) async {
    _setLoading(true);
    try {
      await _repo.deleteAttendance(workId, attendanceId);
      final index = _works.indexWhere((w) => w.id == workId);
      if (index != -1) {
        final work = _works[index];
        final newData = List<AttendanceModel>.from(work.data)..removeWhere((a) => a.id == attendanceId);
        _works[index] = work.copyWith(data: newData);
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  WorkModel? getWorkById(String id) {
    try {
      return _works.firstWhere((w) => w.id == id);
    } catch (_) {
      return null;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
