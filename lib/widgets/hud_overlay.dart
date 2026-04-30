import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/economy_controller.dart';
import '../game/paleto_game.dart';
import '../ui/theme/paleto_colors.dart';
import '../ui/theme/paleto_text.dart';

class HudOverlay extends StatefulWidget {
  final PaletoGame game;

  const HudOverlay({super.key, required this.game});

  @override
  State<HudOverlay> createState() => _HudOverlayState();
}

class _HudOverlayState extends State<HudOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blinkController;
  double _previousPlayerRatio = 1;
  double _flashAlpha = 0;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  void _triggerHpFlash() {
    setState(() => _flashAlpha = 0.8);
    Future<void>.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        setState(() => _flashAlpha = 0);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Consumer<EconomyController>(
              builder: (context, economy, _) {
                final maxHp = economy.maxHp <= 0 ? 1.0 : economy.maxHp;
                final playerRatio = (economy.playerHp / maxHp).clamp(0.0, 1.0);

                if (playerRatio < _previousPlayerRatio) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      _triggerHpFlash();
                    }
                  });
                }
                _previousPlayerRatio = playerRatio;

                final bossData = _bossHpData();
                final stageText = bossData.isBossActive
                    ? 'W${widget.game.currentWave} - ${bossData.bossName}'
                    : 'W${widget.game.currentWave} - LIMPIEZA';

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _HpPanel(
                        label: 'HP',
                        ratio: playerRatio,
                        currentLabel:
                            '${economy.playerHp.round().toString().padLeft(3, '0')}/${maxHp.round()}',
                        gradientColors: const [
                          PaletoColors.elemFire,
                          PaletoColors.elemElec,
                        ],
                        flashAlpha: _flashAlpha,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            stageText,
                            textAlign: TextAlign.center,
                            style: PaletoText.header(
                              size: 7,
                              color: PaletoColors.textPrimary.withValues(alpha: 0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          IconButton(
                            iconSize: 22,
                            onPressed: () {
                              if (widget.game.paused) {
                                widget.game.resumeEngine();
                              } else {
                                widget.game.pauseEngine();
                                if (!widget.game.overlays.isActive('PauseMenu')) {
                                  widget.game.overlays.add('PauseMenu');
                                }
                              }
                            },
                            icon: Icon(
                              widget.game.paused ? Icons.play_arrow : Icons.pause,
                              color: PaletoColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _HpPanel(
                        label: 'BOSS',
                        ratio: bossData.ratio,
                        currentLabel: bossData.label,
                        gradientColors: const [
                          PaletoColors.rarityEpic,
                          Color(0xFFD570FF),
                        ],
                        flashAlpha: 0,
                      ),
                    ),
                  ],
                );
              },
            ),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildSkillCooldown(),
                const Spacer(),
                Consumer<EconomyController>(
                  builder: (context, economy, _) {
                    final score = (economy.coins * 10) + widget.game.enemiesKilledInWave * 120;
                    return _RollingScore(score: score);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _BossHpData _bossHpData() {
    final activeBosses = widget.game.enemyPool.where((enemy) {
      return enemy.isActive && enemy.isBoss;
    }).toList();

    if (activeBosses.isEmpty) {
      return const _BossHpData(
        ratio: 0,
        label: '---/---',
        isBossActive: false,
        bossName: 'SIN JEFE',
      );
    }

    final boss = activeBosses.first;
    final ratio = (boss.hp / math.max(1, boss.maxHp)).clamp(0.0, 1.0);
    return _BossHpData(
      ratio: ratio,
      label: '${boss.hp.round().toString().padLeft(3, '0')}/${boss.maxHp.round()}',
      isBossActive: true,
      bossName: boss.enemyDefinition.name.toUpperCase(),
    );
  }

  Widget _buildSkillCooldown() {
    final progress = (widget.game.enemiesKilledInWave /
            math.max(1, widget.game.enemiesToKillNextWave + 1))
        .clamp(0.0, 1.0);

    return Container(
      width: 88,
      height: 88,
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(76, 76),
            painter: _CooldownArcPainter(progress: progress),
          ),
          const Icon(Icons.local_fire_department, color: PaletoColors.btnGacha, size: 28),
          if (progress >= 1)
            FadeTransition(
              opacity: _blinkController,
              child: Positioned(
                bottom: 2,
                child: Text(
                  'LISTO',
                  style: PaletoText.header(size: 7, color: PaletoColors.textPrimary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HpPanel extends StatelessWidget {
  final String label;
  final double ratio;
  final String currentLabel;
  final List<Color> gradientColors;
  final double flashAlpha;

  const _HpPanel({
    required this.label,
    required this.ratio,
    required this.currentLabel,
    required this.gradientColors,
    required this.flashAlpha,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: PaletoText.header(size: 8, color: PaletoColors.textPrimary)),
        const SizedBox(height: 4),
        SizedBox(
          height: 14,
          child: CustomPaint(
            painter: _HpBarPainter(
              fillRatio: ratio,
              leftColor: gradientColors.first,
              rightColor: gradientColors.last,
              flashAlpha: flashAlpha,
            ),
            child: const SizedBox.expand(),
          ),
        ),
        const SizedBox(height: 2),
        Text(currentLabel, style: PaletoText.stat(size: 20, color: PaletoColors.textAccent)),
      ],
    );
  }
}

class _RollingScore extends StatelessWidget {
  final int score;

  const _RollingScore({required this.score});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: score.toDouble()),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, _) {
        return Text(
          value.round().toString(),
          style: PaletoText.stat(size: 28, color: PaletoColors.textAccent),
        );
      },
    );
  }
}

class _HpBarPainter extends CustomPainter {
  final double fillRatio;
  final Color leftColor;
  final Color rightColor;
  final double flashAlpha;

  _HpBarPainter({
    required this.fillRatio,
    required this.leftColor,
    required this.rightColor,
    required this.flashAlpha,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()..color = const Color(0xFF1A0D00);
    final borderPaint = Paint()
      ..color = PaletoColors.borderDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final fillPaint = Paint()
      ..shader = LinearGradient(colors: [leftColor, rightColor]).createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

    canvas.drawRect(Offset.zero & size, backgroundPaint);
    final fillWidth = size.width * fillRatio;
    canvas.drawRect(Rect.fromLTWH(0, 0, fillWidth, size.height), fillPaint);

    if (flashAlpha > 0) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = Colors.white.withValues(alpha: flashAlpha),
      );
    }

    canvas.drawRect(Offset.zero & size, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _HpBarPainter oldDelegate) {
    return oldDelegate.fillRatio != fillRatio || oldDelegate.flashAlpha != flashAlpha;
  }
}

class _CooldownArcPainter extends CustomPainter {
  final double progress;

  _CooldownArcPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 4;

    final bg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = PaletoColors.bgPanel;

    final fg = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt
      ..strokeWidth = 8
      ..color = PaletoColors.btnGacha;

    canvas.drawCircle(center, radius, bg);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _CooldownArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _BossHpData {
  final double ratio;
  final String label;
  final bool isBossActive;
  final String bossName;

  const _BossHpData({
    required this.ratio,
    required this.label,
    required this.isBossActive,
    required this.bossName,
  });
}
