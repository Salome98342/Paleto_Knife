import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../controllers/economy_controller.dart';
import '../utils/responsive_utils.dart';
import 'retro_style.dart';

class HudOverlay extends StatelessWidget {
  final dynamic game;
  const HudOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    // Padding responsivo
    final padding = ResponsiveUtils.spacing(context, 16);
    
    return SafeArea(
      child: IgnorePointer(
        ignoring: false,
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHealthAndWaveInfo(context),
                  _buildPauseButton(context),
                  _buildCoinDisplay(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPauseButton(BuildContext context) {
    // Botón responsivo
    final buttonSize = RetroStyle.responsiveButtonSize(context);
    final iconSize = RetroStyle.responsiveIconSize(context, 20);
    
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
        padding: EdgeInsets.all(buttonSize * 0.3),
        decoration: RetroStyle.responsiveBox(context, color: Colors.white),
        child: Icon(
          game.paused ? Icons.play_arrow : Icons.pause,
          color: RetroStyle.textDark,
          size: iconSize,
        ),
      ),
    );
  }

  Widget _buildHealthAndWaveInfo(BuildContext context) {
    final spacing = ResponsiveUtils.spacing(context, 8);
    final uiScale = ResponsiveUtils.getUIScaleFactor(context);
    final fontSize = RetroStyle.responsiveLabel(context, color: Colors.white);
    
    return Consumer<EconomyController>(
      builder: (context, economy, child) {
        double hp = economy.playerHp;
        double maxHp = economy.maxHp > 0 ? economy.maxHp : 1.0;
        double hpPercent = (hp / maxHp).clamp(0.0, 1.0);

        Color healthColor = hpPercent > 0.5
            ? Colors.green
            : hpPercent > 0.25
            ? Colors.orange
            : Colors.red;

        // Barras responsivas
        final barWidth = 120.0 * uiScale;
        final barHeight = 12.0 * uiScale;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: barWidth,
              height: barHeight,
              decoration: RetroStyle.responsiveBox(
                context,
                color: Colors.grey.shade800,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: barWidth * hpPercent,
                  height: double.infinity,
                  color: healthColor,
                ),
              ),
            ),
            SizedBox(height: spacing),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: spacing * 0.5,
                vertical: spacing * 0.25,
              ),
              decoration: RetroStyle.responsiveBox(
                context,
                color: Colors.black.withValues(alpha: 0.5),
              ).copyWith(boxShadow: []),
              child: Text(
                'WAVE ${game.currentWave}',
                style: fontSize,
              ),
            ),
          ],
        ).animate().slideX(
          begin: -0.5,
          duration: 400.ms,
          curve: Curves.easeOutBack,
        );
      },
    );
  }

  Widget _buildCoinDisplay(BuildContext context) {
    final spacing = ResponsiveUtils.spacing(context, 8);
    final fontSize = RetroStyle.responsiveBody(context, color: RetroStyle.textDark);
    final iconSize = RetroStyle.responsiveIconSize(context, 16);
    
    return Consumer<EconomyController>(
      builder: (context, economy, child) {
        return Container(
          padding: EdgeInsets.symmetric(
            horizontal: spacing * 0.75,
            vertical: spacing * 0.5,
          ),
          decoration: RetroStyle.responsiveBox(context, color: Colors.white),
          child: Row(
            children: [
              Text(
                '${economy.coins}',
                style: fontSize,
              ),
              SizedBox(width: spacing * 0.5),
              Icon(
                    Icons.monetization_on,
                    color: RetroStyle.accent,
                    size: iconSize,
                  )
                  .animate(key: ValueKey(economy.coins))
                  .scaleXY(begin: 1.5, end: 1.0, duration: 300.ms)
                  .shimmer(),
            ],
          ),
        ).animate().slideX(
          begin: 0.5,
          duration: 400.ms,
          curve: Curves.easeOutBack,
        );
      },
    );
  }
}
