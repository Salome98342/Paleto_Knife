import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../widgets/retro_style.dart';
import '../widgets/pixel_art_icons.dart';
import '../controllers/economy_controller.dart';
import '../services/ad_service.dart';
import '../services/audio_service.dart';
import '../controllers/chef_controller.dart';
import 'gacha_reveal_overlay.dart';

class GachaStoreView extends StatelessWidget {
  const GachaStoreView({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 100,
        bottom: 100,
      ),
      children: [
        Center(
          child: Text(
            "TIENDA",
            style: RetroStyle.font(size: 18, color: RetroStyle.accent),
          ).animate().slideY(begin: -0.5).fadeIn(duration: 500.ms),
        ),
        const SizedBox(height: 24),

        // --- SECCION: OFERTAS PATROCINADAS (PROMINENTE) ---
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.orange, width: 3),
            color: Colors.orange.withValues(alpha: 0.1),
            boxShadow: [BoxShadow(color: Colors.orange.withValues(alpha: 0.3), blurRadius: 8, spreadRadius: 2)],
          ),
          child: Column(
            children: [
              PixelArtIcons.playIcon(size: 40),
              const SizedBox(height: 12),
              Text(
                "¡GANA GEMAS GRATIS!",
                style: RetroStyle.font(size: 12, color: Colors.orange[800]!),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "+10 GEMAS",
                style: RetroStyle.font(size: 14, color: Colors.orange),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero, side: const BorderSide(color: Colors.black, width: 2)),
                ),
                onPressed: () {
                  final eco = context.read<EconomyController>();
                  eco.addGems(10);
                  RetroStyle.showSuccess(context, "¡+10 GEMAS!", icon: Icons.diamond);
                },
                child: Text(
                  "VER",
                  style: RetroStyle.font(size: 12, color: Colors.white),
                ),
              ),
            ],
          ),
        ).animate().slideY(begin: -0.3, duration: 400.ms).fadeIn(),
        const SizedBox(height: 32),

        // --- SECCION: OFERTAS DIARIAS ---
        _buildSectionTitle("OFERTAS DIARIAS", PixelArtIcons.shopIcon()),
        _buildOfferCard(
          context,
          "Ficha Epica Aleatoria",
          "Obten fragmentos garantizados",
          Icons.card_giftcard,
          500,
        ),
        const SizedBox(height: 32),

        // --- SECCION: RECLUTAMIENTO DE CHEFS ---
        _buildSectionTitle(
          "RECLUTAR CHEFS",
          PixelArtIcons.chefIcon(),
          actionView: Builder(
            builder: (ctx) => GestureDetector(
              onTap: () => _showProbabilities(ctx),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: RetroStyle.accent.withValues(alpha: 0.2),
                  border: Border.all(color: RetroStyle.accent),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 12,
                      color: RetroStyle.accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "TASAS",
                      style: RetroStyle.font(size: 8, color: RetroStyle.accent),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        _buildChestCard(
          context,
          name: "Cofre Comun (Chef)",
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
          name: "Cofre Epico (Chef)",
          color: Colors.purple,
          icon: Icons.all_inbox,
          cost1x: 800,
          cost10x: 7000,
          isChef: true,
        ).animate(delay: 300.ms).slideX(begin: 0.5).fadeIn(),
        const SizedBox(height: 32),

        // --- SECCION: FORJA DE CUCHILLOS ---
        _buildSectionTitle(
          "FORJA DE CUCHILLOS",
          PixelArtIcons.questIcon(),
          actionView: Builder(
            builder: (ctx) => GestureDetector(
              onTap: () => _showProbabilities(ctx),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: RetroStyle.accent.withValues(alpha: 0.2),
                  border: Border.all(color: RetroStyle.accent),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 12,
                      color: RetroStyle.accent,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "TASAS",
                      style: RetroStyle.font(size: 8, color: RetroStyle.accent),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        _buildChestCard(
          context,
          name: "Cofre Comun (Arma)",
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
          name: "Cofre Epico (Arma)",
          color: Colors.purple,
          icon: Icons.handyman,
          cost1x: 800,
          cost10x: 7000,
          isChef: false,
        ).animate(delay: 300.ms).slideX(begin: -0.5).fadeIn(),
        const SizedBox(height: 32),

        // --- SECCION: BANCO / PREMIUM ---
        _buildSectionTitle("BANCO / PREMIUM", PixelArtIcons.gemIcon()),
        _buildAdCard(
          context,
          "Anuncio con Recompensa",
          "Recompensa: +10 Gemas",
          Icons.play_circle_fill,
        ),
        const SizedBox(height: 16),
        _buildExchangeCard(
          context,
          "Saco de Monedas",
          "+10,000 Monedas",
          Icons.monetization_on,
          100,
          isGemsCost: true,
        ),
        const SizedBox(height: 16),
        _buildExchangeCard(
          context,
          "Punado de Gemas",
          "+500 Gemas",
          Icons.diamond,
          1,
          isGemsCost: false,
          isRealMoney: true,
        ),
        _buildExchangeCard(
          context,
          "Cofre de Gemas",
          "+5,000 Gemas",
          Icons.diamond,
          5,
          isGemsCost: false,
          isRealMoney: true,
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSectionTitle(String title, Widget icon, {Widget? actionView}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          SizedBox(width: 24, height: 24, child: icon),
          const SizedBox(width: 8),
          Text(
            title,
            style: RetroStyle.font(size: 14, color: RetroStyle.textDark),
          ),
          if (actionView != null) ...[const SizedBox(width: 8), actionView],
          const SizedBox(width: 8),
          Expanded(child: Divider(color: RetroStyle.primary, thickness: 2)),
        ],
      ),
    );
  }

  Widget _buildOfferCard(
    BuildContext context,
    String name,
    String subtitle,
    IconData icon,
    int cost,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: RetroStyle.box(
        color: Colors.white,
      ).copyWith(border: Border.all(color: Colors.amber, width: 4)),
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
                Text(
                  name,
                  style: RetroStyle.font(size: 12, color: RetroStyle.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: RetroStyle.font(size: 8, color: Colors.grey[700]!),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: RetroStyle.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            onPressed: () {
              final eco = context.read<EconomyController>();
              if (eco.gems >= cost) {
                eco.spendGems(cost);
                RetroStyle.showSuccess(
                  context,
                  "FICHA ADQUIRIDA",
                  icon: Icons.card_giftcard,
                );
              } else {
                RetroStyle.showInsufficient(context, "GEMAS INSUFICIENTES");
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.diamond, size: 14, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  "$cost",
                  style: RetroStyle.font(size: 12, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExchangeCard(
    BuildContext context,
    String name,
    String subtitle,
    IconData icon,
    int cost, {
    required bool isGemsCost,
    bool isRealMoney = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: RetroStyle.box(color: RetroStyle.panel).copyWith(
        border: Border.all(
          color: isRealMoney ? Colors.green : Colors.grey,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 32,
            color: isGemsCost ? Colors.yellow : Colors.purpleAccent,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: RetroStyle.font(size: 12, color: RetroStyle.textDark),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: RetroStyle.font(size: 10, color: RetroStyle.primary),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isRealMoney ? Colors.green : RetroStyle.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            onPressed: () {
              final eco = context.read<EconomyController>();

              if (isRealMoney) {
                // Simular compra exitosa con dinero real (modo testing)
                if (name.contains("Punado")) {
                  eco.addGems(500);
                } else if (name.contains("Cofre")) {
                  eco.addGems(5000);
                }
                RetroStyle.showSuccess(
                  context,
                  "!$subtitle COMPRADOS!\nGRACIAS :)",
                );
              } else if (isGemsCost) {
                // Comprando con Gemas
                if (eco.gems >= cost) {
                  eco.spendGems(cost);
                  // Anadir lo prometido (hack simple para el SACO DE MONEDAS que cuesta 100 y da +10,000)
                  if (name.contains("Monedas")) {
                    eco.addCoins(10000);
                  }
                  RetroStyle.showSuccess(
                    context,
                    "$name OBTENIDO",
                    icon: Icons.monetization_on,
                  );
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
                if (!isRealMoney)
                  Icon(
                    isGemsCost ? Icons.diamond : Icons.monetization_on,
                    size: 14,
                    color: Colors.white,
                  ),
                if (!isRealMoney) const SizedBox(width: 4),
                Text(
                  isRealMoney ? "\$$cost.99" : "$cost",
                  style: RetroStyle.font(size: 12, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdCard(
    BuildContext context,
    String name,
    String subtitle,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: RetroStyle.box(
        color: RetroStyle.panel,
      ).copyWith(border: Border.all(color: Colors.amberAccent, width: 2)),
      child: Row(
        children: [
          Icon(icon, size: 32, color: Colors.amberAccent)
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(end: 1.1, duration: 800.ms),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: RetroStyle.font(size: 12, color: RetroStyle.textDark),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: RetroStyle.font(size: 10, color: RetroStyle.primary),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: RetroStyle.accent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(0),
              ),
            ),
            onPressed: () {
              final adService = AdService();
              if (adService.isRewardedGemasReady) {
                adService.showRewardedGemas(
                  () {
                    final eco = context.read<EconomyController>();
                    eco.addGems(10);
                    RetroStyle.showSuccess(
                      context,
                      "+10 GEMAS OBTENIDAS",
                      icon: Icons.diamond,
                    );
                  },
                );
              } else {
                RetroStyle.showInsufficient(
                  context,
                  "ANUNCIO NO DISPONIBLE. INTENTA MAS TARDE.",
                );
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_arrow, size: 14, color: Colors.white),
                const SizedBox(width: 4),
                Text(
                  "VER",
                  style: RetroStyle.font(size: 12, color: Colors.white),
                ),
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
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.8),
            color.withValues(alpha: 0.3),
            Colors.black.withValues(alpha: 0.9),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black45,
                  border: Border.all(color: color, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.6),
                      blurRadius: 15,
                    ),
                  ],
                ),
                child: Icon(icon, size: 40, color: Colors.white)
                    .animate(
                      onPlay: (controller) => controller.repeat(reverse: true),
                    )
                    .slideY(begin: -0.1, end: 0.1, duration: 1.seconds)
                    .shimmer(duration: 1500.ms, color: color),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name.toUpperCase(),
                      style: RetroStyle.font(size: 14, color: Colors.white)
                          .copyWith(
                            shadows: [Shadow(color: color, blurRadius: 10)],
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isChef
                          ? "Desbloquea chefs y sus habilidades"
                          : "Forja equipamiento para tu equipo",
                      style: RetroStyle.font(size: 8, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildBuyButton(
                  context,
                  "1 TIRADA",
                  cost1x,
                  color,
                  name,
                  isChef,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildBuyButton(
                  context,
                  "10 TIRADAS",
                  cost10x,
                  color,
                  name,
                  isChef,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBuyButton(
    BuildContext context,
    String amount,
    int cost,
    Color color,
    String rarityInfo,
    bool isChef,
  ) {
    return GestureDetector(
      onTap: () {
        final eco = context.read<EconomyController>();
        final chefController = context.read<ChefController>();

        if (eco.gems >= cost) {
          // Reproducir sonido de gacha
          AudioService.instance.playClickGacha();
          
          eco.spendGems(cost);

          final rollAmount = amount.contains("1 ") || amount == "1x" ? 1 : 10;

          final results = chefController.rollGacha(
            isChef,
            rollAmount,
            rarityInfo,
            eco,
          );

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
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          gradient: const LinearGradient(
            colors: [Colors.black87, Colors.black],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
        ),
        child: Column(
          children: [
            Text(amount, style: RetroStyle.font(size: 9, color: Colors.white)),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.diamond, color: Colors.purpleAccent, size: 14),
                Text(
                  " $cost",
                  style: RetroStyle.font(size: 12, color: Colors.amber),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate(target: 1).scaleXY(end: 1, duration: 100.ms);
  }

  void _showProbabilities(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: RetroStyle.box(
            color: RetroStyle.panel,
          ).copyWith(border: Border.all(color: RetroStyle.accent, width: 4)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "PROBABILIDADES OBTENCION",
                style: RetroStyle.font(size: 14, color: RetroStyle.accent),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _buildProbRow("COFRE COMUN", Colors.grey, [
                "Comun: 90%",
                "Raro: 10%",
              ]),
              _buildProbRow("COFRE RARO", Colors.blue, [
                "Comun: 60%",
                "Raro: 30%",
                "Epico: 10%",
              ]),
              _buildProbRow("COFRE EPICO", Colors.purple, [
                "Raro: 60%",
                "Epico: 30%",
                "Legendario: 10%",
              ]),
              _buildProbRow("COFRE LEGENDARIO", Colors.orange, [
                "Epico: 70%",
                "Legendario: 30%",
              ]),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  border: Border.all(color: Colors.amber),
                ),
                child: Column(
                  children: [
                    Text(
                      "- SISTEMA PITY -",
                      style: RetroStyle.font(size: 10, color: Colors.amber),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Cada 50 tiradas: Epico (SSR) Garantizado",
                      style: RetroStyle.font(size: 8, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "Cada 100 tiradas: Legendario (UR) Garantizado",
                      style: RetroStyle.font(size: 8, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: RetroStyle.primary,
                ),
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  "ENTENDIDO",
                  style: RetroStyle.font(size: 10, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProbRow(String name, Color color, List<String> rates) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black45,
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(name, style: RetroStyle.font(size: 10, color: color)),
          ),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: rates
                  .map(
                    (r) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        r,
                        style: RetroStyle.font(size: 8, color: Colors.white70),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
