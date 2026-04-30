import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/game_provider.dart';
import '../theme/solo_leveling_theme.dart';
import '../widgets/system_window.dart';

/// Weekly split editor — pick which muscles you train each weekday.
class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        final split = game.workoutSplit;
        final today = DateTime.now().weekday;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SystemWindow(
                title: '[TODAY: ${WorkoutSplit.weekdayLong[today - 1].toUpperCase()}]',
                child: _TodayPanel(split: split, weekday: today),
              ),
              const SizedBox(height: 16),
              SystemWindow(
                title: '[WEEKLY SPLIT]',
                child: Column(
                  children: [
                    for (var i = 1; i <= 7; i++)
                      _DayRow(
                        weekday: i,
                        muscles: split.forWeekday(i),
                        isToday: i == today,
                        onEdit: () => _editDay(context, game, i),
                      ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton.icon(
                          onPressed: () => _applyPreset(context, game),
                          icon: const Icon(Icons.auto_awesome,
                              size: 16, color: SoloLevelingTheme.accentPurple),
                          label: const Text(
                            'PRESETS',
                            style: TextStyle(
                                color: SoloLevelingTheme.accentPurple,
                                letterSpacing: 1),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => _confirmReset(context, game),
                          icon: const Icon(Icons.refresh,
                              size: 16, color: SoloLevelingTheme.textMuted),
                          label: const Text(
                            'RESET',
                            style: TextStyle(
                                color: SoloLevelingTheme.textMuted,
                                letterSpacing: 1),
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

  Future<void> _editDay(
      BuildContext context, GameProvider game, int weekday) async {
    final current = List<String>.from(game.workoutSplit.forWeekday(weekday));
    final updated = await showModalBottomSheet<List<String>>(
      context: context,
      backgroundColor: SoloLevelingTheme.backgroundCard,
      isScrollControlled: true,
      builder: (_) => _DayEditorSheet(
        weekday: weekday,
        initialSelection: current,
      ),
    );
    if (updated != null) {
      await game.setSplitForWeekday(weekday, updated);
    }
  }

  Future<void> _applyPreset(BuildContext context, GameProvider game) async {
    final picked = await showModalBottomSheet<WorkoutSplit>(
      context: context,
      backgroundColor: SoloLevelingTheme.backgroundCard,
      builder: (_) => const _PresetSheet(),
    );
    if (picked != null) {
      await game.setWorkoutSplit(picked);
    }
  }

  Future<void> _confirmReset(BuildContext context, GameProvider game) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: SoloLevelingTheme.backgroundCard,
        title: const Text('Reset Split?',
            style: TextStyle(color: SoloLevelingTheme.hpRed)),
        content: const Text(
          'This will replace your current split with the default.',
          style: TextStyle(color: SoloLevelingTheme.textPrimary),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('RESET',
                style: TextStyle(color: SoloLevelingTheme.hpRed)),
          ),
        ],
      ),
    );
    if (ok == true) {
      await game.setWorkoutSplit(WorkoutSplit.defaults());
    }
  }
}

class _TodayPanel extends StatelessWidget {
  final WorkoutSplit split;
  final int weekday;

  const _TodayPanel({required this.split, required this.weekday});

  @override
  Widget build(BuildContext context) {
    final game = context.read<GameProvider>();
    final muscles = split.forWeekday(weekday);
    if (muscles.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'REST DAY',
            style: TextStyle(
              color: SoloLevelingTheme.successGreen,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'No muscles scheduled. Recover, hunter.',
            style: TextStyle(color: SoloLevelingTheme.textMuted, fontSize: 12),
          ),
        ],
      );
    }

    final exercises = game.todayScheduledExercises;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: muscles
              .map((m) => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: SoloLevelingTheme.primaryCyan.withOpacity(0.15),
                      border: Border.all(
                          color: SoloLevelingTheme.primaryCyan
                              .withOpacity(0.6)),
                    ),
                    child: Text(
                      m.toUpperCase(),
                      style: const TextStyle(
                        color: SoloLevelingTheme.primaryCyan,
                        fontSize: 11,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 12),
        Text(
          '${exercises.length} matching exercise${exercises.length == 1 ? '' : 's'} in your skill book',
          style: TextStyle(color: SoloLevelingTheme.textMuted, fontSize: 11),
        ),
      ],
    );
  }
}

class _DayRow extends StatelessWidget {
  final int weekday;
  final List<String> muscles;
  final bool isToday;
  final VoidCallback onEdit;

  const _DayRow({
    required this.weekday,
    required this.muscles,
    required this.isToday,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isRest = muscles.isEmpty;
    return InkWell(
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: SoloLevelingTheme.textMuted.withOpacity(0.15),
            ),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 44,
              child: Text(
                WorkoutSplit.weekdayLabels[weekday - 1],
                style: TextStyle(
                  color: isToday
                      ? SoloLevelingTheme.primaryCyan
                      : SoloLevelingTheme.textPrimary,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                  letterSpacing: 1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: isRest
                  ? Text(
                      'rest',
                      style: TextStyle(
                        color: SoloLevelingTheme.textMuted,
                        fontStyle: FontStyle.italic,
                        fontSize: 12,
                      ),
                    )
                  : Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: muscles
                          .map((m) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: SoloLevelingTheme.primaryCyan
                                      .withOpacity(0.1),
                                  border: Border.all(
                                    color: SoloLevelingTheme.primaryCyan
                                        .withOpacity(0.4),
                                  ),
                                ),
                                child: Text(
                                  m,
                                  style: const TextStyle(
                                    color: SoloLevelingTheme.primaryCyan,
                                    fontSize: 10,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
            ),
            const Icon(
              Icons.edit,
              size: 16,
              color: SoloLevelingTheme.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _DayEditorSheet extends StatefulWidget {
  final int weekday;
  final List<String> initialSelection;

  const _DayEditorSheet({
    required this.weekday,
    required this.initialSelection,
  });

  @override
  State<_DayEditorSheet> createState() => _DayEditorSheetState();
}

class _DayEditorSheetState extends State<_DayEditorSheet> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSelection.toSet();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Text(
                  '[${WorkoutSplit.weekdayLong[widget.weekday - 1].toUpperCase()}]',
                  style: const TextStyle(
                    color: SoloLevelingTheme.primaryCyan,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const Spacer(),
                if (_selected.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(() => _selected.clear()),
                    child: const Text(
                      'REST DAY',
                      style: TextStyle(
                        color: SoloLevelingTheme.successGreen,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: WorkoutSplit.availableMuscles.map((m) {
                final on = _selected.contains(m);
                return GestureDetector(
                  onTap: () => setState(() {
                    if (on) {
                      _selected.remove(m);
                    } else {
                      _selected.add(m);
                    }
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: on
                          ? SoloLevelingTheme.primaryCyan.withOpacity(0.2)
                          : SoloLevelingTheme.backgroundElevated,
                      border: Border.all(
                        color: on
                            ? SoloLevelingTheme.primaryCyan
                            : SoloLevelingTheme.textMuted.withOpacity(0.4),
                      ),
                    ),
                    child: Text(
                      m.toUpperCase(),
                      style: TextStyle(
                        color: on
                            ? SoloLevelingTheme.primaryCyan
                            : SoloLevelingTheme.textMuted,
                        fontSize: 12,
                        letterSpacing: 1,
                        fontWeight: on ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('CANCEL'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.pop(context, _selected.toList()),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SoloLevelingTheme.primaryCyan,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('SAVE'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetSheet extends StatelessWidget {
  const _PresetSheet();

  @override
  Widget build(BuildContext context) {
    final presets = <_Preset>[
      _Preset(
        name: 'Push / Pull / Legs',
        split: WorkoutSplit(
          name: 'PPL',
          monday: ['chest', 'shoulders', 'triceps'],
          tuesday: ['back', 'biceps'],
          wednesday: ['legs'],
          thursday: ['chest', 'shoulders', 'triceps'],
          friday: ['back', 'biceps'],
          saturday: ['legs'],
          sunday: [],
        ),
      ),
      _Preset(
        name: 'Bro Split (5 day)',
        split: WorkoutSplit(
          name: 'Bro Split',
          monday: ['chest', 'triceps'],
          tuesday: ['back', 'biceps'],
          wednesday: ['legs'],
          thursday: ['shoulders'],
          friday: ['chest', 'back', 'core'],
          saturday: [],
          sunday: [],
        ),
      ),
      _Preset(
        name: 'Upper / Lower (4 day)',
        split: WorkoutSplit(
          name: 'Upper/Lower',
          monday: ['chest', 'back', 'shoulders', 'biceps', 'triceps'],
          tuesday: ['legs', 'core'],
          wednesday: [],
          thursday: ['chest', 'back', 'shoulders', 'biceps', 'triceps'],
          friday: ['legs', 'core'],
          saturday: [],
          sunday: [],
        ),
      ),
      _Preset(
        name: 'Full Body (3 day)',
        split: WorkoutSplit(
          name: 'Full Body',
          monday: ['chest', 'back', 'legs'],
          tuesday: [],
          wednesday: ['shoulders', 'biceps', 'triceps', 'legs'],
          thursday: [],
          friday: ['chest', 'back', 'legs', 'core'],
          saturday: [],
          sunday: [],
        ),
      ),
    ];
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '[CHOOSE A PRESET]',
              style: TextStyle(
                color: SoloLevelingTheme.accentPurple,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            ...presets.map((p) => InkWell(
                  onTap: () => Navigator.pop(context, p.split),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SoloLevelingTheme.backgroundElevated,
                      border: Border.all(
                          color: SoloLevelingTheme.accentPurple.withOpacity(0.4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name.toUpperCase(),
                          style: const TextStyle(
                            color: SoloLevelingTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _previewLine(p.split),
                          style: TextStyle(
                            color: SoloLevelingTheme.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  String _previewLine(WorkoutSplit s) {
    final parts = <String>[];
    for (var i = 1; i <= 7; i++) {
      final m = s.forWeekday(i);
      if (m.isEmpty) continue;
      parts.add('${WorkoutSplit.weekdayLabels[i - 1]}: ${m.join("/")}');
    }
    return parts.join(' • ');
  }
}

class _Preset {
  final String name;
  final WorkoutSplit split;
  const _Preset({required this.name, required this.split});
}
