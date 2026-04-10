import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/element_type.dart';
import './retro_style.dart';

/// Tabla compacta de tipos (solo iconos con tooltips)
class ElementTypeTableWidget extends StatefulWidget {
  const ElementTypeTableWidget({Key? key}) : super(key: key);

  @override
  State<ElementTypeTableWidget> createState() => _ElementTypeTableWidgetState();
}

class _ElementTypeTableWidgetState extends State<ElementTypeTableWidget> {
  late Map<ElementType, ElementInfo> elementInfo;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _initializeElementInfo();
  }

  void _initializeElementInfo() {
    elementInfo = {
      ElementType.fire: ElementInfo(
        name: 'FUEGO',
        emoji: '🔥',
        color: Color(0xFFE74C3C),
        counters: ['AGUA'],
      ),
      ElementType.water: ElementInfo(
        name: 'AGUA',
        emoji: '💧',
        color: Color(0xFF3498DB),
        counters: ['TIERRA'],
      ),
      ElementType.earth: ElementInfo(
        name: 'TIERRA',
        emoji: '🪨',
        color: Color(0xFF795548),
        counters: ['FUEGO'],
      ),
      ElementType.wind: ElementInfo(
        name: 'VIENTO',
        emoji: '💨',
        color: Color(0xFF95A5A6),
        counters: ['TIERRA'],
      ),
      ElementType.lava: ElementInfo(
        name: 'LAVA',
        emoji: '🌋',
        color: Color(0xFFD35400),
        counters: ['AGUA'],
      ),
      ElementType.plant: ElementInfo(
        name: 'PLANTA',
        emoji: '🌱',
        color: Color(0xFF27AE60),
        counters: ['FUEGO'],
      ),
      ElementType.master: ElementInfo(
        name: 'MAESTRO',
        emoji: '👑',
        color: Color(0xFFFFD700),
        counters: [],
      ),
      ElementType.neutral: ElementInfo(
        name: 'NEUTRAL',
        emoji: '⚪',
        color: Color(0xFF95A5A6),
        counters: [],
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        decoration: RetroStyle.box(color: RetroStyle.panel),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título
            Text(
              'TABLA DE TIPOS',
              style: RetroStyle.font(size: 14, color: RetroStyle.textDark),
            ).animate().slideX(begin: -0.5, duration: 400.ms),
            const SizedBox(height: 20),

            // Grid compacto de solo iconos
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                childAspectRatio: 1.0,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: elementInfo.length,
              itemBuilder: (context, index) {
                final element = elementInfo.values.elementAt(index);
                final isHovered = _hoveredIndex == index;

                return MouseRegion(
                  onEnter: (_) {
                    setState(() => _hoveredIndex = index);
                  },
                  onExit: (_) {
                    setState(() => _hoveredIndex = null);
                  },
                  child: GestureDetector(
                    onTap: () {
                      // Mostrar detalles
                      _showElementDetail(context, element);
                    },
                    child: Tooltip(
                      message: element.name +
                          (element.counters.isNotEmpty
                              ? '\n⚔️ Débil a: ${element.counters.join(', ')}'
                              : '\n(Sin debilidad)'),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isHovered
                                ? element.color
                                : Colors.black,
                            width: isHovered ? 3 : 2,
                          ),
                          color: isHovered
                              ? element.color.withValues(alpha: 0.3)
                              : Colors.white,
                          boxShadow: isHovered
                              ? [
                                  BoxShadow(
                                    color: element.color.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                              : [],
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                element.emoji,
                                style: const TextStyle(fontSize: 40),
                              ).animate().scaleXY(
                                    begin: 1.0,
                                    end: isHovered ? 1.15 : 1.0,
                                    duration: 300.ms,
                                  ),
                              if (isHovered)
                                Column(
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      element.name,
                                      style: RetroStyle.font(
                                        size: 7,
                                        color: element.color,
                                      ),
                                    ).animate().fadeIn(duration: 200.ms),
                                    if (element.counters.isNotEmpty)
                                      Text(
                                        '⚔️',
                                        style: const TextStyle(fontSize: 10),
                                      ).animate().fadeIn(duration: 300.ms),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // Leyenda
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                color: RetroStyle.accent.withValues(alpha: 0.2),
              ),
              padding: const EdgeInsets.all(8),
              child: Text(
                'Toca un icono para más detalles | Rojo = Débil a otro tipo',
                style: RetroStyle.font(size: 7, color: RetroStyle.textDark),
                textAlign: TextAlign.center,
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
                    style: RetroStyle.font(size: 11, color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showElementDetail(BuildContext context, ElementInfo element) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          decoration: RetroStyle.box(color: RetroStyle.panel),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Elemento grande
              Text(
                element.emoji,
                style: const TextStyle(fontSize: 60),
              ).animate().scaleXY(begin: 0.5, end: 1.0, duration: 400.ms),

              const SizedBox(height: 12),

              // Nombre
              Text(
                element.name,
                style: RetroStyle.font(size: 14, color: element.color),
              ),

              const SizedBox(height: 16),

              // Debilidades
              if (element.counters.isNotEmpty) ...[
                Text(
                  '⚔️ DÉBIL A:',
                  style: RetroStyle.font(size: 10, color: RetroStyle.primary),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: element.counters.map((counter) {
                    final counterElement = elementInfo.values
                        .firstWhere((e) => e.name == counter);
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: counterElement.color,
                          width: 2,
                        ),
                        color:
                            counterElement.color.withValues(alpha: 0.2),
                      ),
                      child: Column(
                        children: [
                          Text(
                            counterElement.emoji,
                            style: const TextStyle(fontSize: 24),
                          ),
                          Text(
                            counter,
                            style: RetroStyle.font(
                              size: 8,
                              color: counterElement.color,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ] else
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    color: Colors.green.withValues(alpha: 0.2),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Text(
                    '✓ SIN DEBILIDAD CONOCIDA',
                    style:
                        RetroStyle.font(size: 9, color: Colors.green.shade700),
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
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      'CERRAR',
                      style: RetroStyle.font(size: 10, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ElementInfo {
  final String name;
  final String emoji;
  final Color color;
  final List<String> counters;

  ElementInfo({
    required this.name,
    required this.emoji,
    required this.color,
    required this.counters,
  });
}
