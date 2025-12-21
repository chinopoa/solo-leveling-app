import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'skill.g.dart';

/// Hunter Skill ranks (E → S like Hunter ranks)
enum SkillRank { e, d, c, b, a, s }

/// Skill categories matching the stat system
enum SkillCategory { combat, agility, vitality, intelligence, perception }

@HiveType(typeId: 17)
class Skill extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String category; // SkillCategory as string

  @HiveField(3)
  String rank; // SkillRank as string

  @HiveField(4)
  int currentXp;

  @HiveField(5)
  int xpToNextRank;

  @HiveField(6)
  String? relatedStat; // STR, AGI, VIT, INT, SEN

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime lastProgressAt;

  @HiveField(9)
  String? iconEmoji;

  @HiveField(10)
  int totalXpEarned;

  @HiveField(11)
  String? description;

  Skill({
    String? id,
    required this.name,
    required this.category,
    this.rank = 'e',
    this.currentXp = 0,
    this.xpToNextRank = 100,
    this.relatedStat,
    DateTime? createdAt,
    DateTime? lastProgressAt,
    this.iconEmoji,
    this.totalXpEarned = 0,
    this.description,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        lastProgressAt = lastProgressAt ?? DateTime.now();

  SkillRank get skillRank => SkillRank.values.firstWhere(
        (e) => e.name == rank,
        orElse: () => SkillRank.e,
      );

  SkillCategory get skillCategory => SkillCategory.values.firstWhere(
        (e) => e.name == category,
        orElse: () => SkillCategory.combat,
      );

  /// Get display name for rank (uppercase)
  String get rankDisplay => rank.toUpperCase();

  /// Get the next rank, or null if already S rank
  SkillRank? get nextRank {
    final currentIndex = SkillRank.values.indexOf(skillRank);
    if (currentIndex >= SkillRank.values.length - 1) return null;
    return SkillRank.values[currentIndex + 1];
  }

  /// Check if skill can rank up
  bool get canRankUp => currentXp >= xpToNextRank && nextRank != null;

  /// Progress percentage to next rank (0.0 to 1.0)
  double get progressPercentage =>
      xpToNextRank > 0 ? (currentXp / xpToNextRank).clamp(0.0, 1.0) : 1.0;

  /// Add XP to skill and check for rank up
  /// Returns true if rank up occurred
  bool addXp(int amount) {
    currentXp += amount;
    totalXpEarned += amount;
    lastProgressAt = DateTime.now();

    if (canRankUp) {
      return rankUp();
    }

    save();
    return false;
  }

  /// Rank up the skill
  bool rankUp() {
    if (nextRank == null) return false;

    final overflow = currentXp - xpToNextRank;
    rank = nextRank!.name;
    currentXp = overflow > 0 ? overflow : 0;
    xpToNextRank = _getXpRequiredForRank(skillRank);

    save();
    return true;
  }

  /// Get XP required for each rank
  static int _getXpRequiredForRank(SkillRank rank) {
    switch (rank) {
      case SkillRank.e:
        return 100; // E → D
      case SkillRank.d:
        return 250; // D → C
      case SkillRank.c:
        return 500; // C → B
      case SkillRank.b:
        return 1000; // B → A
      case SkillRank.a:
        return 2500; // A → S
      case SkillRank.s:
        return 9999; // Max rank
    }
  }

  /// Create default skills for a new player
  static List<Skill> createDefaultSkills() {
    return [
      Skill(
        name: 'Combat',
        category: 'combat',
        relatedStat: 'STR',
        iconEmoji: '⚔️',
        description: 'Physical strength and power training',
      ),
      Skill(
        name: 'Agility',
        category: 'agility',
        relatedStat: 'AGI',
        iconEmoji: '💨',
        description: 'Speed, cardio, and movement training',
      ),
      Skill(
        name: 'Vitality',
        category: 'vitality',
        relatedStat: 'VIT',
        iconEmoji: '❤️',
        description: 'Endurance, nutrition, and recovery',
      ),
      Skill(
        name: 'Intelligence',
        category: 'intelligence',
        relatedStat: 'INT',
        iconEmoji: '📚',
        description: 'Learning, reading, and mental growth',
      ),
      Skill(
        name: 'Perception',
        category: 'perception',
        relatedStat: 'SEN',
        iconEmoji: '👁️',
        description: 'Mindfulness, awareness, and focus',
      ),
    ];
  }
}
