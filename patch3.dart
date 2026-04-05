import 'dart:io';

void main() {
  var p = 'lib/widgets/combat_arena.dart';
  var c = File(p).readAsStringSync();
  
  var oldTail = '''          const SizedBox(height: 6),
          
          // Amalgama Culinaria Mutante
          Stack(
            alignment: Alignment.center,
            children: [
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
              
              // Cuerpo del enemigo
              Container(
                width: enemySize,
                height: enemySize,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      elementColor.withOpacity(0.9),
                      elementColor.withOpacity(0.6),
                      elementColor.withOpacity(0.4),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: elementColor,
                    width: isBoss ? 4 : 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: elementColor.withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Emoji del elemento (grande)
                    Text(
                      enemy.element.getEmoji(),
                      style: TextStyle(
                        fontSize: isBoss ? 50 : 40,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    
                    // Icono de peligro superpuesto
                    Positioned(
                      bottom: isBoss ? 5 : 2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.warning,
                          color: Colors.red.shade400,
                          size: isBoss ? 20 : 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Partículas flotantes alrededor
              if (isBoss) ..._buildBossParticles(enemySize, elementColor),
            ],
          ),
        ],
      ),
    );
  }''';

  var newTail = '''            ],
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
                textureSize: Vector2(250, 249),
              ),
              playing: true,
            ),
          ),
          
          // Partículas flotantes alrededor
          if (isBoss) ..._buildBossParticles(enemySize, elementColor),
        ],
      ),
    );
  }''';

  var replaced = c.replaceFirst(oldTail, newTail);
  if (replaced != c) {
    File(p).writeAsStringSync(replaced);
    print('done');
  } else {
    print('not found');
  }
}
