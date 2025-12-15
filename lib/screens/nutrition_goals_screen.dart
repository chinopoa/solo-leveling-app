import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/game_provider.dart';
import '../theme/solo_leveling_theme.dart';

class NutritionGoalsScreen extends StatefulWidget {
  const NutritionGoalsScreen({super.key});

  @override
  State<NutritionGoalsScreen> createState() => _NutritionGoalsScreenState();
}

class _NutritionGoalsScreenState extends State<NutritionGoalsScreen> {
  late TextEditingController _caloriesController;
  late TextEditingController _proteinController;
  late TextEditingController _carbsController;
  late TextEditingController _fatController;
  late TextEditingController _fiberController;
  late TextEditingController _sugarController;
  late TextEditingController _sodiumController;
  late bool _isEnabled;

  @override
  void initState() {
    super.initState();
    final goals = context.read<GameProvider>().nutritionGoals;

    _caloriesController = TextEditingController(text: goals.dailyCalories.toString());
    _proteinController = TextEditingController(text: goals.dailyProtein.toString());
    _carbsController = TextEditingController(text: goals.dailyCarbs.toString());
    _fatController = TextEditingController(text: goals.dailyFat.toString());
    _fiberController = TextEditingController(text: goals.dailyFiber.toString());
    _sugarController = TextEditingController(text: goals.dailySugar.toString());
    _sodiumController = TextEditingController(text: goals.dailySodium.toString());
    _isEnabled = goals.isEnabled;
  }

  @override
  void dispose() {
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _fiberController.dispose();
    _sugarController.dispose();
    _sodiumController.dispose();
    super.dispose();
  }

  void _saveGoals() {
    final goals = NutritionGoals(
      dailyCalories: int.tryParse(_caloriesController.text) ?? 2000,
      dailyProtein: int.tryParse(_proteinController.text) ?? 150,
      dailyCarbs: int.tryParse(_carbsController.text) ?? 250,
      dailyFat: int.tryParse(_fatController.text) ?? 65,
      dailyFiber: int.tryParse(_fiberController.text) ?? 25,
      dailySugar: int.tryParse(_sugarController.text) ?? 50,
      dailySodium: int.tryParse(_sodiumController.text) ?? 2300,
      isEnabled: _isEnabled,
    );

    context.read<GameProvider>().updateNutritionGoals(goals);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: SoloLevelingTheme.backgroundCard,
        content: Text(
          'Nutrition goals updated',
          style: TextStyle(color: SoloLevelingTheme.textPrimary),
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
          'NUTRITION GOALS',
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
            // Daily quest toggle
            _buildQuestToggle(),
            const SizedBox(height: 24),

            // Calories
            _buildSectionTitle('DAILY CALORIES'),
            _buildGoalField(
              controller: _caloriesController,
              suffix: 'kcal',
              color: SoloLevelingTheme.xpGold,
              icon: Icons.local_fire_department,
            ),
            const SizedBox(height: 24),

            // Main macros
            _buildSectionTitle('MACRONUTRIENTS'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildMacroField(
                    controller: _proteinController,
                    label: 'Protein',
                    color: SoloLevelingTheme.hpRed,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMacroField(
                    controller: _carbsController,
                    label: 'Carbs',
                    color: SoloLevelingTheme.mpBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMacroField(
                    controller: _fatController,
                    label: 'Fat',
                    color: SoloLevelingTheme.primaryCyan,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Other nutrients
            _buildSectionTitle('OTHER NUTRIENTS'),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildMacroField(
                    controller: _fiberController,
                    label: 'Fiber (g)',
                    color: SoloLevelingTheme.successGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMacroField(
                    controller: _sugarController,
                    label: 'Sugar (g)',
                    color: SoloLevelingTheme.xpGold,
                    isLimit: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMacroField(
                    controller: _sodiumController,
                    label: 'Sodium (mg)',
                    color: SoloLevelingTheme.textMuted,
                    isLimit: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Info text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: SoloLevelingTheme.backgroundCard,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: SoloLevelingTheme.textMuted.withOpacity(0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: SoloLevelingTheme.textMuted,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Sugar and Sodium are limits - staying under is the goal!',
                      style: TextStyle(
                        color: SoloLevelingTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save button
            _buildSaveButton(),
            const SizedBox(height: 16),

            // Reset to defaults
            _buildResetButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SoloLevelingTheme.backgroundCard,
        border: Border.all(
          color: _isEnabled
              ? SoloLevelingTheme.successGreen.withOpacity(0.5)
              : SoloLevelingTheme.primaryCyan.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _isEnabled
                  ? SoloLevelingTheme.successGreen.withOpacity(0.2)
                  : SoloLevelingTheme.backgroundElevated,
              border: Border.all(
                color: _isEnabled
                    ? SoloLevelingTheme.successGreen
                    : SoloLevelingTheme.textMuted,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.restaurant,
              color: _isEnabled
                  ? SoloLevelingTheme.successGreen
                  : SoloLevelingTheme.textMuted,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Count as Daily Quest',
                  style: TextStyle(
                    color: SoloLevelingTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Hitting your calorie goal rewards VIT stat',
                  style: TextStyle(
                    color: SoloLevelingTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _isEnabled,
            onChanged: (value) => setState(() => _isEnabled = value),
            activeColor: SoloLevelingTheme.successGreen,
            inactiveThumbColor: SoloLevelingTheme.textMuted,
            inactiveTrackColor: SoloLevelingTheme.backgroundElevated,
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

  Widget _buildGoalField({
    required TextEditingController controller,
    required String suffix,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SoloLevelingTheme.backgroundCard,
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: TextStyle(
                color: color,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                suffixText: suffix,
                suffixStyle: TextStyle(
                  color: SoloLevelingTheme.textMuted,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroField({
    required TextEditingController controller,
    required String label,
    required Color color,
    bool isLimit = false,
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
            if (isLimit) ...[
              const SizedBox(width: 4),
              Text(
                '(max)',
                style: TextStyle(
                  color: SoloLevelingTheme.textMuted,
                  fontSize: 9,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            suffixText: label.contains('mg') ? '' : 'g',
            suffixStyle: TextStyle(
              color: SoloLevelingTheme.textMuted,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _saveGoals,
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
            'SAVE GOALS',
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

  Widget _buildResetButton() {
    return GestureDetector(
      onTap: () {
        final defaults = NutritionGoals.defaults();
        setState(() {
          _caloriesController.text = defaults.dailyCalories.toString();
          _proteinController.text = defaults.dailyProtein.toString();
          _carbsController.text = defaults.dailyCarbs.toString();
          _fatController.text = defaults.dailyFat.toString();
          _fiberController.text = defaults.dailyFiber.toString();
          _sugarController.text = defaults.dailySugar.toString();
          _sodiumController.text = defaults.dailySodium.toString();
          _isEnabled = defaults.isEnabled;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: SoloLevelingTheme.textMuted.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            'RESET TO DEFAULTS',
            style: TextStyle(
              color: SoloLevelingTheme.textMuted,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }
}
