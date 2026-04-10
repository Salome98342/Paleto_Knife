import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../widgets/retro_style.dart';
import '../widgets/pixel_art_icons.dart';
import '../widgets/enemy_card_widget.dart';
import '../widgets/element_type_table_parchment.dart';
import '../controllers/world_controller.dart';

class WorldView extends StatelessWidget {
  const WorldView({super.key});

  @override
  Widget build(BuildContext context) {
    final world = context.watch<WorldController>();
    final loc = world.selectedLocation;

    return Padding(
      padding: const EdgeInsets.only(top: 60, bottom: 90, left: 12, right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Text(
              "MUNDO",
              style: RetroStyle.font(size: 14, color: Colors.white),
            ),
          ),

          Container(
            height: 100,
            padding: const EdgeInsets.all(6),
            decoration: RetroStyle.box(color: Colors.grey.shade900),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: world.locations.length,
              itemBuilder: (context, index) {
                final l = world.locations[index];
                bool isSelected = loc == l;
                return GestureDetector(
                  onTap: () => world.selectLocation(l),
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 12, top: 8),
                        padding: const EdgeInsets.all(6),
                        decoration: RetroStyle.box(
                          color: isSelected
                              ? RetroStyle.primary
                              : RetroStyle.panel,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l.name,
                              style: RetroStyle.font(
                                size: 11,
                                color: isSelected ? Colors.white : Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      if (l.isAlert && !isSelected)
                        Positioned(
                          top: 0,
                          right: 0,
                          child:
                              const Icon(
                                    Icons.warning,
                                    color: Colors.red,
                                    size: 24,
                                  )
                                  .animate(
                                    onPlay: (c) => c.repeat(reverse: true),
                                  )
                                  .scaleXY(
                                    begin: 1.0,
                                    end: 1.3,
                                    duration: 300.ms,
                                  ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ).animate().fadeIn(duration: 400.ms),

          const SizedBox(height: 8),

          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header temático de región
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      border: Border.all(color: loc.elementColor, width: 2),
                      color: loc.elementColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "REGIÓN: ${loc.name.toUpperCase()}",
                                style: RetroStyle.font(
                                  size: 10,
                                  color: loc.elementColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                loc.description,
                                style: RetroStyle.font(
                                  size: 6,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (loc.isAlert) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.warning, color: Colors.red, size: 24)
                              .animate(onPlay: (c) => c.repeat())
                              .scaleXY(
                                begin: 0.8,
                                end: 1.2,
                                duration: 500.ms,
                                curve: Curves.easeInOut,
                              ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Ventaja de elemento con icono pixel art
                  Row(
                    children: [
                      Text(
                        "VENTAJA: ",
                        style: RetroStyle.font(size: 8, color: Colors.black),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: loc.elementColor, width: 2),
                          color: loc.elementColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            SizedBox(width: 14, height: 14, child: PixelArtIcons.getElementIcon(loc.recommendedElement, size: 14)),
                            const SizedBox(width: 3),
                            Text(
                              loc.recommendedElement,
                              style: RetroStyle.font(
                                size: 8,
                                color: loc.elementColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Barra de liberación mejorada con altura 24px
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "LIBERACIÓN",
                            style: RetroStyle.font(size: 8, color: Colors.black),
                          ),
                          Text(
                            "${world.getLiberation(loc.name).toStringAsFixed(0)}%",
                            style: RetroStyle.font(
                              size: 8,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Container(
                        height: 16,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                          color: Colors.grey.shade200,
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (world.getLiberation(loc.name) / 100.0).clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  loc.elementColor.withValues(alpha: 0.7),
                                  loc.elementColor,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6.0),
                    child: Divider(color: Colors.black, thickness: 2),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "GLOSARIO",
                        style: RetroStyle.font(size: 9, color: Colors.black),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => const ElementTypeTableParchment(),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: RetroStyle.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                            side: const BorderSide(color: Colors.black, width: 2),
                          ),
                        ),
                        child: Text(
                          "TIPOS",
                          style: RetroStyle.font(size: 7, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Enemigos con elementos
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: loc.amalgams.length,
                            itemBuilder: (context, idx) {
                              final a = loc.amalgams[idx];
                              return EnemyCardWidget(
                                name: a.name,
                                description: a.description,
                                icon: a.icon,
                                element: a.element,
                                weakness: a.weakness,
                                isBoss: a.isBoss,
                                region: loc.name,
                                elementColor: loc.elementColor,
                                isNeutral: false,
                                enemyDefinition: a.enemyDefinition,
                              );
                            },
                          ),
                          // Sección de jefes si existen
                          if (loc.bosses.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.yellow.shade700,
                                  width: 2,
                                ),
                                color: Colors.yellow.withValues(alpha: 0.15),
                              ),
                              child: Text(
                                "👑 SOBERANOS",
                                style: RetroStyle.font(
                                  size: 8,
                                  color: Colors.yellow.shade700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: loc.bosses.length,
                              itemBuilder: (context, idx) {
                                final a = loc.bosses[idx];
                                return EnemyCardWidget(
                                  name: a.name,
                                  description: a.description,
                                  icon: a.icon,
                                  element: a.element,
                                  weakness: a.weakness,
                                  isBoss: true,
                                  region: loc.name,
                                  elementColor: Colors.yellow.shade700,
                                  isNeutral: false,
                                  enemyDefinition: a.enemyDefinition,
                                );
                              },
                            ),
                          ],
                          // Sección de neutrales si existen
                          if (loc.neutralEnemies.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(0xFF999999),
                                  width: 2,
                                ),
                                color: Color(0xFFB0B0B0).withValues(alpha: 0.2),
                              ),
                              child: Text(
                                "⚪ NEUTRALES",
                                style: RetroStyle.font(
                                  size: 8,
                                  color: Color(0xFF606060),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: loc.neutralEnemies.length,
                              itemBuilder: (context, idx) {
                                final a = loc.neutralEnemies[idx];
                                return EnemyCardWidget(
                                  name: a.name,
                                  description: a.description,
                                  icon: a.icon,
                                  element: a.element,
                                  weakness: a.weakness,
                                  isBoss: a.isBoss,
                                  region: loc.name,
                                  elementColor: loc.elementColor,
                                  isNeutral: true,
                                  enemyDefinition: a.enemyDefinition,
                                );
                              },
                            ),
                          ],
                        ],
                      ),
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
