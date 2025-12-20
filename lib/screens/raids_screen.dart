import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/solo_leveling_theme.dart';
import '../widgets/system_window.dart';
import '../models/models.dart';

/// Raids Screen - Long-term goals and habit tracking
class RaidsScreen extends StatefulWidget {
  const RaidsScreen({super.key});

  @override
  State<RaidsScreen> createState() => _RaidsScreenState();
}

class _RaidsScreenState extends State<RaidsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        return Column(
          children: [
            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: SoloLevelingTheme.backgroundCard,
                border: Border.all(
                  color: SoloLevelingTheme.primaryCyan.withAlpha(77),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: SoloLevelingTheme.primaryCyan,
                indicatorWeight: 2,
                labelColor: SoloLevelingTheme.primaryCyan,
                unselectedLabelColor: SoloLevelingTheme.textMuted,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  fontSize: 12,
                ),
                tabs: const [
                  Tab(text: 'RAIDS'),
                  Tab(text: 'TRAINING'),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRaidsTab(game),
                  _buildTrainingTab(game),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRaidsTab(GameProvider game) {
    final activeGoals = game.activeGoals;
    final completedGoals = game.completedGoals;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (activeGoals.isEmpty && completedGoals.isEmpty)
                _buildEmptyState()
              else ...[
                if (activeGoals.isNotEmpty)
                  SystemWindow(
                    title: '[ACTIVE RAIDS]',
                    child: Column(
                      children: activeGoals
                          .map((goal) => _buildGoalCard(goal, game))
                          .toList(),
                    ),
                  ),
                if (completedGoals.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  SystemWindow(
                    title: '[CLEARED RAIDS]',
                    child: Column(
                      children: completedGoals
                          .take(5)
                          .map((goal) => _buildCompletedGoalRow(goal))
                          .toList(),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
        // Add Goal FAB
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () => _showAddGoalDialog(context, game),
            backgroundColor: SoloLevelingTheme.primaryCyan,
            child: const Icon(Icons.add, color: Colors.black),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return SystemWindow(
      title: '[NO ACTIVE RAIDS]',
      child: Column(
        children: [
          const SizedBox(height: 24),
          Icon(
            Icons.flag_outlined,
            size: 48,
            color: SoloLevelingTheme.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'Set a long-term goal to conquer',
            style: TextStyle(
              color: SoloLevelingTheme.textMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to create your first raid',
            style: TextStyle(
              color: SoloLevelingTheme.primaryCyan.withAlpha(179),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildGoalCard(Goal goal, GameProvider game) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SoloLevelingTheme.backgroundDark,
        border: Border.all(
          color: SoloLevelingTheme.primaryCyan.withAlpha(128),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              if (goal.iconEmoji != null)
                Text(goal.iconEmoji!, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title.toUpperCase(),
                      style: const TextStyle(
                        color: SoloLevelingTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    if (goal.description.isNotEmpty)
                      Text(
                        goal.description,
                        style: TextStyle(
                          color: SoloLevelingTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                color: SoloLevelingTheme.primaryCyan,
                onPressed: () => _showUpdateProgressDialog(context, goal, game),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: goal.progressPercentage,
                    backgroundColor: SoloLevelingTheme.primaryCyan.withAlpha(51),
                    valueColor: const AlwaysStoppedAnimation(
                      SoloLevelingTheme.primaryCyan,
                    ),
                    minHeight: 8,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${goal.currentProgress.toInt()}/${goal.targetValue.toInt()} ${goal.unit}',
                style: const TextStyle(
                  color: SoloLevelingTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          // Milestones
          if (goal.milestones.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'GATES: ${goal.completedMilestones}/${goal.milestones.length}',
              style: TextStyle(
                color: SoloLevelingTheme.textMuted,
                fontSize: 10,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: goal.milestones.map((m) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: m.isCompleted
                        ? SoloLevelingTheme.successGreen.withAlpha(51)
                        : SoloLevelingTheme.backgroundCard,
                    border: Border.all(
                      color: m.isCompleted
                          ? SoloLevelingTheme.successGreen
                          : SoloLevelingTheme.textMuted.withAlpha(128),
                    ),
                  ),
                  child: Text(
                    m.title,
                    style: TextStyle(
                      color: m.isCompleted
                          ? SoloLevelingTheme.successGreen
                          : SoloLevelingTheme.textMuted,
                      fontSize: 10,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // Deadline
          if (goal.deadline != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 12,
                  color: goal.isOverdue
                      ? SoloLevelingTheme.hpRed
                      : SoloLevelingTheme.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  goal.isOverdue
                      ? 'OVERDUE'
                      : '${goal.daysRemaining} days remaining',
                  style: TextStyle(
                    color: goal.isOverdue
                        ? SoloLevelingTheme.hpRed
                        : SoloLevelingTheme.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCompletedGoalRow(Goal goal) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: SoloLevelingTheme.successGreen,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              goal.title,
              style: const TextStyle(
                color: SoloLevelingTheme.textPrimary,
              ),
            ),
          ),
          Text(
            'CLEARED',
            style: TextStyle(
              color: SoloLevelingTheme.successGreen,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainingTab(GameProvider game) {
    final habits = game.habits;
    final todayHabits = game.todayHabits;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Today's Training
              SystemWindow(
                title: '[TODAY\'S TRAINING]',
                child: todayHabits.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No training regimens set',
                          style: TextStyle(color: SoloLevelingTheme.textMuted),
                        ),
                      )
                    : Column(
                        children: todayHabits
                            .map((h) => _buildHabitRow(h, game))
                            .toList(),
                      ),
              ),
              const SizedBox(height: 16),

              // All Habits
              if (habits.isNotEmpty)
                SystemWindow(
                  title: '[ALL REGIMENS]',
                  child: Column(
                    children: habits
                        .map((h) => _buildHabitDetailRow(h, game))
                        .toList(),
                  ),
                ),
              const SizedBox(height: 80), // Space for FAB
            ],
          ),
        ),
        // Add Habit FAB
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () => _showAddHabitDialog(context, game),
            backgroundColor: SoloLevelingTheme.accentPurple,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildHabitRow(Habit habit, GameProvider game) {
    final isCompleted = habit.isCompletedToday;

    return InkWell(
      onTap: () {
        if (!isCompleted) {
          game.completeHabit(habit.id);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: SoloLevelingTheme.textMuted.withAlpha(51),
            ),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? SoloLevelingTheme.successGreen
                    : Colors.transparent,
                border: Border.all(
                  color: isCompleted
                      ? SoloLevelingTheme.successGreen
                      : SoloLevelingTheme.textMuted,
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            if (habit.iconEmoji != null)
              Text(habit.iconEmoji!, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                habit.name,
                style: TextStyle(
                  color: isCompleted
                      ? SoloLevelingTheme.textMuted
                      : SoloLevelingTheme.textPrimary,
                  decoration:
                      isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (habit.currentStreak > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: SoloLevelingTheme.xpGold.withAlpha(51),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_fire_department,
                      size: 14,
                      color: SoloLevelingTheme.xpGold,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${habit.currentStreak}',
                      style: const TextStyle(
                        color: SoloLevelingTheme.xpGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHabitDetailRow(Habit habit, GameProvider game) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: SoloLevelingTheme.textMuted.withAlpha(51),
          ),
        ),
      ),
      child: Row(
        children: [
          if (habit.iconEmoji != null)
            Text(habit.iconEmoji!, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.name,
                  style: const TextStyle(
                    color: SoloLevelingTheme.textPrimary,
                  ),
                ),
                Text(
                  '${habit.habitFrequency.name.toUpperCase()} | ${(habit.getCompletionRate(30) * 100).toInt()}% (30d)',
                  style: TextStyle(
                    color: SoloLevelingTheme.textMuted,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Best: ${habit.longestStreak}',
                style: TextStyle(
                  color: SoloLevelingTheme.textMuted,
                  fontSize: 10,
                ),
              ),
              Text(
                'Current: ${habit.currentStreak}',
                style: const TextStyle(
                  color: SoloLevelingTheme.xpGold,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            color: SoloLevelingTheme.hpRed,
            iconSize: 20,
            onPressed: () => _confirmDeleteHabit(context, habit, game),
          ),
        ],
      ),
    );
  }

  void _showAddGoalDialog(BuildContext context, GameProvider game) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final targetController = TextEditingController();
    final unitController = TextEditingController(text: 'units');
    String selectedEmoji = '🎯';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SoloLevelingTheme.backgroundCard,
        title: const Text(
          '[NEW RAID]',
          style: TextStyle(
            color: SoloLevelingTheme.primaryCyan,
            letterSpacing: 2,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                style: const TextStyle(color: SoloLevelingTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Goal Name',
                  labelStyle: TextStyle(color: SoloLevelingTheme.textMuted),
                ),
              ),
              TextField(
                controller: descController,
                style: const TextStyle(color: SoloLevelingTheme.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  labelStyle: TextStyle(color: SoloLevelingTheme.textMuted),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: targetController,
                      keyboardType: TextInputType.number,
                      style:
                          const TextStyle(color: SoloLevelingTheme.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Target',
                        labelStyle: TextStyle(color: SoloLevelingTheme.textMuted),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: unitController,
                      style:
                          const TextStyle(color: SoloLevelingTheme.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Unit',
                        labelStyle: TextStyle(color: SoloLevelingTheme.textMuted),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Emoji selector
              Wrap(
                spacing: 8,
                children: ['🎯', '🏃', '📚', '💪', '🧘', '🎨', '💰', '🌟']
                    .map((e) => GestureDetector(
                          onTap: () {
                            selectedEmoji = e;
                            (context as Element).markNeedsBuild();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: selectedEmoji == e
                                    ? SoloLevelingTheme.primaryCyan
                                    : Colors.transparent,
                              ),
                            ),
                            child: Text(e, style: const TextStyle(fontSize: 24)),
                          ),
                        ))
                    .toList(),
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
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  targetController.text.isNotEmpty) {
                final goal = Goal.createWithMilestones(
                  title: titleController.text,
                  description: descController.text,
                  targetValue: double.tryParse(targetController.text) ?? 100,
                  unit: unitController.text,
                  iconEmoji: selectedEmoji,
                );
                game.addGoal(goal);
                Navigator.pop(context);
              }
            },
            child: const Text(
              'CREATE RAID',
              style: TextStyle(color: SoloLevelingTheme.primaryCyan),
            ),
          ),
        ],
      ),
    );
  }

  void _showUpdateProgressDialog(
      BuildContext context, Goal goal, GameProvider game) {
    final progressController = TextEditingController(
      text: goal.currentProgress.toInt().toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SoloLevelingTheme.backgroundCard,
        title: Text(
          'UPDATE: ${goal.title}',
          style: const TextStyle(
            color: SoloLevelingTheme.primaryCyan,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
        content: TextField(
          controller: progressController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: SoloLevelingTheme.textPrimary),
          decoration: InputDecoration(
            labelText: 'Current Progress (${goal.unit})',
            labelStyle: const TextStyle(color: SoloLevelingTheme.textMuted),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              final newProgress =
                  double.tryParse(progressController.text) ?? 0;
              game.updateGoalProgress(goal.id, newProgress);
              Navigator.pop(context);
            },
            child: const Text(
              'UPDATE',
              style: TextStyle(color: SoloLevelingTheme.primaryCyan),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context, GameProvider game) {
    final nameController = TextEditingController();
    String selectedEmoji = '⚡';
    String? selectedStat;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: SoloLevelingTheme.backgroundCard,
          title: const Text(
            '[NEW REGIMEN]',
            style: TextStyle(
              color: SoloLevelingTheme.accentPurple,
              letterSpacing: 2,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: SoloLevelingTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Habit Name',
                    labelStyle: TextStyle(color: SoloLevelingTheme.textMuted),
                  ),
                ),
                const SizedBox(height: 16),
                // Stat selector
                const Text(
                  'Related Stat (optional)',
                  style: TextStyle(
                    color: SoloLevelingTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['STR', 'AGI', 'VIT', 'INT', 'SEN']
                      .map((stat) => GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedStat = selectedStat == stat ? null : stat;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: selectedStat == stat
                                      ? SoloLevelingTheme.primaryCyan
                                      : SoloLevelingTheme.textMuted,
                                ),
                                color: selectedStat == stat
                                    ? SoloLevelingTheme.primaryCyan.withAlpha(51)
                                    : null,
                              ),
                              child: Text(
                                stat,
                                style: TextStyle(
                                  color: selectedStat == stat
                                      ? SoloLevelingTheme.primaryCyan
                                      : SoloLevelingTheme.textMuted,
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 16),
                // Emoji selector
                Wrap(
                  spacing: 8,
                  children: ['⚡', '🏋️', '📖', '🧘', '💊', '🌅', '✍️', '🎵']
                      .map((e) => GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedEmoji = e;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: selectedEmoji == e
                                      ? SoloLevelingTheme.accentPurple
                                      : Colors.transparent,
                                ),
                              ),
                              child: Text(e, style: const TextStyle(fontSize: 24)),
                            ),
                          ))
                      .toList(),
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
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  final habit = Habit(
                    name: nameController.text,
                    iconEmoji: selectedEmoji,
                    relatedStat: selectedStat,
                  );
                  game.addHabit(habit);
                  Navigator.pop(context);
                }
              },
              child: const Text(
                'ADD REGIMEN',
                style: TextStyle(color: SoloLevelingTheme.accentPurple),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteHabit(
      BuildContext context, Habit habit, GameProvider game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SoloLevelingTheme.backgroundCard,
        title: const Text(
          'DELETE REGIMEN?',
          style: TextStyle(color: SoloLevelingTheme.hpRed),
        ),
        content: Text(
          'Remove "${habit.name}"? This cannot be undone.',
          style: const TextStyle(color: SoloLevelingTheme.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              game.deleteHabit(habit.id);
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
}
