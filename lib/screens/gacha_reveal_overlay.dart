import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/retro_style.dart';

class GachaRevealOverlay extends StatelessWidget {
  final Color rarityColor;
  final String rarityName;

  const GachaRevealOverlay({
    super.key,
    required this.rarityColor,
    required this.rarityName,
  });

  @override
  Widget build(BuildContext context) {
    const int dropDuration = 500;
    const int shakeWait = 200;
    const int shakeDuration = 600;
    const int flashTime = dropDuration + shakeWait + shakeDuration; 
    const int silhouetteWait = flashTime + 200; 
    const int revealTime = silhouetteWait + 1200; 

    return Material(
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 250,
            height: 250,
            color: rarityColor,
          )
          .animate(delay: revealTime.ms)
          .fadeIn(duration: 400.ms)
          .scaleXY(begin: 0.1, end: 1.0, duration: 400.ms, curve: Curves.easeOutBack)
          .then()
          .animate(onPlay: (controller) => controller.repeat())
          .rotate(duration: 4.seconds),

          const Icon(Icons.person, size: 150, color: Colors.white)
          .animate(delay: flashTime.ms) 
          .fadeIn(duration: 100.ms)
          .tint(color: Colors.black, begin: 1.0, end: 1.0, duration: 1.ms) 
          .then() 
          .slideY(begin: 0.1, end: -0.1, duration: (revealTime - flashTime).ms, curve: Curves.easeInOut)
          .then()
          .tint(color: Colors.black, begin: 1.0, end: 0.0, duration: 600.ms)
          .scaleXY(begin: 1.0, end: 1.2, duration: 400.ms, curve: Curves.easeOutBack),

          Container(
            width: 100, height: 100,
            decoration: RetroStyle.box(color: rarityColor),
            child: const Icon(Icons.all_inbox, size: 50, color: Colors.white),
          )
          .animate()
          .slideY(begin: -5.0, end: 0.0, duration: dropDuration.ms, curve: Curves.bounceOut)
          .then(delay: shakeWait.ms)
          .shake(hz: 8, curve: Curves.easeInOutCubic, duration: shakeDuration.ms)
          .then()
          .scaleXY(begin: 1.0, end: 3.0, duration: 100.ms)
          .fadeOut(duration: 100.ms),

          Container(color: Colors.white)
          .animate(delay: flashTime.ms)
          .fadeIn(duration: 50.ms)
          .then()
          .fadeOut(duration: 500.ms),

          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: RetroStyle.box(color: Colors.white),
                  child: Column(
                    children: [
                      Text("¡NUEVO HÉROE!", style: RetroStyle.font(size: 14, color: RetroStyle.primary)),
                      const SizedBox(height: 8),
                      Text("Héroe Aleatorio ($rarityName)", style: RetroStyle.font(size: 10)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatLine("ATK", "150", Colors.red),
                          _buildStatLine("SPD", "95", Colors.green),
                          _buildStatLine("HP", "300", Colors.blue),
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: RetroStyle.box(color: RetroStyle.accent),
                    child: Center(
                      child: Text("¡EQUIPAR!", style: RetroStyle.font(size: 12)),
                    ),
                  ),
                )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(begin: 1.0, end: 1.05, duration: 800.ms),
              ],
            )
            .animate(delay: (revealTime + 500).ms)
            .slideY(begin: 1.0, end: 0.0, duration: 600.ms, curve: Curves.easeOutBack)
            .fadeIn(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatLine(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: RetroStyle.font(size: 8, color: color)),
        const SizedBox(height: 4),
        Text(value, style: RetroStyle.font(size: 12)),
      ],
    );
  }
}
