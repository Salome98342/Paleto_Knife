import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/retro_style.dart';
import 'gacha_reveal_overlay.dart';

class GachaStoreView extends StatelessWidget {
  const GachaStoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 100, bottom: 100),
      children: [
        Center(
          child: Text(
            "MERCADO NEGRO", 
            style: RetroStyle.font(size: 18, color: RetroStyle.accent)
          ).animate().slideY(begin: -0.5).fadeIn(duration: 500.ms),
        ),
        const SizedBox(height: 24),
        
        _buildChestCard(
          context,
          name: "Cofre Común",
          color: Colors.grey,
          icon: Icons.inventory_2,
          cost1x: 100,
          cost10x: 900,
        ).animate(delay: 100.ms).slideX(begin: 0.5).fadeIn(),

        const SizedBox(height: 20),

        _buildChestCard(
          context,
          name: "Cofre Raro",
          color: Colors.blue,
          icon: Icons.work,
          cost1x: 300,
          cost10x: 2700,
        ).animate(delay: 200.ms).slideX(begin: -0.5).fadeIn(),

        const SizedBox(height: 20),

        _buildChestCard(
          context,
          name: "Cofre Épico",
          color: Colors.purple,
          icon: Icons.all_inbox,
          cost1x: 800,
          cost10x: 7000,
        ).animate(delay: 300.ms).slideX(begin: 0.5).fadeIn(),
      ],
    );
  }

  Widget _buildChestCard(
    BuildContext context, {
    required String name,
    required Color color,
    required IconData icon,
    required int cost1x,
    required int cost10x,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: RetroStyle.box(color: RetroStyle.panel).copyWith(
        border: Border.all(color: color, width: 4),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, size: 48, color: color)
                .animate(onPlay: (controller) => controller.repeat(reverse: true))
                .slideY(begin: -0.1, end: 0.1, duration: 1.seconds),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  name,
                  style: RetroStyle.font(size: 12, color: RetroStyle.textDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildBuyButton(context, "1x", cost1x, color, name)),
              const SizedBox(width: 16),
              Expanded(child: _buildBuyButton(context, "10x", cost10x, color, name)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBuyButton(BuildContext context, String amount, int cost, Color color, String rarityInfo) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierColor: Colors.black87, 
          barrierDismissible: false, 
          builder: (_) => GachaRevealOverlay(rarityColor: color, rarityName: rarityInfo),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: RetroStyle.box(color: Colors.white),
        child: Column(
          children: [
            Text("Comprar $amount", style: RetroStyle.font(size: 8)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.diamond, color: Colors.purpleAccent, size: 12),
                Text(" $cost", style: RetroStyle.font(size: 10)),
              ],
            )
          ],
        ),
      ),
    ).animate(target: 1).scaleXY(end: 1, duration: 100.ms);
  }
}
