import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'quest.dart';

part 'dungeon.g.dart';

enum DungeonRank { E, D, C, B, A, S }

@HiveType(typeId: 5)
class Dungeon extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  String rank; // E, D, C, B, A, S

  @HiveField(4)
  List<String> questIds; // Sub-quest IDs (mobs and bosses)

  @HiveField(5)
  String? bossQuestId; // The final boss quest

  @HiveField(6)
  bool isCleared;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime? clearedAt;

  @HiveField(9)
  int totalXpReward;

  @HiveField(10)
  int totalGoldReward;

  @HiveField(11)
  String? rewardItemId; // Special item reward for clearing

  Dungeon({
    String? id,
    required this.name,
    this.description = '',
    this.rank = 'E',
    List<String>? questIds,
    this.bossQuestId,
    this.isCleared = false,
    DateTime? createdAt,
    this.clearedAt,
    this.totalXpReward = 0,
    this.totalGoldReward = 0,
    this.rewardItemId,
  })  : id = id ?? const Uuid().v4(),
        questIds = questIds ?? [],
        createdAt = createdAt ?? DateTime.now();

  DungeonRank get dungeonRank => DungeonRank.values.firstWhere(
        (e) => e.name == rank,
        orElse: () => DungeonRank.E,
      );

  void addQuest(Quest quest) {
    questIds.add(quest.id);
    totalXpReward += quest.xpReward;
    totalGoldReward += quest.goldReward;
    save();
  }

  void setBoss(Quest bossQuest) {
    bossQuestId = bossQuest.id;
    addQuest(bossQuest);
  }

  void clear() {
    isCleared = true;
    clearedAt = DateTime.now();
    save();
  }

  // Calculate completion percentage based on completed quests
  double getProgress(List<Quest> allQuests) {
    if (questIds.isEmpty) return 0;

    final dungeonQuests =
        allQuests.where((q) => questIds.contains(q.id)).toList();
    if (dungeonQuests.isEmpty) return 0;

    final completed = dungeonQuests.where((q) => q.isCompleted).length;
    return completed / dungeonQuests.length;
  }

  // Create a dungeon with sub-tasks
  static Dungeon createProject({
    required String name,
    required String description,
    required DungeonRank rank,
    required List<String> subTasks,
    required String bossTask,
  }) {
    final dungeon = Dungeon(
      name: name,
      description: description,
      rank: rank.name,
    );

    // Calculate rewards based on rank
    int xpMultiplier;
    int goldMultiplier;

    switch (rank) {
      case DungeonRank.E:
        xpMultiplier = 1;
        goldMultiplier = 1;
        break;
      case DungeonRank.D:
        xpMultiplier = 2;
        goldMultiplier = 2;
        break;
      case DungeonRank.C:
        xpMultiplier = 3;
        goldMultiplier = 3;
        break;
      case DungeonRank.B:
        xpMultiplier = 5;
        goldMultiplier = 5;
        break;
      case DungeonRank.A:
        xpMultiplier = 8;
        goldMultiplier = 8;
        break;
      case DungeonRank.S:
        xpMultiplier = 15;
        goldMultiplier = 15;
        break;
    }

    dungeon.totalXpReward = 100 * xpMultiplier * (subTasks.length + 1);
    dungeon.totalGoldReward = 50 * goldMultiplier * (subTasks.length + 1);

    return dungeon;
  }
}
