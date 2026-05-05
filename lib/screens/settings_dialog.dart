import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../controllers/settings_controller.dart';
import '../widgets/retro_style.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  late double _bgmVolume;
  late double _sfxVolume;

  @override
  void initState() {
    super.initState();
    _bgmVolume = AudioService.instance.bgmVolume;
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
                    size: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),

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

              // Divisor
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                color: RetroStyle.primary.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 20),

              // Sección de Tema
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Consumer<SettingsController>(
                  builder: (context, settingsController, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TEMA',
                          style: RetroStyle.font(
                            size: 14,
                            color: RetroStyle.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: RetroStyle.box(color: const Color(0xFF3a3a35)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'MODO',
                                    style: RetroStyle.font(
                                      size: 12,
                                      color: RetroStyle.textDark,
                                    ),
                                  ),
                                  Text(
                                    settingsController.isDarkMode ? 'OSCURO' : 'CLARO',
                                    style: RetroStyle.font(
                                      size: 12,
                                      color: RetroStyle.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: GestureDetector(
                                      onTap: settingsController.isDarkMode
                                          ? null
                                          : () => settingsController.setThemeMode('dark'),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        decoration: RetroStyle.box(
                                          color: settingsController.isDarkMode
                                              ? RetroStyle.primary
                                              : const Color(0xFF5a5a55),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'OSCURO',
                                            style: RetroStyle.font(
                                              size: 10,
                                              color: settingsController.isDarkMode
                                                  ? Colors.white
                                                  : RetroStyle.textDark,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    flex: 1,
                                    child: GestureDetector(
                                      onTap: settingsController.isDarkMode
                                          ? () => settingsController.setThemeMode('light')
                                          : null,
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        decoration: RetroStyle.box(
                                          color: !settingsController.isDarkMode
                                              ? RetroStyle.primary
                                              : const Color(0xFF5a5a55),
                                        ),
                                        child: Center(
                                          child: Text(
                                            'CLARO',
                                            style: RetroStyle.font(
                                              size: 10,
                                              color: !settingsController.isDarkMode
                                                  ? Colors.white
                                                  : RetroStyle.textDark,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
              ),

              // Sección de Tamaño de Fuente
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Consumer<SettingsController>(
                  builder: (context, settingsController, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TAMAÑO DE TEXTO',
                          style: RetroStyle.font(
                            size: 14,
                            color: RetroStyle.primary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: RetroStyle.box(color: const Color(0xFF3a3a35)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'TAMAÑO',
                                    style: RetroStyle.font(
                                      size: 12,
                                      color: RetroStyle.textDark,
                                    ),
                                  ),
                                  Text(
                                    '${(settingsController.fontSizeMultiplier * 100).toInt()}%',
                                    style: RetroStyle.font(
                                      size: 12,
                                      color: RetroStyle.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  // Botón Disminuir
                                  GestureDetector(
                                    onTap: settingsController.fontSizeMultiplier > 0.8
                                        ? () => settingsController.decreaseFontSize()
                                        : null,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: RetroStyle.box(
                                        color: settingsController.fontSizeMultiplier > 0.8
                                            ? const Color(0xFF5a5a55)
                                            : const Color(0xFF4a4a45),
                                      ),
                                      child: Text(
                                        'A-',
                                        style: RetroStyle.font(
                                          size: 12,
                                          color: settingsController.fontSizeMultiplier > 0.8
                                              ? RetroStyle.textDark
                                              : const Color(0xFF6a6a65),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Slider
                                  Expanded(
                                    child: Slider(
                                      value: settingsController.fontSizeMultiplier,
                                      min: 0.8,
                                      max: 1.4,
                                      divisions: 6,
                                      onChanged: (value) {
                                        settingsController.setFontSizeMultiplier(value);
                                      },
                                      activeColor: RetroStyle.primary,
                                      inactiveColor:
                                          RetroStyle.textLight.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Botón Aumentar
                                  GestureDetector(
                                    onTap: settingsController.fontSizeMultiplier < 1.4
                                        ? () => settingsController.increaseFontSize()
                                        : null,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 8,
                                      ),
                                      decoration: RetroStyle.box(
                                        color: settingsController.fontSizeMultiplier < 1.4
                                            ? const Color(0xFF5a5a55)
                                            : const Color(0xFF4a4a45),
                                      ),
                                      child: Text(
                                        'A+',
                                        style: RetroStyle.font(
                                          size: 12,
                                          color: settingsController.fontSizeMultiplier < 1.4
                                              ? RetroStyle.textDark
                                              : const Color(0xFF6a6a65),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  _buildSizeBadge(0.8, 'PEQUEÑO',
                                      settingsController.fontSizeMultiplier == 0.8),
                                  const SizedBox(width: 8),
                                  _buildSizeBadge(1.0, 'NORMAL',
                                      settingsController.fontSizeMultiplier == 1.0),
                                  const SizedBox(width: 8),
                                  _buildSizeBadge(1.2, 'GRANDE',
                                      settingsController.fontSizeMultiplier == 1.2),
                                  const SizedBox(width: 8),
                                  _buildSizeBadge(1.4, 'MUY GRANDE',
                                      settingsController.fontSizeMultiplier == 1.4),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  },
                ),
              ),

              // Botón Cerrar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: _buildMenuButton(
                  label: 'CERRAR',
                  onTap: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSizeBadge(double size, String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        final controller = context.read<SettingsController>();
        controller.setFontSizeMultiplier(size);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: RetroStyle.box(
          color: isActive ? RetroStyle.primary : const Color(0xFF5a5a55),
        ),
        child: Text(
          label,
          style: RetroStyle.font(
            size: 8,
            color: isActive ? Colors.white : RetroStyle.textDark,
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
                style: RetroStyle.font(size: 12, color: RetroStyle.textDark),
              ),
              Text(
                '${(_bgmVolume * 100).toInt()}%',
                style: RetroStyle.font(
                  size: 12,
                  color: RetroStyle.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            value: _bgmVolume,
            min: 0.0,
            max: 1.0,
            onChanged: (value) async {
              setState(() => _bgmVolume = value);
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
                style: RetroStyle.font(size: 12, color: RetroStyle.textDark),
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
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: RetroStyle.box(color: RetroStyle.primary),
        child: Center(
          child: Text(
            label,
            style: RetroStyle.font(
              size: 14,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
