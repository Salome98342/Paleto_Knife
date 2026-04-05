import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/retro_style.dart';

class ChefsView extends StatelessWidget {
  const ChefsView({super.key});

  @override
  Widget build(BuildContext context) {
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
            childAspectRatio: 0.75,
            children: [
              _buildChefCard("Chef Maestro", 5, "Rare", false),
              _buildChefCard("Pizza Monster", 1, "Epic", true),
              _buildChefCard("Ninja", 10, "Common", false),
              _buildChefCard("Robot", 1, "Legendary", true),
            ],
          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.2),
        ),
      ],
    );
  }

  Widget _buildChefCard(String name, int level, String rarity, bool isLocked) {
    Color rarityColor = _getRarityColor(rarity);

    return Stack(
      children: [
        Container(
          decoration: RetroStyle.box(color: RetroStyle.panel).copyWith(
            border: Border.all(color: rarityColor, width: 4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  color: Colors.grey.shade300,
                  child: const Center(child: Icon(Icons.person, size: 50)),
                ),
              ),
              Text(name, style: RetroStyle.font(size: 8), textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text("Lv. $level", style: RetroStyle.font(size: 8, color: rarityColor)),
              const SizedBox(height: 8),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6),
                margin: const EdgeInsets.symmetric(horizontal: 8).copyWith(bottom: 8),
                decoration: RetroStyle.box(color: RetroStyle.accent),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.arrow_upward, size: 12),
                      Text(" 500", style: RetroStyle.font(size: 8)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        if (isLocked)
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
