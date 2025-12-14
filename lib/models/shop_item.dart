import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'shop_item.g.dart';

enum ItemCategory { consumable, reward, special }

@HiveType(typeId: 8)
class ShopItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  int price;

  @HiveField(4)
  String category;

  @HiveField(5)
  String? effect; // What this item does

  @HiveField(6)
  bool isUserDefined; // User created reward

  @HiveField(7)
  String? iconEmoji; // Visual representation

  ShopItem({
    String? id,
    required this.name,
    this.description = '',
    required this.price,
    this.category = 'reward',
    this.effect,
    this.isUserDefined = false,
    this.iconEmoji,
  }) : id = id ?? const Uuid().v4();

  ItemCategory get itemCategory => ItemCategory.values.firstWhere(
        (e) => e.name == category,
        orElse: () => ItemCategory.reward,
      );

  // Default shop items
  static List<ShopItem> getDefaultItems() {
    return [
      // Consumables (in-app effects)
      ShopItem(
        id: 'elixir_of_life',
        name: 'Elixir of Life',
        description: 'Skip one daily quest without penalty',
        price: 500,
        category: 'consumable',
        effect: 'skip_penalty',
        iconEmoji: '🧪',
      ),
      ShopItem(
        id: 'xp_boost',
        name: 'Demon King\'s Blessing',
        description: '2x XP for 24 hours',
        price: 300,
        category: 'consumable',
        effect: 'xp_boost',
        iconEmoji: '⚔️',
      ),
      ShopItem(
        id: 'fatigue_potion',
        name: 'Recovery Potion',
        description: 'Instantly remove all fatigue',
        price: 150,
        category: 'consumable',
        effect: 'clear_fatigue',
        iconEmoji: '💊',
      ),
      ShopItem(
        id: 'return_stone',
        name: 'Return Stone',
        description: 'Reset a failed quest back to active',
        price: 400,
        category: 'consumable',
        effect: 'reset_quest',
        iconEmoji: '💎',
      ),

      // Special items
      ShopItem(
        id: 'shadow_extraction',
        name: 'Ruler\'s Authority',
        description: 'Extract an extra shadow from next dungeon',
        price: 1000,
        category: 'special',
        effect: 'extra_shadow',
        iconEmoji: '👑',
      ),
    ];
  }
}

@HiveType(typeId: 9)
class Inventory extends HiveObject {
  @HiveField(0)
  Map<String, int> items; // itemId -> quantity

  Inventory({Map<String, int>? items}) : items = items ?? {};

  int getQuantity(String itemId) => items[itemId] ?? 0;

  void addItem(String itemId, [int quantity = 1]) {
    items[itemId] = (items[itemId] ?? 0) + quantity;
    save();
  }

  bool useItem(String itemId) {
    if ((items[itemId] ?? 0) > 0) {
      items[itemId] = items[itemId]! - 1;
      if (items[itemId] == 0) {
        items.remove(itemId);
      }
      save();
      return true;
    }
    return false;
  }

  bool hasItem(String itemId) => (items[itemId] ?? 0) > 0;
}
