import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/element_type.dart';
import './retro_style.dart';

/// Tabla de tipos mejorada y clara
class ElementTypeTableParchment extends StatefulWidget {
  const ElementTypeTableParchment({super.key});

  @override
  State<ElementTypeTableParchment> createState() =>
      _ElementTypeTableParchmentState();
}

class _ElementTypeTableParchmentState extends State<ElementTypeTableParchment> {
  late Map<ElementType, ElementInfo> elementInfo;
  ElementType? selectedElement;

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
        color: const Color(0xFFE74C3C),
        counters: ['AGUA'],
        advantage: 'TIERRA',
        description: 'Daña a la TIERRA. Es resistente a FUEGO.',
      ),
      ElementType.water: ElementInfo(
        name: 'AGUA',
        emoji: '💧',
        color: const Color(0xFF3498DB),
        counters: ['TIERRA'],
        advantage: 'FUEGO',
        description: 'Daña a FUEGO. Es resistente a AGUA.',
      ),
      ElementType.earth: ElementInfo(
        name: 'TIERRA',
        emoji: '🌿',
        color: const Color(0xFF795548),
        counters: ['FUEGO'],
        advantage: 'AGUA',
        description: 'Daña a AGUA. Es resistente a TIERRA.',
      ),
      ElementType.wind: ElementInfo(
        name: 'VIENTO',
        emoji: '💨',
        color: const Color(0xFF95A5A6),
        counters: ['TIERRA'],
        advantage: 'FUEGO',
        description: 'Elemento híbrido. Débil a TIERRA.',
      ),
      ElementType.lava: ElementInfo(
        name: 'LAVA',
        emoji: '🌋',
        color: const Color(0xFFD35400),
        counters: ['AGUA'],
        advantage: 'PLANTA',
        description: 'Elemento híbrido. Muy débil a AGUA.',
      ),
      ElementType.plant: ElementInfo(
        name: 'PLANTA',
        emoji: '🌱',
        color: const Color(0xFF27AE60),
        counters: ['FUEGO'],
        advantage: 'AGUA',
        description: 'Elemento híbrido. Muy débil a FUEGO.',
      ),
      ElementType.master: ElementInfo(
        name: 'MAESTRO',
        emoji: '⭐',
        color: const Color(0xFFFFD700),
        counters: [],
        advantage: 'TODOS',
        description: 'Domina todos los elementos. Sin debilidades.',
      ),
      ElementType.neutral: ElementInfo(
        name: 'NEUTRAL',
        emoji: '⚪',
        color: const Color(0xFF95A5A6),
        counters: [],
        advantage: 'NINGUNO',
        description: 'Sin elemento. Sin ventajas ni desventajas.',
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: _buildParchmentContent(),
    );
  }

  Widget _buildParchmentContent() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 700, maxHeight: 600),
      decoration: BoxDecoration(
        color: const Color(0xFFF5DEB3),
        border: Border.all(color: Colors.black, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 5,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Título
          Text(
            'TABLA DE ELEMENTOS',
            style: RetroStyle.font(size: 16, color: const Color(0xFF8B4513)),
            textAlign: TextAlign.center,
          ).animate().slideX(begin: -0.5, duration: 400.ms),
          
          const SizedBox(height: 20),

          // Tabla de elementos en filas
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: _buildElementRows(),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Descripción del elemento seleccionado
          if (selectedElement != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 2),
                color: elementInfo[selectedElement]!.color.withValues(alpha: 0.2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ℹ️ ${elementInfo[selectedElement]!.name}',
                    style: RetroStyle.font(
                      size: 10,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    elementInfo[selectedElement]!.description,
                    style: RetroStyle.font(
                      size: 8,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Botón cerrar
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 32),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 3),
                color: RetroStyle.primary,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    offset: const Offset(3, 3),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Text(
                'CERRAR',
                style: RetroStyle.font(size: 12, color: Colors.white),
              ),
            ).animate().scaleXY(begin: 0.8).fadeIn(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildElementRows() {
    final elements = elementInfo.entries.toList();
    final List<Widget> rows = [];

    // Encabezado
    rows.add(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.black, width: 2),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                '🎯',
                style: RetroStyle.font(size: 10, color: Colors.black),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'ELEMENTO',
                style: RetroStyle.font(size: 9, color: Colors.black),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'EFECTIVO VS',
                style: RetroStyle.font(size: 9, color: Colors.green.shade700),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                'DÉBIL A',
                style: RetroStyle.font(size: 9, color: Colors.red.shade700),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );

    // Filas de elementos
    for (int i = 0; i < elements.length; i++) {
      final element = elements[i].value;
      final type = elements[i].key;
      final isSelected = selectedElement == type;

      rows.add(
        GestureDetector(
          onTap: () {
            setState(() {
              selectedElement = isSelected ? null : type;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? element.color.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.5),
              border: Border(
                bottom: BorderSide(
                  color: Colors.black,
                  width: isSelected ? 2 : 1,
                ),
                left: isSelected
                    ? BorderSide(
                        color: Colors.red,
                        width: 3,
                      )
                    : BorderSide.none,
              ),
            ),
            child: Row(
              children: [
                // Icono
                SizedBox(
                  width: 40,
                  child: Center(
                    child: Text(
                      element.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                // Nombre
                Expanded(
                  flex: 2,
                  child: Text(
                    element.name,
                    style: RetroStyle.font(
                      size: 8,
                      color: Colors.black,
                    ),
                  ),
                ),
                // Efectivo vs
                Expanded(
                  flex: 2,
                  child: Text(
                    element.advantage,
                    style: RetroStyle.font(
                      size: 8,
                      color: Colors.green.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Débil a
                Expanded(
                  flex: 2,
                  child: Text(
                    element.counters.isNotEmpty
                        ? element.counters.join(', ')
                        : '-',
                    style: RetroStyle.font(
                      size: 8,
                      color: Colors.red.shade700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return rows;
  }
}

class ElementInfo {
  final String name;
  final String emoji;
  final Color color;
  final List<String> counters;
  final String advantage;
  final String description;

  ElementInfo({
    required this.name,
    required this.emoji,
    required this.color,
    required this.counters,
    required this.advantage,
    required this.description,
  });
}
