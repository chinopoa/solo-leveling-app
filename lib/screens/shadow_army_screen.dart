import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/solo_leveling_theme.dart';
import '../models/models.dart';

/// Shadow Army screen - Your collection of conquered projects
class ShadowArmyScreen extends StatelessWidget {
  const ShadowArmyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        final shadows = game.shadows;

        return Column(
          children: [
            // Header
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SoloLevelingTheme.backgroundCard,
                border: Border.all(
                  color: SoloLevelingTheme.shadowPurple.withOpacity(0.5),
                ),
                borderRadius: BorderRadius.circular(4),
                boxShadow: SoloLevelingTheme.glowEffect(
                  SoloLevelingTheme.shadowPurple,
                  intensity: 0.3,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'SHADOW ARMY',
                    style: TextStyle(
                      color: SoloLevelingTheme.shadowPurple,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatItem(
                        label: 'SHADOWS',
                        value: shadows.length.toString(),
                      ),
                      const SizedBox(width: 24),
                      _StatItem(
                        label: 'TOTAL POWER',
                        value: shadows.fold<int>(
                            0, (sum, s) => sum + s.powerLevel).toString(),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Shadow list
            Expanded(
              child: shadows.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: shadows.length,
                      itemBuilder: (context, index) {
                        return _ShadowCard(shadow: shadows[index]);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.groups_outlined,
            size: 80,
            color: SoloLevelingTheme.shadowPurple.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'NO SHADOWS YET',
            style: TextStyle(
              color: SoloLevelingTheme.textMuted,
              fontSize: 16,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Complete dungeons to extract shadows',
            style: TextStyle(
              color: SoloLevelingTheme.textMuted.withOpacity(0.7),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(
                color: SoloLevelingTheme.shadowPurple.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              children: const [
                Text(
                  '"ARISE"',
                  style: TextStyle(
                    color: SoloLevelingTheme.shadowPurple,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Your conquered projects become\nyour eternal soldiers',
                  style: TextStyle(
                    color: SoloLevelingTheme.textMuted,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: SoloLevelingTheme.shadowPurple,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: SoloLevelingTheme.textMuted,
            fontSize: 10,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

class _ShadowCard extends StatelessWidget {
  final Shadow shadow;

  const _ShadowCard({required this.shadow});

  Color get _rankColor {
    switch (shadow.shadowRank) {
      case ShadowRank.marshal:
        return const Color(0xFFFFD700); // Gold
      case ShadowRank.commander:
        return const Color(0xFFFF6B6B); // Red
      case ShadowRank.knight:
        return const Color(0xFFFF9F43); // Orange
      case ShadowRank.elite:
        return const Color(0xFF54A0FF); // Blue
      case ShadowRank.soldier:
      default:
        return SoloLevelingTheme.textMuted;
    }
  }

  String get _rankLabel {
    switch (shadow.shadowRank) {
      case ShadowRank.marshal:
        return 'MARSHAL';
      case ShadowRank.commander:
        return 'COMMANDER';
      case ShadowRank.knight:
        return 'KNIGHT';
      case ShadowRank.elite:
        return 'ELITE';
      case ShadowRank.soldier:
      default:
        return 'SOLDIER';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: SoloLevelingTheme.backgroundCard,
        border: Border.all(
          color: SoloLevelingTheme.shadowPurple.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: SoloLevelingTheme.shadowPurple.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                // Shadow icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: SoloLevelingTheme.shadowPurple.withOpacity(0.2),
                    border: Border.all(
                      color: _rankColor,
                      width: 2,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      Icons.person,
                      color: _rankColor,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Name and rank
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shadow.name.toUpperCase(),
                        style: TextStyle(
                          color: _rankColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: _rankColor),
                        ),
                        child: Text(
                          _rankLabel,
                          style: TextStyle(
                            color: _rankColor,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Power level
                Column(
                  children: [
                    Text(
                      shadow.powerLevel.toString(),
                      style: const TextStyle(
                        color: SoloLevelingTheme.shadowPurple,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'POWER',
                      style: TextStyle(
                        color: SoloLevelingTheme.textMuted,
                        fontSize: 8,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Details
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Origin
                Row(
                  children: [
                    const Text(
                      'ORIGIN: ',
                      style: TextStyle(
                        color: SoloLevelingTheme.textMuted,
                        fontSize: 10,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        shadow.originalDungeonName,
                        style: const TextStyle(
                          color: SoloLevelingTheme.textSecondary,
                          fontSize: 10,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Type
                Row(
                  children: [
                    const Text(
                      'TYPE: ',
                      style: TextStyle(
                        color: SoloLevelingTheme.textMuted,
                        fontSize: 10,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: SoloLevelingTheme.primaryCyan.withOpacity(0.1),
                        border: Border.all(
                          color: SoloLevelingTheme.primaryCyan.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        shadow.type.toUpperCase(),
                        style: const TextStyle(
                          color: SoloLevelingTheme.primaryCyan,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                // Passive bonus
                if (shadow.passiveBonus != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: SoloLevelingTheme.successGreen.withOpacity(0.1),
                      border: Border.all(
                        color: SoloLevelingTheme.successGreen.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.auto_awesome,
                          color: SoloLevelingTheme.successGreen,
                          size: 14,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            shadow.passiveBonus!,
                            style: const TextStyle(
                              color: SoloLevelingTheme.successGreen,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
