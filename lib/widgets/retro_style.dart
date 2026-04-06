import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

  static void showInsufficient(BuildContext context, String message) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black54, 
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: 300.ms,
      pageBuilder: (context, anim1, anim2) {
        // Auto cerrar el dialog despuës de 1.5 segundos
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });
        
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                decoration: box(color: primary).copyWith(
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(color: Colors.redAccent.withOpacity(0.8), blurRadius: 20, spreadRadius: 4)
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.warning, color: Colors.yellowAccent, size: 64)
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scaleXY(begin: 1.0, end: 1.2, duration: 200.ms),
                    const SizedBox(height: 24),
                    Text(
                      message,
                      style: font(size: 14, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().scaleXY(begin: 0.5, end: 1.0, curve: Curves.elasticOut, duration: 600.ms)
               .shake(duration: 300.ms, hz: 6),
            ),
          ),
        );
      },
    );
  }

  static void showSuccess(BuildContext context, String message, {IconData icon = Icons.diamond}) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black54, 
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      transitionDuration: 400.ms,
      pageBuilder: (context, anim1, anim2) {
        Future.delayed(const Duration(milliseconds: 1800), () {
          if (Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
        });
        
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                decoration: box(color: Colors.green).copyWith(
                  border: Border.all(color: Colors.yellowAccent, width: 4),
                  boxShadow: [
                    BoxShadow(color: Colors.greenAccent.withOpacity(0.8), blurRadius: 24, spreadRadius: 4)
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: Colors.yellowAccent, size: 64)
                      .animate(onPlay: (c) => c.repeat())
                      .shimmer(duration: 800.ms, color: Colors.white)
                      .scaleXY(begin: 1.0, end: 1.3, duration: 400.ms, curve: Curves.easeInOut)
                      .then()
                      .scaleXY(begin: 1.3, end: 1.0, duration: 400.ms, curve: Curves.easeInOut),
                    const SizedBox(height: 24),
                    Text(
                      message,
                      style: font(size: 12, color: Colors.white),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.5),
                  ],
                ),
              ).animate()
                .scaleXY(begin: 0.1, end: 1.0, curve: Curves.elasticOut, duration: 800.ms)
                .rotate(begin: 0.05, end: 0, duration: 500.ms)
                .tint(color: Colors.white, duration: 200.ms),
            ),
          ),
        );
      },
    );
  }
}
