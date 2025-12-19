import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/models.dart';
import '../providers/game_provider.dart';
import '../theme/solo_leveling_theme.dart';

class ManualEntryScreen extends StatefulWidget {
  final String? barcode;
  final DateTime? date;

  const ManualEntryScreen({super.key, this.barcode, this.date});

  @override
  State<ManualEntryScreen> createState() => _ManualEntryScreenState();
}

class _ManualEntryScreenState extends State<ManualEntryScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _servingSizeController;
  late TextEditingController _servingsController;
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  late TextEditingController _fiberController;
  late TextEditingController _sugarController;
  late TextEditingController _sodiumController;

  MealType _selectedMealType = MealType.lunch;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _servingSizeController = TextEditingController(text: '100');
    _servingsController = TextEditingController(text: '1');
    _caloriesController = TextEditingController();
    _proteinController = TextEditingController(text: '0');
    _carbsController = TextEditingController(text: '0');
    _fatController = TextEditingController(text: '0');
    _fiberController = TextEditingController(text: '0');
    _sugarController = TextEditingController(text: '0');
    _sodiumController = TextEditingController(text: '0');

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
    _nameController.dispose();
    _servingSizeController.dispose();
    _servingsController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _sugarController.dispose();
    _sodiumController.dispose();
    super.dispose();
  }

  void _saveEntry() {
    if (!_formKey.currentState!.validate()) return;

    final entry = NutritionEntry.manual(
      id: const Uuid().v4(),
      productName: _nameController.text.trim(),
      servingSize: double.tryParse(_servingSizeController.text) ?? 100,
      servingsConsumed: double.tryParse(_servingsController.text) ?? 1,
      calories: double.tryParse(_caloriesController.text) ?? 0,
      protein: double.tryParse(_proteinController.text) ?? 0,
      carbs: double.tryParse(_carbsController.text) ?? 0,
      fat: double.tryParse(_fatController.text) ?? 0,
      fiber: double.tryParse(_fiberController.text) ?? 0,
      sugar: double.tryParse(_sugarController.text) ?? 0,
      sodium: double.tryParse(_sodiumController.text) ?? 0,
      mealType: _selectedMealType,
      date: widget.date,
    );

    context.read<GameProvider>().addNutritionEntry(entry);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SoloLevelingTheme.backgroundCard,
        content: Text(
          'Added ${entry.productName} to ${_selectedMealType.displayName}',
          style: const TextStyle(color: SoloLevelingTheme.textPrimary),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _getAppBarSubtitle() {
    if (widget.date == null) return '';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(widget.date!.year, widget.date!.month, widget.date!.day);
    if (selectedDay == today) return '';
    final yesterday = today.subtract(const Duration(days: 1));
    if (selectedDay == yesterday) return 'Yesterday';
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[widget.date!.month - 1]} ${widget.date!.day}';
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = _getAppBarSubtitle();
    return Scaffold(
      backgroundColor: SoloLevelingTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: SoloLevelingTheme.backgroundCard,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MANUAL ENTRY',
              style: TextStyle(
                color: SoloLevelingTheme.primaryCyan,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: const TextStyle(
                  color: SoloLevelingTheme.textMuted,
                  fontSize: 11,
                ),
              ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: SoloLevelingTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barcode info (if scanned)
              if (widget.barcode != null) _buildBarcodeInfo(),

              // Food name
              _buildSectionTitle('FOOD NAME'),
              _buildTextField(
                controller: _nameController,
                hint: 'Enter food name',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Meal type
              _buildSectionTitle('MEAL TYPE'),
              _buildMealTypeSelector(),
              const SizedBox(height: 16),

              // Serving info
              _buildSectionTitle('SERVING'),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _servingSizeController,
                      hint: 'Size (g)',
                      keyboardType: TextInputType.number,
                      suffix: 'g',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _servingsController,
                      hint: 'Servings',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      suffix: 'x',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Calories
              _buildSectionTitle('CALORIES'),
              _buildTextField(
                controller: _caloriesController,
                hint: 'Calories per serving',
                keyboardType: TextInputType.number,
                suffix: 'kcal',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter calories';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Main macros
              _buildSectionTitle('MACRONUTRIENTS'),
              Row(
                children: [
                  Expanded(
                    child: _buildNutrientField(
                      controller: _proteinController,
                      label: 'Protein',
                      color: SoloLevelingTheme.hpRed,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildNutrientField(
                      controller: _carbsController,
                      label: 'Carbs',
                      color: SoloLevelingTheme.mpBlue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildNutrientField(
                      controller: _fatController,
                      label: 'Fat',
                      color: SoloLevelingTheme.primaryCyan,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Other nutrients (collapsible)
              _buildSectionTitle('OTHER NUTRIENTS (OPTIONAL)'),
              Row(
                children: [
                  Expanded(
                    child: _buildNutrientField(
                      controller: _fiberController,
                      label: 'Fiber',
                      color: SoloLevelingTheme.successGreen,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildNutrientField(
                      controller: _sugarController,
                      label: 'Sugar',
                      color: SoloLevelingTheme.xpGold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildNutrientField(
                      controller: _sodiumController,
                      label: 'Sodium',
                      color: SoloLevelingTheme.textMuted,
                      unit: 'mg',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Save button
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarcodeInfo() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SoloLevelingTheme.backgroundCard,
        border: Border.all(
          color: SoloLevelingTheme.textMuted.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(
            Icons.qr_code,
            color: SoloLevelingTheme.textMuted,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Barcode: ${widget.barcode}',
            style: TextStyle(
              color: SoloLevelingTheme.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: SoloLevelingTheme.textMuted,
          fontSize: 10,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(
        color: SoloLevelingTheme.textPrimary,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: SoloLevelingTheme.textMuted.withOpacity(0.5),
        ),
        suffixText: suffix,
        suffixStyle: TextStyle(
          color: SoloLevelingTheme.textMuted,
        ),
        filled: true,
        fillColor: SoloLevelingTheme.backgroundCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: SoloLevelingTheme.primaryCyan.withOpacity(0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(
            color: SoloLevelingTheme.primaryCyan.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(
            color: SoloLevelingTheme.primaryCyan,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(
            color: SoloLevelingTheme.hpRed,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      validator: validator,
    );
  }

  Widget _buildNutrientField({
    required TextEditingController controller,
    required String label,
    required Color color,
    String unit = 'g',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: SoloLevelingTheme.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            hintText: '0',
            hintStyle: TextStyle(
              color: SoloLevelingTheme.textMuted.withOpacity(0.5),
            ),
            suffixText: unit,
            suffixStyle: TextStyle(
              color: SoloLevelingTheme.textMuted,
              fontSize: 11,
            ),
            filled: true,
            fillColor: SoloLevelingTheme.backgroundCard,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: color.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: color.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
              borderSide: BorderSide(color: color),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            isDense: true,
          ),
        ),
      ],
    );
  }

  Widget _buildMealTypeSelector() {
    return Row(
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
                  : SoloLevelingTheme.backgroundCard,
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
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 2),
                Text(
                  type.displayName,
                  style: TextStyle(
                    color: isSelected
                        ? SoloLevelingTheme.primaryCyan
                        : SoloLevelingTheme.textMuted,
                    fontSize: 9,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _saveEntry,
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
            'SAVE ENTRY',
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
