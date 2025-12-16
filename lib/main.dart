import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'theme/solo_leveling_theme.dart';
import 'providers/game_provider.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'models/models.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: SoloLevelingTheme.backgroundDark,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  _registerAdapters();

  runApp(const SoloLevelingApp());
}

void _registerAdapters() {
  // 1. Player & Stats
  Hive.registerAdapter(PlayerAdapter());
  Hive.registerAdapter(PlayerStatsAdapter());
  
  // 2. Quests & Daily
  Hive.registerAdapter(QuestAdapter());
  Hive.registerAdapter(DailyQuestConfigAdapter());
  Hive.registerAdapter(DailyQuestProgressAdapter());

  // 3. Shop & Inventory
  Hive.registerAdapter(ShopItemAdapter());
  Hive.registerAdapter(InventoryAdapter());

  // 4. Nutrition Tracking
  Hive.registerAdapter(NutritionEntryAdapter());
  Hive.registerAdapter(NutritionGoalsAdapter());
  Hive.registerAdapter(MealTypeAdapter());

  // 5. Saved Meals
  Hive.registerAdapter(SavedMealAdapter());
  Hive.registerAdapter(SavedMealItemAdapter());
}

class SoloLevelingApp extends StatelessWidget {
  const SoloLevelingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider()..init(),
      child: MaterialApp(
        title: 'Solo Leveling',
        debugShowCheckedModeBanner: false,
        theme: SoloLevelingTheme.darkTheme,
        home: const AppWrapper(),
      ),
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // Wait for provider to initialize
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: SoloLevelingTheme.backgroundDark,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: SoloLevelingTheme.primaryCyan,
                    width: 2,
                  ),
                  boxShadow: SoloLevelingTheme.glowEffect(
                    SoloLevelingTheme.primaryCyan,
                  ),
                ),
                child: const Text(
                  'SYSTEM',
                  style: TextStyle(
                    color: SoloLevelingTheme.primaryCyan,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: SoloLevelingTheme.primaryCyan,
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'INITIALIZING...',
                style: TextStyle(
                  color: SoloLevelingTheme.textMuted,
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Consumer<GameProvider>(
      builder: (context, game, child) {
        // Show onboarding if no player exists
        if (game.player == null) {
          return OnboardingScreen(
            onComplete: () => setState(() {}),
          );
        }

        return const HomeScreen();
      },
    );
  }
}
