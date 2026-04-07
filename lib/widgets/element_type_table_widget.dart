import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/element_type.dart';
import './retro_style.dart';

/// Tabla interactiva de tipos de elementos con sus counters
class ElementTypeTableWidget extends StatefulWidget {
  const ElementTypeTableWidget({Key? key}) : super(key: key);

  @override
  State<ElementTypeTableWidget> createState() => _ElementTypeTableWidgetState();
}

class _ElementTypeTableWidgetState extends State<ElementTypeTableWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Map<ElementType, ElementInfo> elementInfo;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _initializeElementInfo();
  }

  void _initializeElementInfo() {
    elementInfo = {
      ElementType.fire: ElementInfo(
        name: 'FUEGO',
        emoji: '🔥',
        color: Color(0xFFE74C3C),
        counters: ['AGUA'],
        description: 'Tipo ardiente y explosivo',
      ),
      ElementType.water: ElementInfo(
        name: 'AGUA',
        emoji: '💧',
        color: Color(0xFF3498DB),
        counters: ['TIERRA'],
        description: 'Tipo fluido y adaptable',
      ),
      ElementType.earth: ElementInfo(
        name: 'TIERRA',
        emoji: '🪨',
        color: Color(0xFF795548),
        counters: ['FUEGO'],
        description: 'Tipo sólido e inamovible',
      ),
      ElementType.wind: ElementInfo(
        name: 'VIENTO',
        emoji: '💨',
        color: Color(0xFF95A5A6),
        counters: ['TIERRA'],
        description: 'Tipo flotante y veloz',
      ),
      ElementType.lava: ElementInfo(
        name: 'LAVA',
        emoji: '🌋',
        color: Color(0xFFD35400),
        counters: ['AGUA'],
        description: 'Tipo devastador e inmune',
      ),
      ElementType.plant: ElementInfo(
        name: 'PLANTA',
        emoji: '🌱',
        color: Color(0xFF27AE60),
        counters: ['FUEGO'],
        description: 'Tipo regenerador y venenoso',
      ),
      ElementType.neutral: ElementInfo(
        name: 'NEUTRAL',
        emoji: '⚪',
        color: Color(0xFF95A5A6),
        counters: [],
        description: 'Tipo sin elemento definido',
      ),
    };
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        decoration: RetroStyle.box(color: RetroStyle.panel),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Título
                Text(
                  'TABLA DE TIPOS',
                  style: RetroStyle.font(size: 16, color: RetroStyle.textDark),
                )
                    .animate(onPlay: (c) => c.repeat())
                    .shimmer(
                      duration: 1000.ms,
                      color: RetroStyle.accent.withValues(alpha: 0.5),
                    ),
                const SizedBox(height: 16),

                // Grid de tipos
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: elementInfo.length,
                  itemBuilder: (context, index) {
                    final element = elementInfo.values.elementAt(index);
                    return _buildElementCard(element);
                  },
                ),

                const SizedBox(height: 16),

                // Leyenda
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    color: RetroStyle.accent.withValues(alpha: 0.2),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Text(
                        '⚔️ = Counter (Tipo que gana)',
                        style:
                            RetroStyle.font(size: 6, color: RetroStyle.textDark),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Botón cerrar
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      decoration: RetroStyle.box(color: RetroStyle.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'CERRAR',
                        style: RetroStyle.font(
                          size: 12,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildElementCard(ElementInfo element) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2),
        color: element.color.withValues(alpha: 0.15),
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Emoji y nombre
          Row(
            children: [
              Text(
                element.emoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  element.name,
                  style: RetroStyle.font(
                    size: 7,
                    color: element.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Descripción
          Text(
            element.description,
            style: RetroStyle.font(
              size: 5,
              color: RetroStyle.textDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Counters
          if (element.counters.isNotEmpty)
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  color: RetroStyle.accent.withValues(alpha: 0.3),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '⚔️ DEBIL A:',
                      style: RetroStyle.font(size: 5, color: RetroStyle.primary),
                    ),
                    const SizedBox(height: 2),
                    Wrap(
                      spacing: 2,
                      children: element.counters
                          .map((counter) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.black, width: 1),
                                  color: element.color,
                                ),
                                child: Text(
                                  counter,
                                  style: RetroStyle.font(
                                    size: 4,
                                    color: Colors.white,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: Center(
                child: Text(
                  'SIN DEBILIDAD',
                  style: RetroStyle.font(
                    size: 5,
                    color: RetroStyle.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ElementInfo {
  final String name;
  final String emoji;
  final Color color;
  final List<String> counters;
  final String description;

  ElementInfo({
    required this.name,
    required this.emoji,
    required this.color,
    required this.counters,
    required this.description,
  });
}
