import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/game_controller.dart';
import '../main.dart';

/// Pantalla de Equipo - Cuchillos, Joyas, Reliquias, Idolos
class EquipmentScreen extends StatefulWidget {
  final GameController gameController;

  const EquipmentScreen({super.key, required this.gameController});

  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    widget.gameController.addListener(_onGameStateChanged);
  }

  @override
  void dispose() {
    _tabController.dispose();
    widget.gameController.removeListener(_onGameStateChanged);
    super.dispose();
  }

  void _onGameStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PixelColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: const BoxDecoration(
                color: PixelColors.bgPanel,
                border: Border(
                  bottom: BorderSide(color: PixelColors.accent, width: 2),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    ' EQUIPO',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 12,
                      color: PixelColors.accent,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: PixelColors.bgCard,
                          border: Border.all(
                            color: PixelColors.border,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.restaurant,
                              color: PixelColors.text,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.gameController.knifeFragments.toString(),
                              style: GoogleFonts.pressStart2p(
                                color: PixelColors.text,
                                fontSize: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: PixelColors.bgCard,
                          border: Border.all(
                            color: PixelColors.accent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              color: PixelColors.accent,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              widget.gameController.gold.toStringAsFixed(0),
                              style: GoogleFonts.pressStart2p(
                                color: PixelColors.accent,
                                fontSize: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tabs
            TabBar(
              controller: _tabController,
              labelColor: PixelColors.accent,
              unselectedLabelColor: PixelColors.textDim,
              indicatorColor: PixelColors.accent,
              labelStyle: GoogleFonts.pressStart2p(fontSize: 8),
              unselectedLabelStyle: GoogleFonts.pressStart2p(fontSize: 8),
              tabs: const [
                Tab(text: ' CUCHILLOS'),
                Tab(text: ' JOYAS'),
                Tab(text: ' RELIQUIAS'),
                Tab(text: ' IDOLOS'),
              ],
            ),

            // Contenido de tabs
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _KnivesTab(gameController: widget.gameController),
                  _JewelsTab(gameController: widget.gameController),
                  _RelicsTab(gameController: widget.gameController),
                  _IdolsTab(gameController: widget.gameController),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KnivesTab extends StatelessWidget {
  final GameController gameController;

  const _KnivesTab({required this.gameController});

  @override
  Widget build(BuildContext context) {
    final knives = gameController.gameState.knives;

    if (knives.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant, size: 60, color: PixelColors.textDim),
            const SizedBox(height: 16),
            Text(
              'NO TIENES CUCHILLOS',
              style: GoogleFonts.pressStart2p(
                fontSize: 9,
                color: PixelColors.textDim,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Consigue fragmentos derrotando jefes',
              style: GoogleFonts.pressStart2p(
                fontSize: 7,
                color: PixelColors.textDim,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: knives.length,
      itemBuilder: (context, index) {
        final knife = knives[index];
        return Card(
          child: ListTile(
            leading: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Color(knife.rarity.getColor()).withValues(alpha: 0.2),
                border: Border.all(color: PixelColors.border, width: 1),
              ),
              child: const Center(child: Icon(Icons.restaurant, size: 30)),
            ),
            title: Text(
              knife.name.toUpperCase(),
              style: GoogleFonts.pressStart2p(
                fontSize: 8,
                color: Color(knife.rarity.getColor()),
              ),
            ),
            subtitle: Text(
              knife.description,
              style: GoogleFonts.pressStart2p(
                fontSize: 6,
                color: PixelColors.textDim,
              ),
            ),
            trailing: knife.isEquipped
                ? const Icon(Icons.check_circle, color: PixelColors.health)
                : OutlinedButton(
                    onPressed: () => gameController.equipKnife(index),
                    child: Text(
                      'EQUIPAR',
                      style: GoogleFonts.pressStart2p(fontSize: 6),
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _JewelsTab extends StatelessWidget {
  final GameController gameController;

  const _JewelsTab({required this.gameController});

  @override
  Widget build(BuildContext context) {
    final jewels = gameController.gameState.jewels;

    if (jewels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.diamond, size: 60, color: PixelColors.textDim),
            const SizedBox(height: 16),
            Text(
              'NO TIENES JOYAS',
              style: GoogleFonts.pressStart2p(
                fontSize: 9,
                color: PixelColors.textDim,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jewels.length,
      itemBuilder: (context, index) {
        final jewel = jewels[index];
        return Card(
          child: ListTile(
            leading: const Icon(
              Icons.diamond,
              size: 34,
              color: PixelColors.mana,
            ),
            title: Text(
              jewel.name.toUpperCase(),
              style: GoogleFonts.pressStart2p(fontSize: 8),
            ),
            subtitle: Text(
              jewel.description,
              style: GoogleFonts.pressStart2p(
                fontSize: 6,
                color: PixelColors.textDim,
              ),
            ),
            trailing: jewel.isEquipped
                ? const Icon(Icons.check_circle, color: PixelColors.health)
                : OutlinedButton(
                    onPressed: () => gameController.equipJewel(index),
                    child: Text(
                      'EQUIPAR',
                      style: GoogleFonts.pressStart2p(fontSize: 6),
                    ),
                  ),
          ),
        );
      },
    );
  }
}

class _RelicsTab extends StatelessWidget {
  final GameController gameController;

  const _RelicsTab({required this.gameController});

  @override
  Widget build(BuildContext context) {
    final relics = gameController.gameState.relics;

    if (relics.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.auto_awesome,
              size: 60,
              color: PixelColors.textDim,
            ),
            const SizedBox(height: 16),
            Text(
              'NO TIENES RELIQUIAS',
              style: GoogleFonts.pressStart2p(
                fontSize: 9,
                color: PixelColors.textDim,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: relics.length,
      itemBuilder: (context, index) {
        final relic = relics[index];
        return Card(
          child: ListTile(
            leading: const Icon(
              Icons.auto_awesome,
              size: 34,
              color: PixelColors.accentAlt,
            ),
            title: Text(
              relic.name.toUpperCase(),
              style: GoogleFonts.pressStart2p(fontSize: 8),
            ),
            subtitle: Text(
              relic.description,
              style: GoogleFonts.pressStart2p(
                fontSize: 6,
                color: PixelColors.textDim,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _IdolsTab extends StatelessWidget {
  final GameController gameController;

  const _IdolsTab({required this.gameController});

  @override
  Widget build(BuildContext context) {
    final idols = gameController.gameState.idols;

    if (idols.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.emoji_objects,
              size: 60,
              color: PixelColors.textDim,
            ),
            const SizedBox(height: 16),
            Text(
              'NO TIENES IDOLOS',
              style: GoogleFonts.pressStart2p(
                fontSize: 9,
                color: PixelColors.textDim,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: idols.length,
      itemBuilder: (context, index) {
        final idol = idols[index];
        return Card(
          child: ListTile(
            leading: const Icon(
              Icons.emoji_objects,
              size: 34,
              color: PixelColors.accent,
            ),
            title: Text(
              idol.name.toUpperCase(),
              style: GoogleFonts.pressStart2p(fontSize: 8),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  idol.description,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 6,
                    color: PixelColors.textDim,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bonus: ${(idol.bonusValue * 100).toStringAsFixed(0)}% | '
                  'Penalidad: ${(idol.penaltyValue * 100).toStringAsFixed(0)}%',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 6,
                    color: PixelColors.accentAlt,
                  ),
                ),
              ],
            ),
            trailing: idol.isActive
                ? const Icon(Icons.check_circle, color: PixelColors.health)
                : null,
          ),
        );
      },
    );
  }
}
