import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../controllers/world_controller.dart';
import '../services/audio_service.dart';
import '../widgets/element_type_table_parchment.dart';
import '../widgets/enemy_card_widget.dart';
import '../widgets/pixel_art_icons.dart';
import '../widgets/retro_style.dart';

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
              'MUNDO',
              style: RetroStyle.font(size: 14, color: Colors.white),
            ),
          ),
          Container(
            height: 100,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF120D0A), Color(0xFF1E1711)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              border: Border.all(color: Colors.white24, width: 2),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: world.locations.length,
              itemBuilder: (context, index) {
                final location = world.locations[index];
                final isSelected = loc == location;
                return GestureDetector(
                  onTap: () {
                    AudioService.instance.playClickSound();
                    world.selectLocation(location);
                  },
                  child: Stack(
                    children: [
                      Container(
                        width: 114,
                        margin: const EdgeInsets.only(right: 12, top: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isSelected
                                ? [
                                    location.elementColor.withValues(alpha: 0.95),
                                    location.elementColor.withValues(alpha: 0.45),
                                  ]
                                : [
                                    Colors.black.withValues(alpha: 0.85),
                                    const Color(0xFF281C12),
                                  ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
                                : location.elementColor.withValues(alpha: 0.55),
                            width: isSelected ? 3 : 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: location.elementColor.withValues(alpha: 0.25),
                              blurRadius: isSelected ? 12 : 6,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              location.name,
                              style: RetroStyle.font(size: 10, color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              location.recommendedElement.toUpperCase(),
                              style: RetroStyle.font(size: 7, color: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      if (location.isAlert && !isSelected)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: const Icon(
                            Icons.warning,
                            color: Colors.orangeAccent,
                            size: 24,
                          )
                              .animate(onPlay: (c) => c.repeat(reverse: true))
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
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFF5F0E4),
                    loc.elementColor.withValues(alpha: 0.10),
                    Colors.white,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: loc.elementColor, width: 2),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Icon(
                          _regionBackdropIcon(loc.name),
                          size: 180,
                          color: loc.elementColor.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                            Container(
                              width: 6,
                              height: 48,
                              decoration: BoxDecoration(
                                color: loc.elementColor,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'REGION: ${loc.name.toUpperCase()}',
                                    style: RetroStyle.font(
                                      size: 10,
                                      color: loc.elementColor,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    loc.description,
                                    style: RetroStyle.font(
                                      size: 7,
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
                      Row(
                        children: [
                          Text(
                            'VENTAJA: ',
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
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: PixelArtIcons.getElementIcon(
                                    loc.recommendedElement,
                                    size: 14,
                                  ),
                                ),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'LIBERACION',
                                style: RetroStyle.font(size: 8, color: Colors.black),
                              ),
                              Text(
                                '${world.getLiberation(loc.name).toStringAsFixed(0)}%',
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
                              widthFactor: (world.getLiberation(loc.name) / 100.0)
                                  .clamp(0.0, 1.0),
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
                            'GLOSARIO',
                            style: RetroStyle.font(size: 9, color: Colors.black),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              AudioService.instance.playClickSound();
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
                              'TIPOS',
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
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: loc.elementColor.withValues(alpha: 0.08),
                                  border: Border.all(
                                    color: loc.elementColor.withValues(alpha: 0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'IDENTIDAD VISUAL: ${loc.name.toUpperCase()}',
                                  style: RetroStyle.font(
                                    size: 7,
                                    color: loc.elementColor,
                                  ),
                                ),
                              ),
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
                                    '👑 SOBERANOS',
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
                              if (loc.neutralEnemies.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFF999999),
                                      width: 2,
                                    ),
                                    color: const Color(0xFFB0B0B0)
                                        .withValues(alpha: 0.2),
                                  ),
                                  child: Text(
                                    '⚪ NEUTRALES',
                                    style: RetroStyle.font(
                                      size: 8,
                                      color: const Color(0xFF606060),
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
                ],
              ),
            ).animate().slideX(begin: 0.5, duration: 300.ms),
          ),
        ],
      ),
    );
  }

  IconData _regionBackdropIcon(String regionName) {
    switch (regionName) {
      case 'Asia':
        return Icons.local_fire_department;
      case 'Caribe':
        return Icons.water;
      case 'Europa':
        return Icons.nature;
      default:
        return Icons.public;
    }
  }
}
