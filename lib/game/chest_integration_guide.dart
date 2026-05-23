import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../widgets/reward_card.dart';
import 'components/chest_component.dart';

/// Minimal integration example for ChestComponent + RewardCard.
///
/// This file is kept compilable because anything under lib/ is analyzed and
/// included by Flutter tooling.
class ExampleGameWithChest extends FlameGame with TapCallbacks {
  late final ChestComponent chestComponent;
  late BuildContext gameContext;

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
    showDialog<void>(
      context: gameContext,
      barrierDismissible: false,
      builder: (context) => RewardCardOverlay(
        rewardData: const RewardData(
          title: 'Cuchillo Legendario',
          description: 'Un cuchillo forjado en las sombras. +50 ATK',
          icon: Icons.call_split,
          accentColor: Color(0xFFFF6B00),
          rarityLevel: 3,
        ),
        onDismiss: () {
          Navigator.of(context).pop();
          debugPrint('Recompensa aceptada');
        },
      ),
    );
  }
}

class RewardCardOverlay extends StatelessWidget {
  const RewardCardOverlay({
    super.key,
    required this.rewardData,
    this.onDismiss,
  });

  final RewardData rewardData;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: RewardCard(
          rewardData: rewardData,
          onDismiss: onDismiss,
        ),
      ),
    );
  }
}

class GameScreenWithChest extends StatefulWidget {
  const GameScreenWithChest({super.key});

  @override
  State<GameScreenWithChest> createState() => _GameScreenWithChestState();
}

class _GameScreenWithChestState extends State<GameScreenWithChest> {
  late final ExampleGameWithChest gameInstance;

  @override
  void initState() {
    super.initState();
    gameInstance = ExampleGameWithChest()..gameContext = context;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(game: gameInstance),
    );
  }
}
