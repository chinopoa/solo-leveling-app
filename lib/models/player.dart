import 'package:hive/hive.dart';
import 'player_stats.dart';

// 1. Add this line. It allows the generator to create the file.
part 'player.g.dart'; 

@HiveType(typeId: 0)
class Player extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int level;

  @HiveField(2)
  int currentXp;

  @HiveField(3)
  int xpToNextLevel;

  @HiveField(4)
  String jobClass;

  @HiveField(5)
  String title;

  @HiveField(6)
  String rank;

  @HiveField(7)
  int currentHp;

  @HiveField(8)
  int maxHp;

  @HiveField(9)
  int currentMp;

  @HiveField(10)
  int maxMp;

  @HiveField(11)
  int fatigue;

  @HiveField(12)
  int gold;

  @HiveField(13)
  int dailyStreak;

  @HiveField(14)
  DateTime lastDailyCompletion;

  @HiveField(15)
  List<String> unlockedTitles;

  @HiveField(16)
  PlayerStats stats;

  Player({
    required this.name,
    this.level = 1,
    this.currentXp = 0,
    this.xpToNextLevel = 100,
    this.jobClass = '???',
    this.title = 'The Weakest',
    this.rank = 'E',
    this.currentHp = 100,
    this.maxHp = 100,
    this.currentMp = 50,
    this.maxMp = 50,
    this.fatigue = 0,
    this.gold = 0,
    this.dailyStreak = 0,
    DateTime? lastDailyCompletion,
    List<String>? unlockedTitles,
    PlayerStats? stats,
  })  : lastDailyCompletion = lastDailyCompletion ?? DateTime.now(),
        unlockedTitles = unlockedTitles ?? ['The Weakest'],
        stats = stats ?? PlayerStats();

  String get calculatedRank {
    if (level >= 100) return 'S';
    if (level >= 75) return 'A';
    if (level >= 50) return 'B';
    if (level >= 30) return 'C';
    if (level >= 15) return 'D';
    return 'E';
  }

  int calculateXpForLevel(int lvl) {
    return (100 * (lvl * 1.5)).toInt();
  }

  LevelUpResult addXp(int amount) {
    currentXp += amount;
    int levelsGained = 0;
    int pointsGained = 0;

    while (currentXp >= xpToNextLevel) {
      currentXp -= xpToNextLevel;
      level++;
      levelsGained++;
      pointsGained += 5;

      maxHp += (10 + stats.vitality ~/ 2);
      maxMp += (5 + stats.intelligence ~/ 2);
      currentHp = maxHp;
      currentMp = maxMp;

      xpToNextLevel = calculateXpForLevel(level);
      rank = calculatedRank;
    }

    if (levelsGained > 0) {
      stats.availablePoints += pointsGained;
      _checkJobAdvancement();
      _checkTitleUnlocks();
    }

    return LevelUpResult(
      levelsGained: levelsGained,
      pointsGained: pointsGained,
      newLevel: level,
    );
  }

  void _checkJobAdvancement() {
    if (level >= 10 && jobClass == '???') {
      jobClass = 'Awakened';
    }
  }

  void _checkTitleUnlocks() {
    if (level >= 10 && !unlockedTitles.contains('Awakened One')) {
      unlockedTitles.add('Awakened One');
    }
    if (level >= 25 && !unlockedTitles.contains('Rising Hunter')) {
      unlockedTitles.add('Rising Hunter');
    }
    if (level >= 50 && !unlockedTitles.contains('Elite Hunter')) {
      unlockedTitles.add('Elite Hunter');
    }
    if (level >= 75 && !unlockedTitles.contains('Shadow Walker')) {
      unlockedTitles.add('Shadow Walker');
    }
    if (level >= 100 && !unlockedTitles.contains('Shadow Monarch')) {
      unlockedTitles.add('Shadow Monarch');
    }
    if (dailyStreak >= 7 && !unlockedTitles.contains('Dedicated')) {
      unlockedTitles.add('Dedicated');
    }
    if (dailyStreak >= 30 && !unlockedTitles.contains('Unbreakable Will')) {
      unlockedTitles.add('Unbreakable Will');
    }
    if (dailyStreak >= 100 && !unlockedTitles.contains('One Who Defies Death')) {
      unlockedTitles.add('One Who Defies Death');
    }
  }

  void addGold(int amount) {
    gold += amount;
  }

  bool spendGold(int amount) {
    if (gold >= amount) {
      gold -= amount;
      return true;
    }
    return false;
  }

  void addFatigue(int amount) {
    fatigue = (fatigue + amount).clamp(0, 100);
  }

  void rest() {
    fatigue = (fatigue - 20).clamp(0, 100);
    currentHp = (currentHp + maxHp ~/ 4).clamp(0, maxHp);
    currentMp = (currentMp + maxMp ~/ 4).clamp(0, maxMp);
  }

  double get hpPercentage => currentHp / maxHp;
  double get mpPercentage => currentMp / maxMp;
  double get xpPercentage => currentXp / xpToNextLevel;
  double get fatiguePercentage => fatigue / 100;

  Map<String, dynamic> toJson() => {
        'name': name,
        'level': level,
        'currentXp': currentXp,
        'xpToNextLevel': xpToNextLevel,
        'jobClass': jobClass,
        'title': title,
        'rank': rank,
        'currentHp': currentHp,
        'maxHp': maxHp,
        'currentMp': currentMp,
        'maxMp': maxMp,
        'fatigue': fatigue,
        'gold': gold,
        'dailyStreak': dailyStreak,
        'lastDailyCompletion': lastDailyCompletion.toIso8601String(),
        'unlockedTitles': unlockedTitles,
        'stats': stats.toJson(),
      };

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        name: json['name'],
        level: json['level'] ?? 1,
        currentXp: json['currentXp'] ?? 0,
        xpToNextLevel: json['xpToNextLevel'] ?? 100,
        jobClass: json['jobClass'] ?? '???',
        title: json['title'] ?? 'The Weakest',
        rank: json['rank'] ?? 'E',
        currentHp: json['currentHp'] ?? 100,
        maxHp: json['maxHp'] ?? 100,
        currentMp: json['currentMp'] ?? 50,
        maxMp: json['maxMp'] ?? 50,
        fatigue: json['fatigue'] ?? 0,
        gold: json['gold'] ?? 0,
        dailyStreak: json['dailyStreak'] ?? 0,
        lastDailyCompletion: json['lastDailyCompletion'] != null
            ? DateTime.parse(json['lastDailyCompletion'])
            : DateTime.now(),
        unlockedTitles: List<String>.from(json['unlockedTitles'] ?? ['The Weakest']),
        stats: json['stats'] != null
            ? PlayerStats.fromJson(json['stats'])
            : PlayerStats(),
      );
}

class LevelUpResult {
  final int levelsGained;
  final int pointsGained;
  final int newLevel;

  LevelUpResult({
    required this.levelsGained,
    required this.pointsGained,
    required this.newLevel,
  });

  bool get didLevelUp => levelsGained > 0;
}
