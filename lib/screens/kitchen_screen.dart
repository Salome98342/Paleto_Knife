import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/game_controller.dart';
import '../main.dart';
import '../models/sous_chef.dart';

/// Pantalla de la Cocina - Gestion de Sous-chefs
class KitchenScreen extends StatefulWidget {
  final GameController gameController;

  const KitchenScreen({super.key, required this.gameController});

  @override
  State<KitchenScreen> createState() => _KitchenScreenState();
}

class _KitchenScreenState extends State<KitchenScreen> {
  @override
  void initState() {
    super.initState();
    widget.gameController.addListener(_onGameStateChanged);
  }

  @override
  void dispose() {
    widget.gameController.removeListener(_onGameStateChanged);
    super.dispose();
  }

  void _onGameStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _hireSousChef(SousChef chef) {
    final success = widget.gameController.tryHireSousChef(chef);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${chef.name} contratado/mejorado'),
          backgroundColor: Colors.green,
          duration: const Duration(milliseconds: 800),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Oro insuficiente'),
          backgroundColor: Colors.red,
          duration: const Duration(milliseconds: 800),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sousChefs = widget.gameController.sousChefs;
    final gold = widget.gameController.gold;

    return Scaffold(
      backgroundColor: PixelColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header pixel art
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: PixelColors.bgPanel,
                border: Border(
                  bottom: BorderSide(color: PixelColors.accent, width: 2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ' COCINA',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 13,
                      color: PixelColors.accent,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: PixelColors.bgCard,
                      border: Border.all(color: PixelColors.accent, width: 2),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          color: PixelColors.accent,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          gold.toStringAsFixed(0),
                          style: GoogleFonts.pressStart2p(
                            color: PixelColors.accent,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // DPS Total
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PixelColors.bgCard,
                border: Border.all(color: PixelColors.accentAlt, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.flash_on,
                    color: PixelColors.accentAlt,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'DPS: ${widget.gameController.gameState.getTotalSousChefDps().toStringAsFixed(1)}',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 10,
                      color: PixelColors.accentAlt,
                    ),
                  ),
                ],
              ),
            ),

            // Lista de Sous-chefs
            Expanded(
              child: sousChefs.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.restaurant,
                            size: 80,
                            color: Colors.brown.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay sous-chefs contratados',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.brown.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Desbloquea sous-chefs avanzando de nivel',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.brown.shade400,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: sousChefs.length,
                      itemBuilder: (context, index) {
                        final chef = sousChefs[index];
                        return _SousChefCard(
                          chef: chef,
                          playerGold: gold,
                          onHire: () => _hireSousChef(chef),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget para mostrar un Sous-chef
class _SousChefCard extends StatelessWidget {
  final SousChef chef;
  final double playerGold;
  final VoidCallback onHire;

  const _SousChefCard({
    required this.chef,
    required this.playerGold,
    required this.onHire,
  });

  @override
  Widget build(BuildContext context) {
    final canAfford = playerGold >= chef.currentCost;
    final dps = chef.getCurrentDps();

    final borderColor = canAfford ? PixelColors.accent : PixelColors.border;
    return GestureDetector(
      onTap: canAfford ? onHire : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: PixelColors.bgCard,
          border: Border.all(color: borderColor, width: 2),
          boxShadow: canAfford
              ? [
                  BoxShadow(
                    color: PixelColors.accent.withOpacity(0.3),
                    offset: const Offset(3, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            // Emoji elemento
            Container(
              width: 52,
              height: 52,
              color: Color(chef.element.getColor()).withOpacity(0.15),
              child: Center(
                child: Text(
                  chef.element.getEmoji(),
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chef.name.toUpperCase(),
                    style: GoogleFonts.pressStart2p(
                      fontSize: 8,
                      color: PixelColors.text,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'DPS: ${dps.toStringAsFixed(1)}  LVL:${chef.level}',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 7,
                      color: PixelColors.accentAlt,
                    ),
                  ),
                ],
              ),
            ),
            // Costo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: canAfford ? PixelColors.accent : PixelColors.border,
                border: Border.all(
                  color: canAfford ? Colors.white24 : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.monetization_on,
                        color: canAfford ? Colors.black : PixelColors.textDim,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        chef.currentCost.toStringAsFixed(0),
                        style: GoogleFonts.pressStart2p(
                          fontSize: 8,
                          color: canAfford ? Colors.black : PixelColors.textDim,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chef.level == 0 ? 'CONTRATAR' : 'MEJORAR',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 6,
                      color: canAfford ? Colors.black : PixelColors.textDim,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
