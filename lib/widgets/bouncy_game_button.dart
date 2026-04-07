import 'package:flutter/material.dart';
import '../services/audio_service.dart';

class BouncyGameButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const BouncyGameButton({
    super.key,
    required this.onPressed,
    required this.child,
  });

  @override
  State<BouncyGameButton> createState() => _BouncyGameButtonState();
}

class _BouncyGameButtonState extends State<BouncyGameButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.9,
      upperBound: 1.0,
    )..value = 1.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _playAudioFeedback();
    _controller.reverse();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.forward();
    widget.onPressed();
  }

  void _onTapCancel() => _controller.forward();

  void _playAudioFeedback() {
    try {
      AudioService.instance.playClickSound();
    } catch (_) {
      // Ignorar errores de audio
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(scale: _controller, child: widget.child),
    );
  }
}

