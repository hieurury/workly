/// work_model.dart
///
/// Represents a single work/job entry in the Workly app.
/// Each work has its own configuration ([WorkConfigModel]) and a list of
/// attendance records ([AttendanceModel]).

import 'attendance_model.dart';
import 'work_config_model.dart';

class WorkModel {
  /// Unique identifier for this work entry.
  final String id;

  /// Display name of the work/job, e.g. "Công ty ABC".
  final String title;

  /// Optional longer description.
  final String? description;

  /// Icon identifier string — must be one of the 10 allowed icon names
  /// defined by the app (e.g. `'briefcase'`, `'factory'`, `'hospital'` …).
  final String icon;

  /// Color identifier string — must be one of the 10 allowed color names
  /// defined by the app (e.g. `'blue'`, `'red'`, `'green'` …).
  final String color;

  /// Whether this is the primary job shown prominently on the home screen.
  final bool isMain;

  /// Whether this work entry is active. `false` means frozen / archived.
  final bool isActived;

  /// All salary and schedule configuration for this work.
  final WorkConfigModel config;

  /// All attendance records associated with this work, sorted ascending by date.
  final List<AttendanceModel> data;

  /// Timestamp when this work entry was first created.
  final DateTime createdAt;

  const WorkModel({
    required this.id,
    required this.title,
    this.description,
    required this.icon,
    required this.color,
    this.isMain = false,
    this.isActived = true,
    required this.config,
    required this.data,
    required this.createdAt,
  });

  /// Returns true if this work cycle has been finalized (salary received).
  bool get isCompleted => data.any((a) => a.salaryReceived);

  // ---------------------------------------------------------------------------
  // Factory constructors
  // ---------------------------------------------------------------------------

  /// Creates a new [WorkModel] with default configuration and empty attendance.
  factory WorkModel.empty({
    required String id,
    required String title,
    String icon = 'briefcase',
    String color = 'blue',
  }) {
    return WorkModel(
      id: id,
      title: title,
      icon: icon,
      color: color,
      config: WorkConfigModel.defaultConfig(),
      data: const [],
      createdAt: DateTime.now(),
    );
  }

  /// Deserializes a [WorkModel] from a JSON [Map].
  factory WorkModel.fromJson(Map<String, dynamic> json) {
    return WorkModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String,
      color: json['color'] as String,
      isMain: json['isMain'] as bool? ?? false,
      isActived: json['isActived'] as bool? ?? true,
      config: WorkConfigModel.fromJson(
          json['config'] as Map<String, dynamic>),
      data: (json['data'] as List<dynamic>)
          .map((e) => AttendanceModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  /// Serializes this model to a JSON-compatible [Map].
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'icon': icon,
      'color': color,
      'isMain': isMain,
      'isActived': isActived,
      'config': config.toJson(),
      'data': data.map((a) => a.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // ---------------------------------------------------------------------------
  // Attendance helpers
  // ---------------------------------------------------------------------------

  /// Returns the [AttendanceModel] whose [date] matches [targetDate] (by
  /// year / month / day), or `null` if no record exists for that date.
  AttendanceModel? attendanceForDate(DateTime targetDate) {
    final target = DateTime(targetDate.year, targetDate.month, targetDate.day);
    try {
      return data.firstWhere((a) {
        final d = DateTime(a.date.year, a.date.month, a.date.day);
        return d == target;
      });
    } catch (_) {
      return null;
    }
  }

  /// Returns attendance records for the last [days] calendar days (including
  /// today). Results are sorted ascending by date.
  List<AttendanceModel> attendanceForLastDays(int days) {
    final now = DateTime.now();
    final cutoff = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));
    return data
        .where((a) {
          final d = DateTime(a.date.year, a.date.month, a.date.day);
          return !d.isBefore(cutoff);
        })
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// Returns all attendance records for a given [month] and [year].
  List<AttendanceModel> attendanceForMonth(int year, int month) {
    return data
        .where((a) => a.date.year == year && a.date.month == month)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  /// Returns a copy of this model with the given fields replaced.
  WorkModel copyWith({
    String? id,
    String? title,
    String? description,
    String? icon,
    String? color,
    bool? isMain,
    bool? isActived,
    WorkConfigModel? config,
    List<AttendanceModel>? data,
    DateTime? createdAt,
    bool clearDescription = false,
  }) {
    return WorkModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description:
          clearDescription ? null : (description ?? this.description),
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isMain: isMain ?? this.isMain,
      isActived: isActived ?? this.isActived,
      config: config ?? this.config,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality & toString
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is WorkModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'WorkModel(id: $id, title: $title, '
      'isMain: $isMain, isActived: $isActived, '
      'attendanceCount: ${data.length})';
}
