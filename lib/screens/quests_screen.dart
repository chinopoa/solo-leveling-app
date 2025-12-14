import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/solo_leveling_theme.dart';
import '../widgets/widgets.dart';
import '../models/models.dart';

/// Quests and Dungeons screen
class QuestsScreen extends StatefulWidget {
  const QuestsScreen({super.key});

  @override
  State<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends State<QuestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab bar
        Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SoloLevelingTheme.backgroundCard,
            border: Border.all(
              color: SoloLevelingTheme.primaryCyan.withOpacity(0.3),
            ),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorColor: SoloLevelingTheme.primaryCyan,
            labelColor: SoloLevelingTheme.primaryCyan,
            unselectedLabelColor: SoloLevelingTheme.textMuted,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
            tabs: const [
              Tab(text: 'QUESTS'),
              Tab(text: 'DUNGEONS'),
            ],
          ),
        ),
        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              _QuestsTab(),
              _DungeonsTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuestsTab extends StatelessWidget {
  const _QuestsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        final quests = game.activeQuests;

        return Stack(
          children: [
            if (quests.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.assignment_outlined,
                      size: 64,
                      color: SoloLevelingTheme.textMuted,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'NO ACTIVE QUESTS',
                      style: TextStyle(
                        color: SoloLevelingTheme.textMuted,
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add a quest to begin your hunt',
                      style: TextStyle(
                        color: SoloLevelingTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: quests.length,
                itemBuilder: (context, index) {
                  final quest = quests[index];
                  return QuestCard(
                    quest: quest,
                    onComplete: () => game.completeQuest(quest),
                    onIncrement: quest.targetCount > 1
                        ? () => game.incrementQuestProgress(quest)
                        : null,
                  );
                },
              ),
            // FAB
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                onPressed: () => _showAddQuestDialog(context, game),
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddQuestDialog(BuildContext context, GameProvider game) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    String selectedStat = 'STR';
    QuestDifficulty selectedDifficulty = QuestDifficulty.normal;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: SoloLevelingTheme.backgroundCard,
          title: const Text(
            'NEW QUEST',
            style: TextStyle(
              color: SoloLevelingTheme.primaryCyan,
              letterSpacing: 2,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Quest Title',
                    hintText: 'e.g., Complete workout',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                const Text(
                  'STAT BONUS',
                  style: TextStyle(
                    color: SoloLevelingTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['STR', 'AGI', 'VIT', 'INT', 'SEN'].map((stat) {
                    final isSelected = selectedStat == stat;
                    final color = SoloLevelingTheme.getStatColor(stat);
                    return GestureDetector(
                      onTap: () => setState(() => selectedStat = stat),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? color.withOpacity(0.2) : null,
                          border: Border.all(
                            color: isSelected ? color : color.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          stat,
                          style: TextStyle(
                            color: color,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'DIFFICULTY',
                  style: TextStyle(
                    color: SoloLevelingTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: QuestDifficulty.values.map((diff) {
                    final isSelected = selectedDifficulty == diff;
                    return GestureDetector(
                      onTap: () => setState(() => selectedDifficulty = diff),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? SoloLevelingTheme.primaryCyan.withOpacity(0.2)
                              : null,
                          border: Border.all(
                            color: isSelected
                                ? SoloLevelingTheme.primaryCyan
                                : SoloLevelingTheme.primaryCyan.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          diff.name.toUpperCase(),
                          style: TextStyle(
                            color: SoloLevelingTheme.primaryCyan,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty) {
                  final quest = Quest.createWithDifficulty(
                    title: titleController.text,
                    description: descController.text,
                    difficulty: selectedDifficulty,
                    type: QuestType.normal,
                    statBonus: selectedStat,
                  );
                  game.addQuest(quest);
                  Navigator.pop(context);
                }
              },
              child: const Text('CREATE'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DungeonsTab extends StatelessWidget {
  const _DungeonsTab();

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        final dungeons = game.activeDungeons;

        return Stack(
          children: [
            if (dungeons.isEmpty)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.door_front_door_outlined,
                      size: 64,
                      color: SoloLevelingTheme.textMuted,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'NO ACTIVE DUNGEONS',
                      style: TextStyle(
                        color: SoloLevelingTheme.textMuted,
                        fontSize: 14,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create a dungeon for larger projects',
                      style: TextStyle(
                        color: SoloLevelingTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: dungeons.length,
                itemBuilder: (context, index) {
                  final dungeon = dungeons[index];
                  return _DungeonCard(
                    dungeon: dungeon,
                    quests: game.quests
                        .where((q) => dungeon.questIds.contains(q.id))
                        .toList(),
                    onClear: () => _showAriseDialog(context, game, dungeon),
                  );
                },
              ),
            // FAB
            Positioned(
              right: 16,
              bottom: 16,
              child: FloatingActionButton(
                onPressed: () => _showCreateDungeonDialog(context, game),
                backgroundColor: SoloLevelingTheme.accentPurple,
                child: const Icon(Icons.add),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showCreateDungeonDialog(BuildContext context, GameProvider game) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final tasksController = TextEditingController();
    final bossController = TextEditingController();
    DungeonRank selectedRank = DungeonRank.E;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: SoloLevelingTheme.backgroundCard,
          title: const Text(
            'CREATE DUNGEON',
            style: TextStyle(
              color: SoloLevelingTheme.accentPurple,
              letterSpacing: 2,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Dungeon Name',
                    hintText: 'e.g., Build Portfolio Website',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'DUNGEON RANK',
                  style: TextStyle(
                    color: SoloLevelingTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: DungeonRank.values.map((rank) {
                    final isSelected = selectedRank == rank;
                    final color = SoloLevelingTheme.getRankColor(rank.name);
                    return GestureDetector(
                      onTap: () => setState(() => selectedRank = rank),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isSelected ? color.withOpacity(0.2) : null,
                          border: Border.all(
                            color: isSelected ? color : color.withOpacity(0.3),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            rank.name,
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: tasksController,
                  decoration: const InputDecoration(
                    labelText: 'Sub-tasks (one per line)',
                    hintText: 'Write bio\nDesign layout\nAdd images',
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bossController,
                  decoration: const InputDecoration(
                    labelText: 'Boss Task (final task)',
                    hintText: 'e.g., Deploy to production',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.isNotEmpty &&
                    bossController.text.isNotEmpty) {
                  final subTasks = tasksController.text
                      .split('\n')
                      .where((t) => t.trim().isNotEmpty)
                      .toList();

                  game.createDungeon(
                    name: nameController.text,
                    description: descController.text,
                    rank: selectedRank,
                    subTasks: subTasks,
                    bossTask: bossController.text,
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SoloLevelingTheme.accentPurple.withOpacity(0.2),
                foregroundColor: SoloLevelingTheme.accentPurple,
              ),
              child: const Text('CREATE'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAriseDialog(
      BuildContext context, GameProvider game, Dungeon dungeon) {
    final nameController = TextEditingController();
    String selectedType = 'general';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: SoloLevelingTheme.backgroundCard,
          title: const Text(
            'ARISE',
            style: TextStyle(
              color: SoloLevelingTheme.shadowPurple,
              fontSize: 32,
              letterSpacing: 4,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Extract a shadow from "${dungeon.name}"',
                style: const TextStyle(
                  color: SoloLevelingTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Shadow Name',
                  hintText: Shadow.suggestedNames.first,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: Shadow.suggestedNames.take(5).map((name) {
                  return GestureDetector(
                    onTap: () => nameController.text = name,
                    child: Chip(
                      label: Text(name, style: const TextStyle(fontSize: 10)),
                      backgroundColor: SoloLevelingTheme.backgroundElevated,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Shadow Type',
                ),
                items: ['general', 'coding', 'fitness', 'creative', 'learning']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => selectedType = v ?? 'general'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.isNotEmpty
                    ? nameController.text
                    : Shadow.suggestedNames.first;

                game.extractShadow(
                  dungeon: dungeon,
                  shadowName: name,
                  type: selectedType,
                );
                game.clearDungeon(dungeon);
                Navigator.pop(context);

                // Show arise animation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$name has joined your shadow army!'),
                    backgroundColor: SoloLevelingTheme.shadowPurple,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SoloLevelingTheme.shadowPurple.withOpacity(0.2),
                foregroundColor: SoloLevelingTheme.shadowPurple,
              ),
              child: const Text('ARISE'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DungeonCard extends StatelessWidget {
  final Dungeon dungeon;
  final List<Quest> quests;
  final VoidCallback onClear;

  const _DungeonCard({
    required this.dungeon,
    required this.quests,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final color = SoloLevelingTheme.getRankColor(dungeon.rank);
    final progress = dungeon.getProgress(quests);
    final allComplete = progress >= 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: SoloLevelingTheme.backgroundCard,
        border: Border.all(color: color.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: color.withOpacity(0.3)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    border: Border.all(color: color, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      dungeon.rank,
                      style: TextStyle(
                        color: color,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dungeon.name,
                        style: const TextStyle(
                          color: SoloLevelingTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        dungeon.description,
                        style: TextStyle(
                          color: SoloLevelingTheme.textMuted,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (allComplete)
                  ElevatedButton(
                    onPressed: onClear,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SoloLevelingTheme.shadowPurple.withOpacity(0.2),
                      foregroundColor: SoloLevelingTheme.shadowPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text('ARISE'),
                  ),
              ],
            ),
          ),
          // Progress
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'PROGRESS',
                      style: TextStyle(
                        color: SoloLevelingTheme.textMuted,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: color.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
          // Quest list
          ...quests.map((quest) => _DungeonQuestItem(quest: quest)),
          // Rewards
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: color.withOpacity(0.3)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, color: SoloLevelingTheme.xpGold, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${dungeon.totalXpReward} XP',
                  style: const TextStyle(
                    color: SoloLevelingTheme.xpGold,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.monetization_on, color: Colors.amber, size: 14),
                const SizedBox(width: 4),
                Text(
                  '${dungeon.totalGoldReward} G',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DungeonQuestItem extends StatelessWidget {
  final Quest quest;

  const _DungeonQuestItem({required this.quest});

  @override
  Widget build(BuildContext context) {
    final game = context.read<GameProvider>();
    final isBoss = quest.difficulty == 'boss';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isBoss
            ? SoloLevelingTheme.hpRed.withOpacity(0.05)
            : Colors.transparent,
      ),
      child: Row(
        children: [
          Icon(
            quest.isCompleted
                ? Icons.check_circle
                : isBoss
                    ? Icons.whatshot
                    : Icons.circle_outlined,
            size: 16,
            color: quest.isCompleted
                ? SoloLevelingTheme.successGreen
                : isBoss
                    ? SoloLevelingTheme.hpRed
                    : SoloLevelingTheme.textMuted,
          ),
          const SizedBox(width: 8),
          if (isBoss)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: SoloLevelingTheme.hpRed.withOpacity(0.2),
                border: Border.all(color: SoloLevelingTheme.hpRed),
              ),
              child: const Text(
                'BOSS',
                style: TextStyle(
                  color: SoloLevelingTheme.hpRed,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Expanded(
            child: Text(
              quest.title,
              style: TextStyle(
                color: quest.isCompleted
                    ? SoloLevelingTheme.successGreen
                    : SoloLevelingTheme.textPrimary,
                fontSize: 12,
                decoration: quest.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
          if (!quest.isCompleted)
            GestureDetector(
              onTap: () => game.completeQuest(quest),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: SoloLevelingTheme.primaryCyan.withOpacity(0.5),
                  ),
                ),
                child: const Icon(
                  Icons.check,
                  size: 12,
                  color: SoloLevelingTheme.primaryCyan,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
