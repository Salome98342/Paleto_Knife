import 'package:flutter/material.dart';

import '../../game/paleto_game.dart';
import '../../ui/theme/paleto_colors.dart';
import '../../ui/theme/paleto_text.dart';
import '../../widgets/retro/retro_button.dart';
import '../../widgets/retro/retro_menu_box.dart';

enum StageCardState { locked, available, completed }

class StageData {
  final String id;
  final String name;
  final String description;
  final int difficulty;
  final StageCardState state;
  final double progressPercent;
  final bool isCurrent;
  final VoidCallback? onSelected;

  const StageData({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.state,
    this.progressPercent = 0,
    this.isCurrent = false,
    this.onSelected,
  });
}

class StageSelectOverlay extends StatefulWidget {
  final PaletoGame game;
  final List<StageData> stages;

  const StageSelectOverlay({
    super.key,
    required this.game,
    required this.stages,
  });

  @override
  State<StageSelectOverlay> createState() => _StageSelectOverlayState();
}

class _StageSelectOverlayState extends State<StageSelectOverlay> {
  bool _entered = false;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _entered = true;
      });
    });
  }

  Future<void> _closeOverlay() async {
    if (_isClosing) {
      return;
    }

    setState(() {
      _isClosing = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 180));
    if (!mounted) {
      return;
    }
    widget.game.overlays.remove('StageSelect');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _entered && !_isClosing ? 1 : 0,
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: _entered && !_isClosing ? Offset.zero : const Offset(0, 0.03),
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: Container(
          color: Colors.black87,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
              const RetroMenuBox(
                title: 'SELECCIONAR MISION',
                child: Text(
                  'Menu de restaurante corrupto',
                  style: TextStyle(color: PaletoColors.textSecondary),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.separated(
                  itemCount: widget.stages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final stage = widget.stages[index];
                    return _StageCard(
                      stage: stage,
                      onTap: stage.state == StageCardState.locked
                          ? null
                          : () {
                              stage.onSelected?.call();
                              _closeOverlay();
                            },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: RetroButton(
                  label: 'Volver',
                  onPressed: _closeOverlay,
                  baseColor: PaletoColors.btnNeutral,
                  lightBorder: PaletoColors.btnNeutralLt,
                  darkBorder: PaletoColors.btnNeutralDk,
                ),
              ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StageCard extends StatelessWidget {
  final StageData stage;
  final VoidCallback? onTap;

  const _StageCard({required this.stage, this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isLocked = stage.state == StageCardState.locked;
    final bool isCompleted = stage.state == StageCardState.completed;
    final statusText = isLocked
      ? 'BLOQUEADA'
      : isCompleted
        ? 'COMPLETADA'
        : stage.isCurrent
          ? 'ACTUAL'
          : 'DISPONIBLE';
    final statusColor = isLocked
      ? PaletoColors.btnNeutralLt
      : isCompleted
        ? PaletoColors.btnSecondaryLt
        : stage.isCurrent
          ? PaletoColors.textAccent
          : PaletoColors.btnPrimaryLt;

    final content = Stack(
      children: [
        Row(
          children: [
            SizedBox(
              width: 60,
              child: Text(
                stage.id,
                style: PaletoText.stat(size: 32),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(stage.name, style: PaletoText.header(size: 10)),
                  const SizedBox(height: 6),
                  Text(stage.description, style: PaletoText.body(size: 11)),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(3, (index) {
                      final active = index < stage.difficulty;
                      if (index == 2 && active && stage.difficulty == 3) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Text(
                            '☠',
                            style: PaletoText.body(size: 14, color: PaletoColors.elemFire),
                          ),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(
                          active ? Icons.star : Icons.star_border,
                          size: 18,
                          color: active ? PaletoColors.btnGacha : PaletoColors.textSecondary,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            isLocked
                ? Opacity(
                    opacity: 0.4,
                    child: const Icon(Icons.lock, color: Colors.white),
                  )
                : const Icon(Icons.play_arrow, color: PaletoColors.textAccent),
          ],
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: statusColor,
            child: Text(statusText, style: PaletoText.header(size: 7)),
          ),
        ),
      ],
    );

    return Opacity(
      opacity: isLocked ? 0.5 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          border: Border.all(
            color: stage.isCurrent ? PaletoColors.textAccent : Colors.transparent,
            width: 2,
          ),
        ),
        child: RetroMenuBox(
          child: GestureDetector(
            onTap: onTap,
            child: Column(
              children: [
                content,
                const SizedBox(height: 10),
                ClipRect(
                  child: SizedBox(
                    height: 10,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Container(color: PaletoColors.bgPanelAlt),
                        ),
                        Positioned.fill(
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (stage.progressPercent / 100).clamp(0, 1),
                            child: Container(color: PaletoColors.btnGacha),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${stage.progressPercent.toStringAsFixed(0)}%',
                    style: PaletoText.body(size: 8),
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
