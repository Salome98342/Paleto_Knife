import 'package:flutter/material.dart';

import '../../ui/theme/paleto_colors.dart';

class PixelDivider extends StatelessWidget {
  const PixelDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 2,
      decoration: const BoxDecoration(
        color: PaletoColors.borderMid,
        boxShadow: [
          BoxShadow(
            color: PaletoColors.borderLight,
            offset: Offset(0, -1),
            blurRadius: 0,
          ),
          BoxShadow(
            color: PaletoColors.borderDark,
            offset: Offset(0, 1),
            blurRadius: 0,
          ),
        ],
      ),
    );
  }
}
