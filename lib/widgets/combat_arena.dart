import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flame/widgets.dart';
import 'package:flame/sprite.dart';
import 'package:flame/components.dart'; // Para Vector2
import '../models/player.dart';
import '../models/enemy.dart';
import '../models/projectile.dart';
import '../models/element_type.dart';
/// Widget que renderiza la arena de combate
class CombatArena extends StatelessWidget {
  final Player player;
  final Enemy enemy;
  final List<Projectile> projectiles;
  final bool isPaused;

  const CombatArena({
    super.key,
    required this.player,
    required this.enemy,
    required this.projectiles,
    this.isPaused = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Color de fondo basado en el elemento del enemigo
        final bgColors = _getBackgroundColors(enemy.element);
        
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: bgColors,
            ),
          ),
          child: Stack(
            children: [
              // Efecto de partículas elementales (decoración)
              ..._buildElementalParticles(enemy.element, constraints.biggest),
              
              // Proyectiles
              ...projectiles.map((proj) => _buildProjectile(proj)),
              
              // Enemigo
              if (enemy.isAlive) _buildEnemy(enemy),
              
              // Jugador
              if (player.isAlive) _buildPlayer(player),
            ],
          ),
        );
      },
    );
  }
  
  /// Obtiene colores de fondo según el elemento
  List<Color> _getBackgroundColors(ElementType element) {
    switch (element) {
      case ElementType.fire:
        return [Colors.red.shade900, Colors.orange.shade700, Colors.yellow.shade600];
      case ElementType.water:
        return [Colors.blue.shade900, Colors.blue.shade700, Colors.cyan.shade500];
      case ElementType.earth:
        return [Colors.brown.shade900, Colors.green.shade700, Colors.lime.shade600];
      case ElementType.master:
        return [Colors.purple.shade900, Colors.deepPurple.shade600, Colors.purpleAccent.shade200];
      case ElementType.neutral:
        return [Colors.indigo.shade900, Colors.indigo.shade700, Colors.indigo.shade500];
    }
  }
  
  /// Crea partículas decorativas según el elemento
  List<Widget> _buildElementalParticles(ElementType element, Size arenaSize) {
    final particles = <Widget>[];
    final random = math.Random(element.hashCode);

    final isNeutral = element == ElementType.neutral;
    final particleCount = isNeutral ? 6 : 4;

    for (int i = 0; i < particleCount; i++) {
      final left = random.nextDouble() * (arenaSize.width - 24).clamp(1.0, double.infinity);
      final top = random.nextDouble() * (arenaSize.height - 24).clamp(1.0, double.infinity);

      if (isNeutral) {
        final dotSize = 8.0 + random.nextDouble() * 10;
        particles.add(
          Positioned(
            left: left,
            top: top,
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      } else {
        particles.add(
          Positioned(
            left: left,
            top: top,
            child: Opacity(
              opacity: 0.12,
              child: Text(
                element.getEmoji(),
                style: TextStyle(fontSize: 26 + random.nextDouble() * 12),
              ),
            ),
          ),
        );
      }
    }
    
    return particles;
  }

  /// Construye el widget del jugador
  Widget _buildPlayer(Player player) {
    return Positioned(
      left: player.position.dx - (Player.spriteWidth / 2),
      top: player.position.dy - 40,
      child: Column(
        children: [
          // Barra de vida
          Container(
            width: 60,
            height: 6,
            decoration: BoxDecoration(
              color: Colors.red.shade900,
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: Colors.white70, width: 1),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (player.health / player.maxHealth).clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade600, Colors.lightGreen.shade400],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          
          // Chef con gorro y power mode
          Stack(
            alignment: Alignment.center,
            children: [
              // Glow effect cuando power está activo
              if (player.powerActive)
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.8),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              
              // Sprite del Paleto Animado
              Container(
                width: Player.spriteWidth,
                height: Player.spriteHeight,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                    // Glow effect si tiene power activo
                    if (player.powerActive)
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.6),
                        blurRadius: 15,
                        spreadRadius: 3,
                      ),
                  ],
                ),
                child: Image.asset(
                  'assets/images/paleto_spin.gif',
                  width: Player.spriteWidth,
                  height: Player.spriteHeight,
                  gaplessPlayback: true,
                ),
              ),
              
              // Indicador de power active (estrellas)
              if (player.powerActive)
                Positioned(
                  top: -10,
                  child: Row(
                    children: [
                      _buildStar(),
                      const SizedBox(width: 4),
                      _buildStar(),
                      const SizedBox(width: 4),
                      _buildStar(),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildStar() {
    return Icon(
      Icons.star,
      color: Colors.yellow,
      size: 12,
      shadows: [
        Shadow(
          color: Colors.orange,
          blurRadius: 4,
        ),
      ],
    );
  }

  /// Construye el widget del enemigo
  Widget _buildEnemy(Enemy enemy) {
    final elementColor = Color(enemy.element.getColor());
    final isBoss = enemy.isBoss;
    final enemySize = isBoss ? 100.0 : 80.0;
    
    return Positioned(
      left: enemy.position.dx - (enemySize / 2),
      top: enemy.position.dy - (enemySize / 2) - 30,
      child: Column(
        children: [
          // Corona si es Boss
          if (isBoss)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade700, Colors.yellow.shade400],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.6),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_events, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'BOSS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          
          if (isBoss) const SizedBox(height: 4),
          
          // Nombre del enemigo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: elementColor.withOpacity(0.8),
                width: 2,
              ),
            ),
            child: Text(
              enemy.name,
              style: TextStyle(
                color: elementColor,
                fontSize: isBoss ? 12 : 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          
          // Barra de vida
          Container(
            width: enemySize,
            height: isBoss ? 8 : 6,
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: elementColor.withOpacity(0.7),
                width: 2,
              ),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: enemy.healthPercentage,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getHealthColor(enemy.healthPercentage),
                      _getHealthColor(enemy.healthPercentage).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          
          // Amalgama Culinaria Mutante
          Stack(
            alignment: Alignment.center,
            children: [
              // Glow effect para boss
              if (isBoss)
                Container(
                  width: enemySize + 20,
                  height: enemySize + 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: elementColor.withOpacity(0.6),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                ),
              
              // Cuerpo del enemigo agitando el sprite
              SizedBox(
                width: enemySize,
                height: enemySize,
                child: SpriteAnimationWidget.asset(
                  playing: !isPaused,
                  path: 'enemigo.png', // Flame by default looks in assets/images/
                  data: SpriteAnimationData.sequenced(
                    amount: 4,
                    stepTime: 0.15,
                    textureSize: Vector2(1003 / 4, 249),
                  ),
                ),
              ),
              
              // Partículas flotantes alrededor
              if (isBoss) ..._buildBossParticles(enemySize, elementColor),
            ],
          ),
        ],
      ),
    );
  }
  
  /// Crea partículas flotantes alrededor del boss
  List<Widget> _buildBossParticles(double size, Color color) {
    return [
      Positioned(
        left: -size * 0.3,
        top: size * 0.2,
        child: _buildFloatingParticle(color, 8),
      ),
      Positioned(
        right: -size * 0.3,
        top: size * 0.2,
        child: _buildFloatingParticle(color, 10),
      ),
      Positioned(
        left: size * 0.1,
        bottom: -10,
        child: _buildFloatingParticle(color, 6),
      ),
    ];
  }
  
  Widget _buildFloatingParticle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withOpacity(0.7),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }

  /// Construye el widget de un proyectil
  Widget _buildProjectile(Projectile projectile) {
    if (!projectile.isActive) return const SizedBox.shrink();
    
    final isPlayerProj = projectile.isPlayerProjectile;
    final projColor = isPlayerProj ? Colors.cyan : Colors.orange.shade700;
    
    return Positioned(
      left: projectile.position.dx - 8,
      top: projectile.position.dy - 12,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Trail/estela del proyectil
          Container(
            width: 16,
            height: 24,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  projColor.withOpacity(0.8),
                  projColor.withOpacity(0.3),
                  projColor.withOpacity(0.0),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          
          // Proyectil principal (cuchillo para jugador, fuego para enemigo)
          Container(
            width: 12,
            height: 20,
            decoration: BoxDecoration(
              color: projColor,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(2),
                bottom: Radius.circular(6),
              ),
              boxShadow: [
                BoxShadow(
                  color: projColor.withOpacity(0.8),
                  blurRadius: 12,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                isPlayerProj ? Icons.arrow_upward : Icons.arrow_downward,
                color: Colors.white,
                size: 12,
              ),
            ),
          ),
          
          // Brillo central
          Positioned(
            top: 4,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.6),
                    blurRadius: 6,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Obtiene el color de la barra de vida según el porcentaje
  Color _getHealthColor(double percentage) {
    if (percentage > 0.6) return Colors.green;
    if (percentage > 0.3) return Colors.orange;
    return Colors.red;
  }
}
