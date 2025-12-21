import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import '../services/notification_service.dart';

class GameProvider extends ChangeNotifier {
  late Box<Player> _playerBox;
  late Box<Quest> _questBox;
  late Box<Dungeon> _dungeonBox;
  late Box<Shadow> _shadowBox;
  late Box<ShopItem> _shopItemBox;
  late Box<Inventory> _inventoryBox;
  late Box<DailyQuestConfig> _dailyConfigBox;
  late Box<DailyQuestProgress> _dailyProgressBox;
  late Box<NutritionEntry> _nutritionEntryBox;
  late Box<NutritionGoals> _nutritionGoalsBox;
  late Box<SavedMeal> _savedMealBox;

  // New self-improvement boxes
  late Box<Skill> _skillBox;
  late Box<PersonalRecord> _prBox;
  late Box<Goal> _goalBox;
  late Box<Habit> _habitBox;
  late Box<ActivityLog> _activityLogBox;

  // Workout/Training boxes
  late Box<Exercise> _exerciseBox;
  late Box<WorkoutSession> _workoutSessionBox;

  Player? _player;
  List<Quest> _quests = [];
  List<Quest> _dailyQuests = [];
  List<Dungeon> _dungeons = [];
  List<Shadow> _shadows = [];
  List<ShopItem> _shopItems = [];
  Inventory? _inventory;
  List<DailyQuestConfig> _dailyConfigs = [];
  DailyQuestProgress? _todayProgress;

  // Nutrition tracking
  List<NutritionEntry> _nutritionEntries = [];
  NutritionGoals? _nutritionGoals;

  // Saved meals
  List<SavedMeal> _savedMeals = [];

  // Hunter Skills & Self-Improvement
  List<Skill> _skills = [];
  List<PersonalRecord> _personalRecords = [];
  List<Goal> _goals = [];
  List<Habit> _habits = [];
  List<ActivityLog> _activityLogs = [];

  // Workout/Training
  List<Exercise> _exercises = [];
  List<WorkoutSession> _workoutSessions = [];
  WorkoutSession? _activeWorkout;

  // Level up state
  bool _showLevelUp = false;
  int _levelUpNewLevel = 0;
  int _levelUpPointsGained = 0;

  // Auto-backup
  bool _autoBackupEnabled = false;
  DateTime? _lastAutoBackup;
  static const _autoBackupKey = 'auto_backup_enabled';

  // Getters
  Player? get player => _player;
  List<Quest> get quests => _quests;
  List<Quest> get activeQuests =>
      _quests.where((q) => q.isAvailable && q.type != QuestType.daily).toList();
  List<Quest> get scheduledQuests =>
      _quests.where((q) => q.isActive && q.isScheduledForFuture && q.type != QuestType.daily).toList();
  List<Quest> get completedQuests => _quests.where((q) => q.isCompleted).toList();
  List<Quest> get dailyQuests => _dailyQuests;
  List<Dungeon> get dungeons => _dungeons;
  List<Dungeon> get activeDungeons =>
      _dungeons.where((d) => !d.isCleared).toList();
  List<Shadow> get shadows => _shadows;
  List<ShopItem> get shopItems => _shopItems;
  Inventory? get inventory => _inventory;
  List<DailyQuestConfig> get dailyConfigs => _dailyConfigs;
  DailyQuestProgress? get todayProgress => _todayProgress;

  // Nutrition getters
  NutritionGoals get nutritionGoals => _nutritionGoals ?? NutritionGoals.defaults();
  List<NutritionEntry> get allNutritionEntries => _nutritionEntries;

  List<NutritionEntry> get todayNutritionEntries {
    final todayKey = NutritionEntry.getTodayKey();
    return _nutritionEntries.where((e) => e.date == todayKey).toList();
  }

  // Today's nutrition totals
  double get todayCalories => todayNutritionEntries.fold(0, (sum, e) => sum + e.totalCalories);
  double get todayProtein => todayNutritionEntries.fold(0, (sum, e) => sum + e.totalProtein);
  double get todayCarbs => todayNutritionEntries.fold(0, (sum, e) => sum + e.totalCarbs);
  double get todayFat => todayNutritionEntries.fold(0, (sum, e) => sum + e.totalFat);
  double get todayFiber => todayNutritionEntries.fold(0, (sum, e) => sum + e.totalFiber);
  double get todaySugar => todayNutritionEntries.fold(0, (sum, e) => sum + e.totalSugar);
  double get todaySodium => todayNutritionEntries.fold(0, (sum, e) => sum + e.totalSodium);

  // Check if nutrition goal is met (for daily quest)
  bool get isNutritionGoalMet {
    if (!nutritionGoals.isEnabled) return true;
    return nutritionGoals.isCalorieGoalMet(todayCalories);
  }

  // Get entries by meal type
  List<NutritionEntry> getEntriesByMealType(MealType mealType) {
    return todayNutritionEntries.where((e) => e.mealType == mealType).toList();
  }

  // Get entries for a specific date
  List<NutritionEntry> getEntriesForDate(DateTime date) {
    final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _nutritionEntries.where((e) => e.date == dateKey).toList();
  }

  // Get entries by meal type for a specific date
  List<NutritionEntry> getEntriesByMealTypeForDate(MealType mealType, DateTime date) {
    return getEntriesForDate(date).where((e) => e.mealType == mealType).toList();
  }

  // Get nutrition totals for a specific date
  Map<String, double> getNutritionForDate(DateTime date) {
    final entries = getEntriesForDate(date);
    return {
      'calories': entries.fold(0.0, (sum, e) => sum + e.totalCalories),
      'protein': entries.fold(0.0, (sum, e) => sum + e.totalProtein),
      'carbs': entries.fold(0.0, (sum, e) => sum + e.totalCarbs),
      'fat': entries.fold(0.0, (sum, e) => sum + e.totalFat),
      'fiber': entries.fold(0.0, (sum, e) => sum + e.totalFiber),
      'sugar': entries.fold(0.0, (sum, e) => sum + e.totalSugar),
      'sodium': entries.fold(0.0, (sum, e) => sum + e.totalSodium),
    };
  }

  bool get showLevelUp => _showLevelUp;
  int get levelUpNewLevel => _levelUpNewLevel;
  int get levelUpPointsGained => _levelUpPointsGained;
  bool get autoBackupEnabled => _autoBackupEnabled;
  List<SavedMeal> get savedMeals => _savedMeals;

  // Hunter Skills & Self-Improvement getters
  List<Skill> get skills => _skills;
  List<PersonalRecord> get personalRecords => _personalRecords;
  List<Goal> get goals => _goals;
  List<Goal> get activeGoals => _goals.where((g) => g.isActive).toList();
  List<Goal> get completedGoals => _goals.where((g) => g.isCompleted).toList();
  List<Habit> get habits => _habits;
  List<Habit> get activeHabits => _habits.where((h) => h.isEnabled).toList();
  List<Habit> get todayHabits => _habits.where((h) => h.isEnabled && h.isDueToday).toList();
  List<ActivityLog> get activityLogs => _activityLogs;

  // Workout/Training getters
  List<Exercise> get exercises => _exercises;
  List<WorkoutSession> get workoutSessions => _workoutSessions;
  WorkoutSession? get activeWorkout => _activeWorkout;
  bool get hasActiveWorkout => _activeWorkout != null;

  List<Exercise> getExercisesByMuscleGroup(String muscleGroup) {
    return _exercises.where((e) => e.muscleGroup == muscleGroup).toList();
  }

  List<Exercise> getExercisesByArmSubGroup(String subGroup) {
    return _exercises.where((e) => e.armSubGroup == subGroup).toList();
  }

  Exercise? getExerciseById(String id) {
    try {
      return _exercises.firstWhere((e) => e.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get activity-based stat bonuses
  Map<String, int> get activityStatBonuses {
    final bonuses = <String, int>{
      'STR': 0,
      'AGI': 0,
      'VIT': 0,
      'INT': 0,
      'SEN': 0,
    };
    for (final log in _activityLogs) {
      if (log.statAffected != null) {
        bonuses[log.statAffected!] = (bonuses[log.statAffected!] ?? 0) + log.statPoints;
      }
    }
    return bonuses;
  }

  // Get effective stat (base + activity bonus)
  int getEffectiveStat(String stat) {
    final base = _player?.stats.toMap()[stat] ?? 10;
    final activityBonus = (activityStatBonuses[stat] ?? 0) ~/ 100; // Every 100 points = +1
    return base + activityBonus;
  }

  // Time until daily reset
  Duration get timeUntilReset {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    return midnight.difference(now);
  }

  String get formattedTimeUntilReset {
    final duration = timeUntilReset;
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Initialize Hive boxes
  Future<void> init() async {
    _playerBox = await Hive.openBox<Player>('players');
    _questBox = await Hive.openBox<Quest>('quests');
    _dungeonBox = await Hive.openBox<Dungeon>('dungeons');
    _shadowBox = await Hive.openBox<Shadow>('shadows');
    _shopItemBox = await Hive.openBox<ShopItem>('shopItems');
    _inventoryBox = await Hive.openBox<Inventory>('inventory');
    _dailyConfigBox = await Hive.openBox<DailyQuestConfig>('dailyConfigs');
    _dailyProgressBox = await Hive.openBox<DailyQuestProgress>('dailyProgress');
    _nutritionEntryBox = await Hive.openBox<NutritionEntry>('nutritionEntries');
    _nutritionGoalsBox = await Hive.openBox<NutritionGoals>('nutritionGoals');
    _savedMealBox = await Hive.openBox<SavedMeal>('savedMeals');

    // Open self-improvement boxes
    _skillBox = await Hive.openBox<Skill>('skills');
    _prBox = await Hive.openBox<PersonalRecord>('personalRecords');
    _goalBox = await Hive.openBox<Goal>('goals');
    _habitBox = await Hive.openBox<Habit>('habits');
    _activityLogBox = await Hive.openBox<ActivityLog>('activityLogs');

    // Open workout/training boxes
    _exerciseBox = await Hive.openBox<Exercise>('exercises');
    _workoutSessionBox = await Hive.openBox<WorkoutSession>('workoutSessions');

    // Load auto-backup setting
    final prefs = await SharedPreferences.getInstance();
    _autoBackupEnabled = prefs.getBool(_autoBackupKey) ?? false;

    await _loadData();
  }

  Future<void> _loadData() async {
    // Load or create player
    if (_playerBox.isEmpty) {
      _player = null; // Will trigger onboarding
    } else {
      _player = _playerBox.getAt(0);
    }

    // Load quests
    _quests = _questBox.values.toList();

    // Load dungeons
    _dungeons = _dungeonBox.values.toList();

    // Load shadows
    _shadows = _shadowBox.values.toList();

    // Load shop items (defaults if empty)
    if (_shopItemBox.isEmpty) {
      for (final item in ShopItem.getDefaultItems()) {
        await _shopItemBox.put(item.id, item);
      }
    }
    _shopItems = _shopItemBox.values.toList();

    // Load or create inventory
    if (_inventoryBox.isEmpty) {
      _inventory = Inventory();
      await _inventoryBox.add(_inventory!);
    } else {
      _inventory = _inventoryBox.getAt(0);
    }

    // Load daily quest configs (defaults if empty)
    if (_dailyConfigBox.isEmpty) {
      for (final config in DailyQuestConfig.getDefaults()) {
        await _dailyConfigBox.put(config.id, config);
      }
    }
    _dailyConfigs = _dailyConfigBox.values.toList();

    // Load or create today's progress
    await _loadTodayProgress();

    // Load nutrition data
    await _loadNutritionData();

    // Load saved meals
    _savedMeals = _savedMealBox.values.toList();

    // Load self-improvement data
    await _loadSelfImprovementData();

    // Load workout/training data
    await _loadWorkoutData();

    notifyListeners();
  }

  Future<void> _loadSelfImprovementData() async {
    // Load or create default skills
    if (_skillBox.isEmpty) {
      for (final skill in Skill.createDefaultSkills()) {
        await _skillBox.put(skill.id, skill);
      }
    }
    _skills = _skillBox.values.toList();

    // Load or create default personal records
    if (_prBox.isEmpty) {
      for (final pr in PersonalRecord.createDefaultRecords()) {
        await _prBox.put(pr.id, pr);
      }
    }
    _personalRecords = _prBox.values.toList();

    // Load goals
    _goals = _goalBox.values.toList();

    // Load habits
    _habits = _habitBox.values.toList();

    // Load activity logs
    _activityLogs = _activityLogBox.values.toList();
  }

  Future<void> _loadWorkoutData() async {
    // Load or create default exercises
    if (_exerciseBox.isEmpty) {
      for (final exercise in Exercise.createDefaultExercises()) {
        await _exerciseBox.put(exercise.id, exercise);
      }
    }
    _exercises = _exerciseBox.values.toList();

    // Load workout sessions
    _workoutSessions = _workoutSessionBox.values.toList();

    // Check for active workout (not ended)
    try {
      _activeWorkout = _workoutSessions.firstWhere((w) => w.isActive);
    } catch (e) {
      _activeWorkout = null;
    }
  }

  Future<void> _loadNutritionData() async {
    // Load all nutrition entries
    _nutritionEntries = _nutritionEntryBox.values.toList();

    // Load or create nutrition goals
    if (_nutritionGoalsBox.isEmpty) {
      _nutritionGoals = NutritionGoals.defaults();
      await _nutritionGoalsBox.put('goals', _nutritionGoals!);
    } else {
      _nutritionGoals = _nutritionGoalsBox.get('goals');
    }
  }

  Future<void> _loadTodayProgress() async {
    final todayKey = DailyQuestProgress.getTodayKey();
    _todayProgress = _dailyProgressBox.get(todayKey);

    if (_todayProgress == null) {
      _todayProgress = DailyQuestProgress(date: todayKey);
      await _dailyProgressBox.put(todayKey, _todayProgress!);

      // Generate daily quests for today
      _dailyQuests = [];
      for (final config in _dailyConfigs.where((c) => c.isEnabled)) {
        final quest = config.toQuest();
        await _questBox.put(quest.id, quest);
        _dailyQuests.add(quest);
      }
    } else {
      // Load existing daily quests
      _dailyQuests = _quests
          .where((q) =>
              q.type == QuestType.daily &&
              q.createdAt.day == DateTime.now().day &&
              q.createdAt.month == DateTime.now().month &&
              q.createdAt.year == DateTime.now().year)
          .toList();
    }
  }

  // Auto-backup methods
  Future<void> setAutoBackup(bool enabled) async {
    _autoBackupEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoBackupKey, enabled);
    notifyListeners();

    // Perform immediate backup when enabled
    if (enabled) {
      await _performAutoBackup();
    }
  }

  Future<void> _performAutoBackup() async {
    if (!_autoBackupEnabled) return;

    // Throttle backups to at most once per minute
    if (_lastAutoBackup != null &&
        DateTime.now().difference(_lastAutoBackup!) < const Duration(minutes: 1)) {
      return;
    }

    try {
      final jsonData = await exportData();
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/solo_leveling_auto_backup.json');
      await file.writeAsString(jsonData);
      _lastAutoBackup = DateTime.now();
      debugPrint('Auto-backup saved');
    } catch (e) {
      debugPrint('Auto-backup failed: $e');
    }
  }

  /// Get the path to the auto-backup file (for restore)
  Future<String?> getAutoBackupPath() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/solo_leveling_auto_backup.json');
    if (await file.exists()) {
      return file.path;
    }
    return null;
  }

  /// Check when the last auto-backup was made
  Future<DateTime?> getLastAutoBackupTime() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/solo_leveling_auto_backup.json');
    if (await file.exists()) {
      return await file.lastModified();
    }
    return null;
  }

  // Trigger auto-backup after data changes
  void _triggerAutoBackup() {
    if (_autoBackupEnabled) {
      _performAutoBackup();
    }
  }

  // Create new player (onboarding)
  Future<void> createPlayer(String name) async {
    _player = Player(name: name);
    await _playerBox.add(_player!);
    await _loadTodayProgress();
    notifyListeners();
    _triggerAutoBackup();
  }

  // Add XP and handle level up
  void addXp(int amount) {
    if (_player == null) return;

    final result = _player!.addXp(amount);
    if (result.didLevelUp) {
      _showLevelUp = true;
      _levelUpNewLevel = result.newLevel;
      _levelUpPointsGained = result.pointsGained;
    }
    notifyListeners();
  }

  void dismissLevelUp() {
    _showLevelUp = false;
    notifyListeners();
  }

  // Allocate stat point
  void allocateStat(String stat) {
    if (_player == null) return;
    _player!.stats.allocatePoint(stat);
    notifyListeners();
  }

  // Update profile image
  Future<void> updateProfileImage(String imagePath) async {
    if (_player == null) return;

    // Copy image to app documents directory for persistence
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final newPath = '${directory.path}/$fileName';

    // Copy the file
    final originalFile = File(imagePath);
    await originalFile.copy(newPath);

    // Delete old profile image if exists
    if (_player!.profileImagePath != null) {
      try {
        final oldFile = File(_player!.profileImagePath!);
        if (await oldFile.exists()) {
          await oldFile.delete();
        }
      } catch (e) {
        debugPrint('Could not delete old profile image: $e');
      }
    }

    // Update player
    _player!.profileImagePath = newPath;
    await _player!.save();
    notifyListeners();
    _triggerAutoBackup();
  }

  // Update player name
  Future<void> updatePlayerName(String newName) async {
    if (_player == null || newName.trim().isEmpty) return;
    _player!.name = newName.trim();
    await _player!.save();
    notifyListeners();
    _triggerAutoBackup();
  }

  // Quest management
  Future<void> addQuest(Quest quest) async {
    await _questBox.put(quest.id, quest);
    _quests.add(quest);
    notifyListeners();

    // Schedule notification if quest has a scheduled date
    if (quest.scheduledDate != null) {
      NotificationService().scheduleQuestNotification(quest);
    }
  }

  Future<void> completeQuest(Quest quest) async {
    quest.complete();
    addXp(quest.xpReward);
    _player?.addGold(quest.goldReward);

    // Log activity and add to skills
    if (quest.statBonus != null && quest.statBonusAmount > 0) {
      // Log activity
      await logActivity(
        activityType: ActivityLog.getActivityForStat(quest.statBonus!)?.name ?? 'quest',
        statAffected: quest.statBonus,
        points: quest.statBonusAmount * 10, // Scale stat bonus to activity points
        sourceId: quest.id,
        sourceType: 'quest',
        xpEarned: quest.xpReward,
      );

      // Add XP to related skill
      final skill = getSkillByStat(quest.statBonus!);
      if (skill != null) {
        await addSkillXp(skill.id, quest.statBonusAmount * 5);
      }
    }

    // Check for daily streak PR
    if (_player != null) {
      await checkAndUpdatePR('Longest Daily Streak', _player!.dailyStreak.toDouble());
      await checkAndUpdatePR('Highest Level', _player!.level.toDouble());
    }

    notifyListeners();
    _triggerAutoBackup();
  }

  Future<void> incrementQuestProgress(Quest quest, [int amount = 1]) async {
    quest.incrementProgress(amount);
    if (quest.isCompleted) {
      addXp(quest.xpReward);
      _player?.addGold(quest.goldReward);
    }
    notifyListeners();
  }

  Future<void> deleteQuest(Quest quest) async {
    // Cancel notification if it was scheduled
    if (quest.scheduledDate != null) {
      NotificationService().cancelQuestNotification(quest);
    }

    await _questBox.delete(quest.id);
    _quests.removeWhere((q) => q.id == quest.id);
    notifyListeners();
    _triggerAutoBackup();
  }

  // Daily quest management
  Future<void> updateDailyProgress(String questId, int count) async {
    if (_todayProgress == null) return;

    _todayProgress!.updateProgress(questId, count);

    // Update the corresponding quest
    final quest = _dailyQuests.firstWhere(
      (q) => q.id == questId || q.title.toLowerCase().contains(questId),
      orElse: () => _dailyQuests.first,
    );

    final config = _dailyConfigs.firstWhere(
      (c) => c.id == questId,
      orElse: () => _dailyConfigs.first,
    );

    quest.currentCount = count;
    if (count >= config.targetCount && !quest.isCompleted) {
      await completeQuest(quest);
    }

    // Check if all dailies are complete
    if (_todayProgress!.checkAllCompleted(_dailyConfigs)) {
      // Bonus XP for completing all dailies
      addXp(100);
      _player?.dailyStreak++;
      _player?.save();
    }

    notifyListeners();
    _triggerAutoBackup();
  }

  // Dungeon management
  Future<Dungeon> createDungeon({
    required String name,
    required String description,
    required DungeonRank rank,
    required List<String> subTasks,
    required String bossTask,
  }) async {
    final dungeon = Dungeon.createProject(
      name: name,
      description: description,
      rank: rank,
      subTasks: subTasks,
      bossTask: bossTask,
    );

    // Create sub-quests
    for (final task in subTasks) {
      final quest = Quest.createWithDifficulty(
        title: task,
        description: 'Part of: $name',
        difficulty: QuestDifficulty.normal,
        type: QuestType.dungeon,
        parentDungeonId: dungeon.id,
      );
      await _questBox.put(quest.id, quest);
      dungeon.addQuest(quest);
      _quests.add(quest);
    }

    // Create boss quest
    final bossQuest = Quest.createWithDifficulty(
      title: bossTask,
      description: 'BOSS: Final task for $name',
      difficulty: QuestDifficulty.boss,
      type: QuestType.dungeon,
      parentDungeonId: dungeon.id,
    );
    await _questBox.put(bossQuest.id, bossQuest);
    dungeon.setBoss(bossQuest);
    _quests.add(bossQuest);

    await _dungeonBox.put(dungeon.id, dungeon);
    _dungeons.add(dungeon);

    notifyListeners();
    return dungeon;
  }

  Future<void> clearDungeon(Dungeon dungeon) async {
    dungeon.clear();
    addXp(dungeon.totalXpReward);
    _player?.addGold(dungeon.totalGoldReward);
    notifyListeners();
  }

  // Shadow extraction (Arise!)
  Future<Shadow> extractShadow({
    required Dungeon dungeon,
    required String shadowName,
    required String type,
  }) async {
    final shadow = Shadow.fromDungeon(
      dungeonName: dungeon.name,
      dungeonRank: dungeon.rank,
      shadowName: shadowName,
      type: type,
    );

    await _shadowBox.put(shadow.id, shadow);
    _shadows.add(shadow);
    notifyListeners();

    return shadow;
  }

  // Shop
  Future<bool> purchaseItem(ShopItem item) async {
    if (_player == null || !_player!.spendGold(item.price)) {
      return false;
    }

    _inventory?.addItem(item.id);
    notifyListeners();
    return true;
  }

  Future<bool> useItem(String itemId) async {
    if (_inventory?.useItem(itemId) ?? false) {
      final item = _shopItems.firstWhere((i) => i.id == itemId);

      switch (item.effect) {
        case 'xp_boost':
          // TODO: Implement XP boost timer
          break;
        case 'clear_fatigue':
          _player?.fatigue = 0;
          _player?.save();
          break;
        case 'skip_penalty':
          // Mark as having skip available
          break;
        case 'reset_quest':
          // TODO: Let user select quest to reset
          break;
      }

      notifyListeners();
      return true;
    }
    return false;
  }

  // Add custom reward to shop
  Future<void> addCustomReward({
    required String name,
    required String description,
    required int price,
    String? emoji,
  }) async {
    final item = ShopItem(
      name: name,
      description: description,
      price: price,
      category: 'reward',
      isUserDefined: true,
      iconEmoji: emoji ?? '🎁',
    );

    await _shopItemBox.put(item.id, item);
    _shopItems.add(item);
    notifyListeners();
  }

  // Update daily quest config
  Future<void> updateDailyConfig(DailyQuestConfig config) async {
    await _dailyConfigBox.put(config.id, config);
    final index = _dailyConfigs.indexWhere((c) => c.id == config.id);
    if (index >= 0) {
      _dailyConfigs[index] = config;
    } else {
      _dailyConfigs.add(config);
    }
    notifyListeners();
  }

  // ==================== NUTRITION TRACKING ====================

  // Add a nutrition entry
  Future<void> addNutritionEntry(NutritionEntry entry) async {
    await _nutritionEntryBox.put(entry.id, entry);
    _nutritionEntries.add(entry);

    // Check if nutrition goal was just met
    if (nutritionGoals.isEnabled && isNutritionGoalMet) {
      // Award VIT stat bonus (similar to completing a daily quest)
      // The actual stat increase is handled through the daily quest system
    }

    notifyListeners();
    _triggerAutoBackup();
  }

  // Update a nutrition entry
  Future<void> updateNutritionEntry(NutritionEntry entry) async {
    await _nutritionEntryBox.put(entry.id, entry);
    final index = _nutritionEntries.indexWhere((e) => e.id == entry.id);
    if (index >= 0) {
      _nutritionEntries[index] = entry;
    }
    notifyListeners();
    _triggerAutoBackup();
  }

  // Delete a nutrition entry
  Future<void> deleteNutritionEntry(String entryId) async {
    await _nutritionEntryBox.delete(entryId);
    _nutritionEntries.removeWhere((e) => e.id == entryId);
    notifyListeners();
    _triggerAutoBackup();
  }

  // Update nutrition goals
  Future<void> updateNutritionGoals(NutritionGoals goals) async {
    _nutritionGoals = goals;
    await _nutritionGoalsBox.put('goals', goals);
    notifyListeners();
    _triggerAutoBackup();
  }

  // Clear old nutrition entries (keep last 30 days)
  Future<void> cleanupOldNutritionEntries() async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    final oldEntries = _nutritionEntries.where((e) {
      final parts = e.date.split('-');
      if (parts.length != 3) return false;
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      return date.isBefore(thirtyDaysAgo);
    }).toList();

    for (final entry in oldEntries) {
      await _nutritionEntryBox.delete(entry.id);
      _nutritionEntries.remove(entry);
    }
    notifyListeners();
  }

  // ==================== SAVED MEALS ====================

  // Add a new saved meal
  Future<void> addSavedMeal(SavedMeal meal) async {
    await _savedMealBox.put(meal.id, meal);
    _savedMeals.add(meal);
    notifyListeners();
    _triggerAutoBackup();
  }

  // Delete a saved meal
  Future<void> deleteSavedMeal(String mealId) async {
    await _savedMealBox.delete(mealId);
    _savedMeals.removeWhere((m) => m.id == mealId);
    notifyListeners();
    _triggerAutoBackup();
  }

  // Add entries from a saved meal to the log
  Future<void> addEntriesFromSavedMeal(SavedMeal meal, MealType mealType, {DateTime? date}) async {
    final dateKey = date != null ? NutritionEntry.getDateKey(date) : NutritionEntry.getTodayKey();
    for (final item in meal.items) {
      final entry = NutritionEntry(
        id: '${DateTime.now().millisecondsSinceEpoch}_${item.name.hashCode}',
        date: dateKey,
        productName: item.name,
        barcode: item.barcode,
        servingSize: item.servingSize,
        servingsConsumed: item.servings,
        calories: item.calories,
        protein: item.protein,
        carbs: item.carbs,
        fat: item.fat,
        fiber: item.fiber,
        sugar: item.sugar,
        sodium: item.sodium,
        mealType: mealType,
      );
      await addNutritionEntry(entry);
    }
  }

  // Create a saved meal from existing nutrition entries
  SavedMeal createSavedMealFromEntries(String name, List<NutritionEntry> entries) {
    final items = entries.map((e) => SavedMealItem(
      name: e.productName,
      servingSize: e.servingSize,
      servings: e.servingsConsumed,
      calories: e.calories,
      protein: e.protein,
      carbs: e.carbs,
      fat: e.fat,
      fiber: e.fiber,
      sugar: e.sugar,
      sodium: e.sodium,
      barcode: e.barcode,
    )).toList();

    return SavedMeal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      items: items,
    );
  }

  // ==================== HUNTER SKILLS ====================

  /// Add XP to a skill
  Future<bool> addSkillXp(String skillId, int xp) async {
    final skill = _skills.firstWhere(
      (s) => s.id == skillId,
      orElse: () => throw Exception('Skill not found'),
    );

    final didRankUp = skill.addXp(xp);
    notifyListeners();
    _triggerAutoBackup();
    return didRankUp;
  }

  /// Get skill by related stat
  Skill? getSkillByStat(String stat) {
    try {
      return _skills.firstWhere((s) => s.relatedStat == stat);
    } catch (e) {
      return null;
    }
  }

  // ==================== PERSONAL RECORDS ====================

  /// Check and update a personal record
  Future<bool> checkAndUpdatePR(String prName, double value) async {
    try {
      final pr = _personalRecords.firstWhere((p) => p.name == prName);
      if (pr.updateRecord(value)) {
        notifyListeners();
        _triggerAutoBackup();
        return true;
      }
    } catch (e) {
      debugPrint('PR not found: $prName');
    }
    return false;
  }

  /// Get personal records by category
  List<PersonalRecord> getPRsByCategory(String category) {
    return _personalRecords.where((p) => p.category == category).toList();
  }

  // ==================== GOALS (RAIDS) ====================

  /// Add a new goal
  Future<void> addGoal(Goal goal) async {
    await _goalBox.put(goal.id, goal);
    _goals.add(goal);
    notifyListeners();
    _triggerAutoBackup();
  }

  /// Update goal progress
  Future<List<String>> updateGoalProgress(String goalId, double progress) async {
    final goal = _goals.firstWhere((g) => g.id == goalId);
    final completedMilestones = goal.updateProgress(progress);

    // Award XP for completed milestones
    for (final milestone in goal.milestones.where((m) => m.isCompleted)) {
      // Only award XP if just completed (check by looking at completedMilestones)
      if (completedMilestones.contains(milestone.title)) {
        addXp(milestone.xpReward);
      }
    }

    // Award XP if goal was just completed
    if (goal.isCompleted && completedMilestones.isNotEmpty) {
      addXp(goal.xpReward);
    }

    notifyListeners();
    _triggerAutoBackup();
    return completedMilestones;
  }

  /// Delete a goal
  Future<void> deleteGoal(String goalId) async {
    await _goalBox.delete(goalId);
    _goals.removeWhere((g) => g.id == goalId);
    notifyListeners();
    _triggerAutoBackup();
  }

  // ==================== HABITS (TRAINING REGIMEN) ====================

  /// Add a new habit
  Future<void> addHabit(Habit habit) async {
    await _habitBox.put(habit.id, habit);
    _habits.add(habit);
    notifyListeners();
    _triggerAutoBackup();
  }

  /// Complete a habit for today
  Future<void> completeHabit(String habitId) async {
    final habit = _habits.firstWhere((h) => h.id == habitId);

    if (!habit.isCompletedToday) {
      habit.completeToday();

      // Award XP
      addXp(habit.xpPerCompletion);

      // Log activity
      await logActivity(
        activityType: habit.relatedStat != null
            ? ActivityLog.getActivityForStat(habit.relatedStat!)?.name ?? 'habit'
            : 'habit',
        statAffected: habit.relatedStat,
        points: habit.relatedStat != null ? 5 : 0,
        sourceId: habit.id,
        sourceType: 'habit',
      );

      // Add XP to related skill
      if (habit.relatedSkillId != null) {
        await addSkillXp(habit.relatedSkillId!, 10);
      } else if (habit.relatedStat != null) {
        final skill = getSkillByStat(habit.relatedStat!);
        if (skill != null) {
          await addSkillXp(skill.id, 10);
        }
      }

      // Check for streak PR
      await checkAndUpdatePR('Longest Training Streak', habit.currentStreak.toDouble());

      notifyListeners();
      _triggerAutoBackup();
    }
  }

  /// Uncomplete a habit for today
  Future<void> uncompleteHabit(String habitId) async {
    final habit = _habits.firstWhere((h) => h.id == habitId);
    habit.uncompleteForDate(DateTime.now());
    notifyListeners();
    _triggerAutoBackup();
  }

  /// Update a habit
  Future<void> updateHabit(Habit habit) async {
    await _habitBox.put(habit.id, habit);
    final index = _habits.indexWhere((h) => h.id == habit.id);
    if (index >= 0) {
      _habits[index] = habit;
    }
    notifyListeners();
    _triggerAutoBackup();
  }

  /// Delete a habit
  Future<void> deleteHabit(String habitId) async {
    await _habitBox.delete(habitId);
    _habits.removeWhere((h) => h.id == habitId);
    notifyListeners();
    _triggerAutoBackup();
  }

  // ==================== ACTIVITY LOGGING ====================

  /// Log an activity
  Future<void> logActivity({
    required String activityType,
    String? statAffected,
    int points = 0,
    String? sourceId,
    required String sourceType,
    String? note,
    int xpEarned = 0,
    String? skillId,
  }) async {
    final log = ActivityLog(
      activityType: activityType,
      statAffected: statAffected,
      statPoints: points,
      sourceId: sourceId,
      sourceType: sourceType,
      note: note,
      xpEarned: xpEarned,
      skillId: skillId,
    );

    await _activityLogBox.put(log.id, log);
    _activityLogs.add(log);
    notifyListeners();
  }

  // ==================== WORKOUT/TRAINING SYSTEM ====================

  /// Add a new exercise to the Skill Book
  Future<void> addExercise(Exercise exercise) async {
    await _exerciseBox.put(exercise.id, exercise);
    _exercises.add(exercise);
    notifyListeners();
    _triggerAutoBackup();
  }

  /// Update an exercise
  Future<void> updateExercise(Exercise exercise) async {
    await _exerciseBox.put(exercise.id, exercise);
    final index = _exercises.indexWhere((e) => e.id == exercise.id);
    if (index >= 0) {
      _exercises[index] = exercise;
    }
    notifyListeners();
    _triggerAutoBackup();
  }

  /// Delete an exercise
  Future<void> deleteExercise(String exerciseId) async {
    await _exerciseBox.delete(exerciseId);
    _exercises.removeWhere((e) => e.id == exerciseId);
    notifyListeners();
    _triggerAutoBackup();
  }

  /// Start a new workout session
  Future<WorkoutSession> startWorkout({String? name}) async {
    final session = WorkoutSession(name: name);
    await _workoutSessionBox.put(session.id, session);
    _workoutSessions.add(session);
    _activeWorkout = session;
    notifyListeners();
    return session;
  }

  /// Add a set to the active workout
  Future<void> addSetToWorkout({
    required String exerciseId,
    required double weight,
    required int reps,
    bool isPR = false,
    String? note,
  }) async {
    if (_activeWorkout == null) return;

    final exercise = getExerciseById(exerciseId);
    if (exercise == null) return;

    // Determine set number for this exercise
    final existingSets = _activeWorkout!.getSetsForExercise(exerciseId);
    final setNumber = existingSets.length + 1;

    final set = WorkoutSet(
      exerciseId: exerciseId,
      exerciseName: exercise.name,
      weight: weight,
      reps: reps,
      isPR: isPR,
      note: note,
      setNumber: setNumber,
    );

    _activeWorkout!.addSet(set);

    // Add muscle group if not already tracked
    if (!_activeWorkout!.muscleGroupsWorked.contains(exercise.muscleGroup)) {
      _activeWorkout!.muscleGroupsWorked.add(exercise.muscleGroup);
    }

    // Update exercise last performance (Ghost data)
    exercise.updateLastPerformance(weight, reps);

    // If marked as PR, update exercise PR
    if (isPR && exercise.isNewPR(weight, reps)) {
      exercise.updatePR(weight, reps, note: note);

      // Award XP for setting a PR
      addXp(25);

      // Log activity
      await logActivity(
        activityType: 'strength',
        statAffected: 'STR',
        points: 10,
        sourceId: exerciseId,
        sourceType: 'workout_pr',
        note: 'New PR: ${weight}kg × $reps on ${exercise.name}',
        xpEarned: 25,
      );
    }

    notifyListeners();
    _triggerAutoBackup();
  }

  /// Toggle PR status on a set
  Future<void> toggleSetPR(String setId, bool isPR) async {
    if (_activeWorkout == null) return;

    final setIndex = _activeWorkout!.sets.indexWhere((s) => s.id == setId);
    if (setIndex < 0) return;

    final set = _activeWorkout!.sets[setIndex];
    final exercise = getExerciseById(set.exerciseId);

    if (isPR && !set.isPR) {
      // Marking as PR
      set.isPR = true;
      _activeWorkout!.totalPRs++;

      if (exercise != null && exercise.isNewPR(set.weight, set.reps)) {
        exercise.updatePR(set.weight, set.reps);
        addXp(25);
      }
    } else if (!isPR && set.isPR) {
      // Unmarking PR
      set.isPR = false;
      _activeWorkout!.totalPRs--;
    }

    _activeWorkout!.save();
    notifyListeners();
    _triggerAutoBackup();
  }

  /// End the active workout
  Future<void> endWorkout({String? notes}) async {
    if (_activeWorkout == null) return;

    _activeWorkout!.endWorkout(sessionNotes: notes);

    // Award XP based on workout stats
    final xpReward = 10 + (_activeWorkout!.totalSets * 2) + (_activeWorkout!.totalPRs * 10);
    addXp(xpReward);

    // Log activity
    await logActivity(
      activityType: 'strength',
      statAffected: 'STR',
      points: _activeWorkout!.totalSets * 2,
      sourceId: _activeWorkout!.id,
      sourceType: 'workout',
      note: _activeWorkout!.summary,
      xpEarned: xpReward,
    );

    _activeWorkout = null;
    notifyListeners();
    _triggerAutoBackup();
  }

  /// Cancel the active workout without saving
  Future<void> cancelWorkout() async {
    if (_activeWorkout == null) return;

    await _workoutSessionBox.delete(_activeWorkout!.id);
    _workoutSessions.removeWhere((w) => w.id == _activeWorkout!.id);
    _activeWorkout = null;
    notifyListeners();
  }

  /// Get recent workouts (last 10)
  List<WorkoutSession> get recentWorkouts {
    final completed = _workoutSessions.where((w) => !w.isActive).toList();
    completed.sort((a, b) => b.startTime.compareTo(a.startTime));
    return completed.take(10).toList();
  }

  /// Get last performance for an exercise (Ghost data)
  Map<String, dynamic>? getLastPerformance(String exerciseId) {
    final exercise = getExerciseById(exerciseId);
    if (exercise == null || exercise.lastWeight == null) return null;

    return {
      'weight': exercise.lastWeight,
      'reps': exercise.lastReps,
      'date': exercise.lastPerformedAt,
    };
  }

  /// Manually set a PR for an exercise (Hunter Records override)
  Future<void> setExercisePR(String exerciseId, double weight, int reps) async {
    final exercise = getExerciseById(exerciseId);
    if (exercise == null) return;

    exercise.updatePR(weight, reps, note: 'Manual entry');
    notifyListeners();
    _triggerAutoBackup();
  }

  /// Update exercise notes
  Future<void> updateExerciseNotes(String exerciseId, String notes) async {
    final exercise = getExerciseById(exerciseId);
    if (exercise == null) return;

    exercise.notes = notes;
    await exercise.save();
    notifyListeners();
    _triggerAutoBackup();
  }

  // ==================== RESET METHODS ====================

  // Reset today's daily quest progress
  Future<void> resetTodayProgress() async {
    final todayKey = DailyQuestProgress.getTodayKey();
    _todayProgress = DailyQuestProgress(date: todayKey);
    await _dailyProgressBox.put(todayKey, _todayProgress!);

    // Reset daily quest counts
    for (final quest in _dailyQuests) {
      quest.currentCount = 0;
      quest.status = 'active';
      quest.completedAt = null;
    }

    notifyListeners();
  }

  // Reset all data - DANGER
  Future<void> resetAllData() async {
    // Clear all boxes
    await _playerBox.clear();
    await _questBox.clear();
    await _dungeonBox.clear();
    await _shadowBox.clear();
    await _inventoryBox.clear();
    await _dailyProgressBox.clear();
    await _nutritionEntryBox.clear();
    await _nutritionGoalsBox.clear();

    // Clear self-improvement boxes
    await _skillBox.clear();
    await _prBox.clear();
    await _goalBox.clear();
    await _habitBox.clear();
    await _activityLogBox.clear();

    // Clear workout boxes
    await _exerciseBox.clear();
    await _workoutSessionBox.clear();

    // Reset daily configs to defaults
    await _dailyConfigBox.clear();
    for (final config in DailyQuestConfig.getDefaults()) {
      await _dailyConfigBox.put(config.id, config);
    }

    // Reset shop items to defaults
    await _shopItemBox.clear();
    for (final item in ShopItem.getDefaultItems()) {
      await _shopItemBox.put(item.id, item);
    }

    // Reload all data
    await _loadData();
  }

  // ==================== BACKUP & RESTORE ====================

  /// Export all data to JSON string
  Future<String> exportData() async {
    final data = {
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'player': _player != null ? _playerToJson(_player!) : null,
      'quests': _quests.map((q) => _questToJson(q)).toList(),
      'dungeons': _dungeons.map((d) => _dungeonToJson(d)).toList(),
      'shadows': _shadows.map((s) => _shadowToJson(s)).toList(),
      'shopItems': _shopItems.where((i) => i.isUserDefined).map((i) => _shopItemToJson(i)).toList(),
      'inventory': _inventory != null ? _inventoryToJson(_inventory!) : null,
      'dailyConfigs': _dailyConfigs.map((c) => _dailyConfigToJson(c)).toList(),
      'dailyProgress': _dailyProgressBox.values.map((p) => _dailyProgressToJson(p)).toList(),
      'nutritionEntries': _nutritionEntries.map((e) => _nutritionEntryToJson(e)).toList(),
      'nutritionGoals': _nutritionGoals != null ? _nutritionGoalsToJson(_nutritionGoals!) : null,
    };
    return jsonEncode(data);
  }

  /// Export data to a file and return the file path
  Future<String> exportToFile() async {
    final jsonData = await exportData();
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
    final file = File('${directory.path}/solo_leveling_backup_$timestamp.json');
    await file.writeAsString(jsonData);
    return file.path;
  }

  /// Import data from JSON string
  Future<bool> importData(String jsonString) async {
    try {
      final data = jsonDecode(jsonString) as Map<String, dynamic>;

      // Clear existing data first
      await _playerBox.clear();
      await _questBox.clear();
      await _dungeonBox.clear();
      await _shadowBox.clear();
      await _inventoryBox.clear();
      await _dailyProgressBox.clear();
      await _nutritionEntryBox.clear();
      await _nutritionGoalsBox.clear();

      // Reset shop to defaults, then add custom items
      await _shopItemBox.clear();
      for (final item in ShopItem.getDefaultItems()) {
        await _shopItemBox.put(item.id, item);
      }

      // Restore player
      if (data['player'] != null) {
        final player = _playerFromJson(data['player']);
        await _playerBox.add(player);
      }

      // Restore quests
      if (data['quests'] != null) {
        for (final q in data['quests']) {
          final quest = _questFromJson(q);
          await _questBox.put(quest.id, quest);
        }
      }

      // Restore dungeons
      if (data['dungeons'] != null) {
        for (final d in data['dungeons']) {
          final dungeon = _dungeonFromJson(d);
          await _dungeonBox.put(dungeon.id, dungeon);
        }
      }

      // Restore shadows
      if (data['shadows'] != null) {
        for (final s in data['shadows']) {
          final shadow = _shadowFromJson(s);
          await _shadowBox.put(shadow.id, shadow);
        }
      }

      // Restore custom shop items
      if (data['shopItems'] != null) {
        for (final i in data['shopItems']) {
          final item = _shopItemFromJson(i);
          await _shopItemBox.put(item.id, item);
        }
      }

      // Restore inventory
      if (data['inventory'] != null) {
        final inventory = _inventoryFromJson(data['inventory']);
        await _inventoryBox.add(inventory);
      }

      // Restore daily configs
      await _dailyConfigBox.clear();
      if (data['dailyConfigs'] != null) {
        for (final c in data['dailyConfigs']) {
          final config = _dailyConfigFromJson(c);
          await _dailyConfigBox.put(config.id, config);
        }
      } else {
        for (final config in DailyQuestConfig.getDefaults()) {
          await _dailyConfigBox.put(config.id, config);
        }
      }

      // Restore daily progress
      if (data['dailyProgress'] != null) {
        for (final p in data['dailyProgress']) {
          final progress = _dailyProgressFromJson(p);
          await _dailyProgressBox.put(progress.date, progress);
        }
      }

      // Restore nutrition entries
      if (data['nutritionEntries'] != null) {
        for (final e in data['nutritionEntries']) {
          final entry = _nutritionEntryFromJson(e);
          await _nutritionEntryBox.put(entry.id, entry);
        }
      }

      // Restore nutrition goals
      if (data['nutritionGoals'] != null) {
        final goals = _nutritionGoalsFromJson(data['nutritionGoals']);
        await _nutritionGoalsBox.put('goals', goals);
      }

      // Reload all data
      await _loadData();
      return true;
    } catch (e) {
      debugPrint('Import error: $e');
      return false;
    }
  }

  /// Import data from a file
  Future<bool> importFromFile(String filePath) async {
    try {
      final file = File(filePath);
      final jsonString = await file.readAsString();
      return await importData(jsonString);
    } catch (e) {
      debugPrint('Import file error: $e');
      return false;
    }
  }

  // JSON serialization helpers - using existing toJson/fromJson where available
  Map<String, dynamic> _playerToJson(Player p) => p.toJson();

  Player _playerFromJson(Map<String, dynamic> j) => Player.fromJson(j);

  Map<String, dynamic> _questToJson(Quest q) => {
    'id': q.id,
    'title': q.title,
    'description': q.description,
    'xpReward': q.xpReward,
    'goldReward': q.goldReward,
    'questType': q.questType,
    'difficulty': q.difficulty,
    'status': q.status,
    'currentCount': q.currentCount,
    'targetCount': q.targetCount,
    'statBonus': q.statBonus,
    'statBonusAmount': q.statBonusAmount,
    'createdAt': q.createdAt.toIso8601String(),
    'deadline': q.deadline?.toIso8601String(),
    'completedAt': q.completedAt?.toIso8601String(),
    'parentDungeonId': q.parentDungeonId,
    'isRepeatable': q.isRepeatable,
  };

  Quest _questFromJson(Map<String, dynamic> j) {
    return Quest(
      id: j['id'],
      title: j['title'] ?? '',
      description: j['description'] ?? '',
      xpReward: j['xpReward'] ?? 0,
      goldReward: j['goldReward'] ?? 0,
      questType: j['questType'] ?? 'normal',
      difficulty: j['difficulty'] ?? 'normal',
      status: j['status'] ?? 'active',
      currentCount: j['currentCount'] ?? 0,
      targetCount: j['targetCount'] ?? 1,
      statBonus: j['statBonus'],
      statBonusAmount: j['statBonusAmount'] ?? 0,
      createdAt: j['createdAt'] != null ? DateTime.parse(j['createdAt']) : null,
      deadline: j['deadline'] != null ? DateTime.parse(j['deadline']) : null,
      completedAt: j['completedAt'] != null ? DateTime.parse(j['completedAt']) : null,
      parentDungeonId: j['parentDungeonId'],
      isRepeatable: j['isRepeatable'] ?? false,
    );
  }

  Map<String, dynamic> _dungeonToJson(Dungeon d) => {
    'id': d.id,
    'name': d.name,
    'description': d.description,
    'rank': d.rank,
    'isCleared': d.isCleared,
    'createdAt': d.createdAt.toIso8601String(),
    'clearedAt': d.clearedAt?.toIso8601String(),
    'questIds': d.questIds,
    'bossQuestId': d.bossQuestId,
    'totalXpReward': d.totalXpReward,
    'totalGoldReward': d.totalGoldReward,
    'rewardItemId': d.rewardItemId,
  };

  Dungeon _dungeonFromJson(Map<String, dynamic> j) {
    return Dungeon(
      id: j['id'],
      name: j['name'] ?? '',
      description: j['description'] ?? '',
      rank: j['rank'] ?? 'E',
      isCleared: j['isCleared'] ?? false,
      createdAt: j['createdAt'] != null ? DateTime.parse(j['createdAt']) : null,
      clearedAt: j['clearedAt'] != null ? DateTime.parse(j['clearedAt']) : null,
      questIds: List<String>.from(j['questIds'] ?? []),
      bossQuestId: j['bossQuestId'],
      totalXpReward: j['totalXpReward'] ?? 0,
      totalGoldReward: j['totalGoldReward'] ?? 0,
      rewardItemId: j['rewardItemId'],
    );
  }

  Map<String, dynamic> _shadowToJson(Shadow s) => {
    'id': s.id,
    'name': s.name,
    'originalDungeonName': s.originalDungeonName,
    'rank': s.rank,
    'type': s.type,
    'extractedAt': s.extractedAt.toIso8601String(),
    'powerLevel': s.powerLevel,
    'passiveBonus': s.passiveBonus,
    'passiveBonusAmount': s.passiveBonusAmount,
  };

  Shadow _shadowFromJson(Map<String, dynamic> j) {
    return Shadow(
      id: j['id'],
      name: j['name'] ?? '',
      originalDungeonName: j['originalDungeonName'] ?? '',
      rank: j['rank'] ?? 'soldier',
      type: j['type'] ?? 'general',
      extractedAt: j['extractedAt'] != null ? DateTime.parse(j['extractedAt']) : null,
      powerLevel: j['powerLevel'] ?? 1,
      passiveBonus: j['passiveBonus'],
      passiveBonusAmount: j['passiveBonusAmount'] ?? 0,
    );
  }

  Map<String, dynamic> _shopItemToJson(ShopItem i) => {
    'id': i.id,
    'name': i.name,
    'description': i.description,
    'price': i.price,
    'category': i.category,
    'effect': i.effect,
    'isUserDefined': i.isUserDefined,
    'iconEmoji': i.iconEmoji,
  };

  ShopItem _shopItemFromJson(Map<String, dynamic> j) {
    return ShopItem(
      name: j['name'] ?? '',
      description: j['description'] ?? '',
      price: j['price'] ?? 0,
      category: j['category'] ?? 'reward',
      effect: j['effect'],
      isUserDefined: j['isUserDefined'] ?? true,
      iconEmoji: j['iconEmoji'] ?? '',
    );
  }

  Map<String, dynamic> _inventoryToJson(Inventory i) => {
    'items': i.items,
  };

  Inventory _inventoryFromJson(Map<String, dynamic> j) {
    final inventory = Inventory();
    final items = j['items'] as Map<String, dynamic>? ?? {};
    items.forEach((key, value) {
      inventory.items[key] = value as int;
    });
    return inventory;
  }

  Map<String, dynamic> _dailyConfigToJson(DailyQuestConfig c) => {
    'id': c.id,
    'title': c.title,
    'targetCount': c.targetCount,
    'statBonus': c.statBonus,
    'isEnabled': c.isEnabled,
    'order': c.order,
  };

  DailyQuestConfig _dailyConfigFromJson(Map<String, dynamic> j) {
    return DailyQuestConfig(
      id: j['id'] ?? '',
      title: j['title'] ?? '',
      targetCount: j['targetCount'] ?? 1,
      statBonus: j['statBonus'] ?? 'STR',
      isEnabled: j['isEnabled'] ?? true,
      order: j['order'] ?? 0,
    );
  }

  Map<String, dynamic> _dailyProgressToJson(DailyQuestProgress p) => {
    'date': p.date,
    'progress': p.progress,
    'isCompleted': p.isCompleted,
    'penaltyTriggered': p.penaltyTriggered,
    'completedAt': p.completedAt?.toIso8601String(),
  };

  DailyQuestProgress _dailyProgressFromJson(Map<String, dynamic> j) {
    return DailyQuestProgress(
      date: j['date'] ?? '',
      progress: Map<String, int>.from(j['progress'] ?? {}),
      isCompleted: j['isCompleted'] ?? false,
      penaltyTriggered: j['penaltyTriggered'] ?? false,
      completedAt: j['completedAt'] != null ? DateTime.parse(j['completedAt']) : null,
    );
  }

  Map<String, dynamic> _nutritionEntryToJson(NutritionEntry e) => {
    'id': e.id,
    'date': e.date,
    'barcode': e.barcode,
    'productName': e.productName,
    'brand': e.brand,
    'servingSize': e.servingSize,
    'servingsConsumed': e.servingsConsumed,
    'calories': e.calories,
    'protein': e.protein,
    'carbs': e.carbs,
    'fat': e.fat,
    'fiber': e.fiber,
    'sugar': e.sugar,
    'sodium': e.sodium,
    'mealType': e.mealType.index,
    'timestamp': e.timestamp.toIso8601String(),
    'isManualEntry': e.isManualEntry,
  };

  NutritionEntry _nutritionEntryFromJson(Map<String, dynamic> j) {
    return NutritionEntry(
      id: j['id'] ?? '',
      date: j['date'] ?? NutritionEntry.getTodayKey(),
      barcode: j['barcode'],
      productName: j['productName'] ?? '',
      brand: j['brand'],
      servingSize: (j['servingSize'] ?? 100).toDouble(),
      servingsConsumed: (j['servingsConsumed'] ?? 1).toDouble(),
      calories: (j['calories'] ?? 0).toDouble(),
      protein: (j['protein'] ?? 0).toDouble(),
      carbs: (j['carbs'] ?? 0).toDouble(),
      fat: (j['fat'] ?? 0).toDouble(),
      fiber: (j['fiber'] ?? 0).toDouble(),
      sugar: (j['sugar'] ?? 0).toDouble(),
      sodium: (j['sodium'] ?? 0).toDouble(),
      mealType: MealType.values[j['mealType'] ?? 0],
      timestamp: j['timestamp'] != null ? DateTime.parse(j['timestamp']) : null,
      isManualEntry: j['isManualEntry'] ?? false,
    );
  }

  Map<String, dynamic> _nutritionGoalsToJson(NutritionGoals g) => {
    'dailyCalories': g.dailyCalories,
    'dailyProtein': g.dailyProtein,
    'dailyCarbs': g.dailyCarbs,
    'dailyFat': g.dailyFat,
    'dailyFiber': g.dailyFiber,
    'dailySugar': g.dailySugar,
    'dailySodium': g.dailySodium,
    'isEnabled': g.isEnabled,
  };

  NutritionGoals _nutritionGoalsFromJson(Map<String, dynamic> j) {
    return NutritionGoals(
      dailyCalories: j['dailyCalories'] ?? 2000,
      dailyProtein: j['dailyProtein'] ?? 150,
      dailyCarbs: j['dailyCarbs'] ?? 250,
      dailyFat: j['dailyFat'] ?? 65,
      dailyFiber: j['dailyFiber'] ?? 25,
      dailySugar: j['dailySugar'] ?? 50,
      dailySodium: j['dailySodium'] ?? 2300,
      isEnabled: j['isEnabled'] ?? true,
    );
  }
}
