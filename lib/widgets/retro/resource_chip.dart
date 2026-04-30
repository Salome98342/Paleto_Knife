import 'package:flutter/material.dart';

import '../../ui/theme/paleto_colors.dart';
import '../../ui/theme/paleto_text.dart';
import 'retro_menu_box.dart';

class ResourceChip extends StatefulWidget {
  final String assetPath;
  final int value;
  final double iconSize;

  const ResourceChip({
    super.key,
    required this.assetPath,
    required this.value,
    this.iconSize = 20,
  });

  @override
  State<ResourceChip> createState() => _ResourceChipState();
}

class _ResourceChipState extends State<ResourceChip> {
  late int _from;

  @override
  void initState() {
    super.initState();
    _from = widget.value;
  }

  @override
  void didUpdateWidget(covariant ResourceChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _from = oldWidget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RetroMenuBox(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            widget.assetPath,
            width: widget.iconSize,
            height: widget.iconSize,
            filterQuality: FilterQuality.none,
            errorBuilder: (_, __, ___) {
              return Icon(
                Icons.monetization_on,
                size: widget.iconSize,
                color: PaletoColors.textAccent,
              );
            },
          ),
          const SizedBox(width: 4),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: _from.toDouble(), end: widget.value.toDouble()),
            duration: const Duration(milliseconds: 600),
            builder: (context, animatedValue, _) {
              return Text(
                animatedValue.round().toString(),
                style: PaletoText.stat(size: 22, color: PaletoColors.textAccent),
              );
            },
          ),
        ],
      ),
    );
  }
}
