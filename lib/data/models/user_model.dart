/// user_model.dart
///
/// Represents the app user's profile and streak tracking data.

class UserModel {
  /// Display name of the user.
  final String name;

  /// Gender: `'male'`, `'female'`, or `'other'`. Nullable if not set.
  final String? gender;

  /// Absolute or relative path to the user's avatar image stored in /public.
  final String? avatarPath;

  /// Absolute or relative path to the user's cover image stored in /public.
  final String? coverPath;

  /// Current consecutive check-in streak (number of days).
  final int streak;

  /// The date on which the user last checked in (logged attendance for any work).
  /// Used to determine if the streak should increment or reset.
  final DateTime? lastCheckinDate;

  /// The date when the app was first installed / initialized by this user.
  final DateTime downloadDate;

  const UserModel({
    required this.name,
    this.gender,
    this.avatarPath,
    this.coverPath,
    this.streak = 0,
    this.lastCheckinDate,
    required this.downloadDate,
  });

  // ---------------------------------------------------------------------------
  // Factory constructors
  // ---------------------------------------------------------------------------

  /// Creates a new [UserModel] with default values (useful on first launch).
  factory UserModel.initial({String name = 'Người dùng'}) {
    return UserModel(
      name: name,
      downloadDate: DateTime.now(),
    );
  }

  /// Deserializes a [UserModel] from a JSON [Map].
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      name: json['name'] as String,
      gender: json['gender'] as String?,
      avatarPath: json['avatarPath'] as String?,
      coverPath: json['coverPath'] as String?,
      streak: json['streak'] as int? ?? 0,
      lastCheckinDate: json['lastCheckinDate'] != null
          ? DateTime.parse(json['lastCheckinDate'] as String)
          : null,
      downloadDate: DateTime.parse(json['downloadDate'] as String),
    );
  }

  // ---------------------------------------------------------------------------
  // Serialization
  // ---------------------------------------------------------------------------

  /// Serializes this model to a JSON-compatible [Map].
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gender': gender,
      'avatarPath': avatarPath,
      'coverPath': coverPath,
      'streak': streak,
      'lastCheckinDate': lastCheckinDate?.toIso8601String(),
      'downloadDate': downloadDate.toIso8601String(),
    };
  }

  // ---------------------------------------------------------------------------
  // Streak helpers
  // ---------------------------------------------------------------------------

  /// Returns `true` if the user has already checked in today (no streak update needed).
  bool get hasCheckedInToday {
    if (lastCheckinDate == null) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime(
        lastCheckinDate!.year, lastCheckinDate!.month, lastCheckinDate!.day);
    return last == today;
  }

  /// Returns `true` if yesterday was the last check-in date (streak continues).
  bool get wasCheckedInYesterday {
    if (lastCheckinDate == null) return false;
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final last = DateTime(
        lastCheckinDate!.year, lastCheckinDate!.month, lastCheckinDate!.day);
    return last == yesterday;
  }

  // ---------------------------------------------------------------------------
  // copyWith
  // ---------------------------------------------------------------------------

  /// Returns a copy of this model with the given fields replaced.
  UserModel copyWith({
    String? name,
    String? gender,
    String? avatarPath,
    String? coverPath,
    int? streak,
    DateTime? lastCheckinDate,
    DateTime? downloadDate,
    bool clearGender = false,
    bool clearAvatarPath = false,
    bool clearCoverPath = false,
    bool clearLastCheckinDate = false,
  }) {
    return UserModel(
      name: name ?? this.name,
      gender: clearGender ? null : (gender ?? this.gender),
      avatarPath: clearAvatarPath ? null : (avatarPath ?? this.avatarPath),
      coverPath: clearCoverPath ? null : (coverPath ?? this.coverPath),
      streak: streak ?? this.streak,
      lastCheckinDate: clearLastCheckinDate
          ? null
          : (lastCheckinDate ?? this.lastCheckinDate),
      downloadDate: downloadDate ?? this.downloadDate,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality & toString
  // ---------------------------------------------------------------------------

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.name == name &&
        other.streak == streak &&
        other.downloadDate == downloadDate;
  }

  @override
  int get hashCode => Object.hash(name, streak, downloadDate);

  @override
  String toString() => 'UserModel(name: $name, streak: $streak, '
      'gender: $gender, lastCheckinDate: $lastCheckinDate)';
}
