import 'dart:io';

void main() {
  var p = 'lib/widgets/combat_arena.dart';
  var c = File(p).readAsStringSync();
  
  if (!c.contains('package:flame/components.dart')) {
    c = c.replaceFirst('import \\\'package:flame/widgets.dart\\\';', 'import \\\'package:flame/widgets.dart\\\';\\nimport \\\'package:flame/components.dart\\\';');
  }

  var s1 = c.indexOf('          // Amalgama Culinaria Mutante');
  var e1 = c.indexOf('          // Partículas flotantes alrededor', s1);
  if (e1 == -1) e1 = c.indexOf('          // PartÃculas flotantes alrededor', s1);

  if (s1 != -1 && e1 != -1) {
    var repl = '''          SizedBox(
                width: enemySize,
                height: enemySize,
                child: SpriteAnimationWidget.asset(
                  path: 'enemigo.png', // Lee automáticamente de assets/images/
                  data: SpriteAnimationData.sequenced(
                    amount: 4, 
                    stepTime: 0.15,
                    textureSize: Vector2(250.75, 249),
                  ),
                  playing: true,
                ),
              ),
              
''';
    c = c.replaceRange(s1, e1, repl);
    File(p).writeAsStringSync(c);
    print('Patched successfully');
  } else {
    print('Failed ');
  }
}
