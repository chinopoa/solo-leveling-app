import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'workout_set.dart';

part 'workout_session.g.dart';

/// A workout session containing multiple sets
@HiveType(typeId: 25)
class WorkoutSession extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String? name; // e.g., "Pull Day", "Leg Day"

  @HiveField(2)
  List<WorkoutSet> sets;

  @HiveField(3)
  DateTime startTime;

  @HiveField(4)
  DateTime? endTime;

  @HiveField(5)
  List<String> muscleGroupsWorked;

  @HiveField(6)
  List<String> exerciseIds; // Track which exercises were done

  @HiveField(7)
  int totalPRs; // Number of PRs set in this session

  @HiveField(8)
  String? notes;

  WorkoutSession({
    String? id,
    this.name,
    List<WorkoutSet>? sets,
    DateTime? startTime,
    this.endTime,
    List<String>? muscleGroupsWorked,
    List<String>? exerciseIds,
    this.totalPRs = 0,
    this.notes,
  })  : id = id ?? const Uuid().v4(),
        sets = sets ?? [],
        startTime = startTime ?? DateTime.now(),
        muscleGroupsWorked = muscleGroupsWorked ?? [],
        exerciseIds = exerciseIds ?? [];

  /// Check if session is active (not ended)
  bool get isActive => endTime == null;

  /// Get duration of workout
  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }

  /// Get formatted duration string
  String get formattedDuration {
    final d = duration;
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  /// Add a set to the session
  void addSet(WorkoutSet set) {
    sets.add(set);
    if (!exerciseIds.contains(set.exerciseId)) {
      exerciseIds.add(set.exerciseId);
    }
    if (set.isPR) {
      totalPRs++;
    }
    save();
  }

  /// Remove a set from the session
  void removeSet(String setId) {
    final set = sets.firstWhere((s) => s.id == setId, orElse: () => throw Exception('Set not found'));
    if (set.isPR) {
      totalPRs--;
    }
    sets.removeWhere((s) => s.id == setId);
    save();
  }

  /// End the workout session
  void endWorkout({String? sessionNotes}) {
    endTime = DateTime.now();
    if (sessionNotes != null) {
      notes = sessionNotes;
    }
    save();
  }

  /// Get sets for a specific exercise
  List<WorkoutSet> getSetsForExercise(String exerciseId) {
    return sets.where((s) => s.exerciseId == exerciseId).toList();
  }

  /// Get total volume (weight × reps) for the session
  double get totalVolume {
    return sets.fold(0, (sum, set) => sum + (set.weight * set.reps));
  }

  /// Get total sets count
  int get totalSets => sets.length;

  /// Get total reps count
  int get totalReps => sets.fold(0, (sum, set) => sum + set.reps);

  /// Get unique exercise count
  int get exerciseCount => exerciseIds.length;

  /// Get summary string
  String get summary {
    return '$exerciseCount exercises • $totalSets sets • ${totalVolume.toStringAsFixed(0)}kg volume';
  }

  /// Get date formatted string
  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final sessionDate = DateTime(startTime.year, startTime.month, startTime.day);

    if (sessionDate == today) {
      return 'Today';
    } else if (sessionDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${startTime.day}/${startTime.month}/${startTime.year}';
    }
  }
}
