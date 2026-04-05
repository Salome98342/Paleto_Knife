import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../widgets/retro_style.dart';
import '../controllers/chef_controller.dart';
import '../controllers/economy_controller.dart';
import '../services/audio_service.dart';

class ChefsView extends StatelessWidget {
  const ChefsView({super.key});

  @override
  Widget build(BuildContext context) {
    final chefState = context.watch<ChefController>();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 80.0, left: 16.0, right: 16.0),
          child: Text("Tus Chefs", style: RetroStyle.font(size: 16, color: Colors.white)),
        ),
        Expanded(
          child: GridView.count(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 100, top: 16),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.70,
            children: chefState.chefs.map((chef) => _buildChefCard(context, chef, chefState)).toList(),
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
        ),
      ],
    );
  }

  Widget _buildChefCard(BuildContext context, ChefData chef, ChefController chefState) {
    Color rarityColor = _getRarityColor(chef.rarity);
    bool isActive = chefState.activeChef.id == chef.id;

    return GestureDetector(
      onTap: () {
        if (!chef.isUnlocked) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Chef bloqueado. Desbloquéalo en la Tienda / Gacha.", style: RetroStyle.font(size: 10, color: Colors.white)),
            backgroundColor: RetroStyle.background,
          ));
          return;
        }
        try {
          AudioService.instance.playMenuMusic(); // O un SFX de click
        } catch (_) {}
        _showChefDetails(context, chef);
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
                    child: Center(child: Icon(chef.icon, size: 50, color: Colors.white)),
                  ),
                ),
                Text(chef.name, style: RetroStyle.font(size: 8, color: Colors.white), textAlign: TextAlign.center),
                const SizedBox(height: 4),
                Text("Lv. ${chef.level}", style: RetroStyle.font(size: 8, color: rarityColor)),
                const SizedBox(height: 8),
                if (isActive)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text("EN USO", style: RetroStyle.font(size: 10, color: Colors.amber)),
                  ),
              ],
            ),
          ),

          if (!chef.isUnlocked)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                border: Border.all(color: rarityColor, width: 4), 
              ),
              child: Center(
                child: Icon(Icons.lock, size: 40, color: Colors.white.withOpacity(0.9))
                  .animate(onPlay: (controller) => controller.repeat(reverse: true))
                  .slideY(begin: -0.1, end: 0.1, duration: 1.seconds),
              ),
            ),
        ],
      ),
    );
  }

  void _showChefDetails(BuildContext context, ChefData chef) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            final eco = context.watch<EconomyController>();
            final cController = context.watch<ChefController>();
            // Referencia siempre actualizada del chef por si cambia de nivel
            final currentChef = cController.chefs.firstWhere((c) => c.id == chef.id);
            
            bool canUpgrade = eco.coins >= currentChef.upgradeCost;
            bool isActive = cController.activeChef.id == currentChef.id;

            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: RetroStyle.box(color: RetroStyle.panel).copyWith(
                  border: Border.all(color: _getRarityColor(currentChef.rarity), width: 4),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        children: [
                          Icon(currentChef.icon, size: 40, color: Colors.white),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(currentChef.name, style: RetroStyle.font(size: 14, color: Colors.white)),
                                Text("Nivel: ${currentChef.level} | ${currentChef.rarity}", style: RetroStyle.font(size: 10, color: _getRarityColor(currentChef.rarity))),
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
                          currentChef.lore,
                          style: const TextStyle(fontFamily: 'Courier', color: Colors.white70, fontSize: 12),
                          textAlign: TextAlign.justify,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Stats
                      _buildStatRow("Daño Base:", "${currentChef.currentDamage.toStringAsFixed(1)}"),
                      _buildStatRow("Vel. Ataque:", "${currentChef.currentFireRate.toStringAsFixed(2)}s"),
                      const SizedBox(height: 16),

                      // Elementos & Ventajas
                      _buildElementPanel("Mejor Zona", currentChef.favoredLocation, Colors.blueAccent),
                      _buildElementPanel("Fuerte contra", currentChef.strongAgainst, Colors.green),
                      _buildElementPanel("Débil contra", currentChef.weakAgainst, Colors.redAccent),
                      const SizedBox(height: 24),

                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (canUpgrade) {
                                  try { AudioService.instance.playCoinCollect(); } catch (_) {}
                                  eco.spendCoins(currentChef.upgradeCost);
                                  cController.upgradeChef(currentChef);
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: RetroStyle.box(
                                  color: canUpgrade ? RetroStyle.accent : Colors.grey,
                                ),
                                child: Column(
                                  children: [
                                    Text("MEJORAR", style: RetroStyle.font(size: 10)),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.monetization_on, size: 12),
                                        Text(" ${currentChef.upgradeCost}", style: RetroStyle.font(size: 10)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                if (!isActive) {
                                  int idx = cController.chefs.indexWhere((c) => c.id == currentChef.id);
                                  cController.setActiveChef(idx);
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
                                    style: RetroStyle.font(size: 12, color: Colors.white),
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

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: RetroStyle.font(size: 10, color: Colors.white)),
          Text(value, style: RetroStyle.font(size: 12, color: Colors.amber)),
        ],
      ),
    );
  }

  Widget _buildElementPanel(String title, String value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
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

  Color _getRarityColor(String rarity) {
    switch (rarity) {
      case "Common": return Colors.grey;
      case "Rare": return Colors.blue;
      case "Epic": return Colors.purple;
      case "Legendary": return Colors.orangeAccent;
      default: return Colors.black;
    }
  }
}
