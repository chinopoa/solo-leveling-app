import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../providers/game_provider.dart';
import '../services/nutrition_service.dart';
import '../theme/solo_leveling_theme.dart';

class FoodDetailScreen extends StatefulWidget {
  final ProductData product;

  const FoodDetailScreen({super.key, required this.product});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  late TextEditingController _servingsController;
  MealType _selectedMealType = MealType.lunch;

  @override
  void initState() {
    super.initState();
    _servingsController = TextEditingController(text: '1');
    _autoSelectMealType();
  }

  void _autoSelectMealType() {
    final hour = DateTime.now().hour;
    if (hour < 10) {
      _selectedMealType = MealType.breakfast;
    } else if (hour < 14) {
      _selectedMealType = MealType.lunch;
    } else if (hour < 18) {
      _selectedMealType = MealType.snack;
    } else {
      _selectedMealType = MealType.dinner;
    }
  }

  @override
  void dispose() {
    _servingsController.dispose();
    super.dispose();
  }

  double get _servings => double.tryParse(_servingsController.text) ?? 1;

  void _logFood() {
    final entry = NutritionEntry.fromOpenFoodFacts(
      id: const Uuid().v4(),
      barcode: widget.product.barcode,
      productName: widget.product.productName,
      brand: widget.product.brand,
      servingSize: widget.product.servingSize,
      calories: widget.product.calories,
      protein: widget.product.protein,
      carbs: widget.product.carbs,
      fat: widget.product.fat,
      fiber: widget.product.fiber,
      sugar: widget.product.sugar,
      sodium: widget.product.sodium,
      mealType: _selectedMealType,
      servingsConsumed: _servings,
    );

    context.read<GameProvider>().addNutritionEntry(entry);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SoloLevelingTheme.backgroundCard,
        content: Text(
          'Added ${widget.product.productName} to ${_selectedMealType.displayName}',
          style: const TextStyle(color: SoloLevelingTheme.textPrimary),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SoloLevelingTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: SoloLevelingTheme.backgroundCard,
        title: const Text(
          'ADD FOOD',
          style: TextStyle(
            color: SoloLevelingTheme.primaryCyan,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: SoloLevelingTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Product info card
            _buildProductInfoCard(),
            const SizedBox(height: 16),

            // Serving size selector
            _buildServingSizeCard(),
            const SizedBox(height: 16),

            // Meal type selector
            _buildMealTypeCard(),
            const SizedBox(height: 16),

            // Nutrition facts
            _buildNutritionFactsCard(),
            const SizedBox(height: 24),

            // Log button
            _buildLogButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SoloLevelingTheme.backgroundCard,
        border: Border.all(
          color: SoloLevelingTheme.primaryCyan.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // Product image or placeholder
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: SoloLevelingTheme.backgroundElevated,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: SoloLevelingTheme.primaryCyan.withOpacity(0.2),
              ),
            ),
            child: widget.product.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      widget.product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.fastfood,
                        color: SoloLevelingTheme.primaryCyan,
                        size: 30,
                      ),
                    ),
                  )
                : const Icon(
                    Icons.fastfood,
                    color: SoloLevelingTheme.primaryCyan,
                    size: 30,
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.product.productName,
                  style: const TextStyle(
                    color: SoloLevelingTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.product.brand != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    widget.product.brand!,
                    style: TextStyle(
                      color: SoloLevelingTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  'Serving: ${widget.product.servingSize.toStringAsFixed(0)}g',
                  style: TextStyle(
                    color: SoloLevelingTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServingSizeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SoloLevelingTheme.backgroundCard,
        border: Border.all(
          color: SoloLevelingTheme.primaryCyan.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SERVINGS',
            style: TextStyle(
              color: SoloLevelingTheme.textMuted,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              IconButton(
                onPressed: () {
                  final current = _servings;
                  if (current > 0.5) {
                    _servingsController.text = (current - 0.5).toStringAsFixed(1);
                    setState(() {});
                  }
                },
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: SoloLevelingTheme.primaryCyan),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.remove,
                    color: SoloLevelingTheme.primaryCyan,
                    size: 20,
                  ),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _servingsController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: SoloLevelingTheme.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              IconButton(
                onPressed: () {
                  final current = _servings;
                  _servingsController.text = (current + 0.5).toStringAsFixed(1);
                  setState(() {});
                },
                icon: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    border: Border.all(color: SoloLevelingTheme.primaryCyan),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: SoloLevelingTheme.primaryCyan,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMealTypeCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SoloLevelingTheme.backgroundCard,
        border: Border.all(
          color: SoloLevelingTheme.primaryCyan.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MEAL TYPE',
            style: TextStyle(
              color: SoloLevelingTheme.textMuted,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: MealType.values.map((type) {
              final isSelected = type == _selectedMealType;
              return GestureDetector(
                onTap: () => setState(() => _selectedMealType = type),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? SoloLevelingTheme.primaryCyan.withOpacity(0.2)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? SoloLevelingTheme.primaryCyan
                          : SoloLevelingTheme.textMuted.withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    children: [
                      Text(
                        type.icon,
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        type.displayName,
                        style: TextStyle(
                          color: isSelected
                              ? SoloLevelingTheme.primaryCyan
                              : SoloLevelingTheme.textMuted,
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionFactsCard() {
    final p = widget.product;
    final s = _servings;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SoloLevelingTheme.backgroundCard,
        border: Border.all(
          color: SoloLevelingTheme.primaryCyan.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'NUTRITION FACTS',
            style: TextStyle(
              color: SoloLevelingTheme.textMuted,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),

          // Calories (large)
          _buildCalorieRow(p.calories * s),
          const Divider(color: SoloLevelingTheme.backgroundElevated),

          // Main macros
          _buildNutrientRow('Protein', p.protein * s, 'g', SoloLevelingTheme.hpRed),
          _buildNutrientRow('Carbs', p.carbs * s, 'g', SoloLevelingTheme.mpBlue),
          _buildNutrientRow('Fat', p.fat * s, 'g', SoloLevelingTheme.primaryCyan),
          const Divider(color: SoloLevelingTheme.backgroundElevated),

          // Other nutrients
          _buildNutrientRow('Fiber', p.fiber * s, 'g', SoloLevelingTheme.successGreen),
          _buildNutrientRow('Sugar', p.sugar * s, 'g', SoloLevelingTheme.xpGold),
          _buildNutrientRow('Sodium', p.sodium * s, 'mg', SoloLevelingTheme.textMuted),
        ],
      ),
    );
  }

  Widget _buildCalorieRow(double calories) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Calories',
            style: TextStyle(
              color: SoloLevelingTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            '${calories.toStringAsFixed(0)} kcal',
            style: const TextStyle(
              color: SoloLevelingTheme.xpGold,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientRow(String label, double value, String unit, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: SoloLevelingTheme.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Text(
            '${value.toStringAsFixed(1)} $unit',
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogButton() {
    return GestureDetector(
      onTap: _logFood,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: SoloLevelingTheme.primaryCyan.withOpacity(0.2),
          border: Border.all(
            color: SoloLevelingTheme.primaryCyan,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
          boxShadow: SoloLevelingTheme.glowEffect(SoloLevelingTheme.primaryCyan),
        ),
        child: const Center(
          child: Text(
            'LOG FOOD',
            style: TextStyle(
              color: SoloLevelingTheme.primaryCyan,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
