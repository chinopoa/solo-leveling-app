import 'package:hive/hive.dart';

part 'workout_split.g.dart';

/// Weekly training split — which muscle groups are trained on each weekday.
///
/// Weekdays use Dart's `DateTime.weekday` convention: 1 = Mon ... 7 = Sun.
/// Muscle group strings match [Exercise.muscleGroup] / [armSubGroup] values
/// (lowercase), e.g. "chest", "back", "biceps", "triceps", "shoulders".
@HiveType(typeId: 27)
class WorkoutSplit extends HiveObject {
  /// Single key under which the active split is stored.
  static const String boxKey = 'active_split';

  /// monday muscles
  @HiveField(0)
  List<String> monday;

  @HiveField(1)
  List<String> tuesday;

  @HiveField(2)
  List<String> wednesday;

  @HiveField(3)
  List<String> thursday;

  @HiveField(4)
  List<String> friday;

  @HiveField(5)
  List<String> saturday;

  @HiveField(6)
  List<String> sunday;

  /// Optional human-friendly name for the split (e.g. "PPL", "Bro Split").
  @HiveField(7)
  String? name;

  WorkoutSplit({
    List<String>? monday,
    List<String>? tuesday,
    List<String>? wednesday,
    List<String>? thursday,
    List<String>? friday,
    List<String>? saturday,
    List<String>? sunday,
    this.name,
  })  : monday = monday ?? [],
        tuesday = tuesday ?? [],
        wednesday = wednesday ?? [],
        thursday = thursday ?? [],
        friday = friday ?? [],
        saturday = saturday ?? [],
        sunday = sunday ?? [];

  /// Default starter split: a common upper/lower-style 5-day arrangement
  /// that maps closely to the user's described "Mon: chest/triceps/shoulders,
  /// Tue: back/legs/biceps" schedule (with a couple of rest days).
  factory WorkoutSplit.defaults() {
    return WorkoutSplit(
      name: 'Default Split',
      monday: ['chest', 'triceps', 'shoulders'],
      tuesday: ['back', 'biceps'],
      wednesday: ['legs'],
      thursday: ['shoulders', 'triceps'],
      friday: ['chest', 'back'],
      saturday: ['legs', 'biceps'],
      sunday: [],
    );
  }

  /// Get muscles trained on a given DateTime.weekday (1=Mon..7=Sun).
  List<String> forWeekday(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return monday;
      case DateTime.tuesday:
        return tuesday;
      case DateTime.wednesday:
        return wednesday;
      case DateTime.thursday:
        return thursday;
      case DateTime.friday:
        return friday;
      case DateTime.saturday:
        return saturday;
      case DateTime.sunday:
        return sunday;
      default:
        return const [];
    }
  }

  void setForWeekday(int weekday, List<String> muscles) {
    switch (weekday) {
      case DateTime.monday:
        monday = muscles;
        break;
      case DateTime.tuesday:
        tuesday = muscles;
        break;
      case DateTime.wednesday:
        wednesday = muscles;
        break;
      case DateTime.thursday:
        thursday = muscles;
        break;
      case DateTime.friday:
        friday = muscles;
        break;
      case DateTime.saturday:
        saturday = muscles;
        break;
      case DateTime.sunday:
        sunday = muscles;
        break;
    }
  }

  /// Muscles scheduled for today.
  List<String> get today => forWeekday(DateTime.now().weekday);

  bool get isRestToday => today.isEmpty;

  /// All weekday entries as an ordered list (Mon..Sun).
  List<List<String>> get allDays =>
      [monday, tuesday, wednesday, thursday, friday, saturday, sunday];

  static const List<String> weekdayLabels = [
    'MON',
    'TUE',
    'WED',
    'THU',
    'FRI',
    'SAT',
    'SUN'
  ];

  static const List<String> weekdayLong = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];

  /// Selectable muscles for the split editor.
  static const List<String> availableMuscles = [
    'chest',
    'back',
    'legs',
    'shoulders',
    'biceps',
    'triceps',
    'forearms',
    'core',
  ];
}
