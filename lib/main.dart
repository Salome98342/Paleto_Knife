import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'screens/main_layout.dart';
import 'controllers/game_controller.dart';
import 'controllers/economy_controller.dart';
import 'controllers/world_controller.dart';
import 'controllers/chef_controller.dart';
import 'services/audio_service.dart';

// Paleta pixel art global
class PixelColors {
  static const bg = Color(0xFF0D0D1A);
  static const bgPanel = Color(0xFF1A1A2E);
  static const bgCard = Color(0xFF16213E);
  static const accent = Color(0xFFFFD700);
  static const accentAlt = Color(0xFFFF6B00);
  static const health = Color(0xFF44CC44);
  static const danger = Color(0xFFCC3333);
  static const mana = Color(0xFF3399FF);
  static const border = Color(0xFF444466);
  static const text = Color(0xFFE8E8E8);
  static const textDim = Color(0xFF8888AA);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  // InicializaciÃ³n de servicios crÃ­ticos
  await AudioService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameController()..initialize()),
        ChangeNotifierProvider(create: (_) => EconomyController()),
        ChangeNotifierProvider(create: (_) => WorldController()),
        ChangeNotifierProvider(create: (_) => ChefController()),
      ],
      child: const KnifeClickerApp(),
    ),
  );
}

class KnifeClickerApp extends StatelessWidget {
  const KnifeClickerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final pixelTextTheme = GoogleFonts.pressStart2pTextTheme().apply(
      bodyColor: PixelColors.text,
      displayColor: PixelColors.text,
    );

    return MaterialApp(
      title: 'Knife Clicker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: PixelColors.bg,
        colorScheme: const ColorScheme.dark(
          primary: PixelColors.accent,
          secondary: PixelColors.accentAlt,
          surface: PixelColors.bgPanel,
          error: PixelColors.danger,
        ),
        useMaterial3: false,
        textTheme: pixelTextTheme,
        appBarTheme: const AppBarTheme(
          backgroundColor: PixelColors.bgPanel,
          foregroundColor: PixelColors.accent,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: PixelColors.accent,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            elevation: 0,
            side: const BorderSide(color: Colors.white24, width: 2),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: PixelColors.accent,
            side: const BorderSide(color: PixelColors.accent, width: 2),
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: PixelColors.accent,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
        ),
        cardTheme: const CardThemeData(
          color: PixelColors.bgCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: PixelColors.border, width: 2),
          ),
          margin: EdgeInsets.symmetric(vertical: 4),
        ),
        dividerColor: PixelColors.border,
        dialogTheme: const DialogThemeData(
          backgroundColor: PixelColors.bgPanel,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: PixelColors.accent, width: 2),
          ),
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: PixelColors.bgCard,
          contentTextStyle: GoogleFonts.pressStart2p(
            color: PixelColors.text,
            fontSize: 9,
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: PixelColors.border, width: 2),
          ),
          behavior: SnackBarBehavior.floating,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: PixelColors.bgPanel,
          selectedItemColor: PixelColors.accent,
          unselectedItemColor: PixelColors.textDim,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        tabBarTheme: const TabBarThemeData(
          labelColor: PixelColors.accent,
          unselectedLabelColor: PixelColors.textDim,
          indicatorColor: PixelColors.accent,
          indicatorSize: TabBarIndicatorSize.tab,
          dividerColor: PixelColors.border,
        ),
        listTileTheme: const ListTileThemeData(
          tileColor: PixelColors.bgCard,
          iconColor: PixelColors.accent,
          textColor: PixelColors.text,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: PixelColors.accent,
        ),
      ),
      home: const MainLayout(),
    );
  }
}

