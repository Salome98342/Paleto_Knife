import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RetroStyle {
  static const Color background = Color(0xFF2B2B26);
  static const Color primary = Color(0xFFE52521); 
  static const Color accent = Color(0xFFF6D131); 
  static const Color panel = Color(0xFFC4CFA1); 
  static const Color textDark = Color(0xFF1E1E1E);
  static const Color textLight = Colors.white;

  static BoxDecoration box({Color color = panel, bool isPressed = false}) {
    return BoxDecoration(
      color: color,
      border: Border.all(color: Colors.black, width: 4),
      boxShadow: isPressed
          ? []
          : [
              const BoxShadow(
                color: Colors.black,
                offset: Offset(4, 4),
                blurRadius: 0, 
              ),
            ],
    );
  }

  static TextStyle font({double size = 16, Color color = textDark}) {
    return GoogleFonts.pressStart2p(
      fontSize: size,
      color: color,
      height: 1.5,
    );
  }
}
