import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/solo_leveling_theme.dart';
import '../widgets/widgets.dart';
import 'nutrition_screen.dart';
import 'barcode_scanner_screen.dart';

/// Daily Quest screen - The iconic "Strength of the Weak" training
class DailyQuestScreen extends StatefulWidget {
  const DailyQuestScreen({super.key});

  @override
  State<DailyQuestScreen> createState() => _DailyQuestScreenState();
}

class _DailyQuestScreenState extends State<DailyQuestScreen> {
  Timer? _timer;
  String _timeRemaining = '00:00:00';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _updateTime();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    final game = context.read<GameProvider>();
    setState(() {
      _timeRemaining = game.formattedTimeUntilReset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        final configs = game.dailyConfigs;
        final progress = game.todayProgress;
        final allComplete = progress?.isCompleted ?? false;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with timer
              _buildHeader(allComplete),
              const SizedBox(height: 16),

              // Daily quest list
              SystemWindow(
                title: 'DAILY QUEST: STRENGTH OF THE WEAK',
                child: Column(
                  children: [
                    // Warning text
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: allComplete
                            ? SoloLevelingTheme.successGreen.withOpacity(0.1)
                            : SoloLevelingTheme.hpRed.withOpacity(0.1),
                        border: Border.all(
                          color: allComplete
                              ? SoloLevelingTheme.successGreen.withOpacity(0.3)
                              : SoloLevelingTheme.hpRed.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        allComplete
                            ? 'DAILY QUEST COMPLETED'
                            : 'WARNING: Failure to complete will result in penalty',
                        style: TextStyle(
                          color: allComplete
                              ? SoloLevelingTheme.successGreen
                              : SoloLevelingTheme.hpRed,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Quest items
                    ...configs.where((c) => c.isEnabled).map((config) {
                      final currentProgress =
                          progress?.getProgress(config.id) ?? 0;
                      final isComplete = currentProgress >= config.targetCount;

                      return _DailyQuestItem(
                        config: config,
                        currentProgress: currentProgress,
                        isComplete: isComplete,
                        onIncrement: () {
                          game.updateDailyProgress(
                            config.id,
                            currentProgress + 1,
                          );
                        },
                        onSetValue: (value) {
                          game.updateDailyProgress(config.id, value);
                        },
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Nutrition tracking section
              _buildNutritionSection(game),
              const SizedBox(height: 16),

              // Rewards info
              _buildRewardsInfo(game),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool allComplete) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SoloLevelingTheme.backgroundCard,
        border: Border.all(
          color: allComplete
              ? SoloLevelingTheme.successGreen.withOpacity(0.5)
              : SoloLevelingTheme.primaryCyan.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // Status icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              border: Border.all(
                color: allComplete
                    ? SoloLevelingTheme.successGreen
                    : SoloLevelingTheme.primaryCyan,
                width: 2,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              allComplete ? Icons.check : Icons.fitness_center,
              color: allComplete
                  ? SoloLevelingTheme.successGreen
                  : SoloLevelingTheme.primaryCyan,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allComplete ? 'QUEST COMPLETE' : 'TIME REMAINING',
                  style: TextStyle(
                    color: SoloLevelingTheme.textMuted,
                    fontSize: 10,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  allComplete ? 'WELL DONE, HUNTER' : _timeRemaining,
                  style: TextStyle(
                    color: allComplete
                        ? SoloLevelingTheme.successGreen
                        : SoloLevelingTheme.primaryCyan,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardsInfo(GameProvider game) {
    return SystemWindow(
      title: 'COMPLETION REWARDS',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _RewardItem(
            icon: Icons.auto_awesome,
            label: 'XP BONUS',
            value: '+100',
            color: SoloLevelingTheme.xpGold,
          ),
          _RewardItem(
            icon: Icons.local_fire_department,
            label: 'STREAK',
            value: '+1 Day',
            color: SoloLevelingTheme.hpRed,
          ),
          _RewardItem(
            icon: Icons.trending_up,
            label: 'STAT GROWTH',
            value: 'Active',
            color: SoloLevelingTheme.successGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionSection(GameProvider game) {
    final goals = game.nutritionGoals;
    final todayCalories = game.todayCalories;
    final todayProtein = game.todayProtein;
    final todayCarbs = game.todayCarbs;
    final todayFat = game.todayFat;
    final isGoalMet = game.isNutritionGoalMet;

    // VIT stat color for nutrition
    final vitColor = SoloLevelingTheme.getStatColor('VIT');

    return SystemWindow(
      title: 'NUTRITION TRACKING',
      child: Column(
        children: [
          // Status indicator
          if (goals.isEnabled)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: isGoalMet
                    ? SoloLevelingTheme.successGreen.withOpacity(0.1)
                    : vitColor.withOpacity(0.1),
                border: Border.all(
                  color: isGoalMet
                      ? SoloLevelingTheme.successGreen.withOpacity(0.3)
                      : vitColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isGoalMet ? Icons.check_circle : Icons.restaurant,
                    color: isGoalMet
                        ? SoloLevelingTheme.successGreen
                        : vitColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isGoalMet ? 'NUTRITION GOAL MET' : 'TRACK YOUR MEALS',
                    style: TextStyle(
                      color: isGoalMet
                          ? SoloLevelingTheme.successGreen
                          : vitColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

          // Calorie progress
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SoloLevelingTheme.backgroundElevated,
              border: Border.all(color: vitColor.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'CALORIES',
                      style: TextStyle(
                        color: SoloLevelingTheme.textMuted,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      '${todayCalories.toInt()} / ${goals.dailyCalories.toInt()} kcal',
                      style: TextStyle(
                        color: vitColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: goals.dailyCalories > 0
                        ? (todayCalories / goals.dailyCalories).clamp(0.0, 1.0)
                        : 0,
                    backgroundColor: vitColor.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(
                      todayCalories >= goals.dailyCalories * 0.9
                          ? SoloLevelingTheme.successGreen
                          : vitColor,
                    ),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Quick macro summary
          Row(
            children: [
              Expanded(
                child: _MacroQuickView(
                  label: 'PROTEIN',
                  value: todayProtein,
                  goal: goals.dailyProtein.toDouble(),
                  unit: 'g',
                  color: vitColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MacroQuickView(
                  label: 'CARBS',
                  value: todayCarbs,
                  goal: goals.dailyCarbs.toDouble(),
                  unit: 'g',
                  color: vitColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MacroQuickView(
                  label: 'FAT',
                  value: todayFat,
                  goal: goals.dailyFat.toDouble(),
                  unit: 'g',
                  color: vitColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              // Scan button
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const BarcodeScannerScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: vitColor.withOpacity(0.1),
                      border: Border.all(color: vitColor),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.qr_code_scanner, color: vitColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'SCAN FOOD',
                          style: TextStyle(
                            color: vitColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // View details button
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const NutritionScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: vitColor.withOpacity(0.5)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.list_alt,
                          color: vitColor.withOpacity(0.8),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'VIEW ALL',
                          style: TextStyle(
                            color: vitColor.withOpacity(0.8),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DailyQuestItem extends StatelessWidget {
  final dynamic config;
  final int currentProgress;
  final bool isComplete;
  final VoidCallback onIncrement;
  final Function(int) onSetValue;

  const _DailyQuestItem({
    required this.config,
    required this.currentProgress,
    required this.isComplete,
    required this.onIncrement,
    required this.onSetValue,
  });

  @override
  Widget build(BuildContext context) {
    final color = SoloLevelingTheme.getStatColor(config.statBonus);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isComplete
            ? SoloLevelingTheme.successGreen.withOpacity(0.1)
            : SoloLevelingTheme.backgroundElevated,
        border: Border.all(
          color: isComplete
              ? SoloLevelingTheme.successGreen.withOpacity(0.5)
              : color.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Row(
            children: [
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
                    color: isComplete
                        ? SoloLevelingTheme.successGreen
                        : SoloLevelingTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    decoration: isComplete ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              // Counter
              Text(
                '$currentProgress / ${config.targetCount}',
                style: TextStyle(
                  color: isComplete ? SoloLevelingTheme.successGreen : color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isComplete)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.check_circle,
                    color: SoloLevelingTheme.successGreen,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: (currentProgress / config.targetCount).clamp(0.0, 1.0),
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(
                isComplete ? SoloLevelingTheme.successGreen : color,
              ),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          // Quick add/subtract buttons - always visible
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Decrease buttons
              Row(
                children: [
                  _QuickAddButton(
                    label: '-10',
                    onTap: currentProgress >= 10
                        ? () => onSetValue(currentProgress - 10)
                        : null,
                    color: color,
                    isDecrease: true,
                  ),
                  const SizedBox(width: 6),
                  _QuickAddButton(
                    label: '-1',
                    onTap: currentProgress >= 1
                        ? () => onSetValue(currentProgress - 1)
                        : null,
                    color: color,
                    isDecrease: true,
                  ),
                ],
              ),
              // Increase buttons
              Row(
                children: [
                  _QuickAddButton(
                    label: '+1',
                    onTap: onIncrement,
                    color: color,
                  ),
                  const SizedBox(width: 6),
                  _QuickAddButton(
                    label: '+10',
                    onTap: () => onSetValue(currentProgress + 10),
                    color: color,
                  ),
                  if (!isComplete) ...[
                    const SizedBox(width: 6),
                    _QuickAddButton(
                      label: 'MAX',
                      onTap: () => onSetValue(config.targetCount),
                      color: color,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color color;
  final bool isDecrease;

  const _QuickAddButton({
    required this.label,
    required this.onTap,
    required this.color,
    this.isDecrease = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDisabled = onTap == null;
    final buttonColor = isDisabled ? color.withOpacity(0.3) : color;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDecrease ? Colors.transparent : null,
          border: Border.all(
            color: isDisabled ? color.withOpacity(0.2) : color.withOpacity(0.5),
          ),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: buttonColor,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _RewardItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _RewardItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: SoloLevelingTheme.textMuted,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}

class _MacroQuickView extends StatelessWidget {
  final String label;
  final double value;
  final double goal;
  final String unit;
  final Color color;

  const _MacroQuickView({
    required this.label,
    required this.value,
    required this.goal,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goal > 0 ? (value / goal).clamp(0.0, 1.0) : 0.0;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: SoloLevelingTheme.backgroundElevated,
        border: Border.all(color: color.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: SoloLevelingTheme.textMuted,
              fontSize: 8,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${value.toInt()}$unit',
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: color.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 3,
            ),
          ),
        ],
      ),
    );
  }
}
