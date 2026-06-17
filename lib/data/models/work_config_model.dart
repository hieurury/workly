/// work_config_model.dart
///
/// Holds all salary and schedule configuration for a [WorkModel].
/// Overtime percentage bonuses follow Vietnamese labour law conventions.

import 'subsidy_model.dart';

class WorkConfigModel {
  /// Lương cơ bản (base monthly salary).
  final double baseSalary;

  /// Lương mỗi giờ — auto-calculated:
  /// `baseSalary / numberOfDayWork / normalWorkTime`.
  /// Stored so reads are O(1); should be recalculated whenever
  /// [baseSalary], [numberOfDayWork], or [normalWorkTime] changes.
  final double hourSalary;

  /// Số giờ làm cơ bản mỗi ca (standard hours per shift), e.g. `8.0`.
  final double normalWorkTime;

  /// Giờ nghỉ giữa ca (break / meal time deducted from shift), e.g. `0.5`.
  final double timeToEat;

  /// Danh sách ngày cuối tuần, e.g. `['saturday', 'sunday']`.
  final List<String> weekend;

  /// Khung giờ ca ngày, e.g. `'8:00 - 17:00'`. Nullable if not applicable.
  final String? dayWorkTime;

  /// Khung giờ ca đêm, e.g. `'20:00 - 5:00'`. Nullable if not applicable.
  final String? nightWorkTime;

  /// Ngày bắt đầu làm việc trong tháng (e.g. `1` đến `31`). Null means not set.
  final int? dayStartWork;

  /// Ngày nhận lương hàng tháng (e.g. `25`). Null means salary is confirmed
  /// manually per attendance record ([AttendanceModel.salaryReceived]).
  final int? dayToSalary;

  /// Ngày thực tế nhận lương (overrides [dayToSalary] for a given cycle).
  final DateTime? dayGetSalary;

  /// Hệ số lương làm thêm giờ ca ngày (thường = 1.5).
  final double percentBonusDayOvertime;

  /// Hệ số lương làm thêm giờ ca đêm (thường = 1.7).
  final double percentBonusNightOvertime;

  /// Hệ số lương làm thêm giờ cuối tuần ca ngày (thường = 2.0).
  final double percentBonusWeekendDayOvertime;

  /// Hệ số lương làm thêm giờ cuối tuần ca đêm (thường = 2.7).
  final double percentBonusWeekendNightOvertime;

  /// Hệ số lương làm thêm giờ ngày lễ ca ngày (thường = 3.0).
  final double percentBonusHolidayDayOvertime;

  /// Hệ số lương làm thêm giờ ngày lễ ca đêm (thường = 3.9).
  final double percentBonusHolidayNightOvertime;

  /// Tiền đền bù ca ngày.
  final double compensationDay;

  /// Tiền đền bù ca đêm.
  final double compensationNight;

  /// Số ngày công trong tháng dùng để tính lương (e.g. `24`).
  final int numberOfDayWork;

  /// Danh sách các khoản trợ cấp.
  final List<SubsidyModel> subsidy;

  const WorkConfigModel({
    required this.baseSalary,
    required this.hourSalary,
    required this.normalWorkTime,
    required this.timeToEat,
    required this.weekend,
    this.dayWorkTime,
    this.nightWorkTime,
    this.dayStartWork,
    this.dayToSalary,
    this.dayGetSalary,
    required this.percentBonusDayOvertime,
    required this.percentBonusNightOvertime,
    required this.percentBonusWeekendDayOvertime,
    required this.percentBonusWeekendNightOvertime,
    required this.percentBonusHolidayDayOvertime,
    required this.percentBonusHolidayNightOvertime,
    required this.compensationDay,
    required this.compensationNight,
    required this.numberOfDayWork,
    required this.subsidy,
  });

  // ---------------------------------------------------------------------------
  // Factory constructors
  // ---------------------------------------------------------------------------

  /// Returns a default [WorkConfigModel] suitable for a new work entry.
  factory WorkConfigModel.defaultConfig() {
    const double baseSalary = 5000000;
    const int numberOfDayWork = 26;
    const double normalWorkTime = 8.0;
    return WorkConfigModel(
      baseSalary: baseSalary,
      hourSalary: baseSalary / numberOfDayWork / normalWorkTime,
      normalWorkTime: normalWorkTime,
      timeToEat: 0.5,
      weekend: const ['saturday', 'sunday'],
      dayWorkTime: '8:00 - 17:00',
      nightWorkTime: '20:00 - 5:00',
      dayStartWork: null,
      dayToSalary: null,
      dayGetSalary: null,
      percentBonusDayOvertime: 1.5,
      percentBonusNightOvertime: 1.7,
      percentBonusWeekendDayOvertime: 2.0,
      percentBonusWeekendNightOvertime: 2.7,
      percentBonusHolidayDayOvertime: 3.0,
      percentBonusHolidayNightOvertime: 3.9,
      compensationDay: 0.0,
      compensationNight: 0.0,
      numberOfDayWork: numberOfDayWork,
      subsidy: const [],
    );
  }

  /// Deserializes a [WorkConfigModel] from a JSON [Map].
  factory WorkConfigModel.fromJson(Map<String, dynamic> json) {
    return WorkConfigModel(
      baseSalary: (json['baseSalary'] as num).toDouble(),
      hourSalary: (json['hourSalary'] as num).toDouble(),
      normalWorkTime: (json['normalWorkTime'] as num).toDouble(),
      timeToEat: (json['timeToEat'] as num).toDouble(),
      weekend: List<String>.from(json['weekend'] as List),
      dayWorkTime: json['dayWorkTime'] as String?,
      nightWorkTime: json['nightWorkTime'] as String?,
      dayStartWork: json['dayStartWork'] as int?,
      dayToSalary: json['dayToSalary'] as int?,
      dayGetSalary: json['dayGetSalary'] != null
          ? DateTime.parse(json['dayGetSalary'] as String)
          : null,
      percentBonusDayOvertime:
          (json['percentBonusDayOvertime'] as num).toDouble(),
      percentBonusNightOvertime:
          (json['percentBonusNightOvertime'] as num).toDouble(),
      percentBonusWeekendDayOvertime:
          (json['percentBonusWeekendDayOvertime'] as num).toDouble(),
      percentBonusWeekendNightOvertime:
          (json['percentBonusWeekendNightOvertime'] as num).toDouble(),
      percentBonusHolidayDayOvertime:
          (json['percentBonusHolidayDayOvertime'] as num).toDouble(),
      percentBonusHolidayNightOvertime:
          (json['percentBonusHolidayNightOvertime'] as num).toDouble(),
      compensationDay: (json['compensationDay'] as num).toDouble(),
      compensationNight: (json['compensationNight'] as num).toDouble(),
      numberOfDayWork: json['numberOfDayWork'] as int,
      subsidy: (json['subsidy'] as List<dynamic>?)
          ?.map((e) => SubsidyModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  /// Serializes this model to a JSON-compatible [Map].
  Map<String, dynamic> toJson() {
    return {
      'baseSalary': baseSalary,
      'hourSalary': hourSalary,
      'normalWorkTime': normalWorkTime,
      'timeToEat': timeToEat,
      'weekend': weekend,
      'dayWorkTime': dayWorkTime,
      'nightWorkTime': nightWorkTime,
      'dayStartWork': dayStartWork,
      'dayToSalary': dayToSalary,
      'dayGetSalary': dayGetSalary?.toIso8601String(),
      'percentBonusDayOvertime': percentBonusDayOvertime,
      'percentBonusNightOvertime': percentBonusNightOvertime,
      'percentBonusWeekendDayOvertime': percentBonusWeekendDayOvertime,
      'percentBonusWeekendNightOvertime': percentBonusWeekendNightOvertime,
      'percentBonusHolidayDayOvertime': percentBonusHolidayDayOvertime,
      'percentBonusHolidayNightOvertime': percentBonusHolidayNightOvertime,
      'compensationDay': compensationDay,
      'compensationNight': compensationNight,
      'numberOfDayWork': numberOfDayWork,
      'subsidy': subsidy.map((s) => s.toJson()).toList(),
    };
  }

  // ---------------------------------------------------------------------------
  // Computed helpers
  // ---------------------------------------------------------------------------

  /// Re-calculates [hourSalary] based on current field values and returns
  /// a copy with the updated value.
  WorkConfigModel withRecalculatedHourSalary() {
    final recalculated = numberOfDayWork > 0 && normalWorkTime > 0
        ? baseSalary / numberOfDayWork / normalWorkTime
        : 0.0;
    return copyWith(hourSalary: recalculated);
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  /// Returns a copy of this model with the given fields replaced.
  WorkConfigModel copyWith({
    double? baseSalary,
    double? hourSalary,
    double? normalWorkTime,
    double? timeToEat,
    List<String>? weekend,
    String? dayWorkTime,
    String? nightWorkTime,
    int? dayStartWork,
    int? dayToSalary,
    DateTime? dayGetSalary,
    double? percentBonusDayOvertime,
    double? percentBonusNightOvertime,
    double? percentBonusWeekendDayOvertime,
    double? percentBonusWeekendNightOvertime,
    double? percentBonusHolidayDayOvertime,
    double? percentBonusHolidayNightOvertime,
    double? compensationDay,
    double? compensationNight,
    int? numberOfDayWork,
    List<SubsidyModel>? subsidy,
    bool clearDayWorkTime = false,
    bool clearNightWorkTime = false,
    bool clearDayStartWork = false,
    bool clearDayToSalary = false,
    bool clearDayGetSalary = false,
  }) {
    return WorkConfigModel(
      baseSalary: baseSalary ?? this.baseSalary,
      hourSalary: hourSalary ?? this.hourSalary,
      normalWorkTime: normalWorkTime ?? this.normalWorkTime,
      timeToEat: timeToEat ?? this.timeToEat,
      weekend: weekend ?? this.weekend,
      dayWorkTime:
          clearDayWorkTime ? null : (dayWorkTime ?? this.dayWorkTime),
      nightWorkTime:
          clearNightWorkTime ? null : (nightWorkTime ?? this.nightWorkTime),
      dayStartWork:
          clearDayStartWork ? null : (dayStartWork ?? this.dayStartWork),
      dayToSalary:
          clearDayToSalary ? null : (dayToSalary ?? this.dayToSalary),
      dayGetSalary:
          clearDayGetSalary ? null : (dayGetSalary ?? this.dayGetSalary),
      percentBonusDayOvertime:
          percentBonusDayOvertime ?? this.percentBonusDayOvertime,
      percentBonusNightOvertime:
          percentBonusNightOvertime ?? this.percentBonusNightOvertime,
      percentBonusWeekendDayOvertime:
          percentBonusWeekendDayOvertime ?? this.percentBonusWeekendDayOvertime,
      percentBonusWeekendNightOvertime: percentBonusWeekendNightOvertime ??
          this.percentBonusWeekendNightOvertime,
      percentBonusHolidayDayOvertime:
          percentBonusHolidayDayOvertime ?? this.percentBonusHolidayDayOvertime,
      percentBonusHolidayNightOvertime: percentBonusHolidayNightOvertime ??
          this.percentBonusHolidayNightOvertime,
      compensationDay: compensationDay ?? this.compensationDay,
      compensationNight: compensationNight ?? this.compensationNight,
      numberOfDayWork: numberOfDayWork ?? this.numberOfDayWork,
      subsidy: subsidy ?? this.subsidy,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality & toString
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkConfigModel &&
        other.baseSalary == baseSalary &&
        other.numberOfDayWork == numberOfDayWork &&
        other.normalWorkTime == normalWorkTime &&
        other.dayStartWork == dayStartWork &&
        other.dayToSalary == dayToSalary;
  }

  @override
  int get hashCode => Object.hash(baseSalary, numberOfDayWork, normalWorkTime, dayStartWork, dayToSalary);

  @override
  String toString() => 'WorkConfigModel(baseSalary: $baseSalary, '
      'hourSalary: $hourSalary, numberOfDayWork: $numberOfDayWork, '
      'normalWorkTime: $normalWorkTime, dayStartWork: $dayStartWork, dayToSalary: $dayToSalary)';
}
