import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/economy_controller.dart';
import 'retro_style.dart';

class HudOverlay extends StatelessWidget {
  final dynamic game;
  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: IgnorePointer(
        ignoring: false,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHealthAndWaveInfo(),
                  _buildPauseButton(),
                  _buildCoinDisplay(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPauseButton() {
    return GestureDetector(
      onTap: () {
        if (game.paused) {
          game.resumeEngine();
        } else {
          game.pauseEngine();
          if (!game.overlays.isActive('PauseMenu')) {
            game.overlays.add('PauseMenu');
          }
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: RetroStyle.box(color: Colors.white),
        child: Icon(
          game.paused ? Icons.play_arrow : Icons.pause,
          color: RetroStyle.textDark,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildHealthAndWaveInfo() {
    return Consumer<EconomyController>(
      builder: (context, economy, child) {
        int hp = (economy.playerHp > 0) ? economy.playerHp : 0;
        int maxHp = economy.maxHp > 0 ? economy.maxHp : 1;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
               children: List.generate(maxHp, (index) {
                return Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: RetroStyle.box(
                    color: index < hp ? RetroStyle.primary : Colors.grey.shade800,
                  ).copyWith(
                    boxShadow: []
                  ),
                ).animate(target: index < hp ? 0 : 1).shimmer(duration: 500.ms);
              }),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: RetroStyle.box(color: Colors.black.withOpacity(0.5)).copyWith(boxShadow: []),
              child: Text(
                'WAVE ${game.currentWave}',
                style: RetroStyle.font(size: 10, color: Colors.white),
              ),
            ),
          ],
        ).animate().slideX(begin: -0.5, duration: 400.ms, curve: Curves.easeOutBack);
      },
    );
  }

  Widget _buildCoinDisplay() {
    return Consumer<EconomyController>(
      builder: (context, economy, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: RetroStyle.box(color: Colors.white),
          child: Row(
            children: [
              Text(
                '${economy.coins}',
                style: RetroStyle.font(size: 12, color: RetroStyle.textDark),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.monetization_on, color: RetroStyle.accent, size: 16)
                .animate(key: ValueKey(economy.coins))
                .scaleXY(begin: 1.5, end: 1.0, duration: 300.ms)
                .shimmer(),
            ],
          ),
        ).animate().slideX(begin: 0.5, duration: 400.ms, curve: Curves.easeOutBack);
      },
    );
  }
}
