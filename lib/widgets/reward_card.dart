import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../main.dart'; // Para acceder a PixelColors
import '../controllers/chef_controller.dart';

/// Datos de la recompensa que muestra la carta
class RewardData {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final int rarityLevel; // 1-3: común, raro, épico

  const RewardData({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    this.rarityLevel = 2,
  });
}

/// Widget de carta de recompensa con animaciones sofisticadas
/// Se muestra como overlay sobre el canvas de Flame
class RewardCard extends StatefulWidget {
  final RewardData? rewardData;
  final GachaEntity? gachaEntity;
  final bool isGachaReward;
  final bool? isNewGacha;
  final int? tokensGranted;
  final VoidCallback? onDismiss;
  final Duration animationDuration;

  const RewardCard({
    super.key,
    required this.rewardData,
    this.onDismiss,
    this.animationDuration = const Duration(milliseconds: 800),
  }) : gachaEntity = null,
       isGachaReward = false,
       isNewGacha = null,
       tokensGranted = null;

  /// Constructor para mostrar recompensa de gacha (chef/arma)
  const RewardCard.fromGacha({
    super.key,
    required this.gachaEntity,
    required this.isNewGacha,
    required this.tokensGranted,
    this.onDismiss,
    this.animationDuration = const Duration(milliseconds: 800),
  }) : rewardData = null,
       isGachaReward = true;

  @override
  State<RewardCard> createState() => _RewardCardState();
}

class _RewardCardState extends State<RewardCard> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _shimmerController;
  late AnimationController _flashController;
  late List<AnimationController> _particleControllers;

  double _shimmerRotation = 0.0;

  /// Calcula la duración y efectos según rareza
  Duration _getAnimationDuration() {
    if (widget.isGachaReward) {
      final rarity = widget.gachaEntity!.rarity;
      switch (rarity) {
        case GachaRarity.Common:
          return const Duration(milliseconds: 600);
        case GachaRarity.Rare:
          return const Duration(milliseconds: 900);
        case GachaRarity.Epic:
          return const Duration(milliseconds: 1200);
        case GachaRarity.Legendary:
          return const Duration(milliseconds: 1600);
      }
    }
    return const Duration(milliseconds: 800);
  }

  @override
  void initState() {
    super.initState();

    final duration = _getAnimationDuration();

    // Controlador para la animación de escalado
    _scaleController = AnimationController(duration: duration, vsync: this);

    // Controlador para el efecto de brillo infinito
    _shimmerController = AnimationController(
      duration: Duration(seconds: widget.isGachaReward ? 2 : 3),
      vsync: this,
    )..repeat();

    // Controlador para el destello blanco (flash)
    _flashController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Crear controladores para partículas (si es legendario/épico)
    _particleControllers = [];
    if (widget.isGachaReward) {
      final rarity = widget.gachaEntity!.rarity;
      int particleCount = rarity == GachaRarity.Legendary
          ? 15
          : rarity == GachaRarity.Epic
          ? 10
          : 0;

      for (int i = 0; i < particleCount; i++) {
        final controller = AnimationController(
          duration: Duration(milliseconds: 800 + (i * 100)),
          vsync: this,
        );
        _particleControllers.add(controller);
      }
    }

    // Iniciar animaciones
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Ejecutar escala
    _scaleController.forward().then((_) {
      // Cuando la escala termina, ejecutar el flash
      _flashController.forward();
    });

    // Actualizar rotación del shimmer continuamente
    _shimmerController.addListener(() {
      setState(() {
        _shimmerRotation = _shimmerController.value * 2 * math.pi;
      });
    });

    // Animar partículas
    for (final controller in _particleControllers) {
      controller.forward();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _shimmerController.dispose();
    _flashController.dispose();
    for (final controller in _particleControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Obtiene el color del borde según la rareza
  Color _getRarityColor() {
    if (widget.isGachaReward) {
      return widget.gachaEntity!.rarityColor;
    }
    return widget.rewardData!.accentColor;
  }

  /// Construye las partículas de brillo para épico y legendario
  List<Widget> _buildParticles() {
    if (_particleControllers.isEmpty) return [];

    final random = math.Random(42); // Seed para reproducibilidad
    return List.generate(_particleControllers.length, (index) {
      final controller = _particleControllers[index];
      final angle = (index / _particleControllers.length) * 2 * math.pi;
      final distance = 150.0 + random.nextDouble() * 50;
      final dx = math.cos(angle) * distance;
      final dy = math.sin(angle) * distance;

      return AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final progress = controller.value;
          return Positioned(
            left: 160 + dx * progress - 4,
            top: 230 + dy * progress - 4,
            child: Opacity(
              opacity: (1.0 - progress).clamp(0.0, 1.0),
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _getRarityColor().withValues(alpha: 0.7),
                  boxShadow: [
                    BoxShadow(
                      color: _getRarityColor().withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }

  /// Construye el efecto de brillo (shimmer) rotante
  Widget _buildShimmerEffect() {
    return Transform.rotate(
      angle: _shimmerRotation,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                widget.isGachaReward &&
                    widget.gachaEntity!.rarity == GachaRarity.Legendary
                ? [
                    Colors.white.withValues(alpha: 0.5),
                    Colors.white.withValues(alpha: 0.2),
                    Colors.white.withValues(alpha: 0.0),
                  ]
                : [
                    Colors.white.withValues(alpha: 0.3),
                    Colors.white.withValues(alpha: 0.0),
                    Colors.white.withValues(alpha: 0.0),
                  ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
      ),
    );
  }

  /// Construye el efecto de destello (flash) blanco
  Widget _buildFlashEffect() {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: _flashController,
        builder: (context, child) {
          final opacity = (1.0 - _flashController.value).clamp(0.0, 1.0);

          // Múltiples flashes para legendario
          if (widget.isGachaReward &&
              widget.gachaEntity!.rarity == GachaRarity.Legendary) {
            // Pulse effect: múltiples flashes rápidos
            final pulse =
                (math.sin(_flashController.value * math.pi * 4) + 1) / 2;
            final finalOpacity = opacity * pulse * 0.6;

            return Visibility(
              visible: finalOpacity > 0.01,
              child: Container(
                color: Colors.white.withValues(alpha: finalOpacity),
              ),
            );
          }

          return Visibility(
            visible: opacity > 0.01,
            child: Container(
              color: Colors.white.withValues(alpha: opacity * 0.5),
            ),
          );
        },
      ),
    );
  }

  /// Construye el contenido principal de la carta
  Widget _buildCardContent() {
    final accentColor = widget.isGachaReward
        ? widget.gachaEntity!.rarityColor
        : widget.rewardData!.accentColor;

    return ScaleTransition(
      scale: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
      ),
      child: RotationTransition(
        turns: Tween<double>(begin: -0.02, end: 0.0).animate(
          CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
        ),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 280, maxHeight: 400),
          decoration: BoxDecoration(
            color: PixelColors.bgCard,
            border: Border.all(color: accentColor, width: 3),
            borderRadius: BorderRadius.zero,
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 5,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8),
                blurRadius: 30,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Fondo con patrón pixel
              _buildPixelBackground(accentColor: accentColor),

              // Contenido
              Padding(
                padding: const EdgeInsets.all(20),
                child: widget.isGachaReward
                    ? _buildGachaContent(accentColor)
                    : _buildCombatContent(accentColor),
              ),

              // Flash effect
              _buildFlashEffect(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCombatContent(Color accentColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Rareity indicator (stars)
        _buildRarityIndicator(widget.rewardData!.rarityLevel, accentColor),

        const SizedBox(height: 16),

        // Icono de la recompensa
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.15),
            border: Border.all(color: accentColor, width: 2),
            borderRadius: BorderRadius.zero,
          ),
          child: Icon(widget.rewardData!.icon, size: 40, color: accentColor),
        ),

        const SizedBox(height: 16),

        // Título
        Text(
          'RECOMPENSA',
          style: TextStyle(
            color: PixelColors.text,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),

        const SizedBox(height: 8),

        // Nombre de la recompensa
        Text(
          widget.rewardData!.title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: accentColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(height: 12),

        // Descripción
        Text(
          widget.rewardData!.description,
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: PixelColors.textDim,
            fontSize: 11,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 16),

        // Botón de aceptación
        _buildAcceptButton(accentColor),
      ],
    );
  }

  Widget _buildGachaContent(Color accentColor) {
    final entity = widget.gachaEntity!;
    final rarityStars = entity.rarity == GachaRarity.Common
        ? 1
        : entity.rarity == GachaRarity.Rare
        ? 2
        : entity.rarity == GachaRarity.Epic
        ? 3
        : 4;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Rareity indicator
        _buildRarityIndicator(rarityStars, accentColor),

        const SizedBox(height: 8),

        // Tipo de recompensa (Chef/Arma)
        Text(
          widget.isNewGacha! ? '¡NUEVO!' : 'DUPLICADO',
          style: TextStyle(
            color: widget.isNewGacha! ? Colors.greenAccent : Colors.orange,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),

        const SizedBox(height: 12),

        // Icono
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.15),
            border: Border.all(color: accentColor, width: 2),
            borderRadius: BorderRadius.zero,
          ),
          child: Icon(entity.icon, size: 40, color: accentColor),
        ),

        const SizedBox(height: 16),

        // Nombre
        Text(
          entity.isChef ? 'CHEF' : 'ARMA',
          style: const TextStyle(
            color: PixelColors.text,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          entity.name,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: accentColor,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        // Info adicional
        if (widget.isNewGacha!)
          Text(
            'Tokens obtenidos: ${widget.tokensGranted}',
            style: const TextStyle(color: PixelColors.textDim, fontSize: 10),
          )
        else
          Text(
            '+${widget.tokensGranted} tokens (duplicado)',
            style: const TextStyle(color: Colors.amber, fontSize: 10),
          ),

        const SizedBox(height: 12),

        // Botón
        _buildAcceptButton(accentColor),
      ],
    );
  }

  /// Construye el indicador de rareza (estrellas)
  Widget _buildRarityIndicator(int rarityLevel, Color accentColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        4,
        (index) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            index < rarityLevel ? Icons.star : Icons.star_outline,
            color: accentColor,
            size: 14,
          ),
        ),
      ),
    );
  }

  /// Construye el botón de aceptación con efecto hover
  Widget _buildAcceptButton(Color accentColor) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onDismiss,
        borderRadius: BorderRadius.zero,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: accentColor,
            border: Border.all(color: Colors.white, width: 1.5),
            borderRadius: BorderRadius.zero,
          ),
          child: const Text(
            'ACEPTAR',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  /// Construye un patrón pixel art de fondo
  Widget _buildPixelBackground({Color? accentColor}) {
    final color =
        accentColor ??
        (widget.isGachaReward
            ? widget.gachaEntity!.rarityColor
            : widget.rewardData!.accentColor);

    return Positioned.fill(
      child: CustomPaint(
        painter: _PixelPatternPainter(accentColor: color, opacity: 0.05),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Área de brillo rotante detrás de la carta (solo para épico/legendario)
        if (_particleControllers.isNotEmpty)
          Positioned.fill(
            child: Center(
              child: SizedBox(
                width: 320,
                height: 460,
                child: _buildShimmerEffect(),
              ),
            ),
          ),

        // Partículas de explosión (solo para épico/legendario)
        ..._buildParticles(),

        // Contenido de la carta
        Center(child: _buildCardContent()),
      ],
    );
  }
}

/// Painter para dibujar patrón pixel art en el fondo
class _PixelPatternPainter extends CustomPainter {
  final Color accentColor;
  final double opacity;

  _PixelPatternPainter({required this.accentColor, required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accentColor.withValues(alpha: opacity)
      ..strokeWidth = 1.0;

    const pixelSize = 8.0;

    // Dibujar patrón de cuadrícula de pixels
    for (double x = 0; x < size.width; x += pixelSize) {
      for (double y = 0; y < size.height; y += pixelSize) {
        // Alternar patrón de tablero
        if ((x.toInt() ~/ pixelSize.toInt() + y.toInt() ~/ pixelSize.toInt()) %
                2 ==
            0) {
          canvas.drawRect(
            Rect.fromLTWH(x + 1, y + 1, pixelSize - 2, pixelSize - 2),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_PixelPatternPainter oldDelegate) => false;
}
