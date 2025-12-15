import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/game_provider.dart';
import '../theme/solo_leveling_theme.dart';
import '../widgets/widgets.dart';
import 'barcode_scanner_screen.dart';
import 'manual_entry_screen.dart';
import 'nutrition_goals_screen.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SoloLevelingTheme.backgroundDark,
      appBar: AppBar(
        backgroundColor: SoloLevelingTheme.backgroundCard,
        title: const Text(
          'NUTRITION TRACKER',
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
          IconButton(
            icon: const Icon(Icons.settings, color: SoloLevelingTheme.textMuted),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NutritionGoalsScreen(),
                ),
              );
            },
            tooltip: 'Goals Settings',
          ),
        ],
      ),
      body: Consumer<GameProvider>(
        builder: (context, game, child) {
          final goals = game.nutritionGoals;
          final entries = game.todayNutritionEntries;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Calorie summary
                _buildCalorieSummary(game, goals),
                const SizedBox(height: 16),

                // Macro breakdown
                _buildMacroBreakdown(game, goals),
                const SizedBox(height: 16),

                // Detailed nutrients
                _buildDetailedNutrients(game, goals),
                const SizedBox(height: 16),

                // Food log by meal
                _buildFoodLog(context, game, entries),
                const SizedBox(height: 80), // Space for FAB
              ],
            ),
          );
        },
      ),
      floatingActionButton: _buildAddFoodButton(context),
    );
  }

  Widget _buildCalorieSummary(GameProvider game, NutritionGoals goals) {
    final consumed = game.todayCalories;
    final target = goals.dailyCalories;
    final progress = (consumed / target).clamp(0.0, 1.0);
    final remaining = target - consumed;
    final isComplete = goals.isCalorieGoalMet(consumed);

    return SystemWindow(
      title: 'DAILY CALORIES',
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    consumed.toStringAsFixed(0),
                    style: TextStyle(
                      color: isComplete
                          ? SoloLevelingTheme.successGreen
                          : SoloLevelingTheme.xpGold,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'of $target kcal',
                    style: TextStyle(
                      color: SoloLevelingTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    remaining > 0 ? '${remaining.toStringAsFixed(0)}' : '0',
                    style: TextStyle(
                      color: remaining > 0
                          ? SoloLevelingTheme.textSecondary
                          : SoloLevelingTheme.successGreen,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    remaining > 0 ? 'remaining' : 'goal reached!',
                    style: TextStyle(
                      color: SoloLevelingTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: SoloLevelingTheme.xpGold.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(
                isComplete
                    ? SoloLevelingTheme.successGreen
                    : SoloLevelingTheme.xpGold,
              ),
              minHeight: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% of daily goal',
            style: TextStyle(
              color: SoloLevelingTheme.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroBreakdown(GameProvider game, NutritionGoals goals) {
    return SystemWindow(
      title: 'MACRONUTRIENTS',
      child: Row(
        children: [
          Expanded(
            child: _buildMacroItem(
              'PROTEIN',
              game.todayProtein,
              goals.dailyProtein.toDouble(),
              'g',
              SoloLevelingTheme.hpRed,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMacroItem(
              'CARBS',
              game.todayCarbs,
              goals.dailyCarbs.toDouble(),
              'g',
              SoloLevelingTheme.mpBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildMacroItem(
              'FAT',
              game.todayFat,
              goals.dailyFat.toDouble(),
              'g',
              SoloLevelingTheme.primaryCyan,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(
    String label,
    double consumed,
    double target,
    String unit,
    Color color,
  ) {
    final progress = (consumed / target).clamp(0.0, 1.0);

    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: SoloLevelingTheme.textMuted,
            fontSize: 9,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                value: progress,
                backgroundColor: color.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation(color),
                strokeWidth: 6,
              ),
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${consumed.toStringAsFixed(0)}$unit',
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          '/ ${target.toStringAsFixed(0)}$unit',
          style: TextStyle(
            color: SoloLevelingTheme.textMuted,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedNutrients(GameProvider game, NutritionGoals goals) {
    return SystemWindow(
      title: 'OTHER NUTRIENTS',
      child: Column(
        children: [
          _buildNutrientRow(
            'Fiber',
            game.todayFiber,
            goals.dailyFiber.toDouble(),
            'g',
            SoloLevelingTheme.successGreen,
          ),
          const SizedBox(height: 8),
          _buildNutrientRow(
            'Sugar',
            game.todaySugar,
            goals.dailySugar.toDouble(),
            'g',
            SoloLevelingTheme.xpGold,
            isLimit: true,
          ),
          const SizedBox(height: 8),
          _buildNutrientRow(
            'Sodium',
            game.todaySodium,
            goals.dailySodium.toDouble(),
            'mg',
            SoloLevelingTheme.textMuted,
            isLimit: true,
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientRow(
    String label,
    double consumed,
    double target,
    String unit,
    Color color, {
    bool isLimit = false,
  }) {
    final progress = (consumed / target).clamp(0.0, 1.5);
    final isOverLimit = isLimit && consumed > target;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isOverLimit ? SoloLevelingTheme.hpRed : color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: SoloLevelingTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            Text(
              '${consumed.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} $unit',
              style: TextStyle(
                color: isOverLimit ? SoloLevelingTheme.hpRed : color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation(
              isOverLimit ? SoloLevelingTheme.hpRed : color,
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildFoodLog(
    BuildContext context,
    GameProvider game,
    List<NutritionEntry> entries,
  ) {
    if (entries.isEmpty) {
      return SystemWindow(
        title: 'TODAY\'S FOOD LOG',
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Icon(
                  Icons.restaurant_menu,
                  color: SoloLevelingTheme.textMuted,
                  size: 48,
                ),
                const SizedBox(height: 12),
                Text(
                  'No food logged yet',
                  style: TextStyle(
                    color: SoloLevelingTheme.textMuted,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap + to scan a barcode or add food manually',
                  style: TextStyle(
                    color: SoloLevelingTheme.textMuted.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return SystemWindow(
      title: 'TODAY\'S FOOD LOG',
      child: Column(
        children: MealType.values.map((mealType) {
          final mealEntries = game.getEntriesByMealType(mealType);
          if (mealEntries.isEmpty) return const SizedBox.shrink();

          return _buildMealSection(context, game, mealType, mealEntries);
        }).toList(),
      ),
    );
  }

  Widget _buildMealSection(
    BuildContext context,
    GameProvider game,
    MealType mealType,
    List<NutritionEntry> entries,
  ) {
    final mealCalories = entries.fold<double>(0, (sum, e) => sum + e.totalCalories);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    mealType.icon,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    mealType.displayName.toUpperCase(),
                    style: TextStyle(
                      color: SoloLevelingTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              Text(
                '${mealCalories.toStringAsFixed(0)} kcal',
                style: TextStyle(
                  color: SoloLevelingTheme.xpGold,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Food items
          ...entries.map((entry) => _buildFoodItem(context, game, entry)),
        ],
      ),
    );
  }

  Widget _buildFoodItem(
    BuildContext context,
    GameProvider game,
    NutritionEntry entry,
  ) {
    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: SoloLevelingTheme.hpRed.withOpacity(0.2),
        child: const Icon(
          Icons.delete,
          color: SoloLevelingTheme.hpRed,
        ),
      ),
      onDismissed: (_) {
        game.deleteNutritionEntry(entry.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: SoloLevelingTheme.backgroundCard,
            content: Text(
              'Removed ${entry.productName}',
              style: const TextStyle(color: SoloLevelingTheme.textPrimary),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: SoloLevelingTheme.backgroundElevated,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: SoloLevelingTheme.primaryCyan.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.productName,
                    style: const TextStyle(
                      color: SoloLevelingTheme.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${entry.servingsConsumed}x ${entry.servingSize.toStringAsFixed(0)}g',
                    style: TextStyle(
                      color: SoloLevelingTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${entry.totalCalories.toStringAsFixed(0)} kcal',
                  style: const TextStyle(
                    color: SoloLevelingTheme.xpGold,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'P:${entry.totalProtein.toStringAsFixed(0)} C:${entry.totalCarbs.toStringAsFixed(0)} F:${entry.totalFat.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: SoloLevelingTheme.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddFoodButton(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Manual entry button
        FloatingActionButton.small(
          heroTag: 'manual',
          backgroundColor: SoloLevelingTheme.backgroundCard,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ManualEntryScreen(),
              ),
            );
          },
          child: const Icon(
            Icons.edit,
            color: SoloLevelingTheme.textMuted,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        // Scan button
        FloatingActionButton(
          heroTag: 'scan',
          backgroundColor: SoloLevelingTheme.primaryCyan,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const BarcodeScannerScreen(),
              ),
            );
          },
          child: const Icon(
            Icons.qr_code_scanner,
            color: SoloLevelingTheme.backgroundDark,
          ),
        ),
      ],
    );
  }
}
