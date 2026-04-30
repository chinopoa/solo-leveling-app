import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/solo_leveling_theme.dart';
import '../widgets/widgets.dart';

/// The main Status Window - shows player stats like Jinwoo's HUD
class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        final player = game.player;

        if (player == null) {
          return const Center(
            child: CircularProgressIndicator(
              color: SoloLevelingTheme.primaryCyan,
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Player Info Card
              _buildPlayerInfo(player),
              const SizedBox(height: 16),

              // HP, MP, Fatigue bars
              _buildVitalBars(player),
              const SizedBox(height: 16),

              // XP Bar
              XpBar(
                level: player.level,
                currentXp: player.currentXp,
                xpToNext: player.xpToNextLevel,
              ),
              const SizedBox(height: 24),

              // Stats Section
              SystemWindow(
                title: 'STATS',
                child: StatDisplay(
                  stats: player.stats,
                  showAllocateButtons: player.stats.availablePoints > 0,
                  onAllocate: (stat) => game.allocateStat(stat),
                ),
              ),
              const SizedBox(height: 16),

              // Body Vitals (current weight + delta + sparkline)
              _BodyVitalsCard(),
              const SizedBox(height: 16),

              // Quick Stats
              _buildQuickStats(player, game),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayerInfo(player) {
    final hasProfileImage = player.profileImagePath != null;

    return SystemWindow(
      title: 'STATUS WINDOW',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name and Level
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name.toUpperCase(),
                      style: const TextStyle(
                        color: SoloLevelingTheme.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildInfoChip('JOB', player.jobClass),
                        const SizedBox(width: 8),
                        _buildInfoChip('TITLE', player.title),
                      ],
                    ),
                  ],
                ),
              ),
              // Profile picture / Rank badge
              Stack(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: SoloLevelingTheme.getRankColor(player.rank),
                        width: 2,
                      ),
                      boxShadow: SoloLevelingTheme.glowEffect(
                        SoloLevelingTheme.getRankColor(player.rank),
                        intensity: 0.5,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: hasProfileImage
                          ? Image.file(
                              File(player.profileImagePath!),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildRankFallback(player),
                            )
                          : _buildRankFallback(player),
                    ),
                  ),
                  // Rank badge overlay
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: SoloLevelingTheme.backgroundCard,
                        border: Border.all(
                          color: SoloLevelingTheme.getRankColor(player.rank),
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        player.rank,
                        style: TextStyle(
                          color: SoloLevelingTheme.getRankColor(player.rank),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankFallback(player) {
    return Container(
      color: SoloLevelingTheme.backgroundElevated,
      child: Center(
        child: Text(
          player.rank,
          style: TextStyle(
            color: SoloLevelingTheme.getRankColor(player.rank),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(
          color: SoloLevelingTheme.primaryCyan.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: SoloLevelingTheme.textMuted,
              fontSize: 10,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: SoloLevelingTheme.primaryCyan,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalBars(player) {
    return SystemWindow(
      title: 'VITALS',
      child: Column(
        children: [
          StatBar(
            label: 'HP',
            current: player.currentHp,
            max: player.maxHp,
            color: SoloLevelingTheme.hpRed,
          ),
          const SizedBox(height: 12),
          StatBar(
            label: 'MP',
            current: player.currentMp,
            max: player.maxMp,
            color: SoloLevelingTheme.mpBlue,
          ),
          const SizedBox(height: 12),
          StatBar(
            label: 'FATIGUE',
            current: player.fatigue,
            max: 100,
            color: SoloLevelingTheme.fatigueOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(player, GameProvider game) {
    return Row(
      children: [
        Expanded(
          child: _QuickStatCard(
            icon: Icons.fitness_center,
            label: 'WORKOUTS',
            value: game.workoutSessions.where((w) => !w.isActive).length.toString(),
            color: SoloLevelingTheme.primaryCyan,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickStatCard(
            icon: Icons.local_fire_department,
            label: 'STREAK',
            value: '${player.dailyStreak} days',
            color: SoloLevelingTheme.hpRed,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickStatCard(
            icon: Icons.restaurant,
            label: 'CALORIES',
            value: '${game.todayCalories.round()}',
            subValue: '/ ${game.nutritionGoals.dailyCalories}',
            color: SoloLevelingTheme.getStatColor('VIT'),
          ),
        ),
      ],
    );
  }
}

class _QuickStatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String? subValue;
  final Color color;

  const _QuickStatCard({
    required this.icon,
    required this.label,
    required this.value,
    this.subValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SoloLevelingTheme.backgroundCard,
        border: Border.all(color: color.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subValue != null)
                Text(
                  subValue!,
                  style: TextStyle(
                    color: SoloLevelingTheme.textMuted,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
          Text(
            label,
            style: TextStyle(
              color: SoloLevelingTheme.textMuted,
              fontSize: 9,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact body-weight summary on the Status screen. Tap the + to log,
/// shows latest weight, 7-day and 30-day deltas, and a small sparkline.
/// Full chart and history live in Training → Progress.
class _BodyVitalsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, _) {
        final latest = game.latestBodyWeight;
        final delta7 = game.bodyWeightDelta(days: 7);
        final delta30 = game.bodyWeightDelta(days: 30);
        final entries = game.bodyWeightEntries;

        // Sparkline data: most recent ~30 entries, oldest first.
        final sparkPoints = [
          for (final e in entries.take(30).toList().reversed)
            TrendPoint(e.date, e.weight),
        ];

        return SystemWindow(
          title: 'BODY VITALS',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    latest == null ? '—' : latest.toStringAsFixed(1),
                    style: const TextStyle(
                      color: SoloLevelingTheme.textPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Text(
                      'kg',
                      style: TextStyle(
                        color: SoloLevelingTheme.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (delta7 != null) _MiniDelta(label: '7D', delta: delta7),
                  if (delta7 != null && delta30 != null) const SizedBox(width: 6),
                  if (delta30 != null) _MiniDelta(label: '30D', delta: delta30),
                  IconButton(
                    onPressed: () => _logWeight(context, game),
                    icon: const Icon(Icons.add_circle,
                        color: SoloLevelingTheme.primaryCyan),
                    tooltip: 'Log weight',
                  ),
                ],
              ),
              if (sparkPoints.length >= 2) ...[
                const SizedBox(height: 8),
                TrendlineChart(
                  points: sparkPoints,
                  unit: 'kg',
                  lineColor: SoloLevelingTheme.successGreen,
                  height: 80,
                  showDots: false,
                ),
              ] else if (latest == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Tap + to log your first weigh-in.',
                    style: TextStyle(
                      color: SoloLevelingTheme.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _logWeight(BuildContext context, GameProvider game) async {
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
}

class _MiniDelta extends StatelessWidget {
  final String label;
  final double delta;
  const _MiniDelta({required this.label, required this.delta});

  @override
  Widget build(BuildContext context) {
    final isFlat = delta.abs() < 0.05;
    final color = isFlat
        ? SoloLevelingTheme.textMuted
        : (delta > 0
            ? SoloLevelingTheme.xpGold
            : SoloLevelingTheme.successGreen);
    final sign = isFlat ? '±' : (delta > 0 ? '+' : '');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        '$label $sign${delta.toStringAsFixed(1)}',
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
