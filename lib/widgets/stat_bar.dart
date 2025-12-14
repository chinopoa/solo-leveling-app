import 'package:flutter/material.dart';
import '../theme/solo_leveling_theme.dart';

/// A glowing progress bar for HP, MP, XP, etc.
class StatBar extends StatelessWidget {
  final String label;
  final int current;
  final int max;
  final Color color;
  final bool showValues;
  final double height;
  final bool animate;

  const StatBar({
    super.key,
    required this.label,
    required this.current,
    required this.max,
    required this.color,
    this.showValues = true,
    this.height = 20,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = max > 0 ? (current / max).clamp(0.0, 1.0) : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            if (showValues)
              Text(
                '$current / $max',
                style: TextStyle(
                  color: color.withOpacity(0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: height,
          decoration: BoxDecoration(
            color: SoloLevelingTheme.backgroundElevated,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // Background pattern
              ClipRRect(
                borderRadius: BorderRadius.circular(1),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withOpacity(0.05),
                        color.withOpacity(0.02),
                      ],
                    ),
                  ),
                ),
              ),
              // Progress fill
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1),
                    gradient: LinearGradient(
                      colors: [
                        color,
                        color.withOpacity(0.7),
                      ],
                    ),
                    boxShadow: SoloLevelingTheme.glowEffect(color, intensity: 0.5),
                  ),
                ),
              ),
              // Shine effect
              FractionallySizedBox(
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(1),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withOpacity(0.2),
                        Colors.transparent,
                      ],
                      stops: const [0, 0.5],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// XP Bar with level indicator
class XpBar extends StatelessWidget {
  final int level;
  final int currentXp;
  final int xpToNext;

  const XpBar({
    super.key,
    required this.level,
    required this.currentXp,
    required this.xpToNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: SoloLevelingTheme.xpGold,
                    ),
                  ),
                  child: Text(
                    'LV. $level',
                    style: const TextStyle(
                      color: SoloLevelingTheme.xpGold,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              '$currentXp / $xpToNext XP',
              style: TextStyle(
                color: SoloLevelingTheme.xpGold.withOpacity(0.8),
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        StatBar(
          label: '',
          current: currentXp,
          max: xpToNext,
          color: SoloLevelingTheme.xpGold,
          showValues: false,
          height: 8,
        ),
      ],
    );
  }
}
