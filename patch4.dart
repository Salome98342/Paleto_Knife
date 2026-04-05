// ignore_for_file: unused_local_variable
import 'dart:io';

void main() {
  var p = 'lib/widgets/combat_arena.dart';
  var c = File(p).readAsStringSync();
  
  // Find start index
  var startStr = '          // Amalgama Culinaria Mutante';
  var endStr = '          // Partículas flotantes alrededor';
  
  var startIdx = c.indexOf(startStr);
  var endIdx = c.indexOf(endStr, startIdx);
  
  if (startIdx != -1 && endIdx != -1) {
    var before = c.substring(0, startIdx);
    var remainder = c.substring(endIdx);
    var afterCloseBracket = remainder.substring(remainder.indexOf('],') + 2); // skips ],\n          ),
    
    // Actually simpler:
    var block = c.substring(startIdx, c.indexOf('          // Partículas flotantes alrededor', startIdx));
    
    var repl = '''          // Cerramos el Column que contiene la UI (corona, nombre, salud)
            ],
            ),
          ),
          
          // Glow effect para boss
          if (isBoss)
            Container(
              width: enemySize + 20,
              height: enemySize + 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: elementColor.withOpacity(0.6),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
            
          // Sprite del Enemigo Animado
          SizedBox(
            width: enemySize,
            height: enemySize,
            child: SpriteAnimationWidget.asset(
              path: 'enemigo.png', // Lee automáticamente de assets/images/
              data: SpriteAnimationData.sequenced(
                amount: 4, // 4 frames basados en la dimensión 1000x250
                stepTime: 0.15,
                textureSize: Vector2(1003 / 4, 249),
              ),
              playing: true,
            ),
          ),
          
''';
    
    c = c.replaceRange(startIdx, c.indexOf('          // Partículas flotantes alrededor', startIdx), repl);
    File(p).writeAsStringSync(c);
    print('done');
  } else {
    print('Failed to find indices');
  }
}
