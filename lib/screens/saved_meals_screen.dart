import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/game_provider.dart';
import '../theme/solo_leveling_theme.dart';
import '../widgets/widgets.dart';

class SavedMealsScreen extends StatelessWidget {
  const SavedMealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SoloLevelingTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: SoloLevelingTheme.backgroundCard,
        title: const Text(
          'SAVED MEALS',
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
      body: Consumer<GameProvider>(
        builder: (context, game, child) {
          final savedMeals = game.savedMeals;

          if (savedMeals.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.restaurant,
                      color: SoloLevelingTheme.textMuted,
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No saved meals yet',
                      style: TextStyle(
                        color: SoloLevelingTheme.textSecondary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create a meal by adding food items and tapping "Save as Meal"',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: SoloLevelingTheme.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: savedMeals.length,
            itemBuilder: (context, index) {
              final meal = savedMeals[index];
              return _SavedMealCard(meal: meal);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: SoloLevelingTheme.primaryCyan,
        onPressed: () => _showCreateMealDialog(context),
        child: const Icon(
          Icons.add,
          color: SoloLevelingTheme.backgroundDark,
        ),
      ),
    );
  }

  void _showCreateMealDialog(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateMealScreen(),
      ),
    );
  }
}

class _SavedMealCard extends StatelessWidget {
  final SavedMeal meal;

  const _SavedMealCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: SoloLevelingTheme.backgroundCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: SoloLevelingTheme.primaryCyan.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: SoloLevelingTheme.primaryCyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.restaurant_menu,
                    color: SoloLevelingTheme.primaryCyan,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meal.name,
                        style: const TextStyle(
                          color: SoloLevelingTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${meal.itemCount} items',
                        style: TextStyle(
                          color: SoloLevelingTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: SoloLevelingTheme.hpRed),
                  onPressed: () => _confirmDelete(context),
                ),
              ],
            ),
          ),
          // Nutrition summary
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: SoloLevelingTheme.backgroundElevated,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildNutrientInfo('CAL', meal.totalCalories.toStringAsFixed(0), SoloLevelingTheme.xpGold),
                _buildNutrientInfo('P', '${meal.totalProtein.toStringAsFixed(0)}g', SoloLevelingTheme.hpRed),
                _buildNutrientInfo('C', '${meal.totalCarbs.toStringAsFixed(0)}g', SoloLevelingTheme.mpBlue),
                _buildNutrientInfo('F', '${meal.totalFat.toStringAsFixed(0)}g', SoloLevelingTheme.primaryCyan),
                ElevatedButton(
                  onPressed: () => _showAddToLogDialog(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SoloLevelingTheme.primaryCyan,
                    foregroundColor: SoloLevelingTheme.backgroundDark,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    minimumSize: Size.zero,
                  ),
                  child: const Text(
                    'ADD',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientInfo(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: SoloLevelingTheme.textMuted,
            fontSize: 9,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SoloLevelingTheme.backgroundCard,
        title: const Text(
          'Delete Meal?',
          style: TextStyle(color: SoloLevelingTheme.hpRed),
        ),
        content: Text(
          'Are you sure you want to delete "${meal.name}"?',
          style: const TextStyle(color: SoloLevelingTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              context.read<GameProvider>().deleteSavedMeal(meal.id);
              Navigator.pop(context);
            },
            child: const Text(
              'DELETE',
              style: TextStyle(color: SoloLevelingTheme.hpRed),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddToLogDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SoloLevelingTheme.backgroundCard,
        title: const Text(
          'Add to which meal?',
          style: TextStyle(color: SoloLevelingTheme.primaryCyan),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: MealType.values.map((mealType) {
            return ListTile(
              leading: Text(mealType.icon, style: const TextStyle(fontSize: 20)),
              title: Text(
                mealType.displayName,
                style: const TextStyle(color: SoloLevelingTheme.textPrimary),
              ),
              onTap: () {
                context.read<GameProvider>().addEntriesFromSavedMeal(meal, mealType);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: SoloLevelingTheme.backgroundCard,
                    content: Text(
                      '${meal.name} added to ${mealType.displayName}',
                      style: const TextStyle(color: SoloLevelingTheme.textPrimary),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

// Screen to create a new saved meal
class CreateMealScreen extends StatefulWidget {
  const CreateMealScreen({super.key});

  @override
  State<CreateMealScreen> createState() => _CreateMealScreenState();
}

class _CreateMealScreenState extends State<CreateMealScreen> {
  final _nameController = TextEditingController();
  final List<SavedMealItem> _items = [];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SoloLevelingTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: SoloLevelingTheme.backgroundCard,
        title: const Text(
          'CREATE MEAL',
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
        actions: [
          if (_items.isNotEmpty)
            TextButton(
              onPressed: _saveMeal,
              child: const Text(
                'SAVE',
                style: TextStyle(
                  color: SoloLevelingTheme.primaryCyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Meal name input
            SystemWindow(
              title: 'MEAL NAME',
              child: TextField(
                controller: _nameController,
                style: const TextStyle(color: SoloLevelingTheme.textPrimary),
                decoration: InputDecoration(
                  hintText: 'e.g., Morning Breakfast',
                  hintStyle: TextStyle(color: SoloLevelingTheme.textMuted),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: SoloLevelingTheme.primaryCyan.withOpacity(0.3)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: SoloLevelingTheme.primaryCyan),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Items list
            SystemWindow(
              title: 'FOOD ITEMS (${_items.length})',
              child: _items.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: SoloLevelingTheme.textMuted,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No items added yet',
                            style: TextStyle(
                              color: SoloLevelingTheme.textMuted,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the + button to add food items',
                            style: TextStyle(
                              color: SoloLevelingTheme.textMuted.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        ..._items.asMap().entries.map((entry) => _buildItemTile(entry.key, entry.value)),
                        const SizedBox(height: 8),
                        _buildTotalRow(),
                      ],
                    ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: SoloLevelingTheme.primaryCyan,
        onPressed: _addItem,
        child: const Icon(
          Icons.add,
          color: SoloLevelingTheme.backgroundDark,
        ),
      ),
    );
  }

  Widget _buildItemTile(int index, SavedMealItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: SoloLevelingTheme.backgroundElevated,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: SoloLevelingTheme.primaryCyan.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: SoloLevelingTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${item.servings}x ${item.servingSize.toStringAsFixed(0)}g',
                  style: TextStyle(
                    color: SoloLevelingTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${item.totalCalories.toStringAsFixed(0)} kcal',
            style: const TextStyle(
              color: SoloLevelingTheme.xpGold,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: SoloLevelingTheme.hpRed, size: 20),
            onPressed: () {
              setState(() {
                _items.removeAt(index);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow() {
    final totalCal = _items.fold<double>(0, (sum, i) => sum + i.totalCalories);
    final totalP = _items.fold<double>(0, (sum, i) => sum + i.totalProtein);
    final totalC = _items.fold<double>(0, (sum, i) => sum + i.totalCarbs);
    final totalF = _items.fold<double>(0, (sum, i) => sum + i.totalFat);

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: SoloLevelingTheme.primaryCyan.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: SoloLevelingTheme.primaryCyan.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'TOTAL',
            style: TextStyle(
              color: SoloLevelingTheme.primaryCyan,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          Text(
            '${totalCal.toStringAsFixed(0)} kcal  P:${totalP.toStringAsFixed(0)}g  C:${totalC.toStringAsFixed(0)}g  F:${totalF.toStringAsFixed(0)}g',
            style: const TextStyle(
              color: SoloLevelingTheme.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _addItem() {
    showDialog(
      context: context,
      builder: (context) => _AddItemDialog(
        onAdd: (item) {
          setState(() {
            _items.add(item);
          });
        },
      ),
    );
  }

  void _saveMeal() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a meal name')),
      );
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one item')),
      );
      return;
    }

    final meal = SavedMeal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      items: _items,
    );

    context.read<GameProvider>().addSavedMeal(meal);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SoloLevelingTheme.backgroundCard,
        content: Text(
          'Meal "${meal.name}" saved!',
          style: const TextStyle(color: SoloLevelingTheme.textPrimary),
        ),
      ),
    );
  }
}

// Dialog to add a single item to a meal
class _AddItemDialog extends StatefulWidget {
  final Function(SavedMealItem) onAdd;

  const _AddItemDialog({required this.onAdd});

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  final _nameController = TextEditingController();
  final _servingSizeController = TextEditingController(text: '100');
  final _servingsController = TextEditingController(text: '1');
  final _caloriesController = TextEditingController(text: '0');
  final _proteinController = TextEditingController(text: '0');
  final _carbsController = TextEditingController(text: '0');
  final _fatController = TextEditingController(text: '0');

  @override
  void dispose() {
    _nameController.dispose();
    _servingSizeController.dispose();
    _servingsController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: SoloLevelingTheme.backgroundCard,
      title: const Text(
        'Add Food Item',
        style: TextStyle(color: SoloLevelingTheme.primaryCyan),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTextField('Food Name', _nameController),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField('Serving (g)', _servingSizeController, isNumber: true)),
                const SizedBox(width: 8),
                Expanded(child: _buildTextField('Servings', _servingsController, isNumber: true)),
              ],
            ),
            const SizedBox(height: 12),
            _buildTextField('Calories (per serving)', _caloriesController, isNumber: true),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTextField('Protein', _proteinController, isNumber: true)),
                const SizedBox(width: 8),
                Expanded(child: _buildTextField('Carbs', _carbsController, isNumber: true)),
                const SizedBox(width: 8),
                Expanded(child: _buildTextField('Fat', _fatController, isNumber: true)),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: _addItem,
          child: const Text(
            'ADD',
            style: TextStyle(color: SoloLevelingTheme.primaryCyan),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: SoloLevelingTheme.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: SoloLevelingTheme.textMuted, fontSize: 12),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: SoloLevelingTheme.primaryCyan.withOpacity(0.3)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: SoloLevelingTheme.primaryCyan),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  void _addItem() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a food name')),
      );
      return;
    }

    final item = SavedMealItem(
      name: _nameController.text.trim(),
      servingSize: double.tryParse(_servingSizeController.text) ?? 100,
      servings: double.tryParse(_servingsController.text) ?? 1,
      calories: double.tryParse(_caloriesController.text) ?? 0,
      protein: double.tryParse(_proteinController.text) ?? 0,
      carbs: double.tryParse(_carbsController.text) ?? 0,
      fat: double.tryParse(_fatController.text) ?? 0,
    );

    widget.onAdd(item);
    Navigator.pop(context);
  }
}
