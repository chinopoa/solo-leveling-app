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

              // Quick Stats
              _buildQuickStats(player, game),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlayerInfo(player) {
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
              // Rank badge
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: SoloLevelingTheme.getRankColor(player.rank),
                    width: 2,
                  ),
                  boxShadow: SoloLevelingTheme.glowEffect(
                    SoloLevelingTheme.getRankColor(player.rank),
                    intensity: 0.5,
                  ),
                ),
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
              ),
            ],
          ),
        ],
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
            icon: Icons.monetization_on,
            label: 'GOLD',
            value: player.gold.toString(),
            color: Colors.amber,
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
