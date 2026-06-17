/// Workly – Streak Management Logic
///
/// Handles computing, incrementing, and resetting daily check-in streaks.
///
/// Streak rules:
/// - A streak increments any time the user checks in on a given calendar day
///   (even if that day is a configured off-day / weekend).
/// - If the user skips a calendar day entirely (zero check-in records for that
///   day) the streak resets to 0 the next time they check in.
/// - Multiple check-ins on the same day count as a single streak day.
library streak_manager;

import '../../data/models/user_model.dart';
import 'date_utils.dart';

/// Manages daily check-in streak logic for the Workly application.
///
/// All methods are pure functions — they never mutate the given [UserModel]
/// but return a new one with the updated fields.
class StreakManager {
  StreakManager._(); // prevent instantiation

  // ─── Public API ───────────────────────────────────────────────────────────

  /// Returns the current streak count for [user].
  ///
  /// The streak stored on the model is authoritative; this method validates
  /// it against the user's actual check-in history:
  ///
  /// - If the user missed yesterday (and has not yet checked in today) the
  ///   effective streak is `0`.
  /// - Otherwise the streak value from the model is returned as-is.
  static int calculateStreak(UserModel user) {
    if (shouldResetStreak(user)) return 0;
    return user.streak;
  }

  /// Returns `true` if the streak should be reset because the user has no
  /// check-in record for yesterday and has not yet checked in today.
  ///
  /// Logic:
  /// 1. If [user.lastCheckinDate] is null the user has never checked in → no
  ///    reset needed (streak is already 0).
  /// 2. If the last check-in was today → streak is still alive.
  /// 3. If the last check-in was yesterday → streak is still alive.
  /// 4. If the last check-in was two or more days ago → streak should reset.
  static bool shouldResetStreak(UserModel user) {
    final lastCheckin = user.lastCheckinDate;

    // Never checked in before — nothing to reset.
    if (lastCheckin == null) return false;

    final today = _dateOnly(DateTime.now());
    final yesterday = today.subtract(const Duration(days: 1));

    // Still alive if checked in today or yesterday.
    if (WorklyDateUtils.isSameDay(lastCheckin, today)) return false;
    if (WorklyDateUtils.isSameDay(lastCheckin, yesterday)) return false;

    // Missed at least one day → must reset.
    return true;
  }

  /// Returns a new [UserModel] with the streak incremented by 1 and
  /// [lastCheckinDate] set to today.
  ///
  /// If the user has already checked in today the streak count is **not**
  /// double-incremented — the same incremented model is returned, preserving
  /// idempotency within a single calendar day.
  ///
  /// Call [shouldResetStreak] first and branch accordingly if you need to
  /// handle the reset + increment flow in one step.
  static UserModel incrementStreak(UserModel user) {
    final today = _dateOnly(DateTime.now());

    // Idempotency guard: do not increment if already checked in today.
    if (user.lastCheckinDate != null &&
        WorklyDateUtils.isSameDay(user.lastCheckinDate!, today)) {
      // Already checked in today — return unchanged model.
      return user;
    }

    return user.copyWith(
      streak: user.streak + 1,
      lastCheckinDate: today,
    );
  }

  /// Returns a new [UserModel] with the streak reset to 0.
  ///
  /// [lastCheckinDate] is intentionally **preserved** so downstream code can
  /// still inspect when the user last checked in before the reset happened.
  static UserModel resetStreak(UserModel user) {
    return user.copyWith(streak: 0);
  }

  /// Convenience method that handles the full check-in logic:
  ///
  /// 1. If [shouldResetStreak] → reset streak to 0 first, then increment to 1.
  /// 2. Otherwise → increment streak by 1.
  ///
  /// Returns the updated [UserModel].
  static UserModel processCheckin(UserModel user) {
    if (shouldResetStreak(user)) {
      // Reset first, then start a new streak of 1.
      final reset = resetStreak(user);
      return reset.copyWith(
        streak: 1,
        lastCheckinDate: _dateOnly(DateTime.now()),
      );
    }
    return incrementStreak(user);
  }

  // ─── Private helpers ──────────────────────────────────────────────────────

  /// Strips the time portion from [dt], returning midnight of the same day.
  static DateTime _dateOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);
}
