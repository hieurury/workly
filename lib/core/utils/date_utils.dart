/// Workly – Date & Time Utility Helpers
///
/// All methods are static; no instantiation needed.
library workly_date_utils;

/// A collection of date/time formatting and helper utilities used
/// throughout the Workly application.
class WorklyDateUtils {
  WorklyDateUtils._(); // prevent instantiation

  // ─── Vietnamese weekday names ────────────────────────────────────────────
  static const List<String> _weekdayNames = [
    'Thứ 2', // Monday    (weekday == 1)
    'Thứ 3', // Tuesday   (weekday == 2)
    'Thứ 4', // Wednesday (weekday == 3)
    'Thứ 5', // Thursday  (weekday == 4)
    'Thứ 6', // Friday    (weekday == 5)
    'Thứ 7', // Saturday  (weekday == 6)
    'Chủ nhật', // Sunday (weekday == 7)
  ];

  // ─── Formatting ──────────────────────────────────────────────────────────

  /// Returns a full date string in Vietnamese format.
  ///
  /// Example: `DateTime(2026, 6, 17)` → `'Thứ 4, 17/06/2026'`
  static String formatDate(DateTime date) {
    final dayName = getDayOfWeekVi(date);
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    return '$dayName, $day/$month/$year';
  }

  /// Returns a short date string without the year.
  ///
  /// Example: `DateTime(2026, 6, 17)` → `'17/06'`
  static String formatDateShort(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month';
  }

  /// Returns a month string in Vietnamese format.
  ///
  /// Example: `DateTime(2026, 6, 1)` → `'Tháng 6/2026'`
  static String formatMonth(DateTime date) {
    return 'Tháng ${date.month}/${date.year}';
  }

  /// Validates and returns the time string as-is if it matches `HH:mm`.
  ///
  /// Throws a [FormatException] if the string does not conform to `HH:mm`.
  ///
  /// Example: `'08:30'` → `'08:30'`
  static String formatTime(String time) {
    final regex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');
    if (!regex.hasMatch(time)) {
      throw FormatException(
        'Invalid time format. Expected HH:mm (e.g. "08:30"), got "$time".',
      );
    }
    return time;
  }

  /// Returns the Vietnamese day-of-week name for [date].
  ///
  /// Monday → `'Thứ 2'`, …, Sunday → `'Chủ nhật'`
  static String getDayOfWeekVi(DateTime date) {
    // dart's weekday: 1=Monday … 7=Sunday
    return _weekdayNames[date.weekday - 1];
  }

  /// Formats [amount] as a Vietnamese currency string.
  ///
  /// Example: `5000000.0` → `'5.000.000 đ'`
  static String formatCurrency(double amount) {
    final intAmount = amount.round();
    final str = intAmount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
      count++;
    }
    return '${buffer.toString().split('').reversed.join()} đ';
  }

  // ─── Predicates ──────────────────────────────────────────────────────────

  /// Returns `true` if [date]'s day-of-week is contained in [weekendDays].
  ///
  /// [weekendDays] should contain Vietnamese day names such as `'Thứ 7'`
  /// or `'Chủ nhật'`.
  static bool isWeekend(DateTime date, List<String> weekendDays) {
    final dayName = getDayOfWeekVi(date);
    return weekendDays.contains(dayName);
  }

  /// Returns `true` if [date] falls on today's calendar date.
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return isSameDay(date, now);
  }

  /// Returns `true` if [date] is strictly after today (ignores time).
  static bool isFuture(DateTime date) {
    final today = _dateOnly(DateTime.now());
    final d = _dateOnly(date);
    return d.isAfter(today);
  }

  /// Returns `true` if [date] is strictly before today (ignores time).
  static bool isPast(DateTime date) {
    final today = _dateOnly(DateTime.now());
    final d = _dateOnly(date);
    return d.isBefore(today);
  }

  /// Returns `true` if [a] and [b] share the same calendar day.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // ─── Date Lists ──────────────────────────────────────────────────────────

  /// Returns a list of the last 7 days, ending with (and including) today,
  /// in ascending chronological order.
  static List<DateTime> getLast7Days() {
    return _lastNDays(7);
  }

  /// Returns a list of the last 30 days, ending with (and including) today,
  /// in ascending chronological order.
  static List<DateTime> getLast30Days() {
    return _lastNDays(30);
  }

  /// Returns the number of days in the given [month] of [year].
  ///
  /// Correctly handles leap years.
  static int getDaysInMonth(int year, int month) {
    // Day 0 of the next month == last day of [month]
    return DateTime(year, month + 1, 0).day;
  }

  /// Returns a list of every [DateTime] in the given [month] of [year],
  /// in ascending chronological order.
  static List<DateTime> getDaysInMonthList(int year, int month) {
    final count = getDaysInMonth(year, month);
    return List.generate(count, (i) => DateTime(year, month, i + 1));
  }

  // ─── Parsing ─────────────────────────────────────────────────────────────

  /// Parses a time string of the form `'H:mm'` or `'HH:mm'` into
  /// fractional hours.
  ///
  /// Example: `'8:30'` → `8.5`, `'20:45'` → `20.75`
  ///
  /// Throws a [FormatException] if the string cannot be parsed.
  static double parseTimeToHours(String time) {
    final parts = time.trim().split(':');
    if (parts.length != 2) {
      throw FormatException('Cannot parse time "$time" — expected H:mm.');
    }
    final hours = int.tryParse(parts[0]);
    final minutes = int.tryParse(parts[1]);
    if (hours == null || minutes == null) {
      throw FormatException('Cannot parse time "$time" — non-numeric parts.');
    }
    if (hours < 0 || hours > 23 || minutes < 0 || minutes > 59) {
      throw FormatException('Time "$time" is out of valid range.');
    }
    return hours + minutes / 60.0;
  }

  // ─── Private helpers ─────────────────────────────────────────────────────

  /// Strips the time portion from [dt], returning midnight of the same day.
  static DateTime _dateOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  /// Returns the last [n] days (including today) in ascending order.
  static List<DateTime> _lastNDays(int n) {
    final today = _dateOnly(DateTime.now());
    return List.generate(n, (i) => today.subtract(Duration(days: n - 1 - i)));
  }
}
