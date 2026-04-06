import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/retro_style.dart';
import '../controllers/chef_controller.dart';
import 'dart:math';

class GachaRevealOverlay extends StatefulWidget {
  final Color rarityColor;
  final String rarityName;
  final List<RollResult> results;

  const GachaRevealOverlay({
    super.key,
    required this.rarityColor,
    required this.rarityName,
    required this.results,
  });

  @override
  State<GachaRevealOverlay> createState() => _GachaRevealOverlayState();
}

class _GachaRevealOverlayState extends State<GachaRevealOverlay> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.results.isEmpty) return const SizedBox();

    final currentResult = widget.results[currentIndex];
    final entity = currentResult.entity;
    final isDup = !currentResult.isNew;
    final tokens = currentResult.tokensGranted;

    final entityColor = () {
      switch (entity.rarity) {
        case GachaRarity.Common:
          return Colors.grey;
        case GachaRarity.Rare:
          return Colors.blue;
        case GachaRarity.Epic:
          return Colors.purple;
        case GachaRarity.Legendary:
          return Colors.amber;
      }
    }();

    const int dropDuration = 500;
    const int shakeWait = 200;
    const int shakeDuration = 600;
    const int flashTime = dropDuration + shakeWait + shakeDuration;
    const int silhouetteWait = flashTime + 200;
    const int revealTime = silhouetteWait + 1200;

    final random = Random(42);
    final sparkles = List.generate(20, (i) {
      double angle = random.nextDouble() * 2 * pi;
      double distance = random.nextDouble() * 150 + 100;
      double delayOffset = random.nextDouble() * 500;

      return Positioned(
        child:
            Icon(
                  Icons.star,
                  color: entityColor,
                  size: random.nextDouble() * 20 + 10,
                )
                .animate(
                  delay: (revealTime + delayOffset).ms,
                  onPlay: (c) => c.repeat(reverse: true),
                )
                .fadeIn(duration: 300.ms)
                .scaleXY(begin: 0.5, end: 1.5, duration: 500.ms)
                .slide(
                  begin: const Offset(0, 0),
                  end: Offset(
                    cos(angle) * distance / 50,
                    sin(angle) * distance / 50,
                  ),
                  duration: 1000.ms,
                ),
      );
    });

    return Material(
      key: ValueKey(currentIndex),
      color: Colors.transparent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ...sparkles,

          Container(width: 250, height: 250, color: entityColor)
              .animate(delay: revealTime.ms)
              .fadeIn(duration: 400.ms)
              .scaleXY(
                begin: 0.1,
                end: 1.0,
                duration: 400.ms,
                curve: Curves.easeOutBack,
              )
              .then()
              .animate(onPlay: (controller) => controller.repeat())
              .rotate(duration: 4.seconds),

          Icon(
                entity.isChef ? Icons.person : Icons.restaurant,
                size: 150,
                color: Colors.white,
              )
              .animate(delay: flashTime.ms)
              .fadeIn(duration: 100.ms)
              .tint(color: Colors.black, begin: 1.0, end: 1.0, duration: 1.ms)
              .then()
              .slideY(
                begin: 0.1,
                end: -0.1,
                duration: (revealTime - flashTime).ms,
                curve: Curves.easeInOut,
              )
              .then()
              .tint(color: Colors.black, begin: 1.0, end: 0.0, duration: 600.ms)
              .scaleXY(
                begin: 1.0,
                end: 1.2,
                duration: 400.ms,
                curve: Curves.easeOutBack,
              ),

          Container(
                width: 100,
                height: 100,
                decoration: RetroStyle.box(color: entityColor),
                child: const Icon(
                  Icons.all_inbox,
                  size: 50,
                  color: Colors.white,
                ),
              )
              .animate()
              .slideY(
                begin: -5.0,
                end: 0.0,
                duration: dropDuration.ms,
                curve: Curves.bounceOut,
              )
              .then(delay: shakeWait.ms)
              .shake(
                hz: 8,
                curve: Curves.easeInOutCubic,
                duration: shakeDuration.ms,
              )
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
            child:
                Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: RetroStyle.box(color: Colors.white),
                          child: Column(
                            children: [
                              Text(
                                entity.name.toUpperCase(),
                                style: RetroStyle.font(
                                  size: 14,
                                  color: RetroStyle.primary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "${entity.rarity.name.toUpperCase()} ${entity.isChef ? 'CHEF' : 'CUCHILLO'} ${isDup ? '\n\u00A1DUPLICADO!' : ''}",
                                textAlign: TextAlign.center,
                                style: RetroStyle.font(size: 10),
                              ),
                              if (isDup)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    "+${tokens} Tokens",
                                    style: RetroStyle.font(
                                      size: 12,
                                      color: Colors.amber,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: () {
                            if (currentIndex < widget.results.length - 1) {
                              setState(() => currentIndex++);
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                          child: Container(
                            width: 200,
                            padding: const EdgeInsets.all(16),
                            decoration: RetroStyle.box(
                              color: RetroStyle.primary,
                            ),
                            child: Center(
                              child: Text(
                                currentIndex < widget.results.length - 1
                                    ? "SIGUIENTE"
                                    : "CONTINUAR",
                                style: RetroStyle.font(
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                    .animate(delay: revealTime.ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.5, end: 0.0, curve: Curves.easeOutBack),
          ),
        ],
      ),
    );
  }
}
