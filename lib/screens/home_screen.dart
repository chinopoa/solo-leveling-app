import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/solo_leveling_theme.dart';
import '../widgets/level_up_overlay.dart';
import 'status_screen.dart';
import 'daily_quest_screen.dart';
import 'quests_screen.dart';
import 'hunter_screen.dart';
import 'raids_screen.dart';
import 'settings_screen.dart';

/// Main home screen with bottom navigation
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    StatusScreen(),
    DailyQuestScreen(),
    QuestsScreen(),
    HunterScreen(),
    RaidsScreen(),
  ];

  final List<String> _titles = const [
    'STATUS',
    'DAILY QUEST',
    'QUESTS',
    'HUNTER',
    'RAIDS',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        return Stack(
          children: [
            Scaffold(
              backgroundColor: SoloLevelingTheme.backgroundDark,
              appBar: AppBar(
                title: Text(_titles[_currentIndex]),
                actions: [
                  // Settings gear icon
                  IconButton(
                    icon: const Icon(Icons.settings),
                    color: SoloLevelingTheme.textMuted,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              body: _screens[_currentIndex],
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: SoloLevelingTheme.primaryCyan.withOpacity(0.2),
                    ),
                  ),
                ),
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) => setState(() => _currentIndex = index),
                  type: BottomNavigationBarType.fixed,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'Status',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.fitness_center),
                      label: 'Daily',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.assignment),
                      label: 'Quests',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.shield),
                      label: 'Hunter',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.flag),
                      label: 'Raids',
                    ),
                  ],
                ),
              ),
            ),
            // Level up overlay
            if (game.showLevelUp)
              LevelUpOverlay(
                newLevel: game.levelUpNewLevel,
                pointsGained: game.levelUpPointsGained,
                onDismiss: () => game.dismissLevelUp(),
              ),
          ],
        );
      },
    );
  }
}
