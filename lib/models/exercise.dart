import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'exercise.g.dart';

/// Muscle group categories (Combat Styles)
enum MuscleGroup {
  chest,
  back,
  legs,
  shoulders,
  arms,
}

/// Sub-groups for Arms
enum ArmSubGroup {
  triceps,
  biceps,
  forearms,
}

/// PR History entry for an exercise
@HiveType(typeId: 22)
class ExercisePRHistory {
  @HiveField(0)
  double weight;

  @HiveField(1)
  int reps;

  @HiveField(2)
  DateTime achievedAt;

  @HiveField(3)
  String rank; // E, D, C, B, A, S

  @HiveField(4)
  String? note;

  ExercisePRHistory({
    required this.weight,
    required this.reps,
    required this.achievedAt,
    required this.rank,
    this.note,
  });
}

/// Exercise in the Skill Book
@HiveType(typeId: 23)
class Exercise extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String muscleGroup; // MuscleGroup as string

  @HiveField(3)
  String? armSubGroup; // ArmSubGroup as string (only for arms)

  @HiveField(4)
  String? iconEmoji;

  @HiveField(5)
  String? notes; // Persistent notes/cues for this exercise

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  double? currentPRWeight;

  @HiveField(8)
  int? currentPRReps;

  @HiveField(9)
  String rank; // E, D, C, B, A, S

  @HiveField(10)
  List<ExercisePRHistory> prHistory;

  @HiveField(11)
  int prCount; // Number of times PR was set (for rank progression)

  @HiveField(12)
  DateTime? lastPerformedAt;

  @HiveField(13)
  double? lastWeight;

  @HiveField(14)
  int? lastReps;

  Exercise({
    String? id,
    required this.name,
    required this.muscleGroup,
    this.armSubGroup,
    this.iconEmoji,
    this.notes,
    DateTime? createdAt,
    this.currentPRWeight,
    this.currentPRReps,
    this.rank = 'E',
    List<ExercisePRHistory>? prHistory,
    this.prCount = 0,
    this.lastPerformedAt,
    this.lastWeight,
    this.lastReps,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        prHistory = prHistory ?? [];

  MuscleGroup get muscleGroupEnum => MuscleGroup.values.firstWhere(
        (e) => e.name == muscleGroup,
        orElse: () => MuscleGroup.chest,
      );

  ArmSubGroup? get armSubGroupEnum => armSubGroup != null
      ? ArmSubGroup.values.firstWhere(
          (e) => e.name == armSubGroup,
          orElse: () => ArmSubGroup.biceps,
        )
      : null;

  /// Check if a new weight/reps combo beats current PR
  bool isNewPR(double weight, int reps) {
    if (currentPRWeight == null) return true;
    // PR if weight is higher, or same weight with more reps
    if (weight > currentPRWeight!) return true;
    if (weight == currentPRWeight! && reps > (currentPRReps ?? 0)) return true;
    return false;
  }

  /// Update PR with new values
  void updatePR(double weight, int reps, {String? note}) {
    // Save current PR to history if exists
    if (currentPRWeight != null) {
      prHistory.add(ExercisePRHistory(
        weight: currentPRWeight!,
        reps: currentPRReps ?? 0,
        achievedAt: DateTime.now(),
        rank: rank,
        note: note,
      ));
    }

    currentPRWeight = weight;
    currentPRReps = reps;
    prCount++;

    // Update rank based on PR count
    _updateRank();

    save();
  }

  /// Update rank based on PR count
  void _updateRank() {
    if (prCount >= 20) {
      rank = 'S';
    } else if (prCount >= 10) {
      rank = 'A';
    } else if (prCount >= 5) {
      rank = 'B';
    } else if (prCount >= 3) {
      rank = 'C';
    } else if (prCount >= 1) {
      rank = 'D';
    } else {
      rank = 'E';
    }
  }

  /// Update last performance (Ghost data)
  void updateLastPerformance(double weight, int reps) {
    lastWeight = weight;
    lastReps = reps;
    lastPerformedAt = DateTime.now();
    save();
  }

  /// Get display string for muscle group
  String get muscleGroupDisplay {
    if (muscleGroup == 'arms' && armSubGroup != null) {
      return '${armSubGroup!.toUpperCase()} (Arms)';
    }
    return muscleGroup.toUpperCase();
  }

  /// Get rank color
  static String getRankColor(String rank) {
    switch (rank.toUpperCase()) {
      case 'S':
        return 'gold';
      case 'A':
        return 'purple';
      case 'B':
        return 'blue';
      case 'C':
        return 'green';
      case 'D':
        return 'orange';
      default:
        return 'grey';
    }
  }

  /// Get formatted PR string
  String get formattedPR {
    if (currentPRWeight == null) return 'No PR yet';
    return '${currentPRWeight!.toStringAsFixed(1)}kg × ${currentPRReps ?? 0}';
  }

  /// Get formatted last performance string (Ghost data)
  String get formattedLastPerformance {
    if (lastWeight == null) return 'No previous data';
    return '${lastWeight!.toStringAsFixed(1)}kg × ${lastReps ?? 0}';
  }

  /// Create default exercises
  static List<Exercise> createDefaultExercises() {
    return [
      // Chest
      Exercise(name: 'Bench Press', muscleGroup: 'chest', iconEmoji: '🏋️'),
      Exercise(name: 'Incline Bench Press', muscleGroup: 'chest', iconEmoji: '🏋️'),
      Exercise(name: 'Dumbbell Flys', muscleGroup: 'chest', iconEmoji: '🦋'),
      Exercise(name: 'Push-ups', muscleGroup: 'chest', iconEmoji: '💪'),

      // Back
      Exercise(name: 'Pull-ups', muscleGroup: 'back', iconEmoji: '🧗'),
      Exercise(name: 'Barbell Rows', muscleGroup: 'back', iconEmoji: '🚣'),
      Exercise(name: 'Lat Pulldown', muscleGroup: 'back', iconEmoji: '⬇️'),
      Exercise(name: 'Deadlift', muscleGroup: 'back', iconEmoji: '🏋️'),

      // Legs
      Exercise(name: 'Squats', muscleGroup: 'legs', iconEmoji: '🦵'),
      Exercise(name: 'Leg Press', muscleGroup: 'legs', iconEmoji: '🦿'),
      Exercise(name: 'Lunges', muscleGroup: 'legs', iconEmoji: '🚶'),
      Exercise(name: 'Leg Curls', muscleGroup: 'legs', iconEmoji: '🔄'),

      // Shoulders
      Exercise(name: 'Overhead Press', muscleGroup: 'shoulders', iconEmoji: '🙌'),
      Exercise(name: 'Lateral Raises', muscleGroup: 'shoulders', iconEmoji: '🦅'),
      Exercise(name: 'Front Raises', muscleGroup: 'shoulders', iconEmoji: '⬆️'),

      // Arms - Biceps
      Exercise(name: 'Barbell Curls', muscleGroup: 'arms', armSubGroup: 'biceps', iconEmoji: '💪'),
      Exercise(name: 'Hammer Curls', muscleGroup: 'arms', armSubGroup: 'biceps', iconEmoji: '🔨'),
      Exercise(name: 'Preacher Curls', muscleGroup: 'arms', armSubGroup: 'biceps', iconEmoji: '🙏'),

      // Arms - Triceps
      Exercise(name: 'Tricep Pushdown', muscleGroup: 'arms', armSubGroup: 'triceps', iconEmoji: '⬇️'),
      Exercise(name: 'Skull Crushers', muscleGroup: 'arms', armSubGroup: 'triceps', iconEmoji: '💀'),
      Exercise(name: 'Tricep Dips', muscleGroup: 'arms', armSubGroup: 'triceps', iconEmoji: '🪑'),

      // Arms - Forearms
      Exercise(name: 'Wrist Curls', muscleGroup: 'arms', armSubGroup: 'forearms', iconEmoji: '🤚'),
      Exercise(name: 'Farmers Walk', muscleGroup: 'arms', armSubGroup: 'forearms', iconEmoji: '🚶'),
    ];
  }
}
