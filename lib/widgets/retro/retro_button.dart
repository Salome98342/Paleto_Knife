import 'package:flutter/material.dart';

import '../../ui/theme/paleto_text.dart';

class RetroButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;
  final Color baseColor;
  final Color lightBorder;
  final Color darkBorder;
  final double? width;
  final Widget? icon;
  final bool enabled;
  final VoidCallback? onSoundEffect;

  const RetroButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.baseColor,
    required this.lightBorder,
    required this.darkBorder,
    this.width,
    this.icon,
    this.enabled = true,
    this.onSoundEffect,
  });

  @override
  State<RetroButton> createState() => _RetroButtonState();
}

class _RetroButtonState extends State<RetroButton> {
  bool _pressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (!widget.enabled) {
      return;
    }
    widget.onSoundEffect?.call();
    setState(() => _pressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    if (!widget.enabled) {
      return;
    }
    setState(() => _pressed = false);
    widget.onPressed();
  }

  void _handleTapCancel() {
    if (!widget.enabled) {
      return;
    }
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = PaletoText.header(size: 10, color: Colors.white);

    return Opacity(
      opacity: widget.enabled ? 1 : 0.4,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 60),
          curve: Curves.linear,
          transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
          width: widget.width,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: widget.baseColor,
            boxShadow: _pressed
                ? [
                    BoxShadow(
                      color: widget.lightBorder,
                      offset: const Offset(-2, -2),
                      blurRadius: 0,
                    ),
                    BoxShadow(
                      color: widget.lightBorder,
                      offset: const Offset(0, -2),
                      blurRadius: 0,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: widget.lightBorder,
                      offset: const Offset(0, -2),
                      blurRadius: 0,
                    ),
                    BoxShadow(
                      color: widget.darkBorder,
                      offset: const Offset(0, 3),
                      blurRadius: 0,
                    ),
                    BoxShadow(
                      color: widget.lightBorder,
                      offset: const Offset(-2, 0),
                      blurRadius: 0,
                    ),
                    BoxShadow(
                      color: widget.darkBorder,
                      offset: const Offset(3, 0),
                      blurRadius: 0,
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                widget.icon!,
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  widget.label.toUpperCase(),
                  overflow: TextOverflow.ellipsis,
                  style: labelStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
