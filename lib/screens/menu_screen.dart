import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';
import 'game_screen.dart';
import 'main_game_screen.dart';

/// Pantalla de menú principal
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PixelColors.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Titulo pixel art
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: PixelColors.bgPanel,
                    border: Border.all(color: PixelColors.accent, width: 3),
                  ),
                  child: Text(
                    '>> KNIFE\n   CLICKER <<',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 20,
                      color: PixelColors.accent,
                      height: 1.6,
                      shadows: const [
                        Shadow(color: Color(0xFFFF6B00), offset: Offset(3, 3)),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                const Text('🔪', style: TextStyle(fontSize: 72)),

                const SizedBox(height: 8),

                Text(
                  '- PALETO KNIFE RPG -',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 8,
                    color: PixelColors.textDim,
                    letterSpacing: 1,
                  ),
                ),

                const SizedBox(height: 48),

                _MenuButton(
                  icon: Icons.touch_app,
                  title: 'MODO CLICKER',
                  description: 'Incremental clasico',
                  color: PixelColors.mana,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GameScreen()),
                    );
                  },
                ),

                const SizedBox(height: 20),

                _MenuButton(
                  icon: Icons.flash_on,
                  title: 'JUGAR RPG',
                  description: 'Paleto Knife RPG',
                  color: PixelColors.accentAlt,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const MainGameScreen()),
                    );
                  },
                ),

                const SizedBox(height: 48),

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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: PixelColors.bgCard,
          border: Border.all(color: color, width: 3),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.4), offset: const Offset(4, 4)),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              color: color.withOpacity(0.2),
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
                      fontSize: 11,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 7,
                      color: PixelColors.textDim,
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
