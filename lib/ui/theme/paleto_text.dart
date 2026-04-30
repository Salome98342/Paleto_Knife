import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'paleto_colors.dart';

class PaletoText {
  const PaletoText._();

  static TextStyle header({double size = 16, Color? color}) {
    return GoogleFonts.pressStart2p(
      fontSize: size,
      color: color ?? PaletoColors.textPrimary,
      letterSpacing: 1.5,
    );
  }

  static TextStyle stat({double size = 20, Color? color}) {
    return GoogleFonts.vt323(
      fontSize: size,
      color: color ?? PaletoColors.textAccent,
      letterSpacing: 2.0,
    );
  }

  static TextStyle body({double size = 12, Color? color}) {
    return GoogleFonts.silkscreen(
      fontSize: size,
      color: color ?? PaletoColors.textSecondary,
      height: 1.6,
    );
  }
}
