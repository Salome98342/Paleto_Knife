// ignore_for_file: unused_local_variable
import 'dart:io';

void main() {
  var p = 'lib/widgets/combat_arena.dart';
  var c = File(p).readAsStringSync();
  
  if (!c.contains('package:flame/components.dart')) {
    c = c.replaceFirst('import \\\'package:flame/widgets.dart\\\';', 'import \\\'package:flame/widgets.dart\\\';\\nimport \\\'package:flame/components.dart\\\';');
  }

  var searchBefore = '''          // Barra de vida
          Container(
            width: enemySize,
            height: isBoss ? 8 : 6,
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: elementColor.withOpacity(0.7),
                width: 2,
              ),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: enemy.healthPercentage,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getHealthColor(enemy.healthPercentage),
                      _getHealthColor(enemy.healthPercentage).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          
          Stack(
            alignment: Alignment.center,
            children: [
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
              
              // Amalgama Culinaria Mutante''';

  var replaceAfter = '''          // Barra de vida
          Container(
            width: enemySize,
            height: isBoss ? 8 : 6,
            decoration: BoxDecoration(
              color: Colors.grey.shade900,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: elementColor.withOpacity(0.7),
                width: 2,
              ),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: enemy.healthPercentage,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getHealthColor(enemy.healthPercentage),
                      _getHealthColor(enemy.healthPercentage).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          
          Stack(
            alignment: Alignment.center,
            children: [
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
                
              SizedBox(
                width: enemySize,
                height: enemySize,
                child: SpriteAnimationWidget.asset(
                  path: 'enemigo.png',
                  data: SpriteAnimationData.sequenced(
                    amount: 4,
                    stepTime: 0.15,
                    textureSize: Vector2(250.75, 249),
                  ),
                  playing: true,
                ),
              ),
              ''';

  var s1 = c.indexOf(searchBefore);
  var e1 = c.indexOf('          // PartÃculas flotantes alrededor', s1);
  if (e1 == -1) e1 = c.indexOf('          // Partículas flotantes alrededor', s1);

  if (s1 != -1 && e1 != -1) {
    c = c.replaceRange(s1, e1, replaceAfter);
    File(p).writeAsStringSync(c);
    print('Clean patch success');
  } else {
    print('Failed to find indices s1 e1');
  }
}
