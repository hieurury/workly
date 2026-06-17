/// subsidy_model.dart
///
/// Represents a single subsidy (trợ cấp) entry attached to a work configuration.
/// Examples: meal allowance, transport allowance, etc.

class SubsidyModel {
  /// Unique identifier for this subsidy.
  final String id;

  /// Human-readable name, e.g. "Phụ cấp ăn trưa".
  final String title;

  /// Monetary value of the subsidy (VNĐ or any currency unit used by the app).
  final double value;

  const SubsidyModel({
    required this.id,
    required this.title,
    required this.value,
  });

  // ---------------------------------------------------------------------------
  // Factory constructors
  // ---------------------------------------------------------------------------

  /// Creates an empty / default SubsidyModel (useful for form initialization).
  factory SubsidyModel.empty() => const SubsidyModel(
        id: '',
        title: '',
        value: 0.0,
      );

  /// Deserializes a [SubsidyModel] from a JSON [Map].
  factory SubsidyModel.fromJson(Map<String, dynamic> json) {
    return SubsidyModel(
      id: json['id'] as String,
      title: json['title'] as String,
      value: (json['value'] as num).toDouble(),
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
      'value': value,
    };
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  /// Returns a copy of this model with the given fields replaced.
  SubsidyModel copyWith({
    String? id,
    String? title,
    double? value,
  }) {
    return SubsidyModel(
      id: id ?? this.id,
      title: title ?? this.title,
      value: value ?? this.value,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality & toString
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SubsidyModel &&
        other.id == id &&
        other.title == title &&
        other.value == value;
  }

  @override
  int get hashCode => Object.hash(id, title, value);

  @override
  String toString() =>
      'SubsidyModel(id: $id, title: $title, value: $value)';
}
