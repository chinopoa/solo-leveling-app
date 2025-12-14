import 'package:flutter/material.dart';
import '../theme/solo_leveling_theme.dart';
import '../models/quest.dart';

class QuestCard extends StatelessWidget {
  final Quest quest;
  final VoidCallback? onTap;
  final VoidCallback? onComplete;
  final VoidCallback? onIncrement;

  const QuestCard({
    super.key,
    required this.quest,
    this.onTap,
    this.onComplete,
    this.onIncrement,
  });

  Color get _typeColor {
    switch (quest.type) {
      case QuestType.daily:
        return SoloLevelingTheme.primaryCyan;
      case QuestType.emergency:
        return SoloLevelingTheme.hpRed;
      case QuestType.dungeon:
        return SoloLevelingTheme.accentPurple;
      case QuestType.penalty:
        return Colors.orange;
      default:
        return SoloLevelingTheme.textSecondary;
    }
  }

  String get _typeLabel {
    switch (quest.type) {
      case QuestType.daily:
        return 'DAILY';
      case QuestType.emergency:
        return 'EMERGENCY';
      case QuestType.dungeon:
        return 'DUNGEON';
      case QuestType.penalty:
        return 'PENALTY';
      default:
        return 'QUEST';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCompleted = quest.isCompleted;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isCompleted
              ? SoloLevelingTheme.successGreen.withOpacity(0.1)
              : SoloLevelingTheme.backgroundCard,
          border: Border.all(
            color: isCompleted
                ? SoloLevelingTheme.successGreen.withOpacity(0.5)
                : _typeColor.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: _typeColor),
                  ),
                  child: Text(
                    _typeLabel,
                    style: TextStyle(
                      color: _typeColor,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (quest.statBonus != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: SoloLevelingTheme.getStatColor(quest.statBonus!)
                          .withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      '+${quest.statBonusAmount} ${quest.statBonus}',
                      style: TextStyle(
                        color: SoloLevelingTheme.getStatColor(quest.statBonus!),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const Spacer(),
                if (isCompleted)
                  const Icon(
                    Icons.check_circle,
                    color: SoloLevelingTheme.successGreen,
                    size: 18,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Title
            Text(
              quest.title,
              style: TextStyle(
                color: isCompleted
                    ? SoloLevelingTheme.successGreen
                    : SoloLevelingTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                decoration: isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            if (quest.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                quest.description,
                style: TextStyle(
                  color: SoloLevelingTheme.textMuted,
                  fontSize: 11,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            // Progress bar for countable quests
            if (quest.targetCount > 1 && !isCompleted) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value: quest.progressPercentage,
                        backgroundColor: _typeColor.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation(_typeColor),
                        minHeight: 6,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${quest.currentCount}/${quest.targetCount}',
                    style: TextStyle(
                      color: _typeColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (onIncrement != null) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onIncrement,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(color: _typeColor),
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Icon(
                          Icons.add,
                          color: _typeColor,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
            // Rewards row
            const SizedBox(height: 8),
            Row(
              children: [
                _RewardChip(
                  icon: Icons.auto_awesome,
                  value: '${quest.xpReward} XP',
                  color: SoloLevelingTheme.xpGold,
                ),
                const SizedBox(width: 12),
                _RewardChip(
                  icon: Icons.monetization_on,
                  value: '${quest.goldReward} G',
                  color: Colors.amber,
                ),
                const Spacer(),
                if (!isCompleted && quest.targetCount == 1 && onComplete != null)
                  GestureDetector(
                    onTap: onComplete,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: SoloLevelingTheme.primaryCyan.withOpacity(0.2),
                        border:
                            Border.all(color: SoloLevelingTheme.primaryCyan),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: const Text(
                        'COMPLETE',
                        style: TextStyle(
                          color: SoloLevelingTheme.primaryCyan,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
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

class _RewardChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;

  const _RewardChip({
    required this.icon,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
