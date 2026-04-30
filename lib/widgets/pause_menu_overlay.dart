import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../ui/theme/paleto_colors.dart';
import '../services/audio_service.dart';
import 'retro/retro_button.dart';
import 'retro_style.dart';
import 'settings_dialog.dart';

class PauseMenuOverlay extends StatefulWidget {
  final dynamic game;
  const PauseMenuOverlay({super.key, required this.game});

  @override
  State<PauseMenuOverlay> createState() => _PauseMenuOverlayState();
}

class _PauseMenuOverlayState extends State<PauseMenuOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.8, end: 1.0).animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.88,
            constraints: const BoxConstraints(maxWidth: 420),
            padding: const EdgeInsets.all(24),
            decoration: RetroStyle.box(color: RetroStyle.panel),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Título
                  Text(
                    'PAUSA',
                    style: RetroStyle.font(
                      color: RetroStyle.primary,
                      size: 28,
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .slideY(begin: -0.05, end: 0.05, duration: 1.seconds),
                  const SizedBox(height: 24),

                  // Control de volumen rápido
                  _buildQuickVolumeControl(),
                  const SizedBox(height: 20),

                  // Botones principales
                  _buildMenuButton(
                    label: 'CONTINUAR JUEGO',
                    backgroundColor: RetroStyle.primary,
                    onTap: () {
                      widget.game.resumeEngine();
                      widget.game.overlays.remove('PauseMenu');
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildMenuButton(
                    label: 'AJUSTES',
                    backgroundColor: const Color(0xFF3a3a35),
                    onTap: () {
                      widget.game.resumeEngine();
                      widget.game.overlays.remove('PauseMenu');
                      SettingsDialog.show(context);
                    },
                  ),
                  const SizedBox(height: 12),

                  _buildMenuButton(
                    label: 'SALIR A MENU',
                    backgroundColor: const Color(0xFF8B0000),
                    onTap: () {
                      widget.game.resumeEngine();
                      widget.game.overlays.remove('PauseMenu');
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickVolumeControl() {
    final audioService = AudioService.instance;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: RetroStyle.box(color: const Color(0xFF3a3a35)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VOLUMEN: ${(audioService.masterVolume * 100).toInt()}%',
            style: RetroStyle.font(size: 12),
          ),
          const SizedBox(height: 12),
          Slider(
            value: audioService.masterVolume,
            onChanged: (value) async {
              setState(() {});
              await audioService.setMasterVolume(value);
            },
            activeColor: RetroStyle.primary,
            inactiveColor: RetroStyle.textLight.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildVolumeQuickButton(
                    'MUSICA', audioService.musicEnabled, () async {
                  setState(() {});
                  await audioService.toggleMusic(!audioService.musicEnabled);
                }),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildVolumeQuickButton('EFECTOS', audioService.sfxEnabled,
                    () async {
                  setState(() {});
                  await audioService.toggleSfx(!audioService.sfxEnabled);
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeQuickButton(
      String label, bool isActive, VoidCallback onTap) {
    return RetroButton(
      label: label,
      onPressed: onTap,
      baseColor: isActive ? PaletoColors.btnPrimary : PaletoColors.btnNeutral,
      lightBorder: isActive ? PaletoColors.btnPrimaryLt : PaletoColors.btnNeutralLt,
      darkBorder: isActive ? PaletoColors.btnPrimaryDk : PaletoColors.btnNeutralDk,
    );
  }

  Widget _buildMenuButton({
    required String label,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    final bool isNeutral = backgroundColor == const Color(0xFF3a3a35);
    return SizedBox(
      width: double.infinity,
      child: RetroButton(
        label: label,
        onPressed: onTap,
        baseColor: isNeutral ? PaletoColors.btnNeutral : PaletoColors.btnPrimary,
        lightBorder: isNeutral ? PaletoColors.btnNeutralLt : PaletoColors.btnPrimaryLt,
        darkBorder: isNeutral ? PaletoColors.btnNeutralDk : PaletoColors.btnPrimaryDk,
      ),
    );
  }
}
