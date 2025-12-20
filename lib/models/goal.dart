import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'goal.g.dart';

/// Goal status types
enum GoalStatus { active, completed, paused, abandoned }

@HiveType(typeId: 13)
class Milestone {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  double targetValue;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  DateTime? completedAt;

  @HiveField(5)
  int xpReward;

  Milestone({
    String? id,
    required this.title,
    required this.targetValue,
    this.isCompleted = false,
    this.completedAt,
    this.xpReward = 50,
  }) : id = id ?? const Uuid().v4();

  void complete() {
    isCompleted = true;
    completedAt = DateTime.now();
  }
}

@HiveType(typeId: 14)
class Goal extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  double targetValue;

  @HiveField(4)
  double currentProgress;

  @HiveField(5)
  String unit; // "books", "km", "sessions", etc.

  @HiveField(6)
  List<Milestone> milestones;

  @HiveField(7)
  DateTime? deadline;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime? completedAt;

  @HiveField(10)
  String status; // GoalStatus as string

  @HiveField(11)
  String? relatedSkillId; // Completing advances a skill

  @HiveField(12)
  String? iconEmoji;

  @HiveField(13)
  int xpReward; // XP for completing the entire goal

  @HiveField(14)
  String? category; // For grouping goals

  Goal({
    String? id,
    required this.title,
    this.description = '',
    required this.targetValue,
    this.currentProgress = 0,
    required this.unit,
    List<Milestone>? milestones,
    this.deadline,
    DateTime? createdAt,
    this.completedAt,
    this.status = 'active',
    this.relatedSkillId,
    this.iconEmoji,
    this.xpReward = 500,
    this.category,
  })  : id = id ?? const Uuid().v4(),
        milestones = milestones ?? [],
        createdAt = createdAt ?? DateTime.now();

  GoalStatus get goalStatus => GoalStatus.values.firstWhere(
        (e) => e.name == status,
        orElse: () => GoalStatus.active,
      );

  /// Progress percentage (0.0 to 1.0)
  double get progressPercentage =>
      targetValue > 0 ? (currentProgress / targetValue).clamp(0.0, 1.0) : 0.0;

  /// Check if goal is completed
  bool get isCompleted => status == 'completed';

  /// Check if goal is active
  bool get isActive => status == 'active';

  /// Check if goal is overdue
  bool get isOverdue {
    if (deadline == null || isCompleted) return false;
    return DateTime.now().isAfter(deadline!);
  }

  /// Days remaining until deadline
  int? get daysRemaining {
    if (deadline == null) return null;
    return deadline!.difference(DateTime.now()).inDays;
  }

  /// Count completed milestones
  int get completedMilestones =>
      milestones.where((m) => m.isCompleted).length;

  /// Get next uncompleted milestone
  Milestone? get nextMilestone {
    try {
      return milestones.firstWhere((m) => !m.isCompleted);
    } catch (e) {
      return null;
    }
  }

  /// Update progress and check milestones
  /// Returns list of newly completed milestone titles
  List<String> updateProgress(double newProgress) {
    currentProgress = newProgress.clamp(0, targetValue);
    List<String> completedMilestoneNames = [];

    // Check milestones
    for (final milestone in milestones) {
      if (!milestone.isCompleted && currentProgress >= milestone.targetValue) {
        milestone.complete();
        completedMilestoneNames.add(milestone.title);
      }
    }

    // Check if goal is complete
    if (currentProgress >= targetValue && !isCompleted) {
      complete();
    }

    save();
    return completedMilestoneNames;
  }

  /// Add progress incrementally
  List<String> addProgress(double amount) {
    return updateProgress(currentProgress + amount);
  }

  /// Complete the goal
  void complete() {
    status = 'completed';
    completedAt = DateTime.now();
    currentProgress = targetValue;
    save();
  }

  /// Pause the goal
  void pause() {
    status = 'paused';
    save();
  }

  /// Resume the goal
  void resume() {
    status = 'active';
    save();
  }

  /// Abandon the goal
  void abandon() {
    status = 'abandoned';
    save();
  }

  /// Create a goal with auto-generated milestones
  static Goal createWithMilestones({
    required String title,
    required String description,
    required double targetValue,
    required String unit,
    DateTime? deadline,
    String? relatedSkillId,
    String? iconEmoji,
    int milestoneCount = 4,
    int xpReward = 500,
    String? category,
  }) {
    // Generate evenly spaced milestones
    final milestones = <Milestone>[];
    for (int i = 1; i <= milestoneCount; i++) {
      final milestoneValue = (targetValue / milestoneCount) * i;
      milestones.add(Milestone(
        title: 'Gate ${i}',
        targetValue: milestoneValue,
        xpReward: (xpReward / milestoneCount / 2).toInt(),
      ));
    }

    return Goal(
      title: title,
      description: description,
      targetValue: targetValue,
      unit: unit,
      milestones: milestones,
      deadline: deadline,
      relatedSkillId: relatedSkillId,
      iconEmoji: iconEmoji,
      xpReward: xpReward,
      category: category,
    );
  }
}
