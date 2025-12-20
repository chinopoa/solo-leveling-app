import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/solo_leveling_theme.dart';
import '../widgets/system_window.dart';
import '../models/models.dart';

/// Hunter Status Screen - Shows Skills, Stats with activity bonuses, and Personal Records
class HunterScreen extends StatefulWidget {
  const HunterScreen({super.key});

  @override
  State<HunterScreen> createState() => _HunterScreenState();
}

class _HunterScreenState extends State<HunterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        return Column(
          children: [
            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: SoloLevelingTheme.backgroundCard,
                border: Border.all(
                  color: SoloLevelingTheme.primaryCyan.withAlpha(77),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: SoloLevelingTheme.primaryCyan,
                indicatorWeight: 2,
                labelColor: SoloLevelingTheme.primaryCyan,
                unselectedLabelColor: SoloLevelingTheme.textMuted,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  fontSize: 12,
                ),
                tabs: const [
                  Tab(text: 'STATS'),
                  Tab(text: 'SKILLS'),
                  Tab(text: 'RECORDS'),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildStatsTab(game),
                  _buildSkillsTab(game),
                  _buildRecordsTab(game),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatsTab(GameProvider game) {
    final player = game.player;
    if (player == null) return const SizedBox();

    final activityBonuses = game.activityStatBonuses;
    final stats = ['STR', 'AGI', 'VIT', 'INT', 'SEN'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SystemWindow(
            title: '[SYSTEM] HUNTER STATUS',
            child: Column(
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      player.name.toUpperCase(),
                      style: const TextStyle(
                        color: SoloLevelingTheme.primaryCyan,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: SoloLevelingTheme.xpGold,
                        ),
                      ),
                      child: Text(
                        'LV. ${player.level}',
                        style: const TextStyle(
                          color: SoloLevelingTheme.xpGold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(color: SoloLevelingTheme.primaryCyan, height: 24),

                // Stats with activity bonuses
                ...stats.map((stat) => _buildStatRow(
                      stat,
                      player.stats.toMap()[stat] ?? 10,
                      activityBonuses[stat] ?? 0,
                    )),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Activity Summary
          SystemWindow(
            title: 'ACTIVITY POINTS',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Points earned from completing quests and habits',
                  style: TextStyle(
                    color: SoloLevelingTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Every 100 points = +1 to stat',
                  style: TextStyle(
                    color: SoloLevelingTheme.primaryCyan.withOpacity(0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String stat, int base, int activityPoints) {
    final activityBonus = activityPoints ~/ 100;
    final progress = (activityPoints % 100) / 100;

    Color statColor;
    switch (stat) {
      case 'STR':
        statColor = SoloLevelingTheme.strColor;
        break;
      case 'AGI':
        statColor = SoloLevelingTheme.agiColor;
        break;
      case 'VIT':
        statColor = SoloLevelingTheme.vitColor;
        break;
      case 'INT':
        statColor = SoloLevelingTheme.intColor;
        break;
      case 'SEN':
        statColor = SoloLevelingTheme.senColor;
        break;
      default:
        statColor = SoloLevelingTheme.primaryCyan;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  stat,
                  style: TextStyle(
                    color: statColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$base',
                style: const TextStyle(
                  color: SoloLevelingTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (activityBonus > 0) ...[
                const SizedBox(width: 4),
                Text(
                  '[+$activityBonus]',
                  style: TextStyle(
                    color: SoloLevelingTheme.successGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              const Spacer(),
              Text(
                '$activityPoints pts',
                style: TextStyle(
                  color: SoloLevelingTheme.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Progress to next bonus
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: statColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(statColor),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsTab(GameProvider game) {
    final skills = game.skills;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SystemWindow(
            title: '[SKILLS]',
            child: Column(
              children: skills.map((skill) => _buildSkillCard(skill)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillCard(Skill skill) {
    Color rankColor;
    switch (skill.skillRank) {
      case SkillRank.s:
        rankColor = SoloLevelingTheme.xpGold;
        break;
      case SkillRank.a:
        rankColor = Colors.purple;
        break;
      case SkillRank.b:
        rankColor = Colors.blue;
        break;
      case SkillRank.c:
        rankColor = Colors.green;
        break;
      case SkillRank.d:
        rankColor = Colors.orange;
        break;
      default:
        rankColor = SoloLevelingTheme.textMuted;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SoloLevelingTheme.backgroundDark,
        border: Border.all(
          color: rankColor.withOpacity(0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: rankColor.withOpacity(0.1),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (skill.iconEmoji != null)
                Text(
                  skill.iconEmoji!,
                  style: const TextStyle(fontSize: 24),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skill.name.toUpperCase(),
                      style: const TextStyle(
                        color: SoloLevelingTheme.textPrimary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    if (skill.description != null)
                      Text(
                        skill.description!,
                        style: TextStyle(
                          color: SoloLevelingTheme.textMuted,
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: rankColor),
                  boxShadow: [
                    BoxShadow(
                      color: rankColor.withOpacity(0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Text(
                  'RANK ${skill.rankDisplay}',
                  style: TextStyle(
                    color: rankColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // XP Progress
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: skill.progressPercentage,
                    backgroundColor: rankColor.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(rankColor),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${skill.currentXp}/${skill.xpToNextRank}',
                style: TextStyle(
                  color: SoloLevelingTheme.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecordsTab(GameProvider game) {
    final records = game.personalRecords;
    final categories = ['fitness', 'streak', 'achievement', 'nutrition'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: categories.map((category) {
          final categoryRecords =
              records.where((r) => r.category == category).toList();
          if (categoryRecords.isEmpty) return const SizedBox();

          return Column(
            children: [
              SystemWindow(
                title: '[${category.toUpperCase()} RECORDS]',
                child: Column(
                  children: categoryRecords
                      .map((pr) => _buildPRRow(pr))
                      .toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPRRow(PersonalRecord pr) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          if (pr.iconEmoji != null)
            Text(
              pr.iconEmoji!,
              style: const TextStyle(fontSize: 20),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pr.name,
                  style: const TextStyle(
                    color: SoloLevelingTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (pr.improvement > 0)
                  Text(
                    '+${pr.improvement.toStringAsFixed(1)} from previous',
                    style: TextStyle(
                      color: SoloLevelingTheme.successGreen,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                pr.formattedValue,
                style: const TextStyle(
                  color: SoloLevelingTheme.xpGold,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                _formatDate(pr.achievedAt),
                style: TextStyle(
                  color: SoloLevelingTheme.textMuted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
