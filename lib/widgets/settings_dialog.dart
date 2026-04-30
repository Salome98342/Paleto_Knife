import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import 'retro_style.dart';

/// Diálogo de ajustes para gameplay
class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => const SettingsDialog(),
    );
  }

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late double _musicVolume;
  late double _sfxVolume;

  @override
  void initState() {
    super.initState();
    _musicVolume = AudioService.instance.bgmVolume;
    _sfxVolume = AudioService.instance.sfxVolume;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.88,
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: RetroStyle.box(color: RetroStyle.panel),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Título
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: RetroStyle.primary.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                ),
                child: Text(
                  'AJUSTES',
                  style: RetroStyle.font(
                    color: RetroStyle.primary,
                    size: 24,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 20),

              // Sección de Audio
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AUDIO',
                      style: RetroStyle.font(
                        size: 14,
                        color: RetroStyle.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildMusicVolumeControl(),
                    const SizedBox(height: 12),
                    _buildSfxVolumeControl(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // Botón Cerrar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: _buildMenuButton(
                  label: 'CERRAR',
                  backgroundColor: RetroStyle.primary,
                  textColor: Colors.white,
                  onTap: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMusicVolumeControl() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: RetroStyle.box(color: const Color(0xFF3a3a35)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MUSICA',
                style: RetroStyle.font(size: 12, color: RetroStyle.textLight),
              ),
              Text(
                '${(_musicVolume * 100).toInt()}%',
                style: RetroStyle.font(
                  size: 12,
                  color: RetroStyle.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: _musicVolume,
            min: 0.0,
            max: 1.0,
            onChanged: (value) async {
              setState(() => _musicVolume = value);
              await AudioService.instance.setMusicVolume(value);
            },
            activeColor: RetroStyle.primary,
            inactiveColor: RetroStyle.textLight.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildSfxVolumeControl() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: RetroStyle.box(color: const Color(0xFF3a3a35)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'EFECTOS',
                style: RetroStyle.font(size: 12, color: RetroStyle.textLight),
              ),
              Text(
                '${(_sfxVolume * 100).toInt()}%',
                style: RetroStyle.font(
                  size: 12,
                  color: RetroStyle.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: _sfxVolume,
            min: 0.0,
            max: 1.0,
            onChanged: (value) async {
              setState(() => _sfxVolume = value);
              await AudioService.instance.setSfxVolume(value);
            },
            activeColor: RetroStyle.primary,
            inactiveColor: RetroStyle.textLight.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuButton({
    required String label,
    required Color backgroundColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: backgroundColor.withValues(alpha: 0.7),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: RetroStyle.font(
              size: 14,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
