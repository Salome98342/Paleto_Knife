import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/audio_service.dart';
import '../services/ad_service.dart';
import '../main.dart';

class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  double _bgmVolume = AudioService.instance.bgmVolume;
  double _sfxVolume = AudioService.instance.sfxVolume;
  bool _showAdTesting = false;
  late AdService _adService;

  @override
  void initState() {
    super.initState();
    _adService = AdService();
  }

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
              AudioService.instance.setMusicVolume(v);
            }),
            const SizedBox(height: 20),
            _buildSlider('Efectos', _sfxVolume, (v) {
              setState(() => _sfxVolume = v);
              AudioService.instance.setSfxVolume(v);
            }),
            const SizedBox(height: 30),
            
            // 🧪 TESTING DE ANUNCIOS
            _buildAdTestingSection(),
            
            const SizedBox(height: 20),
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

  /// Sección de Testing de Anuncios
  Widget _buildAdTestingSection() {
    return Column(
      children: [
        // Botón expandir/colapsar
        GestureDetector(
          onTap: () => setState(() => _showAdTesting = !_showAdTesting),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.orange.shade900,
              border: Border.all(color: Colors.orange, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _showAdTesting ? Icons.expand_less : Icons.expand_more,
                  color: Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '🧪 TESTING ANUNCIOS',
                  style: GoogleFonts.pressStart2p(
                    color: Colors.orange,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // Sección expandible
        if (_showAdTesting) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 30, 30, 40),
              border: Border.all(color: Colors.orange, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BANNER
                _buildAdTestButton(
                  label: 'BANNER (Inferior)',
                  icon: Icons.campaign,
                  color: Colors.blue,
                  onPressed: () {
                    final banner = _adService.getBanner();
                    if (banner != null && _adService.isBannerReady) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('✅ Banner listo para mostrar')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('⏳ Banner cargando...')),
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),

                // INTERSTITIAL
                _buildAdTestButton(
                  label: 'INTERSTITIAL (Fin de Misión)',
                  icon: Icons.fullscreen,
                  color: Colors.purple,
                  onPressed: () {
                    if (_adService.isInterstitialReady) {
                      _adService.showInterstitial();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('⏳ Interstitial cargando...')),
                      );
                    }
                  },
                ),
                const SizedBox(height: 8),

                // REWARDED GEMAS
                _buildAdTestButton(
                  label: 'REWARDED GEMAS (+10)',
                  icon: Icons.diamond,
                  color: Colors.cyan,
                  onPressed: () {
                    _adService.showRewardedGemas(() {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('💎 Recompensa: +10 GEMAS'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    });
                  },
                ),
                const SizedBox(height: 8),

                // REWARDED MONEDAS
                _buildAdTestButton(
                  label: 'REWARDED MONEDAS (x2)',
                  icon: Icons.attach_money,
                  color: Colors.amber,
                  onPressed: () {
                    _adService.showRewardedMonedas(() {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('💰 Recompensa: MONEDAS x2'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    });
                  },
                ),
                const SizedBox(height: 8),

                // REWARDED REVIVIR
                _buildAdTestButton(
                  label: 'REWARDED REVIVIR',
                  icon: Icons.favorite,
                  color: Colors.red,
                  onPressed: () {
                    _adService.showRewardedRevivir(() {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('❤️ Recompensa: REVIVIR'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    });
                  },
                ),
                const SizedBox(height: 8),

                // REWARDED GACHA
                _buildAdTestButton(
                  label: 'REWARDED GACHA',
                  icon: Icons.card_giftcard,
                  color: Colors.pink,
                  onPressed: () {
                    _adService.showRewardedGacha(() {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🎁 Recompensa: TIRADA GACHA'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    });
                  },
                ),

                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade900,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '📝 Estado:',
                    style: GoogleFonts.pressStart2p(
                      color: Colors.blue,
                      fontSize: 7,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                _buildStatusLine('Banner', _adService.isBannerReady),
                _buildStatusLine('Interstitial', _adService.isInterstitialReady),
                _buildStatusLine('Gemas', _adService.isRewardedGemasReady),
                _buildStatusLine('Monedas', _adService.isRewardedMonedasReady),
                _buildStatusLine('Revivir', _adService.isRewardedRevivirReady),
                _buildStatusLine('Gacha', _adService.isRewardedGachaReady),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Botón de prueba de anuncio
  Widget _buildAdTestButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color.withOpacity(0.3),
          side: BorderSide(color: color, width: 1),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 14),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.pressStart2p(
                color: color,
                fontSize: 7,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Línea de estado
  Widget _buildStatusLine(String name, bool isReady) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Icon(
            isReady ? Icons.check_circle : Icons.hourglass_empty,
            color: isReady ? Colors.green : Colors.orange,
            size: 12,
          ),
          const SizedBox(width: 6),
          Text(
            '$name:',
            style: GoogleFonts.pressStart2p(
              color: isReady ? Colors.green : Colors.orange,
              fontSize: 7,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isReady ? 'LISTO' : 'ESPERANDO',
            style: GoogleFonts.pressStart2p(
              color: isReady ? Colors.green : Colors.orange,
              fontSize: 6,
            ),
          ),
        ],
      ),
    );
  }
}
