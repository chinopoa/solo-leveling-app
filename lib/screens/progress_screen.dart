import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/models.dart';
import '../providers/game_provider.dart';
import '../theme/solo_leveling_theme.dart';
import '../widgets/system_window.dart';
import '../widgets/trendline_chart.dart';

/// Progress dashboard — body weight chart + per-exercise trendlines.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  String? _selectedExerciseId;

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildBodyWeightCard(context, game),
              const SizedBox(height: 16),
              _buildExerciseProgressCard(context, game),
              const SizedBox(height: 16),
              _buildExerciseListCard(context, game),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBodyWeightCard(BuildContext context, GameProvider game) {
    final entries = game.bodyWeightEntries;
    final delta30 = game.bodyWeightDelta(days: 30);
    final delta7 = game.bodyWeightDelta(days: 7);

    return SystemWindow(
      title: '[BODY WEIGHT]',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                game.latestBodyWeight == null
                    ? '—'
                    : '${game.latestBodyWeight!.toStringAsFixed(1)}',
                style: const TextStyle(
                  color: SoloLevelingTheme.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  'kg',
                  style: TextStyle(
                    color: SoloLevelingTheme.textMuted,
                    fontSize: 14,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _showLogWeightDialog(context, game),
                icon: const Icon(Icons.add_circle,
                    color: SoloLevelingTheme.primaryCyan),
                tooltip: 'Log weight',
              ),
            ],
          ),
          if (delta7 != null || delta30 != null) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                if (delta7 != null) _DeltaPill(label: '7D', delta: delta7),
                if (delta7 != null && delta30 != null) const SizedBox(width: 8),
                if (delta30 != null) _DeltaPill(label: '30D', delta: delta30),
              ],
            ),
          ],
          const SizedBox(height: 16),
          TrendlineChart(
            points: [
              for (final e in entries.reversed) TrendPoint(e.date, e.weight),
            ],
            unit: 'kg',
            lineColor: SoloLevelingTheme.successGreen,
            height: 160,
          ),
          if (entries.isNotEmpty) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showWeightHistory(context, game),
                child: const Text(
                  'HISTORY →',
                  style: TextStyle(
                    color: SoloLevelingTheme.primaryCyan,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildExerciseProgressCard(BuildContext context, GameProvider game) {
    final exercises = game.exercises
        .where((e) => game.exerciseProgressSeries(e.id).length >= 2)
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));

    if (exercises.isEmpty) {
      return SystemWindow(
        title: '[EXERCISE PROGRESS]',
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              const Icon(Icons.show_chart,
                  color: SoloLevelingTheme.textMuted, size: 36),
              const SizedBox(height: 8),
              Text(
                'Log at least 2 sessions of an exercise to see a trendline.',
                style: TextStyle(
                  color: SoloLevelingTheme.textMuted,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final selectedId = _selectedExerciseId ?? exercises.first.id;
    final selected = exercises.firstWhere(
      (e) => e.id == selectedId,
      orElse: () => exercises.first,
    );
    final series = game.exerciseProgressSeries(selected.id);

    return SystemWindow(
      title: '[EXERCISE PROGRESS]',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<String>(
            value: selected.id,
            isExpanded: true,
            dropdownColor: SoloLevelingTheme.backgroundElevated,
            decoration: const InputDecoration(
              isDense: true,
              border: OutlineInputBorder(),
            ),
            style: const TextStyle(color: SoloLevelingTheme.textPrimary),
            items: exercises
                .map((e) => DropdownMenuItem(
                      value: e.id,
                      child: Text(
                        '${e.iconEmoji ?? "🏋️"}  ${e.name}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _selectedExerciseId = v),
          ),
          const SizedBox(height: 12),
          _SeriesSummary(series: series, exercise: selected),
          const SizedBox(height: 8),
          TrendlineChart(
            points: series
                .map((p) => TrendPoint(p.date, p.estimated1Rm))
                .toList(),
            unit: 'kg',
            lineColor: SoloLevelingTheme.primaryCyan,
            height: 180,
            referenceY: selected.currentPRWeight,
            referenceLabel: selected.currentPRWeight == null
                ? null
                : 'PR ${selected.currentPRWeight!.toStringAsFixed(1)}kg',
          ),
          const SizedBox(height: 4),
          Text(
            'Estimated 1RM (Epley) per session — higher means stronger.',
            style: TextStyle(
              color: SoloLevelingTheme.textMuted,
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseListCard(BuildContext context, GameProvider game) {
    final list = [...game.exercises]
      ..sort((a, b) {
        final sa = game.exerciseProgressSeries(a.id).length;
        final sb = game.exerciseProgressSeries(b.id).length;
        return sb.compareTo(sa);
      });

    return SystemWindow(
      title: '[ALL EXERCISES]',
      child: Column(
        children: list
            .map((e) => _ExerciseQuickRow(
                  exercise: e,
                  series: game.exerciseProgressSeries(e.id),
                  onTap: () => setState(() => _selectedExerciseId = e.id),
                ))
            .toList(),
      ),
    );
  }

  Future<void> _showLogWeightDialog(
      BuildContext context, GameProvider game) async {
    final controller = TextEditingController(
      text: game.latestBodyWeight?.toStringAsFixed(1) ?? '',
    );
    final saved = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: SoloLevelingTheme.backgroundCard,
        title: const Text('LOG WEIGHT',
            style: TextStyle(
                color: SoloLevelingTheme.primaryCyan, letterSpacing: 2)),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: SoloLevelingTheme.textPrimary),
          decoration: const InputDecoration(
            labelText: 'Weight (kg)',
            labelStyle: TextStyle(color: SoloLevelingTheme.textMuted),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('CANCEL')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('SAVE',
                style: TextStyle(color: SoloLevelingTheme.primaryCyan)),
          ),
        ],
      ),
    );
    if (saved == true) {
      final w = double.tryParse(controller.text.replaceAll(',', '.'));
      if (w != null && w > 0) {
        await game.logBodyWeight(w);
      }
    }
  }

  Future<void> _showWeightHistory(
      BuildContext context, GameProvider game) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: SoloLevelingTheme.backgroundCard,
      isScrollControlled: true,
      builder: (_) => _WeightHistorySheet(),
    );
  }
}

class _DeltaPill extends StatelessWidget {
  final String label;
  final double delta;
  const _DeltaPill({required this.label, required this.delta});

  @override
  Widget build(BuildContext context) {
    final isUp = delta > 0;
    final isFlat = delta.abs() < 0.05;
    final color = isFlat
        ? SoloLevelingTheme.textMuted
        : (isUp ? SoloLevelingTheme.xpGold : SoloLevelingTheme.successGreen);
    final symbol = isFlat ? '±' : (isUp ? '+' : '');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: SoloLevelingTheme.textMuted,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$symbol${delta.toStringAsFixed(1)}kg',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SeriesSummary extends StatelessWidget {
  final List<ExerciseProgressPoint> series;
  final Exercise exercise;

  const _SeriesSummary({required this.series, required this.exercise});

  @override
  Widget build(BuildContext context) {
    if (series.length < 2) return const SizedBox.shrink();
    final first = series.first.estimated1Rm;
    final last = series.last.estimated1Rm;
    final delta = last - first;
    final pct = first == 0 ? 0 : (delta / first) * 100;
    final isUp = delta > 0;
    final color = delta.abs() < 0.5
        ? SoloLevelingTheme.textMuted
        : (isUp ? SoloLevelingTheme.successGreen : SoloLevelingTheme.hpRed);

    return Row(
      children: [
        _Stat(
          label: 'SESSIONS',
          value: '${series.length}',
        ),
        const SizedBox(width: 16),
        _Stat(
          label: 'CURRENT',
          value: '${last.toStringAsFixed(1)}kg',
          color: SoloLevelingTheme.primaryCyan,
        ),
        const SizedBox(width: 16),
        _Stat(
          label: 'CHANGE',
          value:
              '${isUp ? "+" : ""}${delta.toStringAsFixed(1)}kg (${pct.toStringAsFixed(0)}%)',
          color: color,
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  const _Stat({required this.label, required this.value, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: SoloLevelingTheme.textMuted,
            fontSize: 9,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: color ?? SoloLevelingTheme.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _ExerciseQuickRow extends StatelessWidget {
  final Exercise exercise;
  final List<ExerciseProgressPoint> series;
  final VoidCallback onTap;

  const _ExerciseQuickRow({
    required this.exercise,
    required this.series,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String trend;
    Color trendColor;
    if (series.length < 2) {
      trend = '—';
      trendColor = SoloLevelingTheme.textMuted;
    } else {
      final delta =
          series.last.estimated1Rm - series.first.estimated1Rm;
      if (delta.abs() < 0.5) {
        trend = '≈ flat';
        trendColor = SoloLevelingTheme.textMuted;
      } else if (delta > 0) {
        trend = '↑ +${delta.toStringAsFixed(1)}kg';
        trendColor = SoloLevelingTheme.successGreen;
      } else {
        trend = '↓ ${delta.toStringAsFixed(1)}kg';
        trendColor = SoloLevelingTheme.hpRed;
      }
    }

    return InkWell(
      onTap: series.length >= 2 ? onTap : null,
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
            Text(exercise.iconEmoji ?? '🏋️',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                        color: SoloLevelingTheme.textPrimary, fontSize: 13),
                  ),
                  Text(
                    '${series.length} session${series.length == 1 ? '' : 's'}',
                    style: TextStyle(
                        color: SoloLevelingTheme.textMuted, fontSize: 10),
                  ),
                ],
              ),
            ),
            Text(
              trend,
              style: TextStyle(
                color: trendColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeightHistorySheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameProvider>();
    final entries = game.bodyWeightEntries;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '[WEIGHT HISTORY]',
              style: TextStyle(
                color: SoloLevelingTheme.successGreen,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            if (entries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No entries yet.',
                  style: TextStyle(color: SoloLevelingTheme.textMuted),
                  textAlign: TextAlign.center,
                ),
              ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 360),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: entries.length,
                itemBuilder: (_, i) {
                  final e = entries[i];
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 4),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: SoloLevelingTheme.textMuted.withOpacity(0.15),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${e.weight.toStringAsFixed(1)} kg',
                                style: const TextStyle(
                                  color: SoloLevelingTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${e.date.day}/${e.date.month}/${e.date.year}',
                                style: TextStyle(
                                  color: SoloLevelingTheme.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 18),
                          color: SoloLevelingTheme.hpRed,
                          onPressed: () => game.deleteBodyWeightEntry(e.id),
                        ),
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
