import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/audio_service.dart';
import '../main.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  double _bgmVolume = AudioService.instance.bgmVolume;
  double _sfxVolume = AudioService.instance.sfxVolume;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: PixelColors.bgPanel,
          border: Border.all(color: PixelColors.accent, width: 4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ajustes de Sonido',
              style: GoogleFonts.pressStart2p(
                color: Colors.white,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            _buildSlider('Musica', _bgmVolume, (v) {
              setState(() => _bgmVolume = v);
              AudioService.instance.setBgmVolume(v);
            }),
            const SizedBox(height: 20),
            _buildSlider('Efectos', _sfxVolume, (v) {
              setState(() => _sfxVolume = v);
              AudioService.instance.setSfxVolume(v);
            }),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: PixelColors.health,
                side: const BorderSide(color: Colors.white, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'CERRAR',
                style: GoogleFonts.pressStart2p(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    ValueChanged<double> onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label: ${(value * 100).toInt()}%',
          style: GoogleFonts.pressStart2p(
            color: PixelColors.accentAlt,
            fontSize: 8,
          ),
        ),
        Slider(
          value: value,
          min: 0.0,
          max: 1.0,
          activeColor: PixelColors.accent,
          inactiveColor: PixelColors.textDim,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
