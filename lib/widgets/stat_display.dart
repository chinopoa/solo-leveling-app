import 'package:flutter/material.dart';
import '../theme/solo_leveling_theme.dart';
import '../models/player_stats.dart';

/// Display for player stats (STR, AGI, VIT, INT, SEN)
class StatDisplay extends StatelessWidget {
  final PlayerStats stats;
  final bool showAllocateButtons;
  final Function(String)? onAllocate;

  const StatDisplay({
    super.key,
    required this.stats,
    this.showAllocateButtons = false,
    this.onAllocate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (showAllocateButtons && stats.availablePoints > 0)
          _buildAvailablePoints(),
        const SizedBox(height: 8),
        ...stats.toMap().entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: _StatRow(
                stat: entry.key,
                value: entry.value,
                showButton: showAllocateButtons && stats.availablePoints > 0,
                onAllocate: () => onAllocate?.call(entry.key),
              ),
            )),
      ],
    );
  }

  Widget _buildAvailablePoints() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: SoloLevelingTheme.primaryCyan.withOpacity(0.1),
        border: Border.all(
          color: SoloLevelingTheme.primaryCyan.withOpacity(0.5),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.add_circle_outline,
            color: SoloLevelingTheme.primaryCyan,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'AVAILABLE POINTS: ${stats.availablePoints}',
            style: const TextStyle(
              color: SoloLevelingTheme.primaryCyan,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String stat;
  final int value;
  final bool showButton;
  final VoidCallback? onAllocate;

  const _StatRow({
    required this.stat,
    required this.value,
    this.showButton = false,
    this.onAllocate,
  });

  String get statName {
    switch (stat) {
      case 'STR':
        return 'Strength';
      case 'AGI':
        return 'Agility';
      case 'VIT':
        return 'Vitality';
      case 'INT':
        return 'Intelligence';
      case 'SEN':
        return 'Sense';
      default:
        return stat;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = SoloLevelingTheme.getStatColor(stat);

    return Row(
      children: [
        Container(
          width: 40,
          padding: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Text(
            stat,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            statName,
            style: TextStyle(
              color: SoloLevelingTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ),
        Container(
          width: 50,
          alignment: Alignment.centerRight,
          child: Text(
            value.toString(),
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (showButton)
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: GestureDetector(
              onTap: onAllocate,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(color: SoloLevelingTheme.primaryCyan),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: const Icon(
                  Icons.add,
                  color: SoloLevelingTheme.primaryCyan,
                  size: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// Compact stat display for smaller spaces
class CompactStatDisplay extends StatelessWidget {
  final PlayerStats stats;

  const CompactStatDisplay({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: stats.toMap().entries.map((entry) {
        final color = SoloLevelingTheme.getStatColor(entry.key);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${entry.key}:',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              entry.value.toString(),
              style: TextStyle(
                color: color.withOpacity(0.8),
                fontSize: 11,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
