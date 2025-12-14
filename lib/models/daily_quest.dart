import 'package:hive/hive.dart';
import 'quest.dart';

part 'daily_quest.g.dart';

/// The iconic "Daily Quest: Strength of the Weak"
/// These are the non-negotiable daily habits
@HiveType(typeId: 3)
class DailyQuestConfig extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  int targetCount;

  @HiveField(3)
  String statBonus;

  @HiveField(4)
  bool isEnabled;

  @HiveField(5)
  int order;

  DailyQuestConfig({
    required this.id,
    required this.title,
    this.targetCount = 1,
    this.statBonus = 'STR',
    this.isEnabled = true,
    this.order = 0,
  });

  Quest toQuest() {
    return Quest.createWithDifficulty(
      title: title,
      description: 'Daily Quest: Complete $targetCount $title',
      difficulty: QuestDifficulty.normal,
      type: QuestType.daily,
      statBonus: statBonus,
      targetCount: targetCount,
      deadline: _getTodayMidnight(),
    );
  }

  static DateTime _getTodayMidnight() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }

  // Default daily quests (the canonical ones from Solo Leveling)
  static List<DailyQuestConfig> getDefaults() {
    return [
      DailyQuestConfig(
        id: 'pushups',
        title: 'Push-ups',
        targetCount: 100,
        statBonus: 'STR',
        order: 0,
      ),
      DailyQuestConfig(
        id: 'situps',
        title: 'Sit-ups',
        targetCount: 100,
        statBonus: 'STR',
        order: 1,
      ),
      DailyQuestConfig(
        id: 'squats',
        title: 'Squats',
        targetCount: 100,
        statBonus: 'AGI',
        order: 2,
      ),
      DailyQuestConfig(
        id: 'running',
        title: 'Running (km)',
        targetCount: 10,
        statBonus: 'VIT',
        order: 3,
      ),
    ];
  }
}

@HiveType(typeId: 4)
class DailyQuestProgress extends HiveObject {
  @HiveField(0)
  String date; // YYYY-MM-DD format

  @HiveField(1)
  Map<String, int> progress; // questId -> current count

  @HiveField(2)
  bool isCompleted;

  @HiveField(3)
  bool penaltyTriggered;

  @HiveField(4)
  DateTime? completedAt;

  DailyQuestProgress({
    required this.date,
    Map<String, int>? progress,
    this.isCompleted = false,
    this.penaltyTriggered = false,
    this.completedAt,
  }) : progress = progress ?? {};

  static String getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  int getProgress(String questId) => progress[questId] ?? 0;

  void updateProgress(String questId, int count) {
    progress[questId] = count;
    save();
  }

  void incrementProgress(String questId, [int amount = 1]) {
    progress[questId] = (progress[questId] ?? 0) + amount;
    save();
  }

  bool checkAllCompleted(List<DailyQuestConfig> configs) {
    for (final config in configs.where((c) => c.isEnabled)) {
      if ((progress[config.id] ?? 0) < config.targetCount) {
        return false;
      }
    }
    isCompleted = true;
    completedAt = DateTime.now();
    save();
    return true;
  }
}
