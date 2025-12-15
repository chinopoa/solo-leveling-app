import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/solo_leveling_theme.dart';
import '../widgets/widgets.dart';
import 'nutrition_goals_screen.dart';

/// Settings screen - Configure quests and nutrition goals
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SoloLevelingTheme.backgroundCard,
                  border: Border.all(
                    color: SoloLevelingTheme.primaryCyan.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.settings,
                      color: SoloLevelingTheme.primaryCyan,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'SYSTEM SETTINGS',
                      style: TextStyle(
                        color: SoloLevelingTheme.primaryCyan,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Daily Quest Settings
              SystemWindow(
                title: 'DAILY QUEST CONFIGURATION',
                child: Column(
                  children: [
                    ...game.dailyConfigs.map((config) => _QuestConfigTile(
                          config: config,
                          onUpdate: (newTarget) {
                            final updated = config.copyWith(targetCount: newTarget);
                            game.updateDailyConfig(updated);
                          },
                          onToggle: (enabled) {
                            final updated = config.copyWith(isEnabled: enabled);
                            game.updateDailyConfig(updated);
                          },
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Nutrition Calculator
              SystemWindow(
                title: 'CALORIE CALCULATOR',
                child: _CalorieCalculator(),
              ),
              const SizedBox(height: 16),

              // Nutrition Goals Link
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const NutritionGoalsScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: SoloLevelingTheme.backgroundCard,
                    border: Border.all(
                      color: SoloLevelingTheme.getStatColor('VIT').withOpacity(0.5),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        color: SoloLevelingTheme.getStatColor('VIT'),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'NUTRITION GOALS',
                              style: TextStyle(
                                color: SoloLevelingTheme.getStatColor('VIT'),
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Set your daily calorie and macro targets',
                              style: TextStyle(
                                color: SoloLevelingTheme.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: SoloLevelingTheme.getStatColor('VIT'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Reset Data Section
              SystemWindow(
                title: 'DANGER ZONE',
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: SoloLevelingTheme.hpRed.withOpacity(0.1),
                        border: Border.all(
                          color: SoloLevelingTheme.hpRed.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning,
                            color: SoloLevelingTheme.hpRed,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Reset options will permanently delete your data',
                              style: TextStyle(
                                color: SoloLevelingTheme.hpRed,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _DangerButton(
                            label: 'RESET TODAY',
                            onTap: () => _showResetDialog(
                              context,
                              'Reset Today\'s Progress',
                              'This will reset all daily quest progress for today.',
                              () => game.resetTodayProgress(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DangerButton(
                            label: 'RESET ALL',
                            onTap: () => _showResetDialog(
                              context,
                              'Reset All Data',
                              'This will delete ALL your data including stats, level, and history. This cannot be undone!',
                              () => game.resetAllData(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showResetDialog(
    BuildContext context,
    String title,
    String message,
    VoidCallback onConfirm,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SoloLevelingTheme.backgroundCard,
        title: Text(
          title,
          style: const TextStyle(color: SoloLevelingTheme.hpRed),
        ),
        content: Text(
          message,
          style: const TextStyle(color: SoloLevelingTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              onConfirm();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data has been reset')),
              );
            },
            child: const Text(
              'RESET',
              style: TextStyle(color: SoloLevelingTheme.hpRed),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestConfigTile extends StatelessWidget {
  final dynamic config;
  final Function(int) onUpdate;
  final Function(bool) onToggle;

  const _QuestConfigTile({
    required this.config,
    required this.onUpdate,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final color = SoloLevelingTheme.getStatColor(config.statBonus);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: config.isEnabled
            ? SoloLevelingTheme.backgroundElevated
            : SoloLevelingTheme.backgroundElevated.withOpacity(0.5),
        border: Border.all(
          color: config.isEnabled ? color.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Enable/disable toggle
              GestureDetector(
                onTap: () => onToggle(!config.isEnabled),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: config.isEnabled ? color.withOpacity(0.2) : Colors.transparent,
                    border: Border.all(
                      color: config.isEnabled ? color : Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: config.isEnabled
                      ? Icon(Icons.check, color: color, size: 16)
                      : null,
                ),
              ),
              const SizedBox(width: 12),
              // Stat badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  border: Border.all(color: color.withOpacity(0.5)),
                ),
                child: Text(
                  config.statBonus,
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Title
              Expanded(
                child: Text(
                  config.title,
                  style: TextStyle(
                    color: config.isEnabled
                        ? SoloLevelingTheme.textPrimary
                        : SoloLevelingTheme.textMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (config.isEnabled) ...[
            const SizedBox(height: 12),
            // Target adjustment
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _AdjustButton(
                  label: '-10',
                  onTap: config.targetCount > 10
                      ? () => onUpdate(config.targetCount - 10)
                      : null,
                  color: color,
                ),
                const SizedBox(width: 8),
                _AdjustButton(
                  label: '-1',
                  onTap: config.targetCount > 1
                      ? () => onUpdate(config.targetCount - 1)
                      : null,
                  color: color,
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    border: Border.all(color: color),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${config.targetCount}',
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _AdjustButton(
                  label: '+1',
                  onTap: () => onUpdate(config.targetCount + 1),
                  color: color,
                ),
                const SizedBox(width: 8),
                _AdjustButton(
                  label: '+10',
                  onTap: () => onUpdate(config.targetCount + 10),
                  color: color,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _AdjustButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color color;

  const _AdjustButton({
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(
            color: isDisabled ? color.withOpacity(0.2) : color.withOpacity(0.5),
          ),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isDisabled ? color.withOpacity(0.3) : color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _DangerButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _DangerButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: SoloLevelingTheme.hpRed.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: SoloLevelingTheme.hpRed,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ),
    );
  }
}

class _CalorieCalculator extends StatefulWidget {
  @override
  State<_CalorieCalculator> createState() => _CalorieCalculatorState();
}

class _CalorieCalculatorState extends State<_CalorieCalculator> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  final _targetWeightController = TextEditingController();

  String _gender = 'male';
  String _activityLevel = 'moderate';
  String _weightChangeRate = '0.5'; // kg per week

  Map<String, dynamic>? _results;

  final Map<String, double> _activityMultipliers = {
    'sedentary': 1.2,
    'light': 1.375,
    'moderate': 1.55,
    'active': 1.725,
    'very_active': 1.9,
  };

  final Map<String, String> _activityLabels = {
    'sedentary': 'Sedentary (little/no exercise)',
    'light': 'Light (1-3 days/week)',
    'moderate': 'Moderate (3-5 days/week)',
    'active': 'Active (6-7 days/week)',
    'very_active': 'Very Active (2x/day)',
  };

  final Map<String, String> _rateLabels = {
    '0.25': '0.25 kg/week (slow)',
    '0.5': '0.5 kg/week (moderate)',
    '0.75': '0.75 kg/week (fast)',
    '1.0': '1.0 kg/week (aggressive)',
  };

  void _calculate() {
    final weight = double.tryParse(_weightController.text);
    final height = double.tryParse(_heightController.text);
    final age = int.tryParse(_ageController.text);
    final targetWeight = double.tryParse(_targetWeightController.text);

    if (weight == null || height == null || age == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in weight, height, and age')),
      );
      return;
    }

    // Calculate BMR using Mifflin-St Jeor Equation
    double bmr;
    if (_gender == 'male') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    // Apply activity multiplier to get TDEE (maintenance calories)
    final tdee = bmr * _activityMultipliers[_activityLevel]!;

    // Determine goal and calculate calories
    double targetCalories;
    double weightDiff = 0;
    int weeksToGoal = 0;
    String goalType = 'maintain';
    double weeklyChange = double.parse(_weightChangeRate);

    if (targetWeight != null && targetWeight != weight) {
      weightDiff = targetWeight - weight;

      if (weightDiff > 0) {
        // Gaining weight
        goalType = 'gain';
        // 7700 kcal ≈ 1 kg of body weight
        final dailySurplus = (weeklyChange * 7700) / 7;
        targetCalories = tdee + dailySurplus;
        weeksToGoal = (weightDiff / weeklyChange).ceil();
      } else {
        // Losing weight
        goalType = 'lose';
        final dailyDeficit = (weeklyChange * 7700) / 7;
        targetCalories = tdee - dailyDeficit;
        weeksToGoal = (weightDiff.abs() / weeklyChange).ceil();
      }
    } else {
      targetCalories = tdee;
    }

    // Ensure minimum calories for health
    if (targetCalories < 1200) {
      targetCalories = 1200;
    }

    // Calculate macros based on target weight (or current if maintaining)
    final proteinWeight = targetWeight ?? weight;
    // Protein: 2g per kg for muscle building/preservation
    final protein = proteinWeight * 2;
    // Fat: 25% of calories
    final fat = (targetCalories * 0.25) / 9;
    // Carbs: remaining calories
    final carbCalories = targetCalories - (protein * 4) - (fat * 9);
    final carbs = (carbCalories / 4).clamp(50, double.infinity);

    // Calculate goal date
    final goalDate = weeksToGoal > 0
        ? DateTime.now().add(Duration(days: weeksToGoal * 7))
        : null;

    setState(() {
      _results = {
        'tdee': tdee,
        'calories': targetCalories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'goalType': goalType,
        'weightDiff': weightDiff,
        'weeksToGoal': weeksToGoal,
        'goalDate': goalDate,
        'currentWeight': weight,
        'targetWeight': targetWeight,
        'weeklyChange': weeklyChange,
      };
    });
  }

  void _applyToGoals() {
    if (_results == null) return;

    final game = context.read<GameProvider>();
    final currentGoals = game.nutritionGoals;
    final updatedGoals = currentGoals.copyWith(
      dailyCalories: (_results!['calories'] as double).round(),
      dailyProtein: (_results!['protein'] as double).round(),
      dailyCarbs: (_results!['carbs'] as double).round(),
      dailyFat: (_results!['fat'] as double).round(),
    );
    game.updateNutritionGoals(updatedGoals);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nutrition goals updated!')),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    _targetWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vitColor = SoloLevelingTheme.getStatColor('VIT');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Basic info row
        Row(
          children: [
            Expanded(
              child: _InputField(
                controller: _weightController,
                label: 'Current (kg)',
                hint: '70',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InputField(
                controller: _heightController,
                label: 'Height (cm)',
                hint: '175',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _InputField(
                controller: _ageController,
                label: 'Age',
                hint: '25',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Target weight row
        Row(
          children: [
            Expanded(
              flex: 2,
              child: _InputField(
                controller: _targetWeightController,
                label: 'Target Weight (kg)',
                hint: '75 (leave empty to maintain)',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Gender selection
        Row(
          children: [
            Text(
              'Gender: ',
              style: TextStyle(
                color: SoloLevelingTheme.textMuted,
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 8),
            _SelectButton(
              label: 'Male',
              isSelected: _gender == 'male',
              onTap: () => setState(() => _gender = 'male'),
            ),
            const SizedBox(width: 8),
            _SelectButton(
              label: 'Female',
              isSelected: _gender == 'female',
              onTap: () => setState(() => _gender = 'female'),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Activity level
        Text(
          'Activity Level:',
          style: TextStyle(
            color: SoloLevelingTheme.textMuted,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: SoloLevelingTheme.primaryCyan.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButton<String>(
            value: _activityLevel,
            isExpanded: true,
            dropdownColor: SoloLevelingTheme.backgroundCard,
            underline: const SizedBox(),
            style: TextStyle(
              color: SoloLevelingTheme.textPrimary,
              fontSize: 12,
            ),
            items: _activityLabels.entries.map((e) {
              return DropdownMenuItem(
                value: e.key,
                child: Text(e.value),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _activityLevel = value);
            },
          ),
        ),
        const SizedBox(height: 12),

        // Weight change rate
        Text(
          'Weight Change Rate:',
          style: TextStyle(
            color: SoloLevelingTheme.textMuted,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: SoloLevelingTheme.primaryCyan.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: DropdownButton<String>(
            value: _weightChangeRate,
            isExpanded: true,
            dropdownColor: SoloLevelingTheme.backgroundCard,
            underline: const SizedBox(),
            style: TextStyle(
              color: SoloLevelingTheme.textPrimary,
              fontSize: 12,
            ),
            items: _rateLabels.entries.map((e) {
              return DropdownMenuItem(
                value: e.key,
                child: Text(e.value),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _weightChangeRate = value);
            },
          ),
        ),
        const SizedBox(height: 16),

        // Calculate button
        GestureDetector(
          onTap: _calculate,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: SoloLevelingTheme.primaryCyan.withOpacity(0.1),
              border: Border.all(color: SoloLevelingTheme.primaryCyan),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Center(
              child: Text(
                'CALCULATE',
                style: TextStyle(
                  color: SoloLevelingTheme.primaryCyan,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ),

        // Results
        if (_results != null) ...[
          const SizedBox(height: 16),

          // Goal summary
          _buildGoalSummary(vitColor),
          const SizedBox(height: 12),

          // Daily intake
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: vitColor.withOpacity(0.1),
              border: Border.all(color: vitColor.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                Text(
                  'DAILY INTAKE TO REACH GOAL',
                  style: TextStyle(
                    color: vitColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ResultItem(
                      label: 'CALORIES',
                      value: '${(_results!['calories'] as double).round()}',
                      unit: 'kcal',
                      color: vitColor,
                    ),
                    _ResultItem(
                      label: 'PROTEIN',
                      value: '${(_results!['protein'] as double).round()}',
                      unit: 'g',
                      color: vitColor,
                    ),
                    _ResultItem(
                      label: 'CARBS',
                      value: '${(_results!['carbs'] as double).round()}',
                      unit: 'g',
                      color: vitColor,
                    ),
                    _ResultItem(
                      label: 'FAT',
                      value: '${(_results!['fat'] as double).round()}',
                      unit: 'g',
                      color: vitColor,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Maintenance: ${(_results!['tdee'] as double).round()} kcal/day',
                  style: TextStyle(
                    color: SoloLevelingTheme.textMuted,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _applyToGoals,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: vitColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Center(
                      child: Text(
                        'APPLY TO MY GOALS',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildGoalSummary(Color vitColor) {
    final goalType = _results!['goalType'] as String;
    final weightDiff = _results!['weightDiff'] as double;
    final weeksToGoal = _results!['weeksToGoal'] as int;
    final goalDate = _results!['goalDate'] as DateTime?;
    final currentWeight = _results!['currentWeight'] as double;
    final targetWeight = _results!['targetWeight'] as double?;
    final weeklyChange = _results!['weeklyChange'] as double;
    final calories = _results!['calories'] as double;
    final tdee = _results!['tdee'] as double;

    Color goalColor;
    IconData goalIcon;
    String goalText;
    String detailText;

    if (goalType == 'maintain') {
      goalColor = SoloLevelingTheme.primaryCyan;
      goalIcon = Icons.balance;
      goalText = 'MAINTAIN WEIGHT';
      detailText = 'Stay at ${currentWeight.toStringAsFixed(1)} kg';
    } else if (goalType == 'gain') {
      goalColor = SoloLevelingTheme.successGreen;
      goalIcon = Icons.trending_up;
      goalText = 'GAIN ${weightDiff.toStringAsFixed(1)} KG';
      final surplus = (calories - tdee).round();
      detailText = '+$surplus kcal/day surplus';
    } else {
      goalColor = SoloLevelingTheme.hpRed;
      goalIcon = Icons.trending_down;
      goalText = 'LOSE ${weightDiff.abs().toStringAsFixed(1)} KG';
      final deficit = (tdee - calories).round();
      detailText = '-$deficit kcal/day deficit';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: goalColor.withOpacity(0.1),
        border: Border.all(color: goalColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(goalIcon, color: goalColor, size: 24),
              const SizedBox(width: 8),
              Text(
                goalText,
                style: TextStyle(
                  color: goalColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            detailText,
            style: TextStyle(
              color: goalColor.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          if (goalType != 'maintain' && goalDate != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: SoloLevelingTheme.backgroundElevated,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _TimelineItem(
                        label: 'NOW',
                        value: '${currentWeight.toStringAsFixed(1)} kg',
                        color: SoloLevelingTheme.textMuted,
                      ),
                      Icon(
                        Icons.arrow_forward,
                        color: goalColor,
                        size: 20,
                      ),
                      _TimelineItem(
                        label: 'GOAL',
                        value: '${targetWeight?.toStringAsFixed(1)} kg',
                        color: goalColor,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Divider(color: goalColor.withOpacity(0.3), height: 1),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          Text(
                            '$weeksToGoal',
                            style: TextStyle(
                              color: goalColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'WEEKS',
                            style: TextStyle(
                              color: SoloLevelingTheme.textMuted,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '${(weeksToGoal / 4.33).toStringAsFixed(1)}',
                            style: TextStyle(
                              color: goalColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'MONTHS',
                            style: TextStyle(
                              color: SoloLevelingTheme.textMuted,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '${goalDate.day}/${goalDate.month}',
                            style: TextStyle(
                              color: goalColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'TARGET DATE',
                            style: TextStyle(
                              color: SoloLevelingTheme.textMuted,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '@ ${weeklyChange.toStringAsFixed(2)} kg/week',
                    style: TextStyle(
                      color: SoloLevelingTheme.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _TimelineItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;

  const _InputField({
    required this.controller,
    required this.label,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: SoloLevelingTheme.textMuted,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            color: SoloLevelingTheme.textPrimary,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: SoloLevelingTheme.textMuted.withOpacity(0.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            isDense: true,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: SoloLevelingTheme.primaryCyan.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(
                color: SoloLevelingTheme.primaryCyan,
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }
}

class _SelectButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _SelectButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? SoloLevelingTheme.primaryCyan;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? buttonColor.withOpacity(0.2) : Colors.transparent,
          border: Border.all(
            color: isSelected ? buttonColor : SoloLevelingTheme.textMuted.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? buttonColor : SoloLevelingTheme.textMuted,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _ResultItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final Color color;

  const _ResultItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          unit,
          style: TextStyle(
            color: color.withOpacity(0.7),
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: SoloLevelingTheme.textMuted,
            fontSize: 8,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
