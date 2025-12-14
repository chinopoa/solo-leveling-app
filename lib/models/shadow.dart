import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'shadow.g.dart';

enum ShadowRank { soldier, elite, knight, commander, marshal }

/// Shadows are "extracted" from completed dungeons (projects)
/// They represent your past achievements and can provide passive bonuses
@HiveType(typeId: 6)
class Shadow extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String originalDungeonName;

  @HiveField(3)
  String rank; // soldier, elite, knight, commander, marshal

  @HiveField(4)
  String type; // What kind of shadow (coding, fitness, creative, etc.)

  @HiveField(5)
  DateTime extractedAt;

  @HiveField(6)
  int powerLevel;

  @HiveField(7)
  String? passiveBonus; // e.g., "+10% XP to coding tasks"

  @HiveField(8)
  int passiveBonusAmount;

  Shadow({
    String? id,
    required this.name,
    required this.originalDungeonName,
    this.rank = 'soldier',
    this.type = 'general',
    DateTime? extractedAt,
    this.powerLevel = 1,
    this.passiveBonus,
    this.passiveBonusAmount = 0,
  })  : id = id ?? const Uuid().v4(),
        extractedAt = extractedAt ?? DateTime.now();

  ShadowRank get shadowRank => ShadowRank.values.firstWhere(
        (e) => e.name == rank,
        orElse: () => ShadowRank.soldier,
      );

  // Create shadow from completed dungeon
  static Shadow fromDungeon({
    required String dungeonName,
    required String dungeonRank,
    required String shadowName,
    required String type,
  }) {
    String shadowRankStr;
    int power;
    int bonusAmount;

    switch (dungeonRank) {
      case 'S':
        shadowRankStr = 'marshal';
        power = 100;
        bonusAmount = 15;
        break;
      case 'A':
        shadowRankStr = 'commander';
        power = 75;
        bonusAmount = 12;
        break;
      case 'B':
        shadowRankStr = 'knight';
        power = 50;
        bonusAmount = 10;
        break;
      case 'C':
        shadowRankStr = 'elite';
        power = 30;
        bonusAmount = 7;
        break;
      default:
        shadowRankStr = 'soldier';
        power = 10;
        bonusAmount = 5;
    }

    return Shadow(
      name: shadowName,
      originalDungeonName: dungeonName,
      rank: shadowRankStr,
      type: type,
      powerLevel: power,
      passiveBonus: '+$bonusAmount% XP to $type tasks',
      passiveBonusAmount: bonusAmount,
    );
  }

  // Famous shadow names for suggestions
  static List<String> get suggestedNames => [
    'Igris',
    'Iron',
    'Tank',
    'Beru',
    'Tusk',
    'Jima',
    'Greed',
    'Fang',
    'Kaiser',
    'Bellion',
  ];
}

@HiveType(typeId: 7)
class ShadowArmy extends HiveObject {
  @HiveField(0)
  List<String> shadowIds;

  @HiveField(1)
  int totalPower;

  @HiveField(2)
  int maxCapacity;

  ShadowArmy({
    List<String>? shadowIds,
    this.totalPower = 0,
    this.maxCapacity = 10,
  }) : shadowIds = shadowIds ?? [];

  int get count => shadowIds.length;
  bool get isFull => count >= maxCapacity;

  void addShadow(Shadow shadow) {
    if (!isFull) {
      shadowIds.add(shadow.id);
      totalPower += shadow.powerLevel;
      save();
    }
  }

  // Increase capacity as player levels up
  void upgradeCapacity(int playerLevel) {
    maxCapacity = 10 + (playerLevel ~/ 10) * 5;
    save();
  }
}
