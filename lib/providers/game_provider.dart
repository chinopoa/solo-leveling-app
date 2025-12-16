import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  // Auto-backup
  bool _autoBackupEnabled = false;
  DateTime? _lastAutoBackup;
  static const _autoBackupKey = 'auto_backup_enabled';

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
