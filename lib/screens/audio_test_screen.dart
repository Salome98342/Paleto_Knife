import 'package:flutter/material.dart';
import '../services/audio_service.dart';

/// Pantalla de prueba de audio - DEBUG ONLY
/// Muestra botones para probar cada sonido
class AudioTestScreen extends StatefulWidget {
  const AudioTestScreen({super.key});

  @override
  State<AudioTestScreen> createState() => _AudioTestScreenState();
}

class _AudioTestScreenState extends State<AudioTestScreen> {
  String _status = 'Estado: no inicializado';
  
  @override
  void initState() {
    super.initState();
    _checkAudioStatus();
  }

  Future<void> _checkAudioStatus() async {
    await AudioService.instance._ensureInitialized();
    setState(() {
      _status = 'AudioService._initialized = ${AudioService.instance._initialized}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('🔊 Test de Audio')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status
            Container(
              color: Colors.grey[900],
              padding: const EdgeInsets.all(12),
              child: Text(
                _status,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),

            // BGM
            const Text('🎵 MÚSICA DE FONDO (BGM)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                debugPrint('[TEST] ▶️ Reproduciendo Menu Music');
                await AudioService.instance.playMenuMusic();
              },
              child: const Text('Menu Song'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                debugPrint('[TEST] ▶️ Reproduciendo Shop Music');
                await AudioService.instance.playShopMusic();
              },
              child: const Text('Shop Music'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                debugPrint('[TEST] ▶️ Reproduciendo America Music');
                await AudioService.instance.playAmericaMusic();
              },
              child: const Text('America Music'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                debugPrint('[TEST] ⏹️ Deteniendo música');
                await AudioService.instance.stopMusic();
              },
              child: const Text('Stop Music'),
            ),

            const SizedBox(height: 30),

            // SFX
            const Text('🔊 EFECTOS (SFX)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                debugPrint('[TEST] ▶️ Reproduciendo Coin Collect');
                await AudioService.instance.playCoinCollect();
              },
              child: const Text('Coin Collect'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                debugPrint('[TEST] ▶️ Reproduciendo Hit Sound');
                await AudioService.instance.playHitSound();
              },
              child: const Text('Hit Sound'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                debugPrint('[TEST] ▶️ Reproduciendo Powerup Sound');
                await AudioService.instance.playPowerupSound();
              },
              child: const Text('Powerup'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                debugPrint('[TEST] ▶️ Reproduciendo Gacha Sound');
                await AudioService.instance.playClickGacha();
              },
              child: const Text('Click Gacha'),
            ),

            const SizedBox(height: 30),

            // CONTROLES
            const Text('⚙️ CONTROLES', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                debugPrint('[TEST] 🔄 Re-inicializando AudioService');
                await AudioService.instance._ensureInitialized();
                setState(() {
                  _status = 'AudioService._initialized = ${AudioService.instance._initialized}';
                });
              },
              child: const Text('Reiniciar AudioService'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                debugPrint('[TEST] 🔇 Activo: ${AudioService.instance.musicEnabled}');
                await AudioService.instance.toggleMusic(!AudioService.instance.musicEnabled);
              },
              child: const Text('Toggle Music'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                debugPrint('[TEST] 🔊 SFX Activo: ${AudioService.instance.sfxEnabled}');
                await AudioService.instance.toggleSfx(!AudioService.instance.sfxEnabled);
              },
              child: const Text('Toggle SFX'),
            ),
          ],
        ),
      ),
    );
  }
}
