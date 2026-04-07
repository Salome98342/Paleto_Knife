import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/game_controller.dart';
import '../main.dart';
import '../models/technique.dart';

/// Pantalla de Tecnicas - Mejoras del Chef
class TechniquesScreen extends StatefulWidget {
  final GameController gameController;

  const TechniquesScreen({super.key, required this.gameController});

  @override
  State<TechniquesScreen> createState() => _TechniquesScreenState();
}

class _TechniquesScreenState extends State<TechniquesScreen> {
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

  void _buyTechnique(Technique technique) {
    final success = widget.gameController.tryBuyTechnique(technique);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${technique.name} - Nivel ${technique.level}'),
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
    final techniques = widget.gameController.techniques;
    final gold = widget.gameController.gold;

    return Scaffold(
      backgroundColor: PixelColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                    ' TECNICAS',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 12,
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
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Stats del Chef
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: PixelColors.bgCard,
                border: Border.all(color: PixelColors.border, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ESTADISTICAS',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 9,
                      color: PixelColors.text,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _StatItem(
                        icon: Icons.flash_on,
                        label: 'Dano',
                        value: widget.gameController.baseDamage.toStringAsFixed(
                          0,
                        ),
                        color: Colors.red,
                      ),
                      _StatItem(
                        icon: Icons.speed,
                        label: 'Velocidad',
                        value: widget.gameController.attackSpeed
                            .toStringAsFixed(2),
                        color: Colors.blue,
                      ),
                      _StatItem(
                        icon: Icons.star,
                        label: 'Critico',
                        value:
                            '${(widget.gameController.critChance * 100).toStringAsFixed(0)}%',
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Lista de tecnicas
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: techniques.length,
                itemBuilder: (context, index) {
                  final technique = techniques[index];
                  return _TechniqueCard(
                    technique: technique,
                    playerGold: gold,
                    onBuy: () => _buyTechnique(technique),
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

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.pressStart2p(
            fontSize: 6,
            color: PixelColors.textDim,
          ),
        ),
        Text(value, style: GoogleFonts.pressStart2p(fontSize: 7, color: color)),
      ],
    );
  }
}

class _TechniqueCard extends StatelessWidget {
  final Technique technique;
  final double playerGold;
  final VoidCallback onBuy;

  const _TechniqueCard({
    required this.technique,
    required this.playerGold,
    required this.onBuy,
  });

  IconData _getIconForType(TechniqueType type) {
    switch (type) {
      case TechniqueType.damage:
        return Icons.flash_on;
      case TechniqueType.attackSpeed:
        return Icons.speed;
      case TechniqueType.critChance:
        return Icons.star;
      case TechniqueType.critDamage:
        return Icons.auto_awesome;
      case TechniqueType.accuracy:
        return Icons.gps_fixed;
      case TechniqueType.goldBonus:
        return Icons.monetization_on;
    }
  }

  Color _getColorForType(TechniqueType type) {
    switch (type) {
      case TechniqueType.damage:
        return Colors.red;
      case TechniqueType.attackSpeed:
        return Colors.blue;
      case TechniqueType.critChance:
        return Colors.orange;
      case TechniqueType.critDamage:
        return Colors.purple;
      case TechniqueType.accuracy:
        return Colors.green;
      case TechniqueType.goldBonus:
        return Colors.amber;
    }
  }

  @override
  Widget build(BuildContext context) {
    final canAfford = playerGold >= technique.currentCost;
    final color = _getColorForType(technique.type);

    final borderColor = canAfford ? color : PixelColors.border;
    return GestureDetector(
      onTap: canAfford ? onBuy : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: PixelColors.bgCard,
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            // Icono
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.2)),
              child: Icon(
                _getIconForType(technique.type),
                color: color,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),

            // Informacion
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    technique.name.toUpperCase(),
                    style: GoogleFonts.pressStart2p(
                      fontSize: 8,
                      color: PixelColors.text,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.trending_up, size: 12, color: color),
                      const SizedBox(width: 4),
                      Text(
                        'LVL:${technique.level}',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 7,
                          color: color,
                        ),
                      ),
                      if (technique.level > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '+${technique.totalEffect.toStringAsFixed(1)}',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 6,
                            color: PixelColors.textDim,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Boton de compra
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: canAfford ? PixelColors.accent : PixelColors.border,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.monetization_on,
                        color: canAfford ? Colors.black : PixelColors.textDim,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        technique.currentCost.toStringAsFixed(0),
                        style: GoogleFonts.pressStart2p(
                          color: canAfford ? Colors.black : PixelColors.textDim,
                          fontSize: 7,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'COMPRAR',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 6,
                    color: canAfford ? PixelColors.mana : PixelColors.textDim,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
