import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../widgets/retro_style.dart';
import '../widgets/ad_banner_widget.dart';
import '../controllers/world_controller.dart';
import '../controllers/economy_controller.dart';
import '../controllers/chef_controller.dart';
import 'chefs_view.dart';
import 'quests_view.dart';
import 'gacha_store_view.dart';
import 'gameplay_screen.dart'; // Import for RPG
import 'world_view.dart'; // Import for World Map
import 'profile_screen.dart';
import 'settings_dialog.dart';
import '../controllers/game_controller.dart';
import '../services/audio_service.dart'; // Import for audios if needed

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 2;

  final List<Widget> _pages = [
    const GachaStoreView(),
    const ChefsView(),
    const _HomeTab(), // Replaces the placeholder
    const QuestsView(),
    const WorldView(),
  ];

  @override
  void initState() {
    super.initState();
    // Iniciar musica de menu cuando se carga MainLayout
    Future.microtask(() {
      try {
        debugPrint('[MainLayout] 🎵 Iniciando música de menú');
        AudioService.instance.playMenuMusic();
      } catch (e, stack) {
        debugPrint('[MainLayout] ❌ Error reproduciendo música: $e');
        debugPrint(stack.toString());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RetroStyle.background,
      body: SafeArea(
        child: Stack(
          children: [
            AnimatedSwitcher(
              duration: 300.ms,
              transitionBuilder: (child, animation) => SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
              child: _pages[_currentIndex],
            ),

            Positioned(top: 16, left: 16, right: 16, child: _buildTopHUD()),

            Positioned(
              bottom: 80,
              left: 0,
              right: 0,
              child: const AdBannerWidget(),
            ),

            Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomNav()),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHUD() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Consumer<ChefController>(
          builder: (context, chefController, child) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(
                      gameController: Provider.of<GameController>(
                        context,
                        listen: false,
                      ),
                    ),
                  ),
                );
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: RetroStyle.box(color: Colors.grey.shade300),
                child: Icon(
                  chefController.activeChef.icon,
                  size: 30,
                  color: RetroStyle.primary,
                ),
              ),
            ).animate().slideY(
              begin: -1,
              duration: 400.ms,
              curve: Curves.easeOutBack,
            );
          },
        ),

        Consumer<EconomyController>(
          builder: (context, eco, child) {
            return Row(
              children: [
                _buildCurrencyIndicator(
                  Icons.monetization_on,
                  "${eco.coins}",
                  RetroStyle.accent,
                ),
                const SizedBox(width: 8),
                _buildCurrencyIndicator(
                  Icons.diamond,
                  "${eco.gems}",
                  Colors.purpleAccent,
                ),
              ],
            );
          },
        ).animate().slideY(
          begin: -1,
          duration: 500.ms,
          curve: Curves.easeOutBack,
        ),

        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => const SettingsDialog(),
            );
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: RetroStyle.box(color: Colors.grey.shade400),
            child: const Icon(Icons.settings, size: 20),
          ),
        ).animate().slideY(
          begin: -1,
          duration: 600.ms,
          curve: Curves.easeOutBack,
        ),
      ],
    );
  }

  Widget _buildCurrencyIndicator(IconData icon, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: RetroStyle.box(color: Colors.white),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(amount, style: RetroStyle.font(size: 10)),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: RetroStyle.panel,
        border: Border(top: BorderSide(color: Colors.black, width: 4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.store, "Tienda", 0),
          _buildNavItem(Icons.group, "Chefs", 1),
          _buildPlayButton(),
          _buildNavItem(Icons.assignment, "Misiones", 3),
          _buildNavItem(Icons.map, "Mundo", 4),
        ],
      ),
    ).animate().slideY(begin: 1, duration: 500.ms, curve: Curves.easeOutBack);
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
          onTap: () {
            setState(() => _currentIndex = index);
            // Manejar música según tab seleccionado
            if (index == 0) {
              // Tienda
              AudioService.instance.playShopMusic();
            } else {
              // Otros (Chefs, Misiones, Mundo) -> música de menú
              AudioService.instance.playMenuMusic();
            }
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? RetroStyle.primary : Colors.grey.shade700,
                size: 28,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: RetroStyle.font(
                  size: 8,
                  color: isSelected ? RetroStyle.primary : Colors.grey.shade700,
                ),
              ),
            ],
          ),
        )
        .animate(target: isSelected ? 1 : 0)
        .scale(end: const Offset(1.1, 1.1), duration: 200.ms);
  }

  Widget _buildPlayButton() {
    return GestureDetector(
          onTap: () {
            setState(() => _currentIndex = 2);
          },
          child: Transform.translate(
            offset: const Offset(0, -20),
            child: Container(
              width: 80,
              height: 80,
              decoration: RetroStyle.box(color: RetroStyle.primary),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.play_arrow, color: Colors.white, size: 40),
                  Text(
                    "JUGAR",
                    style: RetroStyle.font(size: 10, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scaleXY(
          begin: 1.0,
          end: 1.05,
          duration: 800.ms,
          curve: Curves.easeInOut,
        )
        .animate(target: _currentIndex == 2 ? 1 : 0)
        .shimmer(duration: 1000.ms);
  }
}

class _HomeTab extends StatelessWidget {
  const _HomeTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final world = context.watch<WorldController>();
    final locationName = world.selectedLocation.name.toUpperCase();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 100),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 1. Play RPG Button
          GestureDetector(
                onTap: () {
                  try {
                    AudioService.instance.playGameplayMusic();
                  } catch (_) {}
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const GameplayScreen()),
                  );
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: RetroStyle.box(color: RetroStyle.primary)
                      .copyWith(
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black,
                            offset: Offset(6, 6),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.sports_martial_arts,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "LUCHAR EN",
                        style: RetroStyle.font(size: 14, color: Colors.white70),
                      ),
                      Text(
                        locationName,
                        style: RetroStyle.font(size: 24, color: Colors.amber),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "BATTLE & DASH",
                        style: RetroStyle.font(size: 10, color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scaleXY(begin: 1.0, end: 1.02, duration: 1.seconds),

          const SizedBox(height: 48),

          // 2. Play Classic (Coming Soon)
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "MODO CLASICO: PROXIMAMENTE",
                    style: RetroStyle.font(size: 10, color: Colors.white),
                  ),
                  backgroundColor: RetroStyle.background,
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: RetroStyle.box(color: Colors.grey.shade600),
              child: Column(
                children: [
                  const Icon(Icons.touch_app, size: 40, color: Colors.white54),
                  const SizedBox(height: 8),
                  Text(
                    "MODO CLASICO",
                    style: RetroStyle.font(size: 12, color: Colors.white70),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "No disponible / Proximamente",
                    style: RetroStyle.font(size: 8, color: Colors.white54),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
