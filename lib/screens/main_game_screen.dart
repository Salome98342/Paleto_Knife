import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/game_controller.dart';
import '../main.dart';
import 'combat_screen.dart';
import 'kitchen_screen.dart';
import 'techniques_screen.dart';
import 'equipment_screen.dart';
import 'profile_screen.dart';

/// Pantalla principal del juego con navegación entre tabs
class MainGameScreen extends StatefulWidget {
  const MainGameScreen({super.key});

  @override
  State<MainGameScreen> createState() => _MainGameScreenState();
}

class _MainGameScreenState extends State<MainGameScreen> {
  late final GameController _gameController;
  int _currentIndex = 0;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _gameController = GameController();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    await _gameController.initialize();
    
    setState(() {
      _isInitialized = true;
    });
  }

  @override
  void dispose() {
    _gameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: PixelColors.bg,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: PixelColors.accent, width: 3),
                  color: PixelColors.bgPanel,
                ),
                child: const CircularProgressIndicator(strokeWidth: 3),
              ),
              const SizedBox(height: 24),
              Text(
                'CARGANDO...',
                style: GoogleFonts.pressStart2p(
                  color: PixelColors.accent,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const CombatScreen(),
          KitchenScreen(gameController: _gameController),
          TechniquesScreen(gameController: _gameController),
          EquipmentScreen(gameController: _gameController),
          ProfileScreen(gameController: _gameController),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: PixelColors.accent, width: 2)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: PixelColors.bgPanel,
          selectedItemColor: PixelColors.accent,
          unselectedItemColor: PixelColors.textDim,
          selectedFontSize: 7,
          unselectedFontSize: 7,
          selectedLabelStyle: GoogleFonts.pressStart2p(fontSize: 7),
          unselectedLabelStyle: GoogleFonts.pressStart2p(fontSize: 7),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.sports_kabaddi),
              label: 'LUCHA',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant),
              label: 'COCINA',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome),
              label: 'TECN.',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory),
              label: 'EQUIPO',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'PERFIL',
            ),
          ],
        ),
      ),
    );
  }
}
