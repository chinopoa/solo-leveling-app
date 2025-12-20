import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'habit.g.dart';

/// Frequency types for habits
enum HabitFrequency { daily, weekly, custom }

@HiveType(typeId: 15)
class Habit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  String frequency; // HabitFrequency as string

  @HiveField(4)
  int targetPerPeriod; // e.g., 1 for daily, 3 for 3x/week

  @HiveField(5)
  int currentStreak;

  @HiveField(6)
  int longestStreak;

  @HiveField(7)
  List<String> completionDates; // YYYY-MM-DD format

  @HiveField(8)
  String? relatedStat; // STR, AGI, VIT, INT, SEN

  @HiveField(9)
  String? relatedSkillId;

  @HiveField(10)
  DateTime createdAt;

  @HiveField(11)
  bool isEnabled;

  @HiveField(12)
  String? iconEmoji;

  @HiveField(13)
  int xpPerCompletion;

  @HiveField(14)
  List<int>? customDays; // For custom frequency [1,2,3,4,5] = Mon-Fri

  @HiveField(15)
  bool isDefault; // True for built-in habits

  Habit({
    String? id,
    required this.name,
    this.description,
    this.frequency = 'daily',
    this.targetPerPeriod = 1,
    this.currentStreak = 0,
    this.longestStreak = 0,
    List<String>? completionDates,
    this.relatedStat,
    this.relatedSkillId,
    DateTime? createdAt,
    this.isEnabled = true,
    this.iconEmoji,
    this.xpPerCompletion = 25,
    this.customDays,
    this.isDefault = false,
  })  : id = id ?? const Uuid().v4(),
        completionDates = completionDates ?? [],
        createdAt = createdAt ?? DateTime.now();

  HabitFrequency get habitFrequency => HabitFrequency.values.firstWhere(
        (e) => e.name == frequency,
        orElse: () => HabitFrequency.daily,
      );

  /// Get today's date as string
  static String _dateToString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Check if habit is completed for a specific date
  bool isCompletedForDate(DateTime date) {
    return completionDates.contains(_dateToString(date));
  }

  /// Check if habit is completed today
  bool get isCompletedToday => isCompletedForDate(DateTime.now());

  /// Check if habit should be done today based on frequency
  bool get isDueToday {
    if (!isEnabled) return false;

    final now = DateTime.now();
    switch (habitFrequency) {
      case HabitFrequency.daily:
        return true;
      case HabitFrequency.weekly:
        // Due any day of the week
        return true;
      case HabitFrequency.custom:
        if (customDays == null) return true;
        // 1 = Monday, 7 = Sunday
        return customDays!.contains(now.weekday);
    }
  }

  /// Get completions this week
  int get completionsThisWeek {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    int count = 0;
    for (int i = 0; i < 7; i++) {
      final date = weekStart.add(Duration(days: i));
      if (isCompletedForDate(date)) count++;
    }
    return count;
  }

  /// Check if weekly target is met
  bool get isWeeklyTargetMet {
    if (habitFrequency != HabitFrequency.weekly) return false;
    return completionsThisWeek >= targetPerPeriod;
  }

  /// Complete habit for a specific date
  void completeForDate(DateTime date) {
    final dateStr = _dateToString(date);
    if (!completionDates.contains(dateStr)) {
      completionDates.add(dateStr);
      _updateStreak();
      save();
    }
  }

  /// Complete habit for today
  void completeToday() {
    completeForDate(DateTime.now());
  }

  /// Uncomplete habit for a specific date
  void uncompleteForDate(DateTime date) {
    final dateStr = _dateToString(date);
    completionDates.remove(dateStr);
    _updateStreak();
    save();
  }

  /// Update streak based on completion history
  void _updateStreak() {
    final now = DateTime.now();
    int streak = 0;

    // Count backwards from today
    for (int i = 0; i <= completionDates.length + 30; i++) {
      final checkDate = now.subtract(Duration(days: i));

      // Skip days when habit isn't due (for custom frequency)
      if (habitFrequency == HabitFrequency.custom && customDays != null) {
        if (!customDays!.contains(checkDate.weekday)) continue;
      }

      if (isCompletedForDate(checkDate)) {
        streak++;
      } else if (i > 0) {
        // Allow missing today, but break on previous missed days
        break;
      }
    }

    currentStreak = streak;
    if (currentStreak > longestStreak) {
      longestStreak = currentStreak;
    }
  }

  /// Get completion rate for last N days
  double getCompletionRate(int days) {
    final now = DateTime.now();
    int completed = 0;
    int due = 0;

    for (int i = 0; i < days; i++) {
      final checkDate = now.subtract(Duration(days: i));

      // Check if habit was due on this day
      bool wasDue = true;
      if (habitFrequency == HabitFrequency.custom && customDays != null) {
        wasDue = customDays!.contains(checkDate.weekday);
      }

      if (wasDue) {
        due++;
        if (isCompletedForDate(checkDate)) completed++;
      }
    }

    return due > 0 ? completed / due : 0;
  }

  /// Get last N days completion status for calendar view
  List<bool?> getLastNDaysStatus(int days) {
    final now = DateTime.now();
    final result = <bool?>[];

    for (int i = days - 1; i >= 0; i--) {
      final checkDate = now.subtract(Duration(days: i));

      // Check if habit was due on this day
      bool wasDue = true;
      if (habitFrequency == HabitFrequency.custom && customDays != null) {
        wasDue = customDays!.contains(checkDate.weekday);
      }

      if (!wasDue) {
        result.add(null); // Not due
      } else {
        result.add(isCompletedForDate(checkDate));
      }
    }

    return result;
  }
}
