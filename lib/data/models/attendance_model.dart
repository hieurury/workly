/// attendance_model.dart
///
/// Represents a single day's attendance record for a given work entry.
/// Each [AttendanceModel] belongs to exactly one [WorkModel] (via [workId]).

class AttendanceModel {
  /// Unique identifier for this attendance record.
  final String id;

  /// The ID of the parent [WorkModel] this record belongs to.
  final String workId;

  /// The calendar date this record represents (time component is ignored).
  final DateTime date;

  /// Whether the employee took a day off (nghỉ phép / nghỉ không lương, etc.).
  final bool isOff;

  /// Shift type: `'day'` for day shift, `'night'` for night shift.
  final String typeWorkTime;

  /// Whether this record includes overtime hours.
  final bool isOvertime;

  /// Actual start time as a string, e.g. `'8:00'`. Nullable when [isOff] is true.
  final String? startTime;

  /// Actual end time as a string, e.g. `'17:30'`. Nullable when [isOff] is true.
  final String? endTime;

  /// Whether the compensation (đền bù) for this shift has been received.
  final bool compensationReceived;

  /// Whether the salary for this record has been confirmed as received.
  /// Only relevant when the work config has no [dayToSalary] set.
  final bool salaryReceived;

  /// The actual date the salary was received (if manually confirmed).
  final DateTime? salaryReceivedDate;

  /// Optional free-text note for this record.
  final String? note;

  const AttendanceModel({
    required this.id,
    required this.workId,
    required this.date,
    this.isOff = false,
    this.typeWorkTime = 'day',
    this.isOvertime = false,
    this.startTime,
    this.endTime,
    this.compensationReceived = false,
    this.salaryReceived = false,
    this.salaryReceivedDate,
    this.note,
  });

  // ---------------------------------------------------------------------------
  // Factory constructors
  // ---------------------------------------------------------------------------

  /// Creates an empty / default [AttendanceModel] for [workId] on [date].
  factory AttendanceModel.empty({
    required String id,
    required String workId,
    required DateTime date,
  }) {
    return AttendanceModel(
      id: id,
      workId: workId,
      date: date,
    );
  }

  /// Deserializes an [AttendanceModel] from a JSON [Map].
  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String,
      workId: json['workId'] as String,
      date: DateTime.parse(json['date'] as String),
      isOff: json['isOff'] as bool? ?? false,
      typeWorkTime: json['typeWorkTime'] as String? ?? 'day',
      isOvertime: json['isOvertime'] as bool? ?? false,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      compensationReceived: json['compensationReceived'] as bool? ?? false,
      salaryReceived: json['salaryReceived'] as bool? ?? false,
      salaryReceivedDate: json['salaryReceivedDate'] != null
          ? DateTime.parse(json['salaryReceivedDate'] as String)
          : null,
      note: json['note'] as String?,
    );
  }

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  /// Serializes this model to a JSON-compatible [Map].
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workId': workId,
      'date': date.toIso8601String(),
      'isOff': isOff,
      'typeWorkTime': typeWorkTime,
      'isOvertime': isOvertime,
      'startTime': startTime,
      'endTime': endTime,
      'compensationReceived': compensationReceived,
      'salaryReceived': salaryReceived,
      'salaryReceivedDate': salaryReceivedDate?.toIso8601String(),
      'note': note,
    };
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  /// Returns a copy of this model with the given fields replaced.
  AttendanceModel copyWith({
    String? id,
    String? workId,
    DateTime? date,
    bool? isOff,
    String? typeWorkTime,
    bool? isOvertime,
    String? startTime,
    String? endTime,
    bool? compensationReceived,
    bool? salaryReceived,
    DateTime? salaryReceivedDate,
    String? note,
    bool clearSalaryReceivedDate = false,
    bool clearStartTime = false,
    bool clearEndTime = false,
    bool clearNote = false,
  }) {
    return AttendanceModel(
      id: id ?? this.id,
      workId: workId ?? this.workId,
      date: date ?? this.date,
      isOff: isOff ?? this.isOff,
      typeWorkTime: typeWorkTime ?? this.typeWorkTime,
      isOvertime: isOvertime ?? this.isOvertime,
      startTime: clearStartTime ? null : (startTime ?? this.startTime),
      endTime: clearEndTime ? null : (endTime ?? this.endTime),
      compensationReceived: compensationReceived ?? this.compensationReceived,
      salaryReceived: salaryReceived ?? this.salaryReceived,
      salaryReceivedDate: clearSalaryReceivedDate
          ? null
          : (salaryReceivedDate ?? this.salaryReceivedDate),
      note: clearNote ? null : (note ?? this.note),
    );
  }

  // ---------------------------------------------------------------------------
  // Equality & toString
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AttendanceModel &&
        other.id == id &&
        other.workId == workId &&
        other.date == date;
  }

  @override
  int get hashCode => Object.hash(id, workId, date);

  @override
  String toString() => 'AttendanceModel(id: $id, workId: $workId, '
      'date: ${date.toIso8601String()}, isOff: $isOff, '
      'typeWorkTime: $typeWorkTime, isOvertime: $isOvertime)';
}
