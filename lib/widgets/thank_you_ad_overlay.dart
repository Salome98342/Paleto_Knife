import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'retro_style.dart';

/// Overlay que muestra "Gracias por ver el anuncio" después de revivir
class ThankYouAdOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const ThankYouAdOverlay({
    super.key,
    required this.onComplete,
  });

  @override
  State<ThankYouAdOverlay> createState() => _ThankYouAdOverlayState();
}

class _ThankYouAdOverlayState extends State<ThankYouAdOverlay> {
  @override
  void initState() {
    super.initState();
    // Auto-cerrar después de 3 segundos
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        widget.onComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Container(
          width: 280,
          padding: const EdgeInsets.all(32),
          decoration: RetroStyle.box(
            color: RetroStyle.background,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icono de agradecimiento
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(color: RetroStyle.primary, width: 2),
                  color: RetroStyle.primary.withValues(alpha: 0.1),
                ),
                child: Center(
                  child: Icon(
                    Icons.favorite,
                    color: RetroStyle.primary,
                    size: 32,
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scaleXY(
                        begin: 1.0,
                        end: 1.2,
                        duration: 500.ms,
                      ),
                ),
              ),
              const SizedBox(height: 24),

              // Texto principal
              Text(
                '¡GRACIAS!',
                style: RetroStyle.font(
                  color: RetroStyle.primary,
                  size: 20,
                ),
                textAlign: TextAlign.center,
              )
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: -0.3),

              const SizedBox(height: 12),

              // Texto secundario
              Text(
                'Por ver el anuncio',
                style: RetroStyle.font(
                  color: Colors.white,
                  size: 12,
                ),
                textAlign: TextAlign.center,
              )
                  .animate(delay: 200.ms)
                  .fadeIn(duration: 400.ms),

              const SizedBox(height: 20),

              // Mensaje adicional
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: RetroStyle.accent,
                    width: 2,
                  ),
                  color: RetroStyle.accent.withValues(alpha: 0.1),
                ),
                child: Text(
                  '¡Has revivido con VIDA COMPLETA!',
                  style: RetroStyle.font(
                    color: RetroStyle.accent,
                    size: 10,
                  ),
                  textAlign: TextAlign.center,
                )
                    .animate(delay: 400.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.3),
              ),

              const SizedBox(height: 24),

              // Indicador de progreso
              Text(
                'Continuando en 3 segundos...',
                style: RetroStyle.font(
                  color: Colors.grey,
                  size: 8,
                ),
              )
                  .animate(delay: 600.ms, onPlay: (c) => c.repeat(reverse: true))
                  .fadeOut(duration: 1.5.seconds),
            ],
          ),
        )
            .animate()
            .slideY(
              begin: 1.0,
              end: 0.0,
              curve: Curves.easeOutBack,
              duration: 600.ms,
            )
            .scaleXY(
              begin: 0.9,
              end: 1.0,
              curve: Curves.easeOutBack,
              duration: 600.ms,
            ),
      ),
    );
  }
}
