import 'dart:math' as math;

import '../../data/models/attendance_model.dart';
import '../../data/models/work_config_model.dart';
import '../../data/models/work_model.dart';
import 'date_utils.dart';

class SalaryCycle {
  final DateTime start;
  final DateTime end;

  SalaryCycle({required this.start, required this.end});

  bool contains(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    return !d.isBefore(s) && !d.isAfter(e);
  }
}

class SalaryCalculator {
  SalaryCalculator._();

  static const double _multiplierNormalDay = 1.0;
  static const double _multiplierNormalNight = 1.5;
  static const double _multiplierWeekendDay = 1.5;
  static const double _multiplierWeekendNight = 1.95;

  static double calculateHourSalary(WorkConfigModel config) {
    if (config.numberOfDayWork <= 0 || config.normalWorkTime <= 0) return 0;
    return config.baseSalary / config.numberOfDayWork / config.normalWorkTime;
  }

  static double calculateOvertimeHours(AttendanceModel attendance, WorkConfigModel config) {
    if (attendance.endTime == null || attendance.endTime!.isEmpty) return 0;
    if (attendance.startTime == null || attendance.startTime!.isEmpty) return 0;

    final startHour = WorklyDateUtils.parseTimeToHours(attendance.startTime!);
    var endHour = WorklyDateUtils.parseTimeToHours(attendance.endTime!);
    if (endHour < startHour) {
      endHour += 24.0; // Crossed midnight
    }

    final totalElapsed = endHour - startHour;
    
    // Nếu tổng thời gian lớn hơn mức chuẩn (bao gồm 1 lần nghỉ), thì trừ 2 lần nghỉ
    final breaks = totalElapsed > (config.normalWorkTime + config.timeToEat) 
        ? config.timeToEat * 2 
        : config.timeToEat;

    final totalWorked = totalElapsed - breaks;
    final overtime = totalWorked - config.normalWorkTime;
    
    return math.max(0.0, overtime);
  }

  static double calculateDaySalary(AttendanceModel attendance, WorkModel work) {
    if (attendance.isOff) return 0;

    final config = work.config;
    final hourSalary = calculateHourSalary(config);

    final baseDaySalary = hourSalary * config.normalWorkTime;

    final otHours = calculateOvertimeHours(attendance, config);
    final multiplier = _overtimeMultiplier(attendance, config);
    final overtimePay = otHours * hourSalary * multiplier;

    final compensation = attendance.compensationReceived 
        ? (attendance.typeWorkTime == 'day' ? config.compensationDay : config.compensationNight) 
        : 0.0;

    return baseDaySalary + overtimePay + compensation;
  }

  /// Tính chu kỳ lương hiện tại dựa vào ngày tham chiếu (vd: DateTime.now())
  /// Đã được sửa để KHÓA chu kỳ theo ngày bắt đầu của công việc (không tự nhảy qua tháng mới).
  static SalaryCycle getSalaryCycle(WorkModel work, DateTime referenceDate) {
    // Khóa chu kỳ vào ngày điểm danh đầu tiên, hoặc ngày tạo công việc
    final baseDate = work.data.isNotEmpty 
        ? (List<AttendanceModel>.from(work.data)..sort((a, b) => a.date.compareTo(b.date))).first.date 
        : work.createdAt;

    final startDay = work.config.dayStartWork;
    final payDay = work.config.dayToSalary;
    final y = baseDate.year;
    final m = baseDate.month;

    if (startDay != null && payDay != null) {
      if (payDay < startDay) {
        if (baseDate.day <= payDay) {
          return SalaryCycle(
            start: DateTime(y, m - 1, startDay),
            end: DateTime(y, m, payDay),
          );
        } else {
          return SalaryCycle(
            start: DateTime(y, m, startDay),
            end: DateTime(y, m + 1, payDay),
          );
        }
      } else {
        return SalaryCycle(
          start: DateTime(y, m, startDay),
          end: DateTime(y, m, payDay),
        );
      }
    } else if (startDay != null) {
      DateTime start = DateTime(y, m, startDay);
      if (baseDate.day < startDay) {
        start = DateTime(y, m - 1, startDay);
      }
      DateTime end = DateTime(start.year, start.month + 1, start.day).subtract(const Duration(days: 1));
      return SalaryCycle(start: start, end: end);
    } else if (payDay != null) {
      DateTime end = DateTime(y, m, payDay);
      if (baseDate.day > payDay) {
        end = DateTime(y, m + 1, payDay);
      }
      DateTime start = DateTime(end.year, end.month - 1, end.day).add(const Duration(days: 1));
      return SalaryCycle(start: start, end: end);
    } else {
      if (work.data.isEmpty) {
        // Nếu không có mốc cố định và chưa có điểm danh, chu kỳ chỉ là ngày hiện tại (hoặc baseDate)
        // để không bị hiển thị 30 ngày trống.
        return SalaryCycle(start: referenceDate, end: referenceDate);
      }
      
      final sortedData = List<AttendanceModel>.from(work.data)..sort((a, b) => a.date.compareTo(b.date));
      DateTime cycleStart = sortedData.first.date;
      DateTime? cycleEnd;
      
      for (final att in sortedData) {
        if (att.salaryReceived) {
          cycleEnd = att.date;
          break; // Đã nhận lương -> chốt chu kỳ ở đây, không tự tạo chu kỳ mới
        }
      }
      
      if (cycleEnd != null) {
        return SalaryCycle(start: cycleStart, end: cycleEnd);
      }
      
      // Chưa nhận lương, chu kỳ mở rộng tới referenceDate (hoặc lastDate)
      final lastDate = sortedData.last.date;
      DateTime end = referenceDate.isAfter(lastDate) ? referenceDate : lastDate;
      
      if (cycleStart.isAfter(end)) {
        end = cycleStart;
      }
      return SalaryCycle(start: cycleStart, end: end);
    }
  }

  static double calculateMonthSalary(WorkModel work, int year, int month) {
    double total = 0;
    for (final att in work.data) {
      final date = att.date;
      if (date.year == year && date.month == month) {
        total += calculateDaySalary(att, work);
      }
    }
    return total;
  }

  static double calculateCycleSalary(WorkModel work, SalaryCycle cycle) {
    double total = 0;
    for (final att in work.data) {
      if (cycle.contains(att.date)) {
        total += calculateDaySalary(att, work);
      }
    }
    return total;
  }

  static double calculateWeekSalary(WorkModel work, DateTime weekStart) {
    final monday = DateTime(weekStart.year, weekStart.month, weekStart.day);
    final sunday = monday.add(const Duration(days: 6));
    double total = 0;
    for (final att in work.data) {
      final d = DateTime(att.date.year, att.date.month, att.date.day);
      if (!d.isBefore(monday) && !d.isAfter(sunday)) {
        total += calculateDaySalary(att, work);
      }
    }
    return total;
  }

  static double calculateTotalSubsidy(WorkConfigModel config) {
    if (config.subsidy.isEmpty) return 0;
    return config.subsidy.fold(0.0, (sum, s) => sum + s.value);
  }

  static Map<String, double> calculateCycleSalaryBreakdown(WorkModel work, SalaryCycle cycle) {
    double baseSalary = 0;
    double overtimePay = 0;
    double compensation = 0;

    final config = work.config;
    final hourSalary = calculateHourSalary(config);

    for (final att in work.data) {
      if (!cycle.contains(att.date)) continue;
      if (att.isOff) continue;

      baseSalary += hourSalary * config.normalWorkTime;

      final otHours = calculateOvertimeHours(att, config);
      final multiplier = _overtimeMultiplier(att, config);
      overtimePay += otHours * hourSalary * multiplier;

      if (att.compensationReceived) {
        compensation += att.typeWorkTime == 'day' ? config.compensationDay : config.compensationNight;
      }
    }

    final subsidy = calculateTotalSubsidy(config);

    return {
      'salary': baseSalary,
      'overtime': overtimePay,
      'compensation': compensation,
      'subsidy': subsidy,
    };
  }

  static double predictMonthSalary(WorkModel work) {
    final avg = averageDailySalary(work);
    final days = work.config.numberOfDayWork > 0 ? work.config.numberOfDayWork : 26;
    return avg * days;
  }

  static double predictWeekSalary(WorkModel work) {
    final avg = averageDailySalary(work);
    return avg * 7;
  }

  static double averageHourlySalary(WorkModel work) {
    final config = work.config;
    final hourSalary = calculateHourSalary(config);
    if (hourSalary == 0) return 0;

    final completedShifts = work.data.where((a) => !a.isOff && a.endTime != null).toList();
    if (completedShifts.isEmpty) return hourSalary;

    double totalPay = 0;
    double totalHours = 0;

    for (final att in completedShifts) {
      if (att.startTime == null || att.endTime == null) continue;
      final startH = WorklyDateUtils.parseTimeToHours(att.startTime!);
      var endH = WorklyDateUtils.parseTimeToHours(att.endTime!);
      if (endH < startH) endH += 24.0;
      
      final totalElapsed = endH - startH;
      final breaks = totalElapsed > (config.normalWorkTime + config.timeToEat) ? config.timeToEat * 2 : config.timeToEat;
      final workedHours = math.max(0.0, totalElapsed - breaks);

      final normalHours = math.min(workedHours, config.normalWorkTime);
      final otHours = math.max(0.0, workedHours - config.normalWorkTime);
      final multiplier = _overtimeMultiplier(att, config);

      totalPay += (normalHours * hourSalary) + (otHours * hourSalary * multiplier);
      totalHours += workedHours;
    }

    if (totalHours == 0) return hourSalary;
    return totalPay / totalHours;
  }

  static double averageDailySalary(WorkModel work) {
    final completedShifts = work.data.where((a) => !a.isOff).toList();
    if (completedShifts.isEmpty) return 0;

    final total = completedShifts.fold(0.0, (sum, att) => sum + calculateDaySalary(att, work));
    return total / completedShifts.length;
  }

  static List<MapEntry<DateTime, double>> dailyIncomeCycle(WorkModel work, SalaryCycle cycle) {
    final days = <DateTime>[];
    DateTime current = cycle.start;
    while (!current.isAfter(cycle.end)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }

    final result = <MapEntry<DateTime, double>>[];

    for (final day in days) {
      final att = work.data.where((a) => a.date.year == day.year && a.date.month == day.month && a.date.day == day.day).firstOrNull;
      double dailySalary = 0;
      if (att != null && !att.isOff) {
        dailySalary = calculateDaySalary(att, work);
      }
      result.add(MapEntry(day, dailySalary));
    }
    return result;
  }

  static double _overtimeMultiplier(AttendanceModel attendance, WorkConfigModel config) {
    final weekend = WorklyDateUtils.isWeekend(attendance.date, config.weekend);
    const isHoliday = false;
    final isNight = attendance.typeWorkTime == 'night';
    if (isHoliday || weekend) {
      return isNight ? _multiplierWeekendNight : _multiplierWeekendDay;
    }
    return isNight ? _multiplierNormalNight : _multiplierNormalDay;
  }
}
