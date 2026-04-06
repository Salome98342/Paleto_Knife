import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../widgets/retro_style.dart';
import '../controllers/chef_controller.dart';
import '../controllers/economy_controller.dart';
import '../services/audio_service.dart';

class ChefsView extends StatefulWidget {
  const ChefsView({super.key});

  @override
  State<ChefsView> createState() => _ChefsViewState();
}

class _ChefsViewState extends State<ChefsView> with SingleTickerProviderStateMixin {
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
        Padding(
          padding: const EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
          child: Container(
            decoration: RetroStyle.box(color: Colors.black54),
            child: TabBar(
              controller: _tabController,
              indicatorColor: RetroStyle.accent,
              labelColor: RetroStyle.accent,
              unselectedLabelColor: Colors.white,
              labelStyle: RetroStyle.font(size: 10),
              tabs: const [
                Tab(text: "CHEFS"),
                Tab(text: "CUCHILLOS"),
              ],
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildEntityGrid(context, true),
              _buildEntityGrid(context, false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEntityGrid(BuildContext context, bool isChef) {
    final chefState = context.watch<ChefController>();
    final list = isChef ? chefState.chefs : chefState.knives;

    // Agrupar por rareza
    Map<GachaRarity, List<GachaEntity>> grouped = {};
    for (var rarity in GachaRarity.values.reversed) {
      grouped[rarity] = list.where((e) => e.rarity == rarity).toList();
    }

    return ListView(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100, top: 16),
      children: grouped.entries.map((entry) {
        if (entry.value.isEmpty) return const SizedBox();
        Color rarityColor = _getRarityColor(entry.key);
        String label = entry.key.name.toUpperCase();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                label,
                style: RetroStyle.font(color: rarityColor, size: 14),
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.70,
              children: entry.value.map((e) => _buildChefCard(context, e, chefState, isChef)).toList(),
            ),
            const SizedBox(height: 24),
          ],
        );
      }).toList(),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2);
  }

  Widget _buildChefCard(BuildContext context, GachaEntity entity, ChefController chefState, bool isChef) {
    Color rarityColor = _getRarityColor(entity.rarity);
    final activeEntity = isChef ? chefState.activeChef : chefState.activeKnife;
    bool isActive = activeEntity.id == entity.id;

    return GestureDetector(
      onTap: () {
        if (!entity.isUnlocked) {
          RetroStyle.showInsufficient(context, "${isChef ? 'CHEF' : 'CUCHILLO'} BLOQUEADO.\nCONSIGUELO EN\nLA TIENDA GACHA.");
          return;
        }
        try {
          AudioService.instance.playMenuMusic(); 
        } catch (_) {}
        _showChefDetails(context, entity, isChef);
      },
      child: Stack(
        children: [
          Container(
            decoration: RetroStyle.box(color: isActive ? Colors.grey.shade800 : RetroStyle.panel).copyWith(
              border: Border.all(color: isActive ? Colors.amber : rarityColor, width: isActive ? 6 : 4),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    color: Colors.grey.shade900,
                    child: Center(child: Icon(entity.icon, size: 50, color: Colors.white)),
                  ),
                ),
                Text(entity.name, style: RetroStyle.font(size: 8, color: Colors.white), textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text("Lv. ${entity.level}", style: RetroStyle.font(size: 8, color: rarityColor)),
                const SizedBox(height: 8),
                if (isActive)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text("EN USO", style: RetroStyle.font(size: 10, color: Colors.amber)),
                  ),
              ],
            ),
          ),

          if (!entity.isUnlocked)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                border: Border.all(color: rarityColor, width: 4), 
              ),
              child: Center(
                child: Icon(Icons.lock, size: 40, color: Colors.white.withValues(alpha: 0.9))
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .slideY(begin: -0.1, end: 0.1, duration: 1.seconds),
              ),
            ),
        ],
      ),
    );
  }

  void _showChefDetails(BuildContext context, GachaEntity entity, bool isChef) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final eco = context.watch<EconomyController>();
            final cController = context.watch<ChefController>();
            
            final currentEntity = isChef 
              ? cController.chefs.firstWhere((c) => c.id == entity.id)
              : cController.knives.firstWhere((c) => c.id == entity.id);
            
            final activeEntity = isChef ? cController.activeChef : cController.activeKnife;
            bool isActive = activeEntity.id == currentEntity.id;
            int upgradeCost = currentEntity.tokensNeededToUpgrade;
            int coinCost = currentEntity.coinsNeededToUpgrade;
            bool isMaxLevel = currentEntity.level >= currentEntity.maxLevel;
            bool canUpgrade = (upgradeCost > 0) && (currentEntity.tokens >= upgradeCost) && (eco.coins >= coinCost) && !isMaxLevel;

            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: RetroStyle.box(color: RetroStyle.panel).copyWith(
                  border: Border.all(color: _getRarityColor(currentEntity.rarity), width: 4),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        children: [
                          Icon(currentEntity.icon, size: 40, color: Colors.white)
                            .animate(key: ValueKey(currentEntity.level)) // Reactiva animación de scale si sube de nivel
                            .scaleXY(begin: 1.5, end: 1.0, duration: 400.ms, curve: Curves.elasticOut)
                            .then()
                            .shimmer(duration: 600.ms, color: Colors.yellowAccent),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(currentEntity.name, style: RetroStyle.font(size: 14, color: Colors.white)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text("Lv. ${currentEntity.level} ", style: RetroStyle.font(size: 12, color: Colors.amberAccent))
                                      .animate(key: ValueKey("level_${currentEntity.level}"))
                                      .slideY(begin: -0.5, duration: 300.ms),
                                    Text("| ${currentEntity.rarityName}", style: RetroStyle.font(size: 8, color: _getRarityColor(currentEntity.rarity))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Lore
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: RetroStyle.box(color: Colors.black45),
                        child: Text(
                          currentEntity.lore,
                          style: const TextStyle(fontFamily: 'Courier', color: Colors.white70, fontSize: 12),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Stats
                      _buildStatRow("Daño Base:", currentEntity.currentDamage.toStringAsFixed(1), currentEntity.level),
                      _buildStatRow("Vel. Ataque:", "${currentEntity.currentFireRate.toStringAsFixed(2)}s", currentEntity.level),
                      const SizedBox(height: 16),

                      // Elementos & Ventajas
                      if (isChef) ...[
                        _buildElementPanel("Mejor Zona", currentEntity.favoredLocation, Colors.blueAccent),
                        _buildElementPanel("Fuerte contra", currentEntity.strongAgainst, Colors.green),
                        _buildElementPanel("Débil contra", currentEntity.weakAgainst, Colors.redAccent),
                        const SizedBox(height: 24),
                      ],

                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (canUpgrade) {
                                  try { AudioService.instance.playCoinCollect(); } catch (_) {}
                                  cController.tryUpgrade(currentEntity, ecoController: eco);
                                } else if (!isMaxLevel) {
                                  if (currentEntity.tokens < upgradeCost) {
                                    RetroStyle.showInsufficient(context, "FALTAN ${upgradeCost - currentEntity.tokens} TOKENS");
                                  } else {
                                    RetroStyle.showInsufficient(context, "FALTAN ${coinCost - eco.coins} MONEDAS");
                                  }
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: RetroStyle.box(
                                  color: canUpgrade ? RetroStyle.accent : Colors.grey,
                                ).copyWith(
                                  boxShadow: canUpgrade ? [
                                    BoxShadow(color: RetroStyle.accent.withOpacity(0.6), blurRadius: 12, spreadRadius: 4)
                                  ] : null,
                                ),
                                child: Column(
                                  children: [
                                    Text(isMaxLevel ? "MÁX. NIVEL" : "MEJORAR", style: RetroStyle.font(size: 10)),
                                    if (!isMaxLevel) ...[
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.generating_tokens, size: 12, color: Colors.indigo),
                                          Text(" ${currentEntity.tokens}/$upgradeCost", style: RetroStyle.font(size: 10, color: currentEntity.tokens >= upgradeCost ? Colors.indigo : Colors.red)),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.monetization_on, size: 12, color: Colors.yellow),
                                          Text(" $coinCost", style: RetroStyle.font(size: 10, color: eco.coins >= coinCost ? Colors.yellow : Colors.red)),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ).animate(target: canUpgrade ? 1 : 0).shimmer(duration: 1200.ms, color: Colors.white54),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (!isActive) {
                                  cController.setActive(currentEntity);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: RetroStyle.box(
                                  color: isActive ? Colors.grey : Colors.green,
                                ),
                                child: Center(
                                  child: Text(
                                    isActive ? "EN USO" : "EQUIPAR",
                                    style: RetroStyle.font(size: 10, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => Navigator.pop(dialogContext),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: RetroStyle.box(color: Colors.redAccent),
                          child: Center(child: Text("CERRAR", style: RetroStyle.font(size: 12, color: Colors.white))),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildStatRow(String label, String value, int animKey) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: RetroStyle.font(size: 10, color: Colors.white)),
          Text(value, style: RetroStyle.font(size: 12, color: Colors.amber))
            .animate(key: ValueKey("stat_${animKey}_$label"))
            .scaleXY(begin: 1.5, end: 1.0, duration: 400.ms, curve: Curves.easeOutBack)
            .tint(color: Colors.white, duration: 200.ms),
        ],
      ),
    );
  }

  Widget _buildElementPanel(String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text("$title:", style: RetroStyle.font(size: 8, color: color)),
          ),
          Expanded(
            flex: 3,
            child: Text(value, style: RetroStyle.font(size: 8, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Color _getRarityColor(GachaRarity rarity) {
    switch (rarity) {
      case GachaRarity.Common: return Colors.grey;
      case GachaRarity.Rare: return Colors.blue;
      case GachaRarity.Epic: return Colors.purple;
      case GachaRarity.Legendary: return Colors.orange;
    }
  }
}

