import 'package:hive/hive.dart';

part 'saved_meal.g.dart';

/// A food item within a saved meal
@HiveType(typeId: 20)
class SavedMealItem extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double servingSize; // in grams

  @HiveField(2)
  double servings;

  @HiveField(3)
  double calories;

  @HiveField(4)
  double protein;

  @HiveField(5)
  double carbs;

  @HiveField(6)
  double fat;

  @HiveField(7)
  double fiber;

  @HiveField(8)
  double sugar;

  @HiveField(9)
  double sodium;

  @HiveField(10)
  String? barcode;

  SavedMealItem({
    required this.name,
    required this.servingSize,
    required this.servings,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.fiber = 0,
    this.sugar = 0,
    this.sodium = 0,
    this.barcode,
  });

  // Total values based on servings
  double get totalCalories => calories * servings;
  double get totalProtein => protein * servings;
  double get totalCarbs => carbs * servings;
  double get totalFat => fat * servings;
  double get totalFiber => fiber * servings;
  double get totalSugar => sugar * servings;
  double get totalSodium => sodium * servings;

  Map<String, dynamic> toJson() => {
        'name': name,
        'servingSize': servingSize,
        'servings': servings,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'fiber': fiber,
        'sugar': sugar,
        'sodium': sodium,
        'barcode': barcode,
      };

  factory SavedMealItem.fromJson(Map<String, dynamic> json) {
    return SavedMealItem(
      name: json['name'] ?? '',
      servingSize: (json['servingSize'] ?? 100).toDouble(),
      servings: (json['servings'] ?? 1).toDouble(),
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      fiber: (json['fiber'] ?? 0).toDouble(),
      sugar: (json['sugar'] ?? 0).toDouble(),
      sodium: (json['sodium'] ?? 0).toDouble(),
      barcode: json['barcode'],
    );
  }
}

/// A saved meal that can be quickly added
@HiveType(typeId: 21)
class SavedMeal extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<SavedMealItem> items;

  @HiveField(3)
  DateTime createdAt;

  SavedMeal({
    required this.id,
    required this.name,
    required this.items,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Total nutrition for the meal
  double get totalCalories => items.fold(0, (sum, item) => sum + item.totalCalories);
  double get totalProtein => items.fold(0, (sum, item) => sum + item.totalProtein);
  double get totalCarbs => items.fold(0, (sum, item) => sum + item.totalCarbs);
  double get totalFat => items.fold(0, (sum, item) => sum + item.totalFat);
  double get totalFiber => items.fold(0, (sum, item) => sum + item.totalFiber);
  double get totalSugar => items.fold(0, (sum, item) => sum + item.totalSugar);
  double get totalSodium => items.fold(0, (sum, item) => sum + item.totalSodium);

  int get itemCount => items.length;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'items': items.map((i) => i.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory SavedMeal.fromJson(Map<String, dynamic> json) {
    return SavedMeal(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      name: json['name'] ?? 'Unnamed Meal',
      items: (json['items'] as List<dynamic>?)
              ?.map((i) => SavedMealItem.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
