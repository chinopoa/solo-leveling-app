import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'quest.g.dart';

enum QuestType { daily, normal, emergency, dungeon, penalty }

enum QuestDifficulty { easy, normal, hard, boss }

enum QuestStatus { active, completed, failed, expired }

@HiveType(typeId: 2)
class Quest extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  int xpReward;

  @HiveField(4)
  int goldReward;

  @HiveField(5)
  String questType; // Stored as string for Hive

  @HiveField(6)
  String difficulty; // Stored as string for Hive

  @HiveField(7)
  String status; // Stored as string for Hive

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime? deadline;

  @HiveField(10)
  DateTime? completedAt;

  @HiveField(11)
  String? statBonus; // Which stat this quest benefits (STR, INT, etc.)

  @HiveField(12)
  int statBonusAmount;

  @HiveField(13)
  bool isRepeatable;

  @HiveField(14)
  int targetCount; // For quests like "Do 100 pushups"

  @HiveField(15)
  int currentCount;

  @HiveField(16)
  String? parentDungeonId; // If this quest is part of a dungeon

  Quest({
    String? id,
    required this.title,
    this.description = '',
    this.xpReward = 50,
    this.goldReward = 10,
    this.questType = 'normal',
    this.difficulty = 'normal',
    this.status = 'active',
    DateTime? createdAt,
    this.deadline,
    this.completedAt,
    this.statBonus,
    this.statBonusAmount = 0,
    this.isRepeatable = false,
    this.targetCount = 1,
    this.currentCount = 0,
    this.parentDungeonId,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  QuestType get type => QuestType.values.firstWhere(
        (e) => e.name == questType,
        orElse: () => QuestType.normal,
      );

  QuestDifficulty get difficultyLevel => QuestDifficulty.values.firstWhere(
        (e) => e.name == difficulty,
        orElse: () => QuestDifficulty.normal,
      );

  QuestStatus get currentStatus => QuestStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => QuestStatus.active,
      );

  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
  bool get isActive => status == 'active';
  bool get isExpired {
    if (deadline == null) return false;
    return DateTime.now().isAfter(deadline!) && !isCompleted;
  }

  double get progressPercentage =>
      targetCount > 0 ? (currentCount / targetCount).clamp(0.0, 1.0) : 0.0;

  void incrementProgress([int amount = 1]) {
    currentCount = (currentCount + amount).clamp(0, targetCount);
    if (currentCount >= targetCount) {
      complete();
    }
    save();
  }

  void complete() {
    status = 'completed';
    completedAt = DateTime.now();
    save();
  }

  void fail() {
    status = 'failed';
    save();
  }

  // Calculate rewards based on difficulty
  static Quest createWithDifficulty({
    required String title,
    required String description,
    required QuestDifficulty difficulty,
    required QuestType type,
    String? statBonus,
    DateTime? deadline,
    int targetCount = 1,
    String? parentDungeonId,
  }) {
    int xp;
    int gold;
    int statAmount;

    switch (difficulty) {
      case QuestDifficulty.easy:
        xp = 25;
        gold = 5;
        statAmount = 1;
        break;
      case QuestDifficulty.normal:
        xp = 50;
        gold = 15;
        statAmount = 2;
        break;
      case QuestDifficulty.hard:
        xp = 100;
        gold = 30;
        statAmount = 3;
        break;
      case QuestDifficulty.boss:
        xp = 250;
        gold = 100;
        statAmount = 5;
        break;
    }

    // Daily quests get bonus
    if (type == QuestType.daily) {
      xp = (xp * 1.5).toInt();
    }

    // Emergency quests get even more
    if (type == QuestType.emergency) {
      xp = (xp * 2).toInt();
      gold = (gold * 2).toInt();
    }

    return Quest(
      title: title,
      description: description,
      xpReward: xp,
      goldReward: gold,
      questType: type.name,
      difficulty: difficulty.name,
      statBonus: statBonus,
      statBonusAmount: statAmount,
      deadline: deadline,
      targetCount: targetCount,
      isRepeatable: type == QuestType.daily,
      parentDungeonId: parentDungeonId,
    );
  }
}
