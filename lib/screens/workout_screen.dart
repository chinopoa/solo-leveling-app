import 'package:flutter/material.dart';
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
          ...filteredExercises.map((exercise) => _buildExerciseCard(exercise, game)),

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
      child: InkWell(
        onTap: () => _showExerciseDetail(context, exercise, game),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Icon
              Text(
                exercise.iconEmoji ?? '🏋️',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(width: 12),

              // Exercise Info
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
                      style: TextStyle(
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

              // Arrow
              const Icon(Icons.chevron_right, color: SoloLevelingTheme.textMuted),
            ],
          ),
        ),
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
                      onEditSet: (set) => _showEditSetDialog(context, set, game),
                      onDeleteSet: (set) => _showDeleteSetDialog(context, set, game),
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
/// Shows committed sets with delta vs previous session, plus a draft row
/// for fast logging without modal dialogs.
class _InlineExerciseCard extends StatefulWidget {
  final Exercise exercise;
  final List<WorkoutSet> committedSets;
  final List<WorkoutSet> previousSets;
  final GameProvider game;
  final void Function(WorkoutSet set) onEditSet;
  final void Function(WorkoutSet set) onDeleteSet;

  const _InlineExerciseCard({
    super.key,
    required this.exercise,
    required this.committedSets,
    required this.previousSets,
    required this.game,
    required this.onEditSet,
    required this.onDeleteSet,
  });

  @override
  State<_InlineExerciseCard> createState() => _InlineExerciseCardState();
}

class _InlineExerciseCardState extends State<_InlineExerciseCard> {
  final TextEditingController _weightCtrl = TextEditingController();
  final TextEditingController _repsCtrl = TextEditingController();
  final FocusNode _weightFocus = FocusNode();
  final FocusNode _repsFocus = FocusNode();
  bool _committing = false;

  @override
  void initState() {
    super.initState();
    _seedDraftFromContext();
  }

  @override
  void didUpdateWidget(covariant _InlineExerciseCard old) {
    super.didUpdateWidget(old);
    // After a new set is committed, refresh the draft prefill
    if (widget.committedSets.length != old.committedSets.length) {
      _seedDraftFromContext();
    }
  }

  @override
  void dispose() {
    _weightCtrl.dispose();
    _repsCtrl.dispose();
    _weightFocus.dispose();
    _repsFocus.dispose();
    super.dispose();
  }

  /// Prefill the draft inputs with the most useful suggestion:
  /// 1. Last committed set in this session (fastest progression)
  /// 2. Same-position set from previous session
  /// 3. Last set from previous session
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

  String _formatWeight(double w) {
    return w == w.roundToDouble() ? w.toStringAsFixed(0) : w.toStringAsFixed(1);
  }

  Future<void> _commitDraft() async {
    if (_committing) return;
    final weight = double.tryParse(_weightCtrl.text.trim());
    final reps = int.tryParse(_repsCtrl.text.trim());
    if (weight == null || reps == null || reps <= 0 || weight < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter weight and reps'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }
    setState(() => _committing = true);
    final isPR = widget.exercise.isNewPR(weight, reps);
    await widget.game.addSetToWorkout(
      exerciseId: widget.exercise.id,
      weight: weight,
      reps: reps,
      isPR: isPR,
    );
    if (!mounted) return;
    setState(() => _committing = false);
    // Move focus back to weight for the next set
    FocusScope.of(context).requestFocus(_weightFocus);
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.exercise;
    final committed = widget.committedSets;
    final previous = widget.previousSets;
    final nextSetNumber = committed.length + 1;
    final samePosPrev = committed.length < previous.length
        ? previous[committed.length]
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: SoloLevelingTheme.backgroundCard,
        border: Border.all(
          color: SoloLevelingTheme.textMuted.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 4, 8),
            child: Row(
              children: [
                Text(exercise.iconEmoji ?? '🏋️',
                    style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.name,
                        style: const TextStyle(
                          color: SoloLevelingTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (previous.isNotEmpty)
                        Text(
                          'Last session: ${previous.length} set${previous.length > 1 ? 's' : ''}',
                          style: const TextStyle(
                            color: SoloLevelingTheme.textMuted,
                            fontSize: 11,
                          ),
                        )
                      else
                        const Text(
                          'First time logging',
                          style: TextStyle(
                            color: SoloLevelingTheme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Column headers
          _buildColumnHeaders(),

          // Committed sets
          ...committed.asMap().entries.map((entry) {
            final i = entry.key;
            final set = entry.value;
            final prev = i < previous.length ? previous[i] : null;
            return _CommittedSetRow(
              set: set,
              previous: prev,
              onTap: () => widget.onEditSet(set),
              onLongPress: () => widget.onDeleteSet(set),
              onTogglePR: () => widget.game.toggleSetPR(set.id, !set.isPR),
            );
          }),

          // Draft row
          _buildDraftRow(nextSetNumber, samePosPrev),
        ],
      ),
    );
  }

  Widget _buildColumnHeaders() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: SoloLevelingTheme.backgroundDark.withValues(alpha: 0.4),
        border: Border(
          top: BorderSide(
            color: SoloLevelingTheme.textMuted.withValues(alpha: 0.15),
          ),
          bottom: BorderSide(
            color: SoloLevelingTheme.textMuted.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Row(
        children: const [
          SizedBox(width: 28, child: _HeaderLabel('SET')),
          SizedBox(width: 8),
          Expanded(flex: 3, child: _HeaderLabel('PREVIOUS')),
          Expanded(flex: 2, child: _HeaderLabel('KG', center: true)),
          Expanded(flex: 2, child: _HeaderLabel('REPS', center: true)),
          SizedBox(width: 44),
        ],
      ),
    );
  }

  Widget _buildDraftRow(int setNumber, WorkoutSet? prev) {
    final prevText = prev != null
        ? '${_formatWeight(prev.weight)} × ${prev.reps}'
        : '—';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: SoloLevelingTheme.primaryCyan.withValues(alpha: 0.15),
          ),
        ),
      ),
      child: Row(
        children: [
          _SetNumberChip(number: setNumber, draft: true),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              prevText,
              style: const TextStyle(
                color: SoloLevelingTheme.textMuted,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: _NumericField(
              controller: _weightCtrl,
              focusNode: _weightFocus,
              hint: prev != null ? _formatWeight(prev.weight) : '0',
              decimal: true,
              textInputAction: TextInputAction.next,
              onSubmitted: (_) =>
                  FocusScope.of(context).requestFocus(_repsFocus),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 2,
            child: _NumericField(
              controller: _repsCtrl,
              focusNode: _repsFocus,
              hint: prev != null ? prev.reps.toString() : '0',
              decimal: false,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _commitDraft(),
            ),
          ),
          SizedBox(
            width: 44,
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: _committing ? null : _commitDraft,
              icon: Icon(
                Icons.check_circle,
                color: _committing
                    ? SoloLevelingTheme.textMuted
                    : SoloLevelingTheme.primaryCyan,
                size: 28,
              ),
              tooltip: 'Log set',
            ),
          ),
        ],
      ),
    );
  }
}

class _CommittedSetRow extends StatelessWidget {
  final WorkoutSet set;
  final WorkoutSet? previous;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onTogglePR;

  const _CommittedSetRow({
    required this.set,
    required this.previous,
    required this.onTap,
    required this.onLongPress,
    required this.onTogglePR,
  });

  String _fmt(double w) =>
      w == w.roundToDouble() ? w.toStringAsFixed(0) : w.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final prevText = previous != null
        ? '${_fmt(previous!.weight)} × ${previous!.reps}'
        : '—';

    final delta = _computeDelta();

    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: set.isPR ? Colors.amber.withValues(alpha: 0.08) : null,
          border: Border(
            top: BorderSide(
              color: SoloLevelingTheme.textMuted.withValues(alpha: 0.08),
            ),
          ),
        ),
        child: Row(
          children: [
            _SetNumberChip(number: set.setNumber, draft: false, isPR: set.isPR),
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: Text(
                prevText,
                style: const TextStyle(
                  color: SoloLevelingTheme.textMuted,
                  fontSize: 12,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                _fmt(set.weight),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: set.isPR
                      ? Colors.amber
                      : SoloLevelingTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${set.reps}',
                    style: TextStyle(
                      color: set.isPR
                          ? Colors.amber
                          : SoloLevelingTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (delta != null) ...[
                    const SizedBox(width: 6),
                    Text(
                      delta.text,
                      style: TextStyle(
                        color: delta.color,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(
              width: 44,
              child: IconButton(
                padding: EdgeInsets.zero,
                onPressed: onTogglePR,
                icon: Icon(
                  set.isPR ? Icons.emoji_events : Icons.emoji_events_outlined,
                  color: set.isPR ? Colors.amber : SoloLevelingTheme.textMuted,
                  size: 20,
                ),
                tooltip: set.isPR ? 'Unmark PR' : 'Mark PR',
              ),
            ),
          ],
        ),
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
        : (curVol < prevVol ? SoloLevelingTheme.hpRed : SoloLevelingTheme.textMuted);
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
      parts.add('${sign}${rDelta}r');
    }
    final arrow = curVol > prevVol ? '▲' : (curVol < prevVol ? '▼' : '•');
    return _Delta('$arrow ${parts.join(' ')}', color);
  }
}

class _Delta {
  final String text;
  final Color color;
  _Delta(this.text, this.color);
}

class _SetNumberChip extends StatelessWidget {
  final int number;
  final bool draft;
  final bool isPR;

  const _SetNumberChip({
    required this.number,
    required this.draft,
    this.isPR = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isPR
        ? Colors.amber
        : (draft ? SoloLevelingTheme.primaryCyan : SoloLevelingTheme.textMuted);
    return Container(
      width: 28,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: SoloLevelingTheme.backgroundDark,
        border: Border.all(color: color.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$number',
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _HeaderLabel extends StatelessWidget {
  final String text;
  final bool center;
  const _HeaderLabel(this.text, {this.center = false});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: center ? TextAlign.center : TextAlign.start,
      style: const TextStyle(
        color: SoloLevelingTheme.textMuted,
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _NumericField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final bool decimal;
  final TextInputAction textInputAction;
  final ValueChanged<String> onSubmitted;

  const _NumericField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.decimal,
    required this.textInputAction,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: SoloLevelingTheme.backgroundDark,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: SoloLevelingTheme.primaryCyan.withValues(alpha: 0.25),
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
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: SoloLevelingTheme.textMuted.withValues(alpha: 0.5),
            fontWeight: FontWeight.normal,
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }
}
