import 'package:hive/hive.dart';

part 'nutrition_entry.g.dart';

/// Meal type categorization
@HiveType(typeId: 12)
enum MealType {
  @HiveField(0)
  breakfast,
  @HiveField(1)
  lunch,
  @HiveField(2)
  dinner,
  @HiveField(3)
  snack,
}

extension MealTypeExtension on MealType {
  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  String get icon {
    switch (this) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '☀️';
      case MealType.dinner:
        return '🌙';
      case MealType.snack:
        return '🍎';
    }
  }
}

/// A single food entry logged by the user
@HiveType(typeId: 10)
class NutritionEntry extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String date; // YYYY-MM-DD format

  @HiveField(2)
  String? barcode;

  @HiveField(3)
  String productName;

  @HiveField(4)
  String? brand;

  @HiveField(5)
  double servingSize; // in grams

  @HiveField(6)
  double servingsConsumed;

  @HiveField(7)
  double calories; // per serving

  @HiveField(8)
  double protein; // grams per serving

  @HiveField(9)
  double carbs; // grams per serving

  @HiveField(10)
  double fat; // grams per serving

  @HiveField(11)
  double fiber; // grams per serving

  @HiveField(12)
  double sugar; // grams per serving

  @HiveField(13)
  double sodium; // mg per serving

  @HiveField(14)
  MealType mealType;

  @HiveField(15)
  DateTime timestamp;

  @HiveField(16)
  bool isManualEntry;

  NutritionEntry({
    required this.id,
    required this.date,
    this.barcode,
    required this.productName,
    this.brand,
    required this.servingSize,
    this.servingsConsumed = 1.0,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0,
    this.sugar = 0,
    this.sodium = 0,
    required this.mealType,
    DateTime? timestamp,
    this.isManualEntry = false,
  }) : timestamp = timestamp ?? DateTime.now();

  // Calculate totals based on servings consumed
  double get totalCalories => calories * servingsConsumed;
  double get totalProtein => protein * servingsConsumed;
  double get totalCarbs => carbs * servingsConsumed;
  double get totalFat => fat * servingsConsumed;
  double get totalFiber => fiber * servingsConsumed;
  double get totalSugar => sugar * servingsConsumed;
  double get totalSodium => sodium * servingsConsumed;

  // Get today's date key
  static String getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  // Create from Open Food Facts product data
  factory NutritionEntry.fromOpenFoodFacts({
    required String id,
    required String barcode,
    required String productName,
    String? brand,
    required double servingSize,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    double fiber = 0,
    double sugar = 0,
    double sodium = 0,
    required MealType mealType,
    double servingsConsumed = 1.0,
  }) {
    return NutritionEntry(
      id: id,
      date: getTodayKey(),
      barcode: barcode,
      productName: productName,
      brand: brand,
      servingSize: servingSize,
      servingsConsumed: servingsConsumed,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      fiber: fiber,
      sugar: sugar,
      sodium: sodium,
      mealType: mealType,
      isManualEntry: false,
    );
  }

  // Create manual entry
  factory NutritionEntry.manual({
    required String id,
    required String productName,
    required double servingSize,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    double fiber = 0,
    double sugar = 0,
    double sodium = 0,
    required MealType mealType,
    double servingsConsumed = 1.0,
  }) {
    return NutritionEntry(
      id: id,
      date: getTodayKey(),
      productName: productName,
      servingSize: servingSize,
      servingsConsumed: servingsConsumed,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      fiber: fiber,
      sugar: sugar,
      sodium: sodium,
      mealType: mealType,
      isManualEntry: true,
    );
  }
}
