import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/solo_leveling_theme.dart';
import '../models/models.dart';

/// Main workout screen with Skill Book and active workout
class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

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

    // Filter by muscle group
    if (_selectedMuscleGroup != null) {
      if (_selectedMuscleGroup == 'arms' && _selectedArmSubGroup != null) {
        filteredExercises = game.getExercisesByArmSubGroup(_selectedArmSubGroup!);
      } else {
        filteredExercises = game.getExercisesByMuscleGroup(_selectedMuscleGroup!);
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                  label: const Text('START RAID'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SoloLevelingTheme.primaryCyan,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

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
        ],
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

                    return _buildExerciseSetsCard(exercise, sets, game);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildExerciseSetsCard(Exercise exercise, List<WorkoutSet> sets, GameProvider game) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: SoloLevelingTheme.backgroundCard,
        border: Border.all(color: SoloLevelingTheme.textMuted.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Exercise Header
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text(exercise.iconEmoji ?? '🏋️', style: const TextStyle(fontSize: 20)),
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
                      if (exercise.lastWeight != null)
                        Text(
                          'Last: ${exercise.formattedLastPerformance}',
                          style: TextStyle(
                            color: SoloLevelingTheme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _showAddSetDialog(context, exercise, game),
                  icon: const Icon(Icons.add_circle, color: SoloLevelingTheme.primaryCyan),
                ),
              ],
            ),
          ),

          // Sets
          ...sets.map((set) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: SoloLevelingTheme.textMuted.withValues(alpha: 0.1)),
                  ),
                  color: set.isPR ? Colors.amber.withValues(alpha: 0.1) : null,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: SoloLevelingTheme.backgroundDark,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '${set.setNumber}',
                        style: TextStyle(
                          color: SoloLevelingTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        set.formattedSet,
                        style: TextStyle(
                          color: set.isPR ? Colors.amber : SoloLevelingTheme.textPrimary,
                          fontWeight: set.isPR ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    // Crown toggle
                    IconButton(
                      onPressed: () => game.toggleSetPR(set.id, !set.isPR),
                      icon: Icon(
                        set.isPR ? Icons.emoji_events : Icons.emoji_events_outlined,
                        color: set.isPR ? Colors.amber : SoloLevelingTheme.textMuted,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  void _showStartWorkoutDialog(BuildContext context, GameProvider game) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SoloLevelingTheme.backgroundCard,
        title: const Text('Start Raid', style: TextStyle(color: SoloLevelingTheme.primaryCyan)),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: SoloLevelingTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Workout name (optional)',
            hintStyle: TextStyle(color: SoloLevelingTheme.textMuted),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: SoloLevelingTheme.textMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              await game.startWorkout(name: controller.text.isNotEmpty ? controller.text : null);
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
                    onTap: () {
                      Navigator.pop(context);
                      _showAddSetDialog(context, exercise, game);
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

  void _showAddSetDialog(BuildContext context, Exercise exercise, GameProvider game) {
    final weightController = TextEditingController(
      text: exercise.lastWeight?.toString() ?? '',
    );
    final repsController = TextEditingController(
      text: exercise.lastReps?.toString() ?? '',
    );
    bool isPR = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: SoloLevelingTheme.backgroundCard,
          title: Text(
            exercise.name,
            style: const TextStyle(color: SoloLevelingTheme.primaryCyan),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (exercise.lastWeight != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: SoloLevelingTheme.backgroundDark,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Last: ${exercise.formattedLastPerformance}',
                    style: TextStyle(
                      color: SoloLevelingTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ),
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
              child: Text('Cancel', style: TextStyle(color: SoloLevelingTheme.textMuted)),
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

                await game.addSetToWorkout(
                  exerciseId: exercise.id,
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
              child: const Text('ADD SET'),
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
}
