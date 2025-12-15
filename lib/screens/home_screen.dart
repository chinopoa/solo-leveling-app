import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/solo_leveling_theme.dart';
import '../widgets/level_up_overlay.dart';
import 'status_screen.dart';
import 'daily_quest_screen.dart';
import 'quests_screen.dart';
import 'shop_screen.dart';
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
    ShopScreen(),
    SettingsScreen(),
  ];

  final List<String> _titles = const [
    'STATUS',
    'DAILY QUEST',
    'QUESTS',
    'SHOP',
    'SETTINGS',
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
                  // Gold display in app bar
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.amber.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${game.player?.gold ?? 0}',
                          style: const TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
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
                      icon: Icon(Icons.store),
                      label: 'Shop',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.settings),
                      label: 'Settings',
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
