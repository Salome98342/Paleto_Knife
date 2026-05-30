import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';

/// Widget modal con ajustes de audio
/// Permite controlar volumen y habilitar/deshabilitar música y SFX
class AudioSettingsModal extends StatefulWidget {
  const AudioSettingsModal({super.key});

  @override
  State<AudioSettingsModal> createState() => _AudioSettingsModalState();

  /// Método para mostrar el modal
  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => const AudioSettingsModal(),
    );
  }
}

class _AudioSettingsModalState extends State<AudioSettingsModal> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double modalWidth = screenWidth > 400 ? 350.0 : screenWidth * 0.85;
    
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Center(
        child: Container(
          width: modalWidth,
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a1a),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: Colors.amber.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Consumer<AudioService>(
            builder: (context, audioManager, __) => SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Título
                  Text(
                    'AJUSTES DE AUDIO',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.amber[300],
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 28),

                  // Sección Música
                  _buildAudioSection(
                    context: context,
                    title: '♪ MÚSICA',
                    isEnabled: audioManager.musicEnabled,
                    volume: audioManager.musicVolume,
                    onToggle: (value) async {
                      try {
                        await audioManager.toggleMusic(value);
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al cambiar música: $e')),
                          );
                        }
                      }
                    },
                    onVolumeChange: (value) async {
                      try {
                        await audioManager.setMusicVolume(value);
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al ajustar volumen: $e')),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 24),

                  // Divisor
                  Container(
                    height: 1,
                    color: Colors.amber.withValues(alpha: 0.2),
                  ),
                  const SizedBox(height: 24),

                  // Sección Efectos
                  _buildAudioSection(
                    context: context,
                    title: '⚡ EFECTOS',
                    isEnabled: audioManager.sfxEnabled,
                    volume: audioManager.sfxVolume,
                    onToggle: (value) async {
                      try {
                        await audioManager.toggleSfx(value);
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al cambiar efectos: $e')),
                          );
                        }
                      }
                    },
                    onVolumeChange: (value) async {
                      try {
                        await audioManager.setSfxVolume(value);
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al ajustar efectos: $e')),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 32),

                  // Botón Cerrar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber[700],
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 8,
                      ),
                      child: const Text(
                        'CERRAR',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Construye una sección de control de audio (música o efectos)
  /// 
  /// Parámetros:
  /// - context: Contexto de build
  /// - title: Título de la sección (ej: '♪ MÚSICA')
  /// - isEnabled: Si la sección está habilitada
  /// - volume: Volumen actual (0.0 a 1.0)
  /// - onToggle: Callback cuando se activa/desactiva
  /// - onVolumeChange: Callback cuando cambia el volumen
  Widget _buildAudioSection({
    required BuildContext context,
    required String title,
    required bool isEnabled,
    required double volume,
    required ValueChanged<bool> onToggle,
    required ValueChanged<double> onVolumeChange,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Toggle y título
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.amber[300],
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
            Transform.scale(
              scale: 0.9,
              child: Switch(
                value: isEnabled,
                onChanged: onToggle,
                activeThumbColor: Colors.amber[400],
                inactiveThumbColor: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Slider de volumen
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(
              enabledThumbRadius: 10,
              elevation: 4,
            ),
            activeTrackColor: Colors.amber[400],
            inactiveTrackColor: Colors.grey[700],
            thumbColor: Colors.amber[400],
            overlayColor: Colors.amber.withValues(alpha: 0.3),
            valueIndicatorColor: Colors.amber[700],
            valueIndicatorTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: Semantics(
            slider: true,
            label: '$title Volumen',
            onIncrease: isEnabled && volume < 1.0 ? () => onVolumeChange(volume + 0.1) : null,
            onDecrease: isEnabled && volume > 0.0 ? () => onVolumeChange(volume - 0.1) : null,
            child: Slider(
              value: isEnabled ? volume : 0,
              onChanged: isEnabled ? onVolumeChange : null,
              min: 0,
              max: 1,
              divisions: 100,
              label: '${((isEnabled ? volume : 0) * 100).toStringAsFixed(0)}%',
            ),
          ),
        ),

        // Indicador de volumen en porcentaje
        Align(
          alignment: Alignment.centerRight,
          child: Semantics(
            label: 'Volumen actual ${isEnabled ? (volume * 100).toStringAsFixed(0) : "0"} por ciento',
            child: Text(
              '${isEnabled ? (volume * 100).toStringAsFixed(0) : "0"}%',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Botón flotante para acceder a los ajustes de audio
/// Úsalo en un Stack encima del GameWidget
class AudioSettingsButton extends StatelessWidget {
  /// Callback ejecutado al presionar el botón
  /// Si es null, abre automáticamente [AudioSettingsModal]
  final VoidCallback? onPressed;
  
  /// Color de fondo del botón flotante
  /// Por defecto: amber[700]
  final Color? backgroundColor;
  
  /// Color del icono del volumen
  /// Por defecto: Colors.black
  final Color? iconColor;

  const AudioSettingsButton({
    super.key,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16,
      right: 16,
      child: FloatingActionButton(
        onPressed: onPressed ?? () => AudioSettingsModal.show(context),
        backgroundColor: backgroundColor ?? Colors.amber[700],
        elevation: 8,
        tooltip: 'Ajustes de Audio',
        child: Semantics(
          button: true,
          label: 'Botón de ajustes de audio',
          child: Icon(
            Icons.volume_up,
            color: iconColor ?? Colors.black,
            size: 24,
          ),
        ),
      ),
    );
  }
}

/// Widget para mostrar en la pantalla de juego
/// Muestra el estado actual de música y SFX de forma compacta
class AudioStatusBar extends StatelessWidget {
  /// Alineación del indicador en la pantalla
  final Alignment alignment;
  
  /// Espaciado alrededor del indicador
  final EdgeInsets padding;

  const AudioStatusBar({
    super.key,
    this.alignment = Alignment.topRight,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: Padding(
        padding: padding,
        child: Consumer<AudioService>(
          builder: (context, audioManager, __) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Indicador Música
              Tooltip(
                message: 'Música: ${audioManager.musicEnabled ? "HABILITADA" : "DESHABILITADA"} (${(audioManager.musicVolume * 100).toStringAsFixed(0)}%)',
                child: Semantics(
                  label: 'Estado de música: ${audioManager.musicEnabled ? "habilitada" : "deshabilitada"} a ${(audioManager.musicVolume * 100).toStringAsFixed(0)} por ciento',
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: audioManager.musicEnabled
                          ? Colors.amber.withValues(alpha: 0.8)
                          : Colors.grey.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      audioManager.isMusicPlaying
                          ? Icons.music_note
                          : Icons.music_note_outlined,
                      color: audioManager.musicEnabled ? Colors.black : Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Indicador SFX
              Tooltip(
                message: 'Efectos: ${audioManager.sfxEnabled ? "HABILITADOS" : "DESHABILITADOS"} (${(audioManager.sfxVolume * 100).toStringAsFixed(0)}%)',
                child: Semantics(
                  label: 'Estado de efectos: ${audioManager.sfxEnabled ? "habilitados" : "deshabilitados"} a ${(audioManager.sfxVolume * 100).toStringAsFixed(0)} por ciento',
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: audioManager.sfxEnabled
                          ? Colors.amber.withValues(alpha: 0.8)
                          : Colors.grey.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.graphic_eq,
                      color: audioManager.sfxEnabled ? Colors.black : Colors.white,
                      size: 18,
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
