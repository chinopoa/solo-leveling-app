import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

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

  // Level up state
  bool _showLevelUp = false;
  int _levelUpNewLevel = 0;
  int _levelUpPointsGained = 0;

  // Getters
  Player? get player => _player;
  List<Quest> get quests => _quests;
  List<Quest> get activeQuests =>
      _quests.where((q) => q.isActive && q.type != QuestType.daily).toList();
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

  bool get showLevelUp => _showLevelUp;
  int get levelUpNewLevel => _levelUpNewLevel;
  int get levelUpPointsGained => _levelUpPointsGained;

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

    notifyListeners();
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

  // Create new player (onboarding)
  Future<void> createPlayer(String name) async {
    _player = Player(name: name);
    await _playerBox.add(_player!);
    await _loadTodayProgress();
    notifyListeners();
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

  // Quest management
  Future<void> addQuest(Quest quest) async {
    await _questBox.put(quest.id, quest);
    _quests.add(quest);
    notifyListeners();
  }

  Future<void> completeQuest(Quest quest) async {
    quest.complete();
    addXp(quest.xpReward);
    _player?.addGold(quest.goldReward);

    // Add stat bonus if applicable
    if (quest.statBonus != null && quest.statBonusAmount > 0) {
      // Stat bonuses from quests don't use allocation points
    }

    notifyListeners();
  }

  Future<void> incrementQuestProgress(Quest quest, [int amount = 1]) async {
    quest.incrementProgress(amount);
    if (quest.isCompleted) {
      addXp(quest.xpReward);
      _player?.addGold(quest.goldReward);
    }
    notifyListeners();
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
  }

  // Update a nutrition entry
  Future<void> updateNutritionEntry(NutritionEntry entry) async {
    await _nutritionEntryBox.put(entry.id, entry);
    final index = _nutritionEntries.indexWhere((e) => e.id == entry.id);
    if (index >= 0) {
      _nutritionEntries[index] = entry;
    }
    notifyListeners();
  }

  // Delete a nutrition entry
  Future<void> deleteNutritionEntry(String entryId) async {
    await _nutritionEntryBox.delete(entryId);
    _nutritionEntries.removeWhere((e) => e.id == entryId);
    notifyListeners();
  }

  // Update nutrition goals
  Future<void> updateNutritionGoals(NutritionGoals goals) async {
    _nutritionGoals = goals;
    await _nutritionGoalsBox.put('goals', goals);
    notifyListeners();
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
}
