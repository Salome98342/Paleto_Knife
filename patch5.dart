import 'dart:io';

void main() {
  var p = 'lib/widgets/combat_arena.dart';
  var lines = File(p).readAsLinesSync();
  
  int startIdx = lines.indexWhere((l) => l.contains('Widget _buildEnemy(Enemy enemy) {'));
  int endIdx = lines.indexWhere((l) => l.contains('List<Widget> _buildBossParticles'), startIdx);
  
  var newMethod = '''  Widget _buildEnemy(Enemy enemy) {
    final elementColor = Color(enemy.element.getColor());
    final isBoss = enemy.isBoss;
    final enemySize = isBoss ? 100.0 : 80.0;
    
    return Positioned(
      left: enemy.position.dx - (enemySize / 2),
      top: enemy.position.dy - (enemySize / 2) - 30,
      child: Column(
        children: [
          // Corona si es Boss
          if (isBoss)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade700, Colors.yellow.shade400],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.6),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.emoji_events, color: Colors.white, size: 16),
                  SizedBox(width: 4),
                  Text(
                    'BOSS',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          
          if (isBoss) const SizedBox(height: 4),
          
          // Nombre del enemigo
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: elementColor.withOpacity(0.8),
                width: 2,
              ),
            ),
            child: Text(
              enemy.name,
              style: TextStyle(
                color: elementColor,
                fontSize: isBoss ? 12 : 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          
          // Barra de vida
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
          
          // El cuerpo del enemigo (Sprite y efectos)
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
                
              // Sprite del Enemigo Animado
              SizedBox(
                width: enemySize,
                height: enemySize,
                child: SpriteAnimationWidget.asset(
                  path: 'enemigo.png', // Lee automáticamente de assets/images/
                  data: SpriteAnimationData.sequenced(
                    amount: 4, // 4 frames basados en la dimensión 1000x250
                    stepTime: 0.15,
                    textureSize: Vector2(250.75, 249), // 1003 / 4, evitamos usar Vector2(1003 / 4...) que es código para flame
                  ),
                  playing: true,
                ),
              ),
              
              // Partículas flotantes alrededor
              if (isBoss) ..._buildBossParticles(enemySize, elementColor),
            ],
          ),
        ],
      ),
    );
  }
''';

  lines.replaceRange(startIdx, endIdx - 2, newMethod.split('\\n'));
  File(p).writeAsStringSync(lines.join('\\n'));
  print('patched!');
}
