import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../controllers/economy_controller.dart';
import '../controllers/game_controller.dart';
import '../controllers/chef_controller.dart';
import '../main.dart';

/// Pantalla de Perfil - Stats, Reinicio, Configuracion
class ProfileScreen extends StatefulWidget {
  final GameController gameController;

  const ProfileScreen({super.key, required this.gameController});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

  void _showResetDialog() {
    final resetState = widget.gameController.gameState.resetState;
    final tokensToGain = resetState.calculateTokensForReset(
      widget.gameController.currentLevel,
    );
    final canReset = resetState.canReset(widget.gameController.currentLevel);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(' Reinicio (Prestige)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (canReset) ...[
              Text(
                'Al reiniciar obtendras ${tokensToGain.toStringAsFixed(0)} tokens de reinicio.',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Perderas:\n- Nivel actual\n- Oro\n\nConservaras:\n- Tecnicas\n- Sous-chefs\n- Equipo\n- Monedas y Gemas',
              ),
            ] else ...[
              const Text(
                'Necesitas estar en nivel 150 o superior para reiniciar.',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          if (canReset)
            ElevatedButton(
              onPressed: () {
                widget.gameController.tryPerformReset();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('!Reinicio completado!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Reiniciar'),
            ),
        ],
      ),
    );
  }

  void _showFullResetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(' Reinicio Completo'),
        content: const Text(
          '?Estas seguro de que quieres borrar TODO el progreso?\n\n'
          'Esta accion NO se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.gameController.resetGame();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Juego reiniciado completamente'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Borrar Todo'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gameState = widget.gameController.gameState;
    final resetState = gameState.resetState;
    final ecoController = context.watch<EconomyController>();
    final chefController = context.watch<ChefController>();

    return Scaffold(
      backgroundColor: PixelColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: const BoxDecoration(
                  color: PixelColors.bgPanel,
                  border: Border(
                    bottom: BorderSide(color: PixelColors.accent, width: 2),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      child: IconButton(
                        icon: const Icon(
                          Icons.arrow_back,
                          color: PixelColors.text,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Column(
                      children: [
                        Icon(
                          chefController.activeChef.icon,
                          size: 62,
                          color: PixelColors.accent,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          chefController.activeChef.name.toUpperCase(),
                          style: GoogleFonts.pressStart2p(
                            fontSize: 11,
                            color: PixelColors.accent,
                          ),
                        ),
                        Text(
                          'NIVEL ${widget.gameController.currentLevel}',
                          style: GoogleFonts.pressStart2p(
                            color: PixelColors.textDim,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Stats del Chef
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
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
                        const Divider(),
                        _StatRow(
                          icon: Icons.flash_on,
                          label: 'Dano Base',
                          value: widget.gameController.baseDamage
                              .toStringAsFixed(1),
                          color: Colors.red,
                        ),
                        _StatRow(
                          icon: Icons.speed,
                          label: 'Velocidad de Ataque',
                          value: widget.gameController.attackSpeed
                              .toStringAsFixed(2),
                          color: Colors.blue,
                        ),
                        _StatRow(
                          icon: Icons.star,
                          label: 'Probabilidad de Critico',
                          value:
                              '${(widget.gameController.critChance * 100).toStringAsFixed(1)}%',
                          color: Colors.orange,
                        ),
                        _StatRow(
                          icon: Icons.auto_awesome,
                          label: 'Multiplicador de Critico',
                          value:
                              '${widget.gameController.critMultiplier.toStringAsFixed(2)}x',
                          color: Colors.purple,
                        ),
                        _StatRow(
                          icon: Icons.gps_fixed,
                          label: 'Precision',
                          value:
                              '${(widget.gameController.accuracy * 100).toStringAsFixed(1)}%',
                          color: Colors.green,
                        ),
                        _StatRow(
                          icon: Icons.monetization_on,
                          label: 'Bonus de Oro',
                          value:
                              '+${(widget.gameController.goldBonus * 100).toStringAsFixed(1)}%',
                          color: Colors.amber,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'STATS MINIJUEGO',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 7,
                            color: PixelColors.textDim,
                          ),
                        ),
                        const Divider(),
                        _StatRow(
                          icon: Icons.favorite,
                          label: 'Vida Maxima',
                          value: chefController.activeChef.currentHp
                              .toInt()
                              .toString(),
                          color: Colors.red,
                        ),
                        _StatRow(
                          icon: Icons.sports_martial_arts,
                          label: 'Dano Total (Chef + Arma)',
                          value: chefController
                              .getTotalDamage('')
                              .toStringAsFixed(1),
                          color: Colors.orange,
                        ),
                        _StatRow(
                          icon: Icons.timer,
                          label: 'Cadencia',
                          value:
                              '${chefController.activeChef.currentFireRate.toStringAsFixed(2)}s',
                          color: Colors.blueAccent,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Stats de Reinicio
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  color: PixelColors.bgCard,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'REINICIO',
                              style: GoogleFonts.pressStart2p(
                                fontSize: 9,
                                color: PixelColors.text,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: PixelColors.bgPanel,
                                border: Border.all(
                                  color: PixelColors.accent,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                '${resetState.resetTokens.toStringAsFixed(0)} tokens',
                                style: GoogleFonts.pressStart2p(
                                  color: PixelColors.accent,
                                  fontSize: 7,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        _StatRow(
                          icon: Icons.refresh,
                          label: 'Reinicios Totales',
                          value: resetState.totalResets.toString(),
                        ),
                        _StatRow(
                          icon: Icons.trending_up,
                          label: 'Nivel Mas Alto',
                          value: resetState.highestLevelReached.toString(),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _showResetDialog,
                            icon: const Icon(Icons.refresh),
                            label: Text(
                              'REALIZAR REINICIO',
                              style: GoogleFonts.pressStart2p(fontSize: 7),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Recursos
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'RECURSOS',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 9,
                            color: PixelColors.text,
                          ),
                        ),
                        const Divider(),
                        _StatRow(
                          icon: Icons.monetization_on,
                          label: 'Oro',
                          value: widget.gameController.gold.toStringAsFixed(0),
                          color: Colors.amber,
                        ),
                        _StatRow(
                          icon: Icons.circle,
                          label: 'Monedas',
                          value: ecoController.coins.toString(),
                          color: Colors.yellow,
                        ),
                        _StatRow(
                          icon: Icons.diamond,
                          label: 'Gemas',
                          value: ecoController.gems.toString(),
                          color: Colors.purpleAccent,
                        ),
                        _StatRow(
                          icon: Icons.restaurant,
                          label: 'Fragmentos de Cuchillo',
                          value: widget.gameController.knifeFragments
                              .toString(),
                          color: Colors.grey,
                        ),
                        _StatRow(
                          icon: Icons.inventory,
                          label: 'Cofres de Reliquia',
                          value: widget.gameController.relicChests.toString(),
                          color: Colors.brown,
                        ),
                        _StatRow(
                          icon: Icons.favorite,
                          label: 'Corazones de Culto',
                          value: widget.gameController.cultHearts.toString(),
                          color: Colors.redAccent,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Opciones
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.save),
                        title: Text(
                          'GUARDAR',
                          style: GoogleFonts.pressStart2p(fontSize: 8),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          widget.gameController.saveGame();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Progreso guardado'),
                              backgroundColor: Colors.green,
                              duration: Duration(milliseconds: 800),
                            ),
                          );
                        },
                      ),
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(
                          Icons.delete_forever,
                          color: PixelColors.danger,
                        ),
                        title: Text(
                          'BORRAR TODO',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 8,
                            color: PixelColors.danger,
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: _showFullResetDialog,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final rowColor = color ?? PixelColors.text;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: rowColor, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: GoogleFonts.pressStart2p(
                fontSize: 7,
                color: PixelColors.textDim,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.pressStart2p(fontSize: 7, color: rowColor),
          ),
        ],
      ),
    );
  }
}
