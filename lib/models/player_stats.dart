import 'package:hive/hive.dart';

// This connects the file to the generated adapter
part 'player_stats.g.dart';

@HiveType(typeId: 1)
class PlayerStats {
  @HiveField(0)
  int strength;

  @HiveField(1)
  int agility;

  @HiveField(2)
  int vitality;

  @HiveField(3)
  int intelligence;

  @HiveField(4)
  int sense;

  @HiveField(5)
  int availablePoints;

  PlayerStats({
    this.strength = 10,
    this.agility = 10,
    this.vitality = 10,
    this.intelligence = 10,
    this.sense = 10,
    this.availablePoints = 0,
  });

  int get totalStats => strength + agility + vitality + intelligence + sense;

  Map<String, int> toMap() => {
        'STR': strength,
        'AGI': agility,
        'VIT': vitality,
        'INT': intelligence,
        'SEN': sense,
      };

  void allocatePoint(String stat) {
    if (availablePoints <= 0) return;

    switch (stat.toUpperCase()) {
      case 'STR':
      case 'STRENGTH':
        strength++;
        break;
      case 'AGI':
      case 'AGILITY':
        agility++;
        break;
      case 'VIT':
      case 'VITALITY':
        vitality++;
        break;
      case 'INT':
      case 'INTELLIGENCE':
        intelligence++;
        break;
      case 'SEN':
      case 'SENSE':
      case 'PERCEPTION': // Handled just in case
        sense++;
        break;
      default:
        return;
    }
    availablePoints--;
  }

  Map<String, dynamic> toJson() => {
        'strength': strength,
        'agility': agility,
        'vitality': vitality,
        'intelligence': intelligence,
        'sense': sense,
        'availablePoints': availablePoints,
      };

  factory PlayerStats.fromJson(Map<String, dynamic> json) => PlayerStats(
        strength: json['strength'] ?? 10,
        agility: json['agility'] ?? 10,
        vitality: json['vitality'] ?? 10,
        intelligence: json['intelligence'] ?? 10,
        sense: json['sense'] ?? 10,
        availablePoints: json['availablePoints'] ?? 0,
      );
}