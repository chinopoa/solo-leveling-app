import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/solo_leveling_theme.dart';
import '../widgets/widgets.dart';
import '../models/models.dart';

/// Shop and Inventory screen
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen>
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
    return Consumer<GameProvider>(
      builder: (context, game, child) {
        return Column(
          children: [
            // Gold display
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SoloLevelingTheme.backgroundCard,
                border: Border.all(color: Colors.amber.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber, size: 32),
                  const SizedBox(width: 12),
                  Text(
                    '${game.player?.gold ?? 0}',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'GOLD',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 14,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            // Tab bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
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
                  Tab(text: 'SHOP'),
                  Tab(text: 'INVENTORY'),
                ],
              ),
            ),
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _ShopTab(game: game),
                  _InventoryTab(game: game),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ShopTab extends StatelessWidget {
  final GameProvider game;

  const _ShopTab({required this.game});

  @override
  Widget build(BuildContext context) {
    final items = game.shopItems;

    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _ShopItemCard(
              item: item,
              canAfford: (game.player?.gold ?? 0) >= item.price,
              onBuy: () => _buyItem(context, item),
            );
          },
        ),
        // Add custom reward button
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton(
            onPressed: () => _showAddRewardDialog(context),
            child: const Icon(Icons.card_giftcard),
          ),
        ),
      ],
    );
  }

  void _buyItem(BuildContext context, ShopItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SoloLevelingTheme.backgroundCard,
        title: const Text(
          'CONFIRM PURCHASE',
          style: TextStyle(
            color: SoloLevelingTheme.primaryCyan,
            letterSpacing: 1,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.iconEmoji ?? '📦',
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 12),
            Text(
              item.name,
              style: const TextStyle(
                color: SoloLevelingTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.monetization_on, color: Colors.amber, size: 20),
                const SizedBox(width: 4),
                Text(
                  '${item.price} Gold',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            // We added 'async' here
            onPressed: () async {
              // We added 'await' here because buying takes time
              if (await game.purchaseItem(item)) {
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item.name} added to inventory!'),
                    backgroundColor: SoloLevelingTheme.successGreen,
                  ),
                );
              } else {
                if (!context.mounted) return;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Not enough gold!'),
                    backgroundColor: SoloLevelingTheme.hpRed,
                  ),
                );
              }
            },
            child: const Text('BUY'),
          ),
        ],
      ),
    );
  }

  void _showAddRewardDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final priceController = TextEditingController(text: '100');
    String selectedEmoji = '🎁';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: SoloLevelingTheme.backgroundCard,
          title: const Text(
            'ADD CUSTOM REWARD',
            style: TextStyle(
              color: SoloLevelingTheme.primaryCyan,
              letterSpacing: 1,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Set your own real-life rewards!',
                  style: TextStyle(
                    color: SoloLevelingTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                // Emoji picker
                const Text(
                  'ICON',
                  style: TextStyle(
                    color: SoloLevelingTheme.textMuted,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: ['🎁', '☕', '🍕', '🎮', '📱', '👕', '🎬', '🍦']
                      .map((emoji) {
                    return GestureDetector(
                      onTap: () => setState(() => selectedEmoji = emoji),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: selectedEmoji == emoji
                              ? SoloLevelingTheme.primaryCyan.withOpacity(0.2)
                              : null,
                          border: Border.all(
                            color: selectedEmoji == emoji
                                ? SoloLevelingTheme.primaryCyan
                                : SoloLevelingTheme.textMuted,
                          ),
                        ),
                        child: Text(emoji, style: const TextStyle(fontSize: 24)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Reward Name',
                    hintText: 'e.g., Coffee Break',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'e.g., Get a nice coffee',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price (Gold)',
                    prefixIcon: Icon(Icons.monetization_on, color: Colors.amber),
                  ),
                  keyboardType: TextInputType.number,
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
                if (nameController.text.isNotEmpty) {
                  game.addCustomReward(
                    name: nameController.text,
                    description: descController.text,
                    price: int.tryParse(priceController.text) ?? 100,
                    emoji: selectedEmoji,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('ADD'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopItemCard extends StatelessWidget {
  final ShopItem item;
  final bool canAfford;
  final VoidCallback onBuy;

  const _ShopItemCard({
    required this.item,
    required this.canAfford,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SoloLevelingTheme.backgroundCard,
        border: Border.all(
          color: canAfford
              ? SoloLevelingTheme.primaryCyan.withOpacity(0.3)
              : SoloLevelingTheme.textMuted.withOpacity(0.2),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: SoloLevelingTheme.backgroundElevated,
              border: Border.all(
                color: _getCategoryColor().withOpacity(0.5),
              ),
            ),
            child: Center(
              child: Text(
                item.iconEmoji ?? '📦',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      item.name,
                      style: TextStyle(
                        color: canAfford
                            ? SoloLevelingTheme.textPrimary
                            : SoloLevelingTheme.textMuted,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (item.isUserDefined) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: SoloLevelingTheme.accentPurple,
                          ),
                        ),
                        child: const Text(
                          'CUSTOM',
                          style: TextStyle(
                            color: SoloLevelingTheme.accentPurple,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: TextStyle(
                    color: SoloLevelingTheme.textMuted,
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Price and buy button
          Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.monetization_on, color: Colors.amber, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '${item.price}',
                    style: TextStyle(
                      color: canAfford ? Colors.amber : SoloLevelingTheme.textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: canAfford ? onBuy : null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: canAfford
                        ? SoloLevelingTheme.primaryCyan.withOpacity(0.2)
                        : SoloLevelingTheme.backgroundElevated,
                    border: Border.all(
                      color: canAfford
                          ? SoloLevelingTheme.primaryCyan
                          : SoloLevelingTheme.textMuted,
                    ),
                  ),
                  child: Text(
                    'BUY',
                    style: TextStyle(
                      color: canAfford
                          ? SoloLevelingTheme.primaryCyan
                          : SoloLevelingTheme.textMuted,
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
    );
  }

  Color _getCategoryColor() {
    switch (item.itemCategory) {
      case ItemCategory.consumable:
        return SoloLevelingTheme.successGreen;
      case ItemCategory.special:
        return SoloLevelingTheme.accentPurple;
      default:
        return SoloLevelingTheme.primaryCyan;
    }
  }
}

class _InventoryTab extends StatelessWidget {
  final GameProvider game;

  const _InventoryTab({required this.game});

  @override
  Widget build(BuildContext context) {
    final inventory = game.inventory;
    final items = game.shopItems;

    if (inventory == null || inventory.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: SoloLevelingTheme.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'INVENTORY EMPTY',
              style: TextStyle(
                color: SoloLevelingTheme.textMuted,
                fontSize: 14,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Purchase items from the shop',
              style: TextStyle(
                color: SoloLevelingTheme.textMuted,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: inventory.items.length,
      itemBuilder: (context, index) {
        final entry = inventory.items.entries.elementAt(index);
        final item = items.firstWhere(
          (i) => i.id == entry.key,
          orElse: () => ShopItem(name: 'Unknown', price: 0),
        );
        final quantity = entry.value;

        return _InventoryItemCard(
          item: item,
          quantity: quantity,
          onUse: () => _useItem(context, item),
        );
      },
    );
  }

  void _useItem(BuildContext context, ShopItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: SoloLevelingTheme.backgroundCard,
        title: const Text(
          'USE ITEM',
          style: TextStyle(
            color: SoloLevelingTheme.primaryCyan,
            letterSpacing: 1,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              item.iconEmoji ?? '📦',
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 12),
            Text(
              'Use ${item.name}?',
              style: const TextStyle(
                color: SoloLevelingTheme.textPrimary,
                fontSize: 16,
              ),
            ),
            if (item.effect != null) ...[
              const SizedBox(height: 8),
              Text(
                item.description,
                style: TextStyle(
                  color: SoloLevelingTheme.textMuted,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              game.useItem(item.id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${item.name} used!'),
                  backgroundColor: SoloLevelingTheme.successGreen,
                ),
              );
            },
            child: const Text('USE'),
          ),
        ],
      ),
    );
  }
}

class _InventoryItemCard extends StatelessWidget {
  final ShopItem item;
  final int quantity;
  final VoidCallback onUse;

  const _InventoryItemCard({
    required this.item,
    required this.quantity,
    required this.onUse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SoloLevelingTheme.backgroundCard,
        border: Border.all(
          color: SoloLevelingTheme.primaryCyan.withOpacity(0.3),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          // Icon with quantity badge
          Stack(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: SoloLevelingTheme.backgroundElevated,
                  border: Border.all(
                    color: SoloLevelingTheme.primaryCyan.withOpacity(0.5),
                  ),
                ),
                child: Center(
                  child: Text(
                    item.iconEmoji ?? '📦',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              Positioned(
                right: -4,
                bottom: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: SoloLevelingTheme.primaryCyan,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'x$quantity',
                    style: const TextStyle(
                      color: SoloLevelingTheme.backgroundDark,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    color: SoloLevelingTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: TextStyle(
                    color: SoloLevelingTheme.textMuted,
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Use button
          GestureDetector(
            onTap: onUse,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: SoloLevelingTheme.successGreen.withOpacity(0.2),
                border: Border.all(color: SoloLevelingTheme.successGreen),
              ),
              child: const Text(
                'USE',
                style: TextStyle(
                  color: SoloLevelingTheme.successGreen,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
