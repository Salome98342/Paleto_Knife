import 'package:flutter/material.dart';

import '../../ui/theme/paleto_colors.dart';
import '../../ui/theme/paleto_text.dart';
import 'pixel_divider.dart';

class RetroMenuBox extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? backgroundColor;
  final String? title;
  final bool hasScanlines;

  const RetroMenuBox({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.title,
    this.hasScanlines = false,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: padding ?? const EdgeInsets.all(12),
      child: title == null
          ? child
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title!, style: PaletoText.header(size: 10)),
                const SizedBox(height: 8),
                const PixelDivider(),
                const SizedBox(height: 10),
                child,
              ],
            ),
    );

    final baseBox = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? PaletoColors.bgPanel,
        boxShadow: const [
          BoxShadow(
            color: PaletoColors.borderLight,
            offset: Offset(-2, -2),
            blurRadius: 0,
          ),
          BoxShadow(
            color: PaletoColors.borderMid,
            offset: Offset(-4, -4),
            blurRadius: 0,
          ),
          BoxShadow(
            color: PaletoColors.borderDark,
            offset: Offset(2, 2),
            blurRadius: 0,
          ),
          BoxShadow(
            color: Color(0xFF1A0D00),
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: content,
    );

    if (!hasScanlines) {
      return baseBox;
    }

    return Stack(
      children: [
        baseBox,
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _ScanlinesPainter(),
            ),
          ),
        ),
      ],
    );
  }
}

class _ScanlinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black.withValues(alpha: 0.06);
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
