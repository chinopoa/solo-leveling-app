import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/solo_leveling_theme.dart';
import 'workout_screen.dart';
import 'schedule_screen.dart';
import 'progress_screen.dart';

/// Top-level Training hub with three tabs:
/// WORKOUT (skill book + start workout) / SCHEDULE (split editor) / PROGRESS (charts)
class TrainingScreen extends StatefulWidget {
  const TrainingScreen({super.key});

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen>
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
                  Tab(text: 'WORKOUT'),
                  Tab(text: 'SCHEDULE'),
                  Tab(text: 'PROGRESS'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  WorkoutScreen(showHabits: false, game: game),
                  const ScheduleScreen(),
                  const ProgressScreen(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
