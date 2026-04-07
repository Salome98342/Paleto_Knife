import 'package:flutter/material.dart';
import 'retro_style.dart';

/// Tarjeta mejorada para mostrar enemigos en el glosario (Estética Retro)
class EnemyCardWidget extends StatefulWidget {
  final String name;
  final String description;
  final IconData icon;
  final String element;
  final String weakness;
  final bool isBoss;
  final String region;
  final Color elementColor;
  final bool isNeutral;

  const EnemyCardWidget({
    Key? key,
    required this.name,
    required this.description,
    required this.icon,
    required this.element,
    required this.weakness,
    required this.isBoss,
    required this.region,
    required this.elementColor,
    this.isNeutral = false,
  }) : super(key: key);

  @override
  State<EnemyCardWidget> createState() => _EnemyCardWidgetState();
}

class _EnemyCardWidgetState extends State<EnemyCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color getRegionBgColor() {
    switch (widget.region.toLowerCase()) {
      case 'asia':
        return Colors.red.shade900.withValues(alpha: 0.1);
      case 'caribe':
        return Colors.blue.shade900.withValues(alpha: 0.1);
      case 'europa':
        return Colors.green.shade900.withValues(alpha: 0.1);
      default:
        return Colors.grey.shade900.withValues(alpha: 0.1);
    }
  }

  Color getRegionBorder() {
    switch (widget.region.toLowerCase()) {
      case 'asia':
        return Colors.red.shade700;
      case 'caribe':
        return Colors.blue.shade700;
      case 'europa':
        return Colors.green.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  String getElementEmoji() {
    switch (widget.element.toLowerCase()) {
      case 'fire':
        return '🔥';
      case 'water':
        return '💧';
      case 'earth':
        return '🪨';
      case 'wind':
        return '💨';
      case 'lava':
        return '🌋';
      case 'plant':
        return '🌱';
      default:
        return '❓';
    }
  }

  String getWeaknessEmoji() {
    switch (widget.weakness.toLowerCase()) {
      case 'agua':
        return '💧';
      case 'tierra':
        return '🪨';
      case 'fuego':
        return '🔥';
      case 'viento':
        return '💨';
      default:
        return '❌';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: RetroStyle.box(
          color: widget.isNeutral 
              ? Color(0xFFB0B0B0).withValues(alpha: 0.4)
              : widget.elementColor.withValues(alpha: 0.15),
          isPressed: isHovered,
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // Icono con fondo retro
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 1),
                  color: widget.isNeutral
                      ? Color(0xFFE0E0E0)
                      : widget.elementColor.withValues(alpha: 0.3),
                ),
                child: Icon(
                  widget.icon,
                  color: widget.isNeutral
                      ? Color(0xFF808080)
                      : widget.elementColor,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre y badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.name,
                            style: RetroStyle.font(
                              size: 8,
                              color: widget.isNeutral
                                  ? Color(0xFF606060)
                                  : widget.elementColor,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.isBoss)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 3,
                              vertical: 1,
                            ),
                            decoration: RetroStyle.box(
                              color: RetroStyle.primary,
                            ),
                            child: Text(
                              '👑',
                              style: RetroStyle.font(size: 6),
                            ),
                          ),
                        if (widget.isNeutral)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 3,
                              vertical: 1,
                            ),
                            decoration: RetroStyle.box(
                              color: Color(0xFF999999),
                            ),
                            child: Text(
                              '⚪',
                              style: RetroStyle.font(size: 6),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    // Elemento y debilidad
                    Text(
                      '${getElementEmoji()} ${widget.element} → 🛡️ ${widget.weakness}',
                      style: RetroStyle.font(
                        size: 6,
                        color: RetroStyle.textDark,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Descripción
                    Text(
                      widget.description,
                      style: RetroStyle.font(
                        size: 5,
                        color: RetroStyle.textDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
