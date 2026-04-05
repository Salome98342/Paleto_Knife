import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../widgets/retro_style.dart';

class QuestsView extends StatelessWidget {
  const QuestsView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Column(
        children: [
          Container(
            color: RetroStyle.background,
            child: TabBar(
              isScrollable: true,
              indicatorColor: RetroStyle.primary,
              indicatorWeight: 4,
              labelStyle: RetroStyle.font(size: 12, color: RetroStyle.primary),
              unselectedLabelStyle: RetroStyle.font(size: 10, color: Colors.grey),
              tabs: const [
                Tab(text: "LUN"), Tab(text: "MAR"), Tab(text: "MIE"),
                Tab(text: "JUE"), Tab(text: "VIE"), Tab(text: "SAB"), Tab(text: "DOM"),
              ],
            ),
          ),
          
          Expanded(
            child: TabBarView(
              children: List.generate(7, (index) => _buildQuestList()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestList() {
    return ListView(
      padding: const EdgeInsets.only(top: 100.0, left: 16.0, right: 16.0, bottom: 100.0), // Padding for Top HUD and Bottom Nav
      children: [
        _buildQuestCard("Juega 3 partidas", 3, 3, isCompleted: true),
        const SizedBox(height: 16),
        _buildQuestCard("Mejora a Chef Maestro", 0, 1, isCompleted: false),
        const SizedBox(height: 16),
        _buildQuestCard("Derrota 100 monstruos", 45, 100, isCompleted: false),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.2);
  }

  Widget _buildQuestCard(String title, int current, int target, {required bool isCompleted}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: RetroStyle.box(color: Colors.white),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: RetroStyle.font(size: 10)),
          const SizedBox(height: 12),
          
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
                          color: isFilled ? RetroStyle.primary : Colors.grey.shade300,
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Text("$current/$target", style: RetroStyle.font(size: 10)),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Align(
            alignment: Alignment.centerRight,
            child: isCompleted
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: RetroStyle.box(color: RetroStyle.accent),
                    child: Text("RECLAMAR", style: RetroStyle.font(size: 10)),
                  )
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .scaleXY(begin: 1.0, end: 1.05, duration: 600.ms)
                    .shimmer(duration: 1000.ms)
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: RetroStyle.box(color: Colors.grey.shade400),
                    child: Text("PENDIENTE", style: RetroStyle.font(size: 10, color: Colors.grey.shade700)),
                  ),
          ),
        ],
      ),
    );
  }
}
