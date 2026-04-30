import 'package:flutter/material.dart';

import '../../ui/theme/paleto_colors.dart';

enum PaletoRarity { common, rare, epic, legendary }

class RarityBorder extends StatefulWidget {
  final Widget child;
  final PaletoRarity rarity;
  final double borderWidth;

  const RarityBorder({
    super.key,
    required this.child,
    required this.rarity,
    this.borderWidth = 3.0,
  });

  @override
  State<RarityBorder> createState() => _RarityBorderState();
}

class _RarityBorderState extends State<RarityBorder>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _legendaryPulse;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _legendaryPulse = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    if (widget.rarity == PaletoRarity.legendary) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant RarityBorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.rarity == PaletoRarity.legendary &&
        oldWidget.rarity != PaletoRarity.legendary) {
      _controller.repeat(reverse: true);
    } else if (widget.rarity != PaletoRarity.legendary &&
        oldWidget.rarity == PaletoRarity.legendary) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _borderColor {
    switch (widget.rarity) {
      case PaletoRarity.common:
        return PaletoColors.rarityCommon;
      case PaletoRarity.rare:
        return PaletoColors.rarityRare;
      case PaletoRarity.epic:
        return PaletoColors.rarityEpic;
      case PaletoRarity.legendary:
        return PaletoColors.rarityLegendary;
    }
  }

  double get _baseGlow {
    switch (widget.rarity) {
      case PaletoRarity.common:
        return 0;
      case PaletoRarity.rare:
        return 0.3;
      case PaletoRarity.epic:
        return 0.35;
      case PaletoRarity.legendary:
        return 0.3;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.rarity != PaletoRarity.legendary) {
      return _buildFrame(_baseGlow);
    }

    return AnimatedBuilder(
      animation: _legendaryPulse,
      builder: (context, _) {
        final alpha = 0.3 + (_legendaryPulse.value * 0.3);
        return _buildFrame(alpha);
      },
    );
  }

  Widget _buildFrame(double glowAlpha) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: _borderColor, width: widget.borderWidth),
        boxShadow: glowAlpha <= 0
            ? const []
            : [
                BoxShadow(
                  color: _borderColor.withValues(alpha: glowAlpha),
                  blurRadius: 0,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: widget.child,
    );
  }
}
