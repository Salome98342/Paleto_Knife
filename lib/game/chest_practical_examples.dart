import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../widgets/reward_card.dart';
import 'components/chest_component.dart';

class ChestGameScreen extends FlameGame with TapCallbacks {
  ChestGameScreen(this.screenContext);

  final BuildContext screenContext;
  late final ChestComponent chestComponent;

  static final List<RewardData> availableRewards = [
    RewardData(
      title: 'Cuchillo Legendario',
      description: 'Legendario arcano que desgarra el espacio.',
      icon: Icons.call_split,
      accentColor: const Color(0xFFFF6B00),
      rarityLevel: 3,
    ),
    RewardData(
      title: 'Pocion de Fortaleza',
      description: 'Tu ataque aumenta permanentemente +25.',
      icon: Icons.local_fire_department,
      accentColor: const Color(0xFFCC3333),
      rarityLevel: 2,
    ),
    RewardData(
      title: 'Monedas de Oro',
      description: 'Obtienes 1000 monedas de oro.',
      icon: Icons.paid,
      accentColor: const Color(0xFFFFD700),
      rarityLevel: 1,
    ),
  ];

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    chestComponent = ChestComponent(
      position: size / 2,
      size: Vector2(80, 70),
      onChestOpened: _handleChestOpened,
    );

    add(chestComponent);
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    if (chestComponent.hitTest(event.localPosition)) {
      chestComponent.onTap();
    }
  }

  void _handleChestOpened() {
    final reward =
        availableRewards[DateTime.now().millisecond % availableRewards.length];

    showDialog<void>(
      context: screenContext,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: RewardCard(
          rewardData: reward,
          onDismiss: () {
            Navigator.pop(context);
            debugPrint('Recompensa aceptada: ${reward.title}');
          },
        ),
      ),
    );
  }
}

class ChestGameWidget extends StatefulWidget {
  const ChestGameWidget({super.key});

  @override
  State<ChestGameWidget> createState() => _ChestGameWidgetState();
}

class _ChestGameWidgetState extends State<ChestGameWidget> {
  late final ChestGameScreen gameInstance;

  @override
  void initState() {
    super.initState();
    gameInstance = ChestGameScreen(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(game: gameInstance),
    );
  }
}

class AdvancedChestGameScreen extends FlameGame with TapCallbacks {
  AdvancedChestGameScreen(this.screenContext);

  final BuildContext screenContext;
  final List<ChestComponent> chests = [];
  int chestsOpened = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final positions = [
      Vector2(size.x * 0.2, size.y * 0.5),
      Vector2(size.x * 0.5, size.y * 0.5),
      Vector2(size.x * 0.8, size.y * 0.5),
    ];

    for (var i = 0; i < positions.length; i++) {
      final chest = ChestComponent(
        position: positions[i],
        size: Vector2(80, 70),
        onChestOpened: () => _handleChestOpened(i),
      );
      chests.add(chest);
      add(chest);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);

    for (final chest in chests) {
      if (!chest.isOpened && chest.hitTest(event.localPosition)) {
        chest.onTap();
        break;
      }
    }
  }

  void _handleChestOpened(int chestIndex) {
    chestsOpened++;
    final reward =
        ChestGameScreen.availableRewards[_rewardIndexFor(chestIndex)];
    debugPrint('Cofre $chestIndex abierto ($chestsOpened/${chests.length})');

    showDialog<void>(
      context: screenContext,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: RewardCard(
          rewardData: reward,
          onDismiss: () => Navigator.pop(context),
        ),
      ),
    );
  }

  int _rewardIndexFor(int chestIndex) {
    return chestIndex % ChestGameScreen.availableRewards.length;
  }
}
