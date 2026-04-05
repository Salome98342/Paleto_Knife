import 'package:flutter/material.dart';
import '../widgets/retro_style.dart';

class AppTheme {
  static const Color background = RetroStyle.background;
  static const Color surface = RetroStyle.panel;
  static Color surfaceTransparent = RetroStyle.panel.withOpacity(0.9);
  
  static const Color textMain = Colors.white; 
  static const Color textDim = Colors.white70;

  static const Color danger = RetroStyle.primary;
  static const Color health = RetroStyle.primary;
  static const Color healthDark = Color(0xFF4A4A4A);
  static const Color gold = RetroStyle.accent;
  static const Color goldLight = Color(0xFFFFF200);
  static const Color magic = Colors.blue;
  
  static const Color rarityCommon = Colors.grey;
  static const Color rarityRare = Colors.blue;
  static const Color rarityEpic = Colors.purple;
  static const Color rarityLegendary = Colors.orangeAccent;

  static const List<BoxShadow> neonShadowMagic = [];
  static const List<BoxShadow> neonShadowGold = [];

  static TextStyle get titleStyle => RetroStyle.font(size: 16, color: Colors.white);

  static TextStyle get numberStyle => RetroStyle.font(size: 16, color: Colors.white);
      
  static TextStyle get numberStyleSmall => RetroStyle.font(size: 10, color: Colors.white);

  static BoxDecoration get hudPanelDecoration => RetroStyle.box(color: RetroStyle.panel);
  
  static BoxDecoration get cardDecoration => RetroStyle.box(color: RetroStyle.panel);

  static BoxDecoration buttonDecoration(Color buttonColor) => RetroStyle.box(color: buttonColor);
}
