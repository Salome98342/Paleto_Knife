import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import '../services/audio_service.dart';
import 'game_screen.dart';
import 'main_game_screen.dart';

/// Pantalla de menú principal
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    super.initState();
    AudioService.instance.playMenuMusic();
  }

  Future<void> _openGameplay(Widget destination) async {
    await AudioService.instance.playGameplayMusic();
    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => destination),
    );

    if (!mounted) return;
    await AudioService.instance.playMenuMusic();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PixelColors.bg,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF090917),
                      PixelColors.bg,
                      const Color(0xFF120A08),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 30,
              left: -20,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PixelColors.accent.withOpacity(0.06),
                ),
              ),
            ),
            Positioned(
              bottom: 40,
              right: -30,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: PixelColors.accentAlt.withOpacity(0.08),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 320,
                      constraints: const BoxConstraints(maxWidth: 360),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: PixelColors.bgPanel,
                        border: Border.all(color: PixelColors.accent, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.45),
                            blurRadius: 12,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: PixelColors.border, width: 2),
                          color: const Color(0xFF111428),
                        ),
                        child: Image.asset(
                          'assets/images/PaletoLogo.png',
                          fit: BoxFit.contain,
                          height: 130,
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: PixelColors.bgPanel,
                        border: Border.all(color: PixelColors.border, width: 2),
                      ),
                      child: Text(
                        'RPG DE COCINA RETRO',
                        style: GoogleFonts.pressStart2p(
                          fontSize: 7,
                          color: PixelColors.textDim,
                          letterSpacing: 1,
                        ),
                      ),
                    ),

                    const SizedBox(height: 34),

                    _MenuButton(
                      icon: Icons.touch_app,
                      title: 'MODO CLICKER',
                      description: 'Incremental clasico',
                      color: PixelColors.mana,
                      onPressed: () {
                        _openGameplay(const GameScreen());
                      },
                    ),

                    const SizedBox(height: 14),

                    _MenuButton(
                      icon: Icons.sports_martial_arts,
                      title: 'MODO RPG',
                      description: 'Combate en tiempo real',
                      color: PixelColors.accentAlt,
                      onPressed: () {
                        _openGameplay(const MainGameScreen());
                      },
                    ),

                    const SizedBox(height: 30),

                    Text(
                      'v1.0.0',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 8,
                        color: PixelColors.textDim,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget de botón del menú
class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final VoidCallback onPressed;

  const _MenuButton({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF17203B), Color(0xFF11172B)],
          ),
          border: Border.all(color: color, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: 10,
              offset: const Offset(0, 7),
            ),
            BoxShadow(color: color.withOpacity(0.32), offset: const Offset(4, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                border: Border.all(color: color, width: 2),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 10,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 7,
                      color: PixelColors.text,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 16),
          ],
        ),
      ),
    );
  }
}
