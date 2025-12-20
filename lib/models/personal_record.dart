import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'personal_record.g.dart';

/// Categories for personal records
enum PRCategory { fitness, streak, achievement, nutrition }

@HiveType(typeId: 11)
class PRHistoryEntry {
  @HiveField(0)
  double value;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  String? note;

  PRHistoryEntry({
    required this.value,
    required this.date,
    this.note,
  });
}

@HiveType(typeId: 12)
class PersonalRecord extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String category; // PRCategory as string

  @HiveField(3)
  double currentValue;

  @HiveField(4)
  String unit; // "reps", "km", "days", "kcal", etc.

  @HiveField(5)
  DateTime achievedAt;

  @HiveField(6)
  List<PRHistoryEntry> history;

  @HiveField(7)
  String? relatedQuestType; // Links to quest type if applicable

  @HiveField(8)
  bool isAutoTracked; // True for automatically tracked PRs

  @HiveField(9)
  String? iconEmoji;

  @HiveField(10)
  double? previousValue; // For showing improvement

  PersonalRecord({
    String? id,
    required this.name,
    required this.category,
    this.currentValue = 0,
    required this.unit,
    DateTime? achievedAt,
    List<PRHistoryEntry>? history,
    this.relatedQuestType,
    this.isAutoTracked = false,
    this.iconEmoji,
    this.previousValue,
  })  : id = id ?? const Uuid().v4(),
        achievedAt = achievedAt ?? DateTime.now(),
        history = history ?? [];

  PRCategory get prCategory => PRCategory.values.firstWhere(
        (e) => e.name == category,
        orElse: () => PRCategory.achievement,
      );

  /// Check if a new value beats the current record
  bool isNewRecord(double newValue) {
    return newValue > currentValue;
  }

  /// Update the record with a new value
  /// Returns true if it was a new record
  bool updateRecord(double newValue, {String? note}) {
    if (!isNewRecord(newValue)) return false;

    // Save current to history
    history.add(PRHistoryEntry(
      value: currentValue,
      date: achievedAt,
      note: note,
    ));

    previousValue = currentValue;
    currentValue = newValue;
    achievedAt = DateTime.now();

    save();
    return true;
  }

  /// Get improvement over previous record
  double get improvement {
    if (previousValue == null || previousValue == 0) return 0;
    return currentValue - previousValue!;
  }

  /// Get improvement percentage
  double get improvementPercentage {
    if (previousValue == null || previousValue == 0) return 0;
    return ((currentValue - previousValue!) / previousValue!) * 100;
  }

  /// Format value with unit
  String get formattedValue {
    if (currentValue == currentValue.toInt()) {
      return '${currentValue.toInt()} $unit';
    }
    return '${currentValue.toStringAsFixed(1)} $unit';
  }

  /// Create default personal records for tracking
  static List<PersonalRecord> createDefaultRecords() {
    return [
      // Fitness PRs
      PersonalRecord(
        name: 'Most Push-ups',
        category: 'fitness',
        unit: 'reps',
        iconEmoji: '💪',
        isAutoTracked: true,
        relatedQuestType: 'daily',
      ),
      PersonalRecord(
        name: 'Most Sit-ups',
        category: 'fitness',
        unit: 'reps',
        iconEmoji: '🏋️',
        isAutoTracked: true,
        relatedQuestType: 'daily',
      ),
      PersonalRecord(
        name: 'Most Squats',
        category: 'fitness',
        unit: 'reps',
        iconEmoji: '🦵',
        isAutoTracked: true,
        relatedQuestType: 'daily',
      ),
      PersonalRecord(
        name: 'Longest Run',
        category: 'fitness',
        unit: 'km',
        iconEmoji: '🏃',
        isAutoTracked: true,
        relatedQuestType: 'daily',
      ),

      // Streak PRs
      PersonalRecord(
        name: 'Longest Daily Streak',
        category: 'streak',
        unit: 'days',
        iconEmoji: '🔥',
        isAutoTracked: true,
      ),
      PersonalRecord(
        name: 'Longest Training Streak',
        category: 'streak',
        unit: 'days',
        iconEmoji: '⚡',
        isAutoTracked: true,
      ),

      // Achievement PRs
      PersonalRecord(
        name: 'Highest Level',
        category: 'achievement',
        unit: 'level',
        iconEmoji: '⭐',
        isAutoTracked: true,
      ),
      PersonalRecord(
        name: 'Most Quests in Day',
        category: 'achievement',
        unit: 'quests',
        iconEmoji: '📋',
        isAutoTracked: true,
      ),

      // Nutrition PRs
      PersonalRecord(
        name: 'Best Nutrition Week',
        category: 'nutrition',
        unit: 'days on target',
        iconEmoji: '🥗',
        isAutoTracked: true,
      ),
    ];
  }
}
