import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'activity_log.g.dart';

/// Types of activities that can be logged
enum ActivityType {
  strength, // Push-ups, weights, etc.
  cardio, // Running, cycling, etc.
  nutrition, // Hitting nutrition goals
  learning, // Reading, courses, etc.
  mindfulness, // Meditation, journaling
  recovery, // Rest days, sleep
  quest, // Completing quests
  habit, // Completing habits
  goal, // Goal progress
}

@HiveType(typeId: 16)
class ActivityLog extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String activityType; // ActivityType as string

  @HiveField(2)
  String? statAffected; // STR, AGI, VIT, INT, SEN

  @HiveField(3)
  int statPoints; // Points earned for this stat

  @HiveField(4)
  DateTime timestamp;

  @HiveField(5)
  String? sourceId; // Quest ID, Habit ID, Goal ID, etc.

  @HiveField(6)
  String sourceType; // quest, habit, goal, manual

  @HiveField(7)
  String? note;

  @HiveField(8)
  int xpEarned;

  @HiveField(9)
  String? skillId; // Skill that was progressed

  ActivityLog({
    String? id,
    required this.activityType,
    this.statAffected,
    this.statPoints = 0,
    DateTime? timestamp,
    this.sourceId,
    required this.sourceType,
    this.note,
    this.xpEarned = 0,
    this.skillId,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  ActivityType get type => ActivityType.values.firstWhere(
        (e) => e.name == activityType,
        orElse: () => ActivityType.quest,
      );

  /// Get the appropriate stat for an activity type
  static String? getStatForActivity(ActivityType type) {
    switch (type) {
      case ActivityType.strength:
        return 'STR';
      case ActivityType.cardio:
        return 'AGI';
      case ActivityType.nutrition:
      case ActivityType.recovery:
        return 'VIT';
      case ActivityType.learning:
        return 'INT';
      case ActivityType.mindfulness:
        return 'SEN';
      default:
        return null;
    }
  }

  /// Get activity type from stat
  static ActivityType? getActivityForStat(String stat) {
    switch (stat.toUpperCase()) {
      case 'STR':
        return ActivityType.strength;
      case 'AGI':
        return ActivityType.cardio;
      case 'VIT':
        return ActivityType.nutrition;
      case 'INT':
        return ActivityType.learning;
      case 'SEN':
        return ActivityType.mindfulness;
      default:
        return null;
    }
  }

  /// Create a log entry from a quest completion
  static ActivityLog fromQuest({
    required String questId,
    required String? statBonus,
    required int statAmount,
    required int xp,
    String? skillId,
  }) {
    final activityType = statBonus != null
        ? getActivityForStat(statBonus)?.name ?? 'quest'
        : 'quest';

    return ActivityLog(
      activityType: activityType,
      statAffected: statBonus,
      statPoints: statAmount,
      sourceId: questId,
      sourceType: 'quest',
      xpEarned: xp,
      skillId: skillId,
    );
  }

  /// Create a log entry from a habit completion
  static ActivityLog fromHabit({
    required String habitId,
    required String? relatedStat,
    required int xp,
    String? skillId,
  }) {
    final activityType = relatedStat != null
        ? getActivityForStat(relatedStat)?.name ?? 'habit'
        : 'habit';

    return ActivityLog(
      activityType: activityType,
      statAffected: relatedStat,
      statPoints: relatedStat != null ? 5 : 0, // 5 points per habit completion
      sourceId: habitId,
      sourceType: 'habit',
      xpEarned: xp,
      skillId: skillId,
    );
  }
}

/// Extension to aggregate activity logs
extension ActivityLogAggregation on List<ActivityLog> {
  /// Get total stat points earned for a specific stat
  int totalPointsForStat(String stat) {
    return where((log) => log.statAffected == stat)
        .fold(0, (sum, log) => sum + log.statPoints);
  }

  /// Get all logs for today
  List<ActivityLog> get todaysLogs {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return where((log) {
      final logDate = DateTime(
        log.timestamp.year,
        log.timestamp.month,
        log.timestamp.day,
      );
      return logDate == today;
    }).toList();
  }

  /// Get all logs for the last N days
  List<ActivityLog> logsForLastDays(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return where((log) => log.timestamp.isAfter(cutoff)).toList();
  }

  /// Get stat points earned in time period
  Map<String, int> statPointsSince(DateTime since) {
    final result = <String, int>{
      'STR': 0,
      'AGI': 0,
      'VIT': 0,
      'INT': 0,
      'SEN': 0,
    };

    for (final log in this) {
      if (log.timestamp.isAfter(since) && log.statAffected != null) {
        result[log.statAffected!] =
            (result[log.statAffected!] ?? 0) + log.statPoints;
      }
    }

    return result;
  }
}
