import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../widgets/retro_style.dart';
import '../controllers/economy_controller.dart';
import '../controllers/chef_controller.dart';
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
        
        // --- SECCIÓN: OFERTAS DEL DÍA ---
        _buildSectionTitle("OFERTAS DIARIAS", Icons.local_offer),
        _buildOfferCard(context, "Ficha Épica Aleatoria", "Obtén fragmentos garantizados", Icons.card_giftcard, 500),
        const SizedBox(height: 32),

        // --- SECCIÓN: RECLUTAMIENTO DE CHEFS ---
        _buildSectionTitle("RECLUTAR CHEFS", Icons.group_add),
        _buildChestCard(
          context,
          name: "Cofre Común (Chef)",
          color: Colors.grey,
          icon: Icons.inventory_2,
          cost1x: 100,
          cost10x: 900,
          isChef: true,
        ).animate(delay: 100.ms).slideX(begin: 0.5).fadeIn(),
        const SizedBox(height: 20),
        _buildChestCard(
          context,
          name: "Cofre Raro (Chef)",
          color: Colors.blue,
          icon: Icons.work,
          cost1x: 300,
          cost10x: 2700,
          isChef: true,
        ).animate(delay: 200.ms).slideX(begin: -0.5).fadeIn(),
        const SizedBox(height: 20),
        _buildChestCard(
          context,
          name: "Cofre Épico (Chef)",
          color: Colors.purple,
          icon: Icons.all_inbox,
          cost1x: 800,
          cost10x: 7000,
          isChef: true,
        ).animate(delay: 300.ms).slideX(begin: 0.5).fadeIn(),
        const SizedBox(height: 32),

        // --- SECCIÓN: FORJA DE CUCHILLOS ---
        _buildSectionTitle("FORJA DE CUCHILLOS", Icons.restaurant),
        _buildChestCard(
          context,
          name: "Cofre Común (Arma)",
          color: Colors.grey,
          icon: Icons.hardware,
          cost1x: 100,
          cost10x: 900,
          isChef: false,
        ).animate(delay: 100.ms).slideX(begin: -0.5).fadeIn(),
        const SizedBox(height: 20),
        _buildChestCard(
          context,
          name: "Cofre Raro (Arma)",
          color: Colors.blue,
          icon: Icons.construction,
          cost1x: 300,
          cost10x: 2700,
          isChef: false,
        ).animate(delay: 200.ms).slideX(begin: 0.5).fadeIn(),
        const SizedBox(height: 20),
        _buildChestCard(
          context,
          name: "Cofre Épico (Arma)",
          color: Colors.purple,
          icon: Icons.handyman,
          cost1x: 800,
          cost10x: 7000,
          isChef: false,
        ).animate(delay: 300.ms).slideX(begin: -0.5).fadeIn(),
        const SizedBox(height: 32),

        // --- SECCIÓN: BANCO / PREMIUM ---
        _buildSectionTitle("BANCO / PREMIUM", Icons.account_balance),
        _buildExchangeCard(context, "Saco de Monedas", "+10,000 Monedas", Icons.monetization_on, 100, isGemsCost: true),
        const SizedBox(height: 16),
        _buildExchangeCard(context, "Puñado de Gemas", "+500 Gemas", Icons.diamond, 1, isGemsCost: false, isRealMoney: true),
        _buildExchangeCard(context, "Cofre de Gemas", "+5,000 Gemas", Icons.diamond, 5, isGemsCost: false, isRealMoney: true),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: RetroStyle.primary, size: 24),
          const SizedBox(width: 8),
          Text(title, style: RetroStyle.font(size: 14, color: RetroStyle.textDark)),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: RetroStyle.primary, thickness: 2)),
        ],
      ),
    );
  }

  Widget _buildOfferCard(BuildContext context, String name, String subtitle, IconData icon, int cost) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: RetroStyle.box(color: Colors.white).copyWith(
        border: Border.all(color: Colors.amber, width: 4),
      ),
      child: Row(
        children: [
          Icon(icon, size: 40, color: Colors.amber)
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .scaleXY(end: 1.1, duration: 600.ms),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: RetroStyle.font(size: 12, color: RetroStyle.primary)),
                const SizedBox(height: 4),
                Text(subtitle, style: RetroStyle.font(size: 8, color: Colors.grey[700]!)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: RetroStyle.accent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            ),
            onPressed: () {
              final eco = context.read<EconomyController>();
              if (eco.gems >= cost) {
                eco.spendGems(cost);
                RetroStyle.showSuccess(context, "FICHA ADQUIRIDA", icon: Icons.card_giftcard);
              } else {
                RetroStyle.showInsufficient(context, "GEMAS INSUFICIENTES");
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.diamond, size: 14, color: Colors.white),
                const SizedBox(width: 4),
                Text("$cost", style: RetroStyle.font(size: 12, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExchangeCard(BuildContext context, String name, String subtitle, IconData icon, int cost, {required bool isGemsCost, bool isRealMoney = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: RetroStyle.box(color: RetroStyle.panel).copyWith(
        border: Border.all(color: isRealMoney ? Colors.green : Colors.grey, width: 2),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32, color: isGemsCost ? Colors.yellow : Colors.purpleAccent),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: RetroStyle.font(size: 12, color: RetroStyle.textDark)),
                const SizedBox(height: 4),
                Text(subtitle, style: RetroStyle.font(size: 10, color: RetroStyle.primary)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isRealMoney ? Colors.green : RetroStyle.accent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
            ),
            onPressed: () {
              final eco = context.read<EconomyController>();

              if (isRealMoney) {
                // Simular compra exitosa con dinero real (modo testing)
                if (name.contains("Puñado")) {
                  eco.addGems(500);
                } else if (name.contains("Cofre")) {
                  eco.addGems(5000);
                }
                RetroStyle.showSuccess(context, "¡$subtitle COMPRADOS!\nGRACIAS :)");
              } else if (isGemsCost) {
                // Comprando con Gemas
                if (eco.gems >= cost) {
                  eco.spendGems(cost);
                  // Añadir lo prometido (hack simple para el SACO DE MONEDAS que cuesta 100 y da +10,000)
                  if (name.contains("Monedas")) {
                    eco.addCoins(10000);
                  }
                  RetroStyle.showSuccess(context, "$name OBTENIDO", icon: Icons.monetization_on);
                } else {
                  RetroStyle.showInsufficient(context, "GEMAS INSUFICIENTES");
                }
              } else {
                // Comprando con dinero del juego / monedas (si existiese)
                if (eco.coins >= cost) {
                  eco.spendCoins(cost);
                  RetroStyle.showSuccess(context, "COMPRADO");
                } else {
                  RetroStyle.showInsufficient(context, "MONEDAS INSUFICIENTES");
                }
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isRealMoney) Icon(isGemsCost ? Icons.diamond : Icons.monetization_on, size: 14, color: Colors.white),
                if (!isRealMoney) const SizedBox(width: 4),
                Text(isRealMoney ? "\$$cost.99" : "$cost", style: RetroStyle.font(size: 12, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChestCard(
    BuildContext context, {
    required String name,
    required Color color,
    required IconData icon,
    required int cost1x,
    required int cost10x,
    required bool isChef,
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
              Expanded(child: _buildBuyButton(context, "1x", cost1x, color, name, isChef)),
              const SizedBox(width: 16),
              Expanded(child: _buildBuyButton(context, "10x", cost10x, color, name, isChef)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBuyButton(BuildContext context, String amount, int cost, Color color, String rarityInfo, bool isChef) {
    return GestureDetector(
      onTap: () {
        final eco = context.read<EconomyController>();
        final chefController = context.read<ChefController>();
        
        if (eco.gems >= cost) {
          eco.spendGems(cost);
          
          final rollAmount = amount == "1x" ? 1 : 10;
          
          final results = chefController.rollGacha(isChef, rollAmount);
          
          showDialog(
            context: context,
            barrierColor: Colors.black87, 
            barrierDismissible: false, 
            builder: (_) => GachaRevealOverlay(
              rarityColor: color, 
              rarityName: rarityInfo,
              results: results,
            ),
          );
        } else {
          RetroStyle.showInsufficient(context, "GEMAS INSUFICIENTES");
        }
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
