import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../widgets/retro_style.dart';
import '../controllers/world_controller.dart';

class WorldView extends StatelessWidget {
  const WorldView({super.key});

  @override
  Widget build(BuildContext context) {
    final world = context.watch<WorldController>();
    final loc = world.selectedLocation;

    return Padding(
      padding: const EdgeInsets.only(top: 80, bottom: 90, left: 16, right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text("MUNDO", style: RetroStyle.font(size: 16, color: Colors.white)),
          ),
          
          Container(
            height: 150,
            padding: const EdgeInsets.all(8),
            decoration: RetroStyle.box(color: Colors.grey.shade900),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: world.locations.length,
              itemBuilder: (context, index) {
                final l = world.locations[index];
                bool isSelected = loc == l;
                return GestureDetector(
                  onTap: () => world.selectLocation(l),
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        margin: const EdgeInsets.only(right: 12, top: 12),
                        padding: const EdgeInsets.all(8),
                        decoration: RetroStyle.box(
                          color: isSelected ? RetroStyle.primary : RetroStyle.panel,
                        ),
                        child: Center(
                          child: Text(
                            l.name, 
                            style: RetroStyle.font(size: 12, color: isSelected ? Colors.white : Colors.black),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      if (l.isAlert && !isSelected)
                        Positioned(
                          top: 0, right: 0,
                          child: const Icon(Icons.warning, color: Colors.red, size: 24)
                            .animate(onPlay: (c) => c.repeat(reverse: true)).scaleXY(begin: 1.0, end: 1.3, duration: 300.ms),
                        )
                    ],
                  ),
                );
              },
            ),
          ).animate().fadeIn(duration: 400.ms),
          
          const SizedBox(height: 16),
          
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: RetroStyle.box(color: Colors.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("LOCALIZACIÃ“N: ", style: RetroStyle.font(size: 10, color: Colors.black)),
                      Expanded(child: Text(loc.name, style: RetroStyle.font(size: 12, color: RetroStyle.primary))),
                      if (loc.isAlert)
                        const Icon(Icons.warning, color: Colors.red, size: 16)
                          .animate(onPlay: (c) => c.repeat()).shakeX(duration: 500.ms),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(loc.description, style: RetroStyle.font(size: 8, color: Colors.grey.shade800)),
                  
                  const SizedBox(height: 12),
                  // Barra de liberación
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("ESTADO DE LIBERACIÓN:", style: RetroStyle.font(size: 10, color: Colors.black)),
                      const SizedBox(height: 4),
                      Container(
                        height: 15,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (world.getLiberation(loc.name) / 100.0).clamp(0.0, 1.0),
                          child: Container(color: Colors.green),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("${world.getLiberation(loc.name).toStringAsFixed(0)}% LIBERADO", style: RetroStyle.font(size: 8, color: Colors.green.shade800)),
                          Text("${(100.0 - world.getLiberation(loc.name)).toStringAsFixed(0)}% RESTANTE", style: RetroStyle.font(size: 8, color: Colors.red.shade800)),
                        ],
                      ),
                    ],
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.0),
                    child: Divider(color: Colors.black, thickness: 2),
                  ),

                  Text("GLOSARIO DE AMALGAMAS", style: RetroStyle.font(size: 10, color: Colors.black)),
                  const SizedBox(height: 8),
                  
                  Expanded(
                    child: ListView.builder(
                      itemCount: loc.amalgams.length,
                      itemBuilder: (context, idx) {
                        final a = loc.amalgams[idx];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(a.icon, color: Colors.black, size: 24),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(a.name, style: RetroStyle.font(size: 8, color: RetroStyle.primary)),
                                    const SizedBox(height: 4),
                                    Text(a.description, style: RetroStyle.font(size: 6, color: Colors.black87)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ).animate().slideX(begin: 0.5, duration: 300.ms),
          ),
        ],
      ),
    );
  }
}


