import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'workout_set.g.dart';

/// A single set performed during a workout
@HiveType(typeId: 24)
class WorkoutSet extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String exerciseId;

  @HiveField(2)
  String exerciseName; // Denormalized for display

  @HiveField(3)
  double weight;

  @HiveField(4)
  int reps;

  @HiveField(5)
  bool isPR; // Crown toggle - marked as personal record

  @HiveField(6)
  DateTime timestamp;

  @HiveField(7)
  String? note; // Per-set notes

  @HiveField(8)
  int setNumber; // Which set number in the exercise (1, 2, 3...)

  WorkoutSet({
    String? id,
    required this.exerciseId,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    this.isPR = false,
    DateTime? timestamp,
    this.note,
    this.setNumber = 1,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();

  /// Get formatted display string
  String get formattedSet => '${weight.toStringAsFixed(1)}kg × $reps';

  /// Copy with modifications
  WorkoutSet copyWith({
    String? id,
    String? exerciseId,
    String? exerciseName,
    double? weight,
    int? reps,
    bool? isPR,
    DateTime? timestamp,
    String? note,
    int? setNumber,
  }) {
    return WorkoutSet(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      weight: weight ?? this.weight,
      reps: reps ?? this.reps,
      isPR: isPR ?? this.isPR,
      timestamp: timestamp ?? this.timestamp,
      note: note ?? this.note,
      setNumber: setNumber ?? this.setNumber,
    );
  }
}
