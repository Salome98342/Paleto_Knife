import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../controllers/economy_controller.dart';
import '../widgets/retro_style.dart';

class QuestsView extends StatefulWidget {
  const QuestsView({super.key});

  @override
  State<QuestsView> createState() => _QuestsViewState();
}

class _QuestsViewState extends State<QuestsView> {
  // Lista simulada de misiones con estados de "reclamado". En el futuro vendran de un backend o controller.
  final Map<String, bool> _claimedStatus = {};

  @override
  Widget build(BuildContext context) {
    final eco = context.watch<EconomyController>();

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 80.0), // Margen para el HUD general
            child: Container(
              decoration: RetroStyle.box(color: Colors.black54),
              child: TabBar(
                isScrollable: true,
                indicatorColor: RetroStyle.accent,
                indicatorWeight: 4,
                labelStyle: RetroStyle.font(size: 10, color: RetroStyle.accent),
                unselectedLabelStyle: RetroStyle.font(size: 8, color: Colors.grey),
                tabs: const [
                  Tab(text: "RETOS DIARIOS"), Tab(text: "SEMANALES"), Tab(text: "LOGROS"),
                ],
              ),
            ),
          ),
          
          Expanded(
            child: TabBarView(
              children: [
                _buildDailyQuests(eco),
                _buildDailyQuests(eco), // Placeholder para otras pestanas
                _buildDailyQuests(eco), // Placeholder
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyQuests(EconomyController eco) {
    return ListView(
      padding: const EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0, bottom: 100.0),
      children: [
        _buildQuestCard(
          id: "q1", 
          title: "Elimina a 50 Monstruos", 
          current: eco.monstersKilled, 
          target: 50, 
          reward: 25, 
          isGems: true
        ),
        const SizedBox(height: 16),
        _buildQuestCard(
          id: "q2", 
          title: "Sube de Nivel 1 Chef", 
          current: eco.chefsLeveledUp, 
          target: 1, 
          reward: 500, 
          isGems: false
        ),
        const SizedBox(height: 16),
        _buildQuestCard(
          id: "q3", 
          title: "Juega 3 partidas ('Game Overs')", 
          current: eco.gamesPlayed, 
          target: 3, 
          reward: 50, 
          isGems: true
        ),
        const SizedBox(height: 16),
        _buildQuestCard(
          id: "q4", 
          title: "Gasta 1000 Monedas", 
          current: eco.coinsSpent, 
          target: 1000, 
          reward: 3500, 
          isGems: false
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildQuestCard({
    required String id, 
    required String title, 
    required int current, 
    required int target, 
    required int reward, 
    required bool isGems
  }) {
    bool isCompleted = current >= target;
    bool isClaimed = _claimedStatus[id] ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: RetroStyle.box(color: isClaimed ? Colors.grey.shade400 : RetroStyle.panel).copyWith(
        border: Border.all(
          color: isClaimed ? Colors.grey.shade600 : (isCompleted ? RetroStyle.primary : Colors.black), 
          width: 4
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title, 
                  style: RetroStyle.font(size: 10, color: isClaimed ? Colors.grey.shade800 : RetroStyle.textDark),
                ),
              ),
              // Recompensa visual
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isClaimed ? Colors.grey.shade500 : Colors.black87,
                  border: Border.all(color: isGems ? Colors.purpleAccent : Colors.yellow, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(isGems ? Icons.diamond : Icons.monetization_on, 
                         size: 14, 
                         color: isClaimed ? Colors.grey : (isGems ? Colors.purpleAccent : Colors.yellow)),
                    const SizedBox(width: 4),
                    Text("+$reward", style: RetroStyle.font(
                      size: 8, 
                      color: isClaimed ? Colors.grey : (isGems ? Colors.purpleAccent : Colors.yellow),
                    )),
                  ],
                ),
              ).animate(target: isClaimed ? 0 : 1).shimmer(duration: 2.seconds),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: Row(
                  children: List.generate(10, (index) {
                    double progressRatio = current / target;
                    bool isFilled = index < (progressRatio * 10).floor();
                    return Expanded(
                      child: Container(
                        height: 12,
                        margin: const EdgeInsets.only(right: 2),
                        decoration: BoxDecoration(
                          color: isFilled ? (isClaimed ? Colors.grey : RetroStyle.primary) : Colors.black.withOpacity(0.3),
                          border: Border.all(color: Colors.black54, width: 2),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Text("$current/$target", style: RetroStyle.font(size: 8, color: isClaimed ? Colors.grey.shade700 : RetroStyle.textDark)),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Action Button
          Align(
            alignment: Alignment.centerRight,
            child: isClaimed 
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Text("RECLAMADO", style: RetroStyle.font(size: 10, color: Colors.grey.shade600)),
                  )
                : (isCompleted
                    ? GestureDetector(
                        onTap: () {
                          // Dar recompensas globalmente
                          final eco = context.read<EconomyController>();
                          if (isGems) {
                            eco.addGems(reward);
                          } else {
                            eco.addCoins(reward);
                          }

                          // Reproducir sonido e indicar cobro en la UI
                          setState(() {
                            _claimedStatus[id] = true;
                          });

                          RetroStyle.showSuccess(
                            context, 
                            "!MISION CUMPLIDA!\n+$reward ${isGems ? 'GEMAS' : 'MONEDAS'}",
                            icon: isGems ? Icons.diamond : Icons.monetization_on,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: RetroStyle.box(color: RetroStyle.accent).copyWith(
                            boxShadow: [
                              BoxShadow(color: RetroStyle.accent.withOpacity(0.8), blurRadius: 8, spreadRadius: 2)
                            ]
                          ),
                          child: Text("RECLAMAR", style: RetroStyle.font(size: 10, color: Colors.white)),
                        )
                        .animate(onPlay: (controller) => controller.repeat(reverse: true))
                        .scaleXY(begin: 1.0, end: 1.05, duration: 600.ms)
                        .shimmer(duration: 1000.ms, color: Colors.white54),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: RetroStyle.box(color: Colors.grey.shade400),
                        child: Text("PENDIENTE", style: RetroStyle.font(size: 10, color: Colors.grey.shade700)),
                      )),
          ),
        ],
      ),
    );
  }
}
