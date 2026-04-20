import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/solo_leveling_theme.dart';
import '../models/models.dart';
import '../widgets/system_window.dart';

/// Main training screen with Skill Book and workout logging
class WorkoutScreen extends StatefulWidget {
  final bool showHabits;
  final GameProvider? game;

  const WorkoutScreen({super.key, this.showHabits = true, this.game});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  String? _selectedMuscleGroup;
  String? _selectedArmSubGroup;

  final List<Map<String, dynamic>> _muscleGroups = [
    {'name': 'chest', 'label': 'CHEST', 'emoji': '💪'},
    {'name': 'back', 'label': 'BACK', 'emoji': '🦴'},
    {'name': 'legs', 'label': 'LEGS', 'emoji': '🦵'},
    {'name': 'shoulders', 'label': 'SHOULDERS', 'emoji': '🏋️'},
    {'name': 'arms', 'label': 'ARMS', 'emoji': '💪'},
  ];

  final List<Map<String, dynamic>> _armSubGroups = [
    {'name': 'biceps', 'label': 'BICEPS'},
    {'name': 'triceps', 'label': 'TRICEPS'},
    {'name': 'forearms', 'label': 'FOREARMS'},
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        // If there's an active workout, show the logging interface
        if (game.hasActiveWorkout) {
          return _buildActiveWorkout(context, game);
        }

        // Otherwise show the Skill Book and start workout option
        return _buildSkillBook(context, game);
      },
    );
  }

  Widget _buildSkillBook(BuildContext context, GameProvider game) {
    List<Exercise> filteredExercises = game.exercises;
    final todayHabits = game.todayHabits;

    // Filter by muscle group
    if (_selectedMuscleGroup != null) {
      if (_selectedMuscleGroup == 'arms' && _selectedArmSubGroup != null) {
        filteredExercises = game.getExercisesByArmSubGroup(_selectedArmSubGroup!);
      } else {
        filteredExercises = game.getExercisesByMuscleGroup(_selectedMuscleGroup!);
      }
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Today's Habits Section (only if showHabits is true)
              if (widget.showHabits && todayHabits.isNotEmpty) ...[
                SystemWindow(
                  title: '[TODAY\'S REGIMEN]',
                  child: Column(
                    children: todayHabits.map((h) => _buildHabitRow(h, game)).toList(),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Start Workout Button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: SoloLevelingTheme.backgroundCard,
                  border: Border.all(
                    color: SoloLevelingTheme.primaryCyan.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    const Text(
                      '⚔️ COMBAT TRAINING',
                      style: TextStyle(
                        color: SoloLevelingTheme.primaryCyan,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => _showStartWorkoutDialog(context, game),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('START WORKOUT'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: SoloLevelingTheme.primaryCyan,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Workout History Section
              if (game.recentWorkouts.isNotEmpty) ...[
                Row(
                  children: [
                    const Text(
                      '📜 WORKOUT HISTORY',
                      style: TextStyle(
                        color: SoloLevelingTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => _showWorkoutHistory(context, game),
                      child: const Text('View All', style: TextStyle(color: SoloLevelingTheme.primaryCyan)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: game.recentWorkouts.take(5).length,
                    itemBuilder: (context, index) {
                      final workout = game.recentWorkouts[index];
                      return Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: SoloLevelingTheme.backgroundCard,
                          border: Border.all(color: SoloLevelingTheme.textMuted.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              workout.name ?? 'Workout',
                              style: const TextStyle(
                                color: SoloLevelingTheme.textPrimary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              workout.formattedDate,
                              style: const TextStyle(color: SoloLevelingTheme.textMuted, fontSize: 10),
                            ),
                            const Spacer(),
                            Text(
                              '${workout.totalSets} sets • ${workout.totalPRs} PRs',
                              style: const TextStyle(color: SoloLevelingTheme.primaryCyan, fontSize: 10),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Skill Book Header
              Row(
                children: [
                  const Text(
                    '📖 SKILL BOOK',
                    style: TextStyle(
                      color: SoloLevelingTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => _showAddExerciseDialog(context, game),
                    icon: const Icon(Icons.add, color: SoloLevelingTheme.primaryCyan),
                    tooltip: 'Add Exercise',
                  ),
                ],
              ),

          const SizedBox(height: 12),

          // Muscle Group Filter
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildFilterChip(
                label: 'ALL',
                isSelected: _selectedMuscleGroup == null,
                onTap: () => setState(() {
                  _selectedMuscleGroup = null;
                  _selectedArmSubGroup = null;
                }),
              ),
              ..._muscleGroups.map((group) => _buildFilterChip(
                    label: group['label'],
                    emoji: group['emoji'],
                    isSelected: _selectedMuscleGroup == group['name'],
                    onTap: () => setState(() {
                      _selectedMuscleGroup = group['name'];
                      if (group['name'] != 'arms') {
                        _selectedArmSubGroup = null;
                      }
                    }),
                  )),
            ],
          ),

          // Arm Sub-group Filter (only show when Arms is selected)
          if (_selectedMuscleGroup == 'arms') ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _armSubGroups.map((subGroup) => _buildFilterChip(
                    label: subGroup['label'],
                    isSelected: _selectedArmSubGroup == subGroup['name'],
                    onTap: () => setState(() {
                      _selectedArmSubGroup = subGroup['name'];
                    }),
                    small: true,
                  )).toList(),
            ),
          ],

          const SizedBox(height: 16),

          // Exercise List
          SlidableAutoCloseBehavior(
            child: Column(
              children: filteredExercises
                  .map((exercise) => _buildExerciseCard(exercise, game))
                  .toList(),
            ),
          ),

          if (filteredExercises.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(Icons.fitness_center, color: SoloLevelingTheme.textMuted, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'No exercises found',
                    style: TextStyle(color: SoloLevelingTheme.textMuted),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 80), // Space for FAB
        ],
      ),
    ),
    // Add Habit FAB (only if showHabits is true)
    if (widget.showHabits)
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
              color: SoloLevelingTheme.textMuted.withValues(alpha: 0.2),
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
                  decoration: isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (habit.currentStreak > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: SoloLevelingTheme.xpGold.withValues(alpha: 0.2),
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
                                    ? SoloLevelingTheme.primaryCyan.withValues(alpha: 0.2)
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

  Widget _buildFilterChip({
    required String label,
    String? emoji,
    required bool isSelected,
    required VoidCallback onTap,
    bool small = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: small ? 10 : 12,
          vertical: small ? 4 : 6,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? SoloLevelingTheme.primaryCyan.withValues(alpha: 0.2)
              : SoloLevelingTheme.backgroundCard,
          border: Border.all(
            color: isSelected
                ? SoloLevelingTheme.primaryCyan
                : SoloLevelingTheme.textMuted.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          emoji != null ? '$emoji $label' : label,
          style: TextStyle(
            color: isSelected ? SoloLevelingTheme.primaryCyan : SoloLevelingTheme.textMuted,
            fontSize: small ? 10 : 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseCard(Exercise exercise, GameProvider game) {
    final rankColor = _getRankColor(exercise.rank);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: SoloLevelingTheme.backgroundCard,
        border: Border.all(color: SoloLevelingTheme.textMuted.withValues(alpha: 0.2)),
      ),
      child: Slidable(
        key: ValueKey('skill-${exercise.id}'),
        groupTag: 'skill-book',
        endActionPane: ActionPane(
          motion: const BehindMotion(),
          extentRatio: 0.5,
          children: [
            SlidableAction(
              onPressed: (_) => _showEditExerciseDialog(context, exercise, game),
              backgroundColor: SoloLevelingTheme.backgroundElevated,
              foregroundColor: SoloLevelingTheme.primaryCyan,
              icon: Icons.edit,
              label: 'Edit',
            ),
            SlidableAction(
              onPressed: (_) => _confirmDeleteExercise(context, exercise, game),
              backgroundColor: SoloLevelingTheme.hpRed,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
            ),
          ],
        ),
        child: InkWell(
          onTap: () => _showExerciseDetail(context, exercise, game),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text(
                  exercise.iconEmoji ?? '🏋️',
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              exercise.name,
                              style: const TextStyle(
                                color: SoloLevelingTheme.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: rankColor.withValues(alpha: 0.2),
                              border: Border.all(color: rankColor),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              exercise.rank,
                              style: TextStyle(
                                color: rankColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exercise.muscleGroupDisplay,
                        style: const TextStyle(
                          color: SoloLevelingTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                      if (exercise.currentPRWeight != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.emoji_events, color: Colors.amber, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              'PR: ${exercise.formattedPR}',
                              style: const TextStyle(
                                color: Colors.amber,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.swipe_left,
                  color: SoloLevelingTheme.textMuted.withValues(alpha: 0.4),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditExerciseDialog(BuildContext context, Exercise exercise, GameProvider game) {
    final nameController = TextEditingController(text: exercise.name);
    String selectedMuscleGroup = exercise.muscleGroup;
    String? selectedArmSubGroup = exercise.armSubGroup;
    String selectedEmoji = exercise.iconEmoji ?? '🏋️';
    final emojis = ['🏋️', '💪', '🦵', '🦴', '🏃', '🔥', '⚡', '🎯', '🦋', '🚣', '⬇️', '🧗'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: SoloLevelingTheme.backgroundCard,
          title: const Text('Edit Exercise', style: TextStyle(color: SoloLevelingTheme.primaryCyan)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: SoloLevelingTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Exercise Name',
                    labelStyle: TextStyle(color: SoloLevelingTheme.textMuted),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Muscle Group', style: TextStyle(color: SoloLevelingTheme.textMuted, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _muscleGroups.map((group) => GestureDetector(
                        onTap: () => setState(() {
                          selectedMuscleGroup = group['name'];
                          if (group['name'] != 'arms') selectedArmSubGroup = null;
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: selectedMuscleGroup == group['name']
                                ? SoloLevelingTheme.primaryCyan.withValues(alpha: 0.2)
                                : SoloLevelingTheme.backgroundDark,
                            border: Border.all(
                              color: selectedMuscleGroup == group['name']
                                  ? SoloLevelingTheme.primaryCyan
                                  : SoloLevelingTheme.textMuted.withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            group['label'],
                            style: TextStyle(
                              color: selectedMuscleGroup == group['name']
                                  ? SoloLevelingTheme.primaryCyan
                                  : SoloLevelingTheme.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      )).toList(),
                ),
                if (selectedMuscleGroup == 'arms') ...[
                  const SizedBox(height: 12),
                  const Text('Arm Sub-group', style: TextStyle(color: SoloLevelingTheme.textMuted, fontSize: 12)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _armSubGroups.map((sub) => GestureDetector(
                          onTap: () => setState(() => selectedArmSubGroup = sub['name']),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: selectedArmSubGroup == sub['name']
                                  ? SoloLevelingTheme.primaryCyan.withValues(alpha: 0.2)
                                  : SoloLevelingTheme.backgroundDark,
                              border: Border.all(
                                color: selectedArmSubGroup == sub['name']
                                    ? SoloLevelingTheme.primaryCyan
                                    : SoloLevelingTheme.textMuted.withValues(alpha: 0.3),
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              sub['label'],
                              style: TextStyle(
                                color: selectedArmSubGroup == sub['name']
                                    ? SoloLevelingTheme.primaryCyan
                                    : SoloLevelingTheme.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        )).toList(),
                  ),
                ],
                const SizedBox(height: 16),
                const Text('Icon', style: TextStyle(color: SoloLevelingTheme.textMuted, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: emojis.map((emoji) => GestureDetector(
                        onTap: () => setState(() => selectedEmoji = emoji),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: selectedEmoji == emoji
                                ? SoloLevelingTheme.primaryCyan.withValues(alpha: 0.2)
                                : SoloLevelingTheme.backgroundDark,
                            border: Border.all(
                              color: selectedEmoji == emoji
                                  ? SoloLevelingTheme.primaryCyan
                                  : SoloLevelingTheme.textMuted.withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(emoji, style: const TextStyle(fontSize: 20)),
                        ),
                      )).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: SoloLevelingTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;
                exercise.name = nameController.text.trim();
                exercise.muscleGroup = selectedMuscleGroup;
                exercise.armSubGroup = selectedMuscleGroup == 'arms' ? selectedArmSubGroup : null;
                exercise.iconEmoji = selectedEmoji;
                await game.updateExercise(exercise);
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SoloLevelingTheme.primaryCyan,
                foregroundColor: Colors.black,
              ),
              child: const Text('SAVE'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmRemoveExerciseFromWorkout(
      BuildContext context, Exercise exercise, GameProvider game) async {
    final removedSets =
        await game.removeExerciseFromActiveWorkout(exercise.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            removedSets.isEmpty
                ? '${exercise.name} removed'
                : '${exercise.name} removed (${removedSets.length} set${removedSets.length == 1 ? '' : 's'})',
          ),
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: SoloLevelingTheme.primaryCyan,
            onPressed: () => removedSets.isEmpty
                ? game.addExerciseToActiveWorkout(exercise.id)
                : game.restoreSetsToActiveWorkout(exercise.id, removedSets),
          ),
        ),
      );
  }

  void _confirmDeleteExercise(BuildContext context, Exercise exercise, GameProvider game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SoloLevelingTheme.backgroundCard,
        title: const Text('Delete Exercise?', style: TextStyle(color: SoloLevelingTheme.hpRed)),
        content: Text(
          'Permanently delete "${exercise.name}" from the Skill Book? Past workout records will keep their entries.',
          style: const TextStyle(color: SoloLevelingTheme.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: SoloLevelingTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              await game.deleteExercise(exercise.id);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${exercise.name} deleted'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SoloLevelingTheme.hpRed,
              foregroundColor: Colors.white,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveWorkout(BuildContext context, GameProvider game) {
    final workout = game.activeWorkout!;

    return Column(
      children: [
        // Workout Header
        Container(
          padding: const EdgeInsets.all(16),
          color: SoloLevelingTheme.primaryCyan.withValues(alpha: 0.1),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    workout.name ?? 'RAID IN PROGRESS',
                    style: const TextStyle(
                      color: SoloLevelingTheme.primaryCyan,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${workout.formattedDuration} • ${workout.totalSets} sets • ${workout.totalPRs} PRs',
                    style: TextStyle(
                      color: SoloLevelingTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              TextButton(
                onPressed: () => _showEndWorkoutDialog(context, game),
                child: const Text(
                  'END',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),

        // Add Exercise Button
        Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: () => _showSelectExerciseDialog(context, game),
            icon: const Icon(Icons.add),
            label: const Text('ADD EXERCISE'),
            style: ElevatedButton.styleFrom(
              backgroundColor: SoloLevelingTheme.backgroundCard,
              foregroundColor: SoloLevelingTheme.primaryCyan,
            ),
          ),
        ),

        // Sets List
        Expanded(
          child: workout.sets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.fitness_center, color: SoloLevelingTheme.textMuted, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        'Add an exercise to start logging',
                        style: TextStyle(color: SoloLevelingTheme.textMuted),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: workout.exerciseIds.length,
                  itemBuilder: (context, index) {
                    final exerciseId = workout.exerciseIds[index];
                    final exercise = game.getExerciseById(exerciseId);
                    if (exercise == null) return const SizedBox();

                    final sets = workout.getSetsForExercise(exerciseId);
                    sets.sort((a, b) => a.setNumber.compareTo(b.setNumber));
                    final previousSets = game.getLastSessionSets(exerciseId);

                    return _InlineExerciseCard(
                      key: ValueKey(exerciseId),
                      exercise: exercise,
                      committedSets: sets,
                      previousSets: previousSets,
                      game: game,
                      onViewHistory: () => _showExerciseDetail(context, exercise, game),
                      onRemoveExercise: () =>
                          _confirmRemoveExerciseFromWorkout(context, exercise, game),
                      onSetDeleted: (deletedSet) {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text(
                                'Set deleted from ${exercise.name}',
                              ),
                              duration: const Duration(seconds: 4),
                              action: SnackBarAction(
                                label: 'UNDO',
                                textColor: SoloLevelingTheme.primaryCyan,
                                onPressed: () => game.restoreSet(deletedSet),
                              ),
                            ),
                          );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _showStartWorkoutDialog(BuildContext context, GameProvider game) {
    final controller = TextEditingController();
    DateTime? selectedDate;
    TimeOfDay? selectedTime;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: SoloLevelingTheme.backgroundCard,
          title: const Text('Start Raid', style: TextStyle(color: SoloLevelingTheme.primaryCyan)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: controller,
                style: const TextStyle(color: SoloLevelingTheme.textPrimary),
                decoration: const InputDecoration(
                  hintText: 'Workout name (optional)',
                  hintStyle: TextStyle(color: SoloLevelingTheme.textMuted),
                ),
              ),
              const SizedBox(height: 16),
              // Date/Time picker for backdating
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now().subtract(const Duration(days: 365)),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => selectedDate = date);
                        }
                      },
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: Text(
                        selectedDate != null
                            ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                            : 'Today',
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: SoloLevelingTheme.textMuted,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime ?? TimeOfDay.now(),
                        );
                        if (time != null) {
                          setState(() => selectedTime = time);
                        }
                      },
                      icon: const Icon(Icons.access_time, size: 16),
                      label: Text(
                        selectedTime != null
                            ? selectedTime!.format(context)
                            : 'Now',
                        style: const TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: SoloLevelingTheme.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
              if (selectedDate != null || selectedTime != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Backdating workout',
                    style: TextStyle(color: SoloLevelingTheme.textMuted, fontSize: 11),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: SoloLevelingTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: () async {
                DateTime? startTime;
                if (selectedDate != null || selectedTime != null) {
                  final date = selectedDate ?? DateTime.now();
                  final time = selectedTime ?? TimeOfDay.now();
                  startTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                }
                await game.startWorkout(
                  name: controller.text.isNotEmpty ? controller.text : null,
                  startTime: startTime,
                );
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SoloLevelingTheme.primaryCyan,
                foregroundColor: Colors.black,
              ),
              child: const Text('START'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEndWorkoutDialog(BuildContext context, GameProvider game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SoloLevelingTheme.backgroundCard,
        title: const Text('End Raid?', style: TextStyle(color: SoloLevelingTheme.primaryCyan)),
        content: Text(
          'You logged ${game.activeWorkout!.totalSets} sets with ${game.activeWorkout!.totalPRs} PRs.',
          style: const TextStyle(color: SoloLevelingTheme.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Continue', style: TextStyle(color: SoloLevelingTheme.textMuted)),
          ),
          TextButton(
            onPressed: () async {
              await game.cancelWorkout();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Discard', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton(
            onPressed: () async {
              await game.endWorkout();
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SoloLevelingTheme.primaryCyan,
              foregroundColor: Colors.black,
            ),
            child: const Text('COMPLETE'),
          ),
        ],
      ),
    );
  }

  void _showSelectExerciseDialog(BuildContext context, GameProvider game) {
    showModalBottomSheet(
      context: context,
      backgroundColor: SoloLevelingTheme.backgroundCard,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'SELECT EXERCISE',
                style: TextStyle(
                  color: SoloLevelingTheme.primaryCyan,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: game.exercises.length,
                itemBuilder: (context, index) {
                  final exercise = game.exercises[index];
                  return ListTile(
                    leading: Text(exercise.iconEmoji ?? '🏋️', style: const TextStyle(fontSize: 24)),
                    title: Text(
                      exercise.name,
                      style: const TextStyle(color: SoloLevelingTheme.textPrimary),
                    ),
                    subtitle: Text(
                      exercise.muscleGroupDisplay,
                      style: TextStyle(color: SoloLevelingTheme.textMuted, fontSize: 12),
                    ),
                    trailing: exercise.lastWeight != null
                        ? Text(
                            exercise.formattedLastPerformance,
                            style: TextStyle(color: SoloLevelingTheme.textMuted, fontSize: 11),
                          )
                        : null,
                    onTap: () async {
                      await game.addExerciseToActiveWorkout(exercise.id);
                      if (context.mounted) Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExerciseDetail(BuildContext context, Exercise exercise, GameProvider game) {
    showModalBottomSheet(
      context: context,
      backgroundColor: SoloLevelingTheme.backgroundCard,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(exercise.iconEmoji ?? '🏋️', style: const TextStyle(fontSize: 40)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exercise.name,
                          style: const TextStyle(
                            color: SoloLevelingTheme.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          exercise.muscleGroupDisplay,
                          style: TextStyle(color: SoloLevelingTheme.textMuted),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getRankColor(exercise.rank).withValues(alpha: 0.2),
                      border: Border.all(color: _getRankColor(exercise.rank)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'RANK ${exercise.rank}',
                      style: TextStyle(
                        color: _getRankColor(exercise.rank),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Current PR
              if (exercise.currentPRWeight != null) ...[
                const Text(
                  '🏆 PERSONAL RECORD',
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    border: Border.all(color: Colors.amber),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        exercise.formattedPR,
                        style: const TextStyle(
                          color: Colors.amber,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // PR History
              if (exercise.prHistory.isNotEmpty) ...[
                const Text(
                  '📜 RANK HISTORY',
                  style: TextStyle(
                    color: SoloLevelingTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...exercise.prHistory.reversed.take(5).map((pr) => Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: SoloLevelingTheme.textMuted.withValues(alpha: 0.1),
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getRankColor(pr.rank).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              pr.rank,
                              style: TextStyle(
                                color: _getRankColor(pr.rank),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${pr.weight}kg × ${pr.reps}',
                            style: const TextStyle(color: SoloLevelingTheme.textPrimary),
                          ),
                          const Spacer(),
                          Text(
                            '${pr.achievedAt.day}/${pr.achievedAt.month}/${pr.achievedAt.year}',
                            style: TextStyle(
                              color: SoloLevelingTheme.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],

              const SizedBox(height: 24),

              // Notes
              const Text(
                '📝 NOTES',
                style: TextStyle(
                  color: SoloLevelingTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: SoloLevelingTheme.backgroundDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: TextEditingController(text: exercise.notes ?? ''),
                  maxLines: 3,
                  style: const TextStyle(color: SoloLevelingTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Add notes/cues for this exercise...',
                    hintStyle: TextStyle(color: SoloLevelingTheme.textMuted),
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    game.updateExerciseNotes(exercise.id, value);
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Manual PR Override
              ElevatedButton(
                onPressed: () => _showManualPRDialog(context, exercise, game),
                style: ElevatedButton.styleFrom(
                  backgroundColor: SoloLevelingTheme.backgroundCard,
                  foregroundColor: Colors.amber,
                ),
                child: const Text('Set Manual PR'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showManualPRDialog(BuildContext context, Exercise exercise, GameProvider game) {
    final weightController = TextEditingController(
      text: exercise.currentPRWeight?.toString() ?? '',
    );
    final repsController = TextEditingController(
      text: exercise.currentPRReps?.toString() ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SoloLevelingTheme.backgroundCard,
        title: const Text('Set Manual PR', style: TextStyle(color: Colors.amber)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Override the current PR with a manual entry.',
              style: TextStyle(color: SoloLevelingTheme.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: weightController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: SoloLevelingTheme.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Weight (kg)',
                      labelStyle: TextStyle(color: SoloLevelingTheme.textMuted),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: repsController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: SoloLevelingTheme.textPrimary),
                    decoration: const InputDecoration(
                      labelText: 'Reps',
                      labelStyle: TextStyle(color: SoloLevelingTheme.textMuted),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: SoloLevelingTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              final weight = double.tryParse(weightController.text);
              final reps = int.tryParse(repsController.text);

              if (weight != null && reps != null) {
                await game.setExercisePR(exercise.id, weight, reps);
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            child: const Text('SAVE PR'),
          ),
        ],
      ),
    );
  }

  void _showAddExerciseDialog(BuildContext context, GameProvider game) {
    final nameController = TextEditingController();
    String selectedMuscleGroup = 'chest';
    String? selectedArmSubGroup;
    String selectedEmoji = '🏋️';

    final emojis = ['🏋️', '💪', '🦵', '🦴', '🏃', '🔥', '⚡', '🎯'];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: SoloLevelingTheme.backgroundCard,
          title: const Text('Add Exercise', style: TextStyle(color: SoloLevelingTheme.primaryCyan)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: SoloLevelingTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Exercise Name',
                    labelStyle: TextStyle(color: SoloLevelingTheme.textMuted),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Muscle Group', style: TextStyle(color: SoloLevelingTheme.textMuted, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _muscleGroups.map((group) => GestureDetector(
                        onTap: () => setState(() {
                          selectedMuscleGroup = group['name'];
                          if (group['name'] != 'arms') {
                            selectedArmSubGroup = null;
                          }
                        }),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: selectedMuscleGroup == group['name']
                                ? SoloLevelingTheme.primaryCyan.withValues(alpha: 0.2)
                                : SoloLevelingTheme.backgroundDark,
                            border: Border.all(
                              color: selectedMuscleGroup == group['name']
                                  ? SoloLevelingTheme.primaryCyan
                                  : SoloLevelingTheme.textMuted.withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            group['label'],
                            style: TextStyle(
                              color: selectedMuscleGroup == group['name']
                                  ? SoloLevelingTheme.primaryCyan
                                  : SoloLevelingTheme.textMuted,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      )).toList(),
                ),
                if (selectedMuscleGroup == 'arms') ...[
                  const SizedBox(height: 12),
                  const Text('Arm Sub-group', style: TextStyle(color: SoloLevelingTheme.textMuted, fontSize: 12)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: _armSubGroups.map((sub) => GestureDetector(
                          onTap: () => setState(() => selectedArmSubGroup = sub['name']),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: selectedArmSubGroup == sub['name']
                                  ? SoloLevelingTheme.primaryCyan.withValues(alpha: 0.2)
                                  : SoloLevelingTheme.backgroundDark,
                              border: Border.all(
                                color: selectedArmSubGroup == sub['name']
                                    ? SoloLevelingTheme.primaryCyan
                                    : SoloLevelingTheme.textMuted.withValues(alpha: 0.3),
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              sub['label'],
                              style: TextStyle(
                                color: selectedArmSubGroup == sub['name']
                                    ? SoloLevelingTheme.primaryCyan
                                    : SoloLevelingTheme.textMuted,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        )).toList(),
                  ),
                ],
                const SizedBox(height: 16),
                const Text('Icon', style: TextStyle(color: SoloLevelingTheme.textMuted, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: emojis.map((emoji) => GestureDetector(
                        onTap: () => setState(() => selectedEmoji = emoji),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: selectedEmoji == emoji
                                ? SoloLevelingTheme.primaryCyan.withValues(alpha: 0.2)
                                : SoloLevelingTheme.backgroundDark,
                            border: Border.all(
                              color: selectedEmoji == emoji
                                  ? SoloLevelingTheme.primaryCyan
                                  : SoloLevelingTheme.textMuted.withValues(alpha: 0.3),
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(emoji, style: const TextStyle(fontSize: 20)),
                        ),
                      )).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: SoloLevelingTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;

                final exercise = Exercise(
                  name: nameController.text.trim(),
                  muscleGroup: selectedMuscleGroup,
                  armSubGroup: selectedArmSubGroup,
                  iconEmoji: selectedEmoji,
                );

                await game.addExercise(exercise);
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SoloLevelingTheme.primaryCyan,
                foregroundColor: Colors.black,
              ),
              child: const Text('ADD'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getRankColor(String rank) {
    switch (rank.toUpperCase()) {
      case 'S':
        return Colors.amber;
      case 'A':
        return Colors.purple;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.green;
      case 'D':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _showEditSetDialog(BuildContext context, WorkoutSet set, GameProvider game) {
    final weightController = TextEditingController(text: set.weight.toString());
    final repsController = TextEditingController(text: set.reps.toString());
    bool isPR = set.isPR;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: SoloLevelingTheme.backgroundCard,
          title: Text(
            'Edit Set ${set.setNumber}',
            style: const TextStyle(color: SoloLevelingTheme.primaryCyan),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                set.exerciseName,
                style: const TextStyle(color: SoloLevelingTheme.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: weightController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(color: SoloLevelingTheme.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Weight (kg)',
                        labelStyle: TextStyle(color: SoloLevelingTheme.textMuted),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: repsController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: SoloLevelingTheme.textPrimary),
                      decoration: const InputDecoration(
                        labelText: 'Reps',
                        labelStyle: TextStyle(color: SoloLevelingTheme.textMuted),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () => setState(() => isPR = !isPR),
                child: Row(
                  children: [
                    Icon(
                      isPR ? Icons.emoji_events : Icons.emoji_events_outlined,
                      color: isPR ? Colors.amber : SoloLevelingTheme.textMuted,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Mark as PR',
                      style: TextStyle(
                        color: isPR ? Colors.amber : SoloLevelingTheme.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: SoloLevelingTheme.textMuted)),
            ),
            ElevatedButton(
              onPressed: () async {
                final weight = double.tryParse(weightController.text);
                final reps = int.tryParse(repsController.text);

                if (weight == null || reps == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter valid numbers')),
                  );
                  return;
                }

                await game.updateSet(
                  setId: set.id,
                  weight: weight,
                  reps: reps,
                  isPR: isPR,
                );
                if (context.mounted) Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SoloLevelingTheme.primaryCyan,
                foregroundColor: Colors.black,
              ),
              child: const Text('SAVE'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteSetDialog(BuildContext context, WorkoutSet set, GameProvider game) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SoloLevelingTheme.backgroundCard,
        title: const Text('Delete Set?', style: TextStyle(color: Colors.red)),
        content: Text(
          'Delete ${set.formattedSet} from ${set.exerciseName}?',
          style: const TextStyle(color: SoloLevelingTheme.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: SoloLevelingTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              await game.deleteSet(set.id);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }

  void _showWorkoutHistory(BuildContext context, GameProvider game) {
    showModalBottomSheet(
      context: context,
      backgroundColor: SoloLevelingTheme.backgroundCard,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: const Text(
                '📜 RAID HISTORY',
                style: TextStyle(
                  color: SoloLevelingTheme.primaryCyan,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
            ),
            Expanded(
              child: game.workoutSessions.where((w) => !w.isActive).isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.fitness_center, color: SoloLevelingTheme.textMuted, size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'No completed workouts yet',
                            style: TextStyle(color: SoloLevelingTheme.textMuted),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: game.workoutSessions.where((w) => !w.isActive).length,
                      itemBuilder: (context, index) {
                        final workouts = game.workoutSessions
                            .where((w) => !w.isActive)
                            .toList()
                          ..sort((a, b) => b.startTime.compareTo(a.startTime));
                        final workout = workouts[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: SoloLevelingTheme.backgroundDark,
                            border: Border.all(
                              color: SoloLevelingTheme.textMuted.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      workout.name ?? 'Workout',
                                      style: const TextStyle(
                                        color: SoloLevelingTheme.textPrimary,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (workout.totalPRs > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.emoji_events, color: Colors.amber, size: 14),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${workout.totalPRs} PR${workout.totalPRs > 1 ? 's' : ''}',
                                            style: const TextStyle(color: Colors.amber, fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${workout.formattedDate} • ${workout.formattedDuration}',
                                style: TextStyle(color: SoloLevelingTheme.textMuted, fontSize: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                workout.summary,
                                style: TextStyle(color: SoloLevelingTheme.primaryCyan, fontSize: 12),
                              ),
                              if (workout.muscleGroupsWorked.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  children: workout.muscleGroupsWorked
                                      .map((muscle) => Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: SoloLevelingTheme.backgroundCard,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              muscle.toUpperCase(),
                                              style: const TextStyle(
                                                color: SoloLevelingTheme.textMuted,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ))
                                      .toList(),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Inline exercise card used during an active workout.
/// Two-line committed rows (swipe to delete) with delta vs previous session,
/// a distinct draft section with large inputs and a full-width LOG SET button,
/// optional rest timer chip, and a header menu for exercise-level actions.
class _InlineExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final List<WorkoutSet> committedSets;
  final List<WorkoutSet> previousSets;
  final GameProvider game;
  final VoidCallback onViewHistory;
  final VoidCallback onRemoveExercise;
  final void Function(WorkoutSet deletedSet) onSetDeleted;

  const _InlineExerciseCard({
    super.key,
    required this.exercise,
    required this.committedSets,
    required this.previousSets,
    required this.game,
    required this.onViewHistory,
    required this.onRemoveExercise,
    required this.onSetDeleted,
  });

  @override
  State<_InlineExerciseCard> createState() => _InlineExerciseCardState();
}

class _InlineExerciseCardState extends State<_InlineExerciseCard> {
  static const int _defaultRestSeconds = 90;

  final TextEditingController _weightCtrl = TextEditingController();
  final TextEditingController _repsCtrl = TextEditingController();
  final FocusNode _weightFocus = FocusNode();
  final FocusNode _repsFocus = FocusNode();
  bool _committing = false;

  Timer? _restTimer;
  int _restRemaining = 0;

  @override
  void initState() {
    super.initState();
    _seedDraftFromContext();
  }

  @override
  void didUpdateWidget(covariant _InlineExerciseCard old) {
    super.didUpdateWidget(old);
    if (widget.committedSets.length != old.committedSets.length) {
      _seedDraftFromContext();
    }
  }

  @override
  void dispose() {
    _restTimer?.cancel();
    _weightCtrl.dispose();
    _repsCtrl.dispose();
    _weightFocus.dispose();
    _repsFocus.dispose();
    super.dispose();
  }

  void _seedDraftFromContext() {
    final lastCommitted = widget.committedSets.isNotEmpty
        ? widget.committedSets.last
        : null;
    final idx = widget.committedSets.length;
    final samePosPrev = idx < widget.previousSets.length
        ? widget.previousSets[idx]
        : null;
    final fallbackPrev = widget.previousSets.isNotEmpty
        ? widget.previousSets.last
        : null;
    final source = lastCommitted ?? samePosPrev ?? fallbackPrev;
    if (source != null) {
      _weightCtrl.text = _formatWeight(source.weight);
      _repsCtrl.text = source.reps.toString();
    } else {
      _weightCtrl.clear();
      _repsCtrl.clear();
    }
  }

  String _formatWeight(double w) =>
      w == w.roundToDouble() ? w.toStringAsFixed(0) : w.toStringAsFixed(1);

  void _startRestTimer() {
    _restTimer?.cancel();
    setState(() => _restRemaining = _defaultRestSeconds);
    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (_restRemaining <= 1) {
        t.cancel();
        HapticFeedback.mediumImpact();
        setState(() => _restRemaining = 0);
      } else {
        setState(() => _restRemaining--);
      }
    });
  }

  void _stopRestTimer() {
    _restTimer?.cancel();
    setState(() => _restRemaining = 0);
  }

  Future<void> _commitDraft() async {
    if (_committing) return;
    final weight = double.tryParse(_weightCtrl.text.trim());
    final reps = int.tryParse(_repsCtrl.text.trim());
    if (weight == null || reps == null || reps <= 0 || weight < 0) {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(
          content: Text('Enter a valid weight and rep count'),
          duration: Duration(seconds: 2),
        ));
      return;
    }
    setState(() => _committing = true);
    final isPR = widget.exercise.isNewPR(weight, reps);
    HapticFeedback.lightImpact();
    await widget.game.addSetToWorkout(
      exerciseId: widget.exercise.id,
      weight: weight,
      reps: reps,
      isPR: isPR,
    );
    if (!mounted) return;
    setState(() => _committing = false);
    _startRestTimer();
    FocusScope.of(context).unfocus();
  }

  Future<void> _deleteSet(WorkoutSet set) async {
    final removed = WorkoutSet(
      id: set.id,
      exerciseId: set.exerciseId,
      exerciseName: set.exerciseName,
      weight: set.weight,
      reps: set.reps,
      isPR: set.isPR,
      timestamp: set.timestamp,
      note: set.note,
      setNumber: set.setNumber,
    );
    HapticFeedback.mediumImpact();
    await widget.game.deleteSet(set.id);
    if (!mounted) return;
    widget.onSetDeleted(removed);
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    final committed = widget.committedSets;
    final previous = widget.previousSets;
    final samePosPrev = committed.length < previous.length
        ? previous[committed.length]
        : null;
    final rankColor = _rankColor(exercise.rank);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: SoloLevelingTheme.backgroundCard,
        border: Border.all(
          color: SoloLevelingTheme.textMuted.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildHeader(exercise, rankColor, committed, previous),
          if (committed.isEmpty) _buildEmptyState(previous),
          if (committed.isNotEmpty)
            SlidableAutoCloseBehavior(
              child: Column(
                children: [
                  for (int i = 0; i < committed.length; i++)
                    _buildCommittedRow(
                      committed[i],
                      i < previous.length ? previous[i] : null,
                    ),
                ],
              ),
            ),
          if (_restRemaining > 0) _buildRestTimer(),
          _buildDraftSection(committed.length + 1, samePosPrev, previous),
        ],
      ),
    );
  }

  Widget _buildHeader(
    Exercise exercise,
    Color rankColor,
    List<WorkoutSet> committed,
    List<WorkoutSet> previous,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: SoloLevelingTheme.textMuted.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: SoloLevelingTheme.backgroundDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: rankColor.withValues(alpha: 0.4),
              ),
            ),
            child: Text(exercise.iconEmoji ?? '🏋️',
                style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    color: SoloLevelingTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    _Pill(
                      label: 'RANK ${exercise.rank}',
                      color: rankColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      exercise.muscleGroupDisplay,
                      style: const TextStyle(
                        color: SoloLevelingTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    if (committed.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        '· ${committed.length} set${committed.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                          color: SoloLevelingTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert,
              color: SoloLevelingTheme.textMuted,
            ),
            color: SoloLevelingTheme.backgroundElevated,
            onSelected: (val) {
              switch (val) {
                case 'history':
                  widget.onViewHistory();
                  break;
                case 'remove':
                  widget.onRemoveExercise();
                  break;
                case 'rest':
                  if (_restRemaining > 0) {
                    _stopRestTimer();
                  } else {
                    _startRestTimer();
                  }
                  break;
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'history',
                child: Row(children: [
                  Icon(Icons.show_chart,
                      color: SoloLevelingTheme.primaryCyan, size: 18),
                  SizedBox(width: 8),
                  Text('View history',
                      style: TextStyle(color: SoloLevelingTheme.textPrimary)),
                ]),
              ),
              PopupMenuItem(
                value: 'rest',
                child: Row(children: [
                  const Icon(Icons.timer,
                      color: SoloLevelingTheme.primaryCyan, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    _restRemaining > 0 ? 'Stop rest timer' : 'Start rest timer',
                    style: const TextStyle(color: SoloLevelingTheme.textPrimary),
                  ),
                ]),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'remove',
                child: Row(children: [
                  Icon(Icons.delete_outline,
                      color: SoloLevelingTheme.hpRed, size: 18),
                  SizedBox(width: 8),
                  Text('Remove from workout',
                      style: TextStyle(color: SoloLevelingTheme.hpRed)),
                ]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(List<WorkoutSet> previous) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_outline,
              size: 14, color: SoloLevelingTheme.textMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              previous.isEmpty
                  ? 'No previous data — log your first set below.'
                  : 'Last session: ${previous.length} set${previous.length == 1 ? '' : 's'}. Match it or beat it.',
              style: const TextStyle(
                color: SoloLevelingTheme.textMuted,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommittedRow(WorkoutSet set, WorkoutSet? prev) {
    return Slidable(
      key: ValueKey('set-${set.id}'),
      groupTag: 'sets-${widget.exercise.id}',
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        extentRatio: 0.25,
        children: [
          SlidableAction(
            onPressed: (_) => _deleteSet(set),
            backgroundColor: SoloLevelingTheme.hpRed,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: _CommittedSetRow(
        set: set,
        previous: prev,
        onTogglePR: () {
          HapticFeedback.selectionClick();
          widget.game.toggleSetPR(set.id, !set.isPR);
        },
      ),
    );
  }

  Widget _buildRestTimer() {
    final mins = _restRemaining ~/ 60;
    final secs = _restRemaining % 60;
    final text = mins > 0
        ? '$mins:${secs.toString().padLeft(2, '0')}'
        : '${secs}s';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: SoloLevelingTheme.accentPurple.withValues(alpha: 0.12),
        border: Border(
          top: BorderSide(
            color: SoloLevelingTheme.accentPurple.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt,
              color: SoloLevelingTheme.accentPurple, size: 16),
          const SizedBox(width: 6),
          const Text(
            'MANA REGEN',
            style: TextStyle(
              color: SoloLevelingTheme.accentPurple,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: SoloLevelingTheme.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.bold,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: _stopRestTimer,
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: Text(
                'SKIP',
                style: TextStyle(
                  color: SoloLevelingTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraftSection(int setNumber, WorkoutSet? samePosPrev,
      List<WorkoutSet> allPrevious) {
    final hintWeight = samePosPrev != null
        ? _formatWeight(samePosPrev.weight)
        : (allPrevious.isNotEmpty ? _formatWeight(allPrevious.last.weight) : '0');
    final hintReps = samePosPrev != null
        ? samePosPrev.reps.toString()
        : (allPrevious.isNotEmpty ? allPrevious.last.reps.toString() : '0');
    final prevText = samePosPrev != null
        ? '${_formatWeight(samePosPrev.weight)}kg × ${samePosPrev.reps}'
        : (allPrevious.isNotEmpty
            ? '${_formatWeight(allPrevious.last.weight)}kg × ${allPrevious.last.reps}'
            : 'no data');

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: SoloLevelingTheme.primaryCyan.withValues(alpha: 0.05),
        border: Border(
          top: BorderSide(
            color: SoloLevelingTheme.primaryCyan.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: SoloLevelingTheme.primaryCyan.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'NEXT · SET $setNumber',
                  style: const TextStyle(
                    color: SoloLevelingTheme.primaryCyan,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'Previous: $prevText',
                style: const TextStyle(
                  color: SoloLevelingTheme.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _DraftField(
                  controller: _weightCtrl,
                  focusNode: _weightFocus,
                  label: 'KG',
                  hint: hintWeight,
                  decimal: true,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(_repsFocus),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DraftField(
                  controller: _repsCtrl,
                  focusNode: _repsFocus,
                  label: 'REPS',
                  hint: hintReps,
                  decimal: false,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _commitDraft(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _committing ? null : _commitDraft,
            icon: _committing
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : const Icon(Icons.bolt, size: 18),
            label: Text(_committing ? 'LOGGING…' : 'LOG SET $setNumber'),
            style: ElevatedButton.styleFrom(
              backgroundColor: SoloLevelingTheme.primaryCyan,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 12),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.4,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _rankColor(String rank) {
    switch (rank.toUpperCase()) {
      case 'S':
        return Colors.amber;
      case 'A':
        return Colors.purple;
      case 'B':
        return Colors.blue;
      case 'C':
        return Colors.green;
      case 'D':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

class _CommittedSetRow extends StatelessWidget {
  final WorkoutSet set;
  final WorkoutSet? previous;
  final VoidCallback onTogglePR;

  const _CommittedSetRow({
    required this.set,
    required this.previous,
    required this.onTogglePR,
  });

  String _fmt(double w) =>
      w == w.roundToDouble() ? w.toStringAsFixed(0) : w.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final delta = _computeDelta();
    final isPR = set.isPR;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isPR ? Colors.amber.withValues(alpha: 0.06) : null,
        border: Border(
          top: BorderSide(
            color: SoloLevelingTheme.textMuted.withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: SoloLevelingTheme.backgroundDark,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: (isPR ? Colors.amber : SoloLevelingTheme.textMuted)
                    .withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              '${set.setNumber}',
              style: TextStyle(
                color: isPR ? Colors.amber : SoloLevelingTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      _fmt(set.weight),
                      style: TextStyle(
                        color: isPR
                            ? Colors.amber
                            : SoloLevelingTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Text(
                      'kg',
                      style: TextStyle(
                        color: SoloLevelingTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '×',
                      style: TextStyle(
                        color: SoloLevelingTheme.textMuted,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${set.reps}',
                      style: TextStyle(
                        color: isPR
                            ? Colors.amber
                            : SoloLevelingTheme.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Text(
                      'reps',
                      style: TextStyle(
                        color: SoloLevelingTheme.textMuted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    if (previous != null)
                      Text(
                        'prev: ${_fmt(previous!.weight)}×${previous!.reps}',
                        style: const TextStyle(
                          color: SoloLevelingTheme.textMuted,
                          fontSize: 10,
                        ),
                      )
                    else
                      const Text(
                        'first time',
                        style: TextStyle(
                          color: SoloLevelingTheme.textMuted,
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    if (delta != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: delta.color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          delta.text,
                          style: TextStyle(
                            color: delta.color,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            onPressed: onTogglePR,
            icon: Icon(
              isPR ? Icons.emoji_events : Icons.emoji_events_outlined,
              color: isPR ? Colors.amber : SoloLevelingTheme.textMuted,
              size: 22,
            ),
            tooltip: isPR ? 'Unmark PR' : 'Mark PR',
          ),
        ],
      ),
    );
  }

  _Delta? _computeDelta() {
    if (previous == null) return null;
    final wDelta = set.weight - previous!.weight;
    final rDelta = set.reps - previous!.reps;
    if (wDelta == 0 && rDelta == 0) {
      return _Delta('=', SoloLevelingTheme.textMuted);
    }
    final curVol = set.weight * set.reps;
    final prevVol = previous!.weight * previous!.reps;
    final color = curVol > prevVol
        ? SoloLevelingTheme.successGreen
        : (curVol < prevVol
            ? SoloLevelingTheme.hpRed
            : SoloLevelingTheme.textMuted);
    final parts = <String>[];
    if (wDelta != 0) {
      final sign = wDelta > 0 ? '+' : '';
      final formatted = wDelta == wDelta.roundToDouble()
          ? wDelta.toStringAsFixed(0)
          : wDelta.toStringAsFixed(1);
      parts.add('$sign${formatted}kg');
    }
    if (rDelta != 0) {
      final sign = rDelta > 0 ? '+' : '';
      parts.add('$sign${rDelta}r');
    }
    final arrow =
        curVol > prevVol ? '▲' : (curVol < prevVol ? '▼' : '•');
    return _Delta('$arrow ${parts.join(' ')}', color);
  }
}

class _Delta {
  final String text;
  final Color color;
  _Delta(this.text, this.color);
}

class _Pill extends StatelessWidget {
  final String label;
  final Color color;
  const _Pill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        border: Border.all(color: color.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(3),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _DraftField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String hint;
  final bool decimal;
  final TextInputAction textInputAction;
  final ValueChanged<String> onSubmitted;

  const _DraftField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.hint,
    required this.decimal,
    required this.textInputAction,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            label,
            style: const TextStyle(
              color: SoloLevelingTheme.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: SoloLevelingTheme.backgroundDark,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: SoloLevelingTheme.primaryCyan.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          alignment: Alignment.center,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            keyboardType: TextInputType.numberWithOptions(decimal: decimal),
            textAlign: TextAlign.center,
            textInputAction: textInputAction,
            onSubmitted: onSubmitted,
            style: const TextStyle(
              color: SoloLevelingTheme.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: SoloLevelingTheme.textMuted.withValues(alpha: 0.45),
                fontWeight: FontWeight.normal,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }
}
