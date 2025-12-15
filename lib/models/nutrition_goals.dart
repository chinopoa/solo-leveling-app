import 'package:hive/hive.dart';

part 'nutrition_goals.g.dart';

/// User's daily nutrition targets
@HiveType(typeId: 11)
class NutritionGoals extends HiveObject {
  @HiveField(0)
  int dailyCalories;

  @HiveField(1)
  int dailyProtein; // grams

  @HiveField(2)
  int dailyCarbs; // grams

  @HiveField(3)
  int dailyFat; // grams

  @HiveField(4)
  int dailyFiber; // grams

  @HiveField(5)
  int dailySugar; // grams (max limit)

  @HiveField(6)
  int dailySodium; // mg (max limit)

  @HiveField(7)
  bool isEnabled; // Whether nutrition tracking counts as a daily quest

  NutritionGoals({
    this.dailyCalories = 2000,
    this.dailyProtein = 150,
    this.dailyCarbs = 250,
    this.dailyFat = 65,
    this.dailyFiber = 25,
    this.dailySugar = 50,
    this.dailySodium = 2300,
    this.isEnabled = true,
  });

  /// Check if calorie goal is met (within 10% tolerance)
  bool isCalorieGoalMet(double consumed) {
    final lowerBound = dailyCalories * 0.9;
    final upperBound = dailyCalories * 1.1;
    return consumed >= lowerBound && consumed <= upperBound;
  }

  /// Check if protein goal is met (must reach target)
  bool isProteinGoalMet(double consumed) {
    return consumed >= dailyProtein;
  }

  /// Check if carbs goal is met (within range)
  bool isCarbsGoalMet(double consumed) {
    return consumed >= dailyCarbs * 0.8 && consumed <= dailyCarbs * 1.2;
  }

  /// Check if fat goal is met (within range)
  bool isFatGoalMet(double consumed) {
    return consumed >= dailyFat * 0.8 && consumed <= dailyFat * 1.2;
  }

  /// Check if fiber goal is met (must reach target)
  bool isFiberGoalMet(double consumed) {
    return consumed >= dailyFiber;
  }

  /// Check if sugar is under limit
  bool isSugarGoalMet(double consumed) {
    return consumed <= dailySugar;
  }

  /// Check if sodium is under limit
  bool isSodiumGoalMet(double consumed) {
    return consumed <= dailySodium;
  }

  /// Calculate progress percentage for calories (capped at 100%)
  double getCalorieProgress(double consumed) {
    return (consumed / dailyCalories).clamp(0.0, 1.0);
  }

  /// Calculate progress percentage for protein
  double getProteinProgress(double consumed) {
    return (consumed / dailyProtein).clamp(0.0, 1.0);
  }

  /// Calculate progress percentage for carbs
  double getCarbsProgress(double consumed) {
    return (consumed / dailyCarbs).clamp(0.0, 1.0);
  }

  /// Calculate progress percentage for fat
  double getFatProgress(double consumed) {
    return (consumed / dailyFat).clamp(0.0, 1.0);
  }

  /// Calculate progress percentage for fiber
  double getFiberProgress(double consumed) {
    return (consumed / dailyFiber).clamp(0.0, 1.0);
  }

  /// Calculate progress percentage for sugar (inverse - lower is better)
  double getSugarProgress(double consumed) {
    return (consumed / dailySugar).clamp(0.0, 1.5); // Allow showing over limit
  }

  /// Calculate progress percentage for sodium (inverse - lower is better)
  double getSodiumProgress(double consumed) {
    return (consumed / dailySodium).clamp(0.0, 1.5); // Allow showing over limit
  }

  /// Default goals factory
  factory NutritionGoals.defaults() {
    return NutritionGoals(
      dailyCalories: 2000,
      dailyProtein: 150,
      dailyCarbs: 250,
      dailyFat: 65,
      dailyFiber: 25,
      dailySugar: 50,
      dailySodium: 2300,
      isEnabled: true,
    );
  }

  /// Copy with modifications
  NutritionGoals copyWith({
    int? dailyCalories,
    int? dailyProtein,
    int? dailyCarbs,
    int? dailyFat,
    int? dailyFiber,
    int? dailySugar,
    int? dailySodium,
    bool? isEnabled,
  }) {
    return NutritionGoals(
      dailyCalories: dailyCalories ?? this.dailyCalories,
      dailyProtein: dailyProtein ?? this.dailyProtein,
      dailyCarbs: dailyCarbs ?? this.dailyCarbs,
      dailyFat: dailyFat ?? this.dailyFat,
      dailyFiber: dailyFiber ?? this.dailyFiber,
      dailySugar: dailySugar ?? this.dailySugar,
      dailySodium: dailySodium ?? this.dailySodium,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }
}
