import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class ExplosionHelper {
  static void spawn(
    FlameGame game,
    Vector2 position, {
    Color color = Colors.orangeAccent,
  }) {
    final random = math.Random();

    game.add(
      ParticleSystemComponent(
        position: position,
        particle: Particle.generate(
          count: 20,
          lifespan: 0.4, // Duracion muy corta, agil
          generator: (i) {
            final angle = random.nextDouble() * 2 * math.pi;
            final speed = random.nextDouble() * 150 + 50;
            return AcceleratedParticle(
              speed: Vector2(math.cos(angle), math.sin(angle)) * speed,
              position: Vector2.zero(), // Relativo al ParticleSystemComponent
              child: ComputedParticle(
                renderer: (canvas, particle) {
                  final paint = Paint()
                    ..color = color.withValues(alpha: 1.0 - particle.progress)
                    ..blendMode =
                        BlendMode.screen; // Da un brillo de neon (Game feel)

                  // El circulo se hace mas pequeno al ir desapareciendo
                  final radius = 4.0 * (1.0 - particle.progress);
                  canvas.drawCircle(Offset.zero, radius, paint);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
