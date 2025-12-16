import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/game_provider.dart';
import '../theme/solo_leveling_theme.dart';
import '../widgets/widgets.dart';

/// The main Status Window - shows player stats like Jinwoo's HUD
class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  Future<void> _pickProfileImage(BuildContext context, GameProvider game) async {
    final picker = ImagePicker();

    // Show options dialog
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SoloLevelingTheme.backgroundCard,
        title: const Text(
          'Change Profile Picture',
          style: TextStyle(color: SoloLevelingTheme.primaryCyan),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: SoloLevelingTheme.primaryCyan),
              title: const Text('Choose from Gallery', style: TextStyle(color: SoloLevelingTheme.textPrimary)),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: SoloLevelingTheme.primaryCyan),
              title: const Text('Take a Photo', style: TextStyle(color: SoloLevelingTheme.textPrimary)),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null) return;

    final XFile? image = await picker.pickImage(
      source: source,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (image != null) {
      await game.updateProfileImage(image.path);
    }
  }

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
              _buildPlayerInfo(context, player, game),
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

  Widget _buildPlayerInfo(BuildContext context, player, GameProvider game) {
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
              GestureDetector(
                onTap: () => _pickProfileImage(context, game),
                child: Stack(
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
                    // Camera icon hint
                    Positioned(
                      left: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: SoloLevelingTheme.backgroundCard.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: SoloLevelingTheme.primaryCyan,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
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
