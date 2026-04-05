import 'dart:io';

void main() {
  var p = 'lib/widgets/combat_arena.dart';
  var c = File(p).readAsStringSync();
  c = c.replaceFirst(
    '''import 'dart:math' as math;''',
    '''import 'dart:math' as math;\nimport 'package:flame/widgets.dart';'''
  );
  
  var oldM = '''  /// Construye el widget del enemigo
  Widget _buildEnemy(Enemy enemy) {
    final elementColor = Color(enemy.element.getColor());
    final isBoss = enemy.isBoss;
    final enemySize = isBoss ? 100.0 : 80.0;
    
    return Positioned(
      left: enemy.position.dx - (enemySize / 2),
      top: enemy.position.dy - (enemySize / 2) - 30,
      child: Column(
        children: [''';
        
  var newM = '''  /// Construye el widget del enemigo
  Widget _buildEnemy(Enemy enemy) {
    final elementColor = Color(enemy.element.getColor());
    final isBoss = enemy.isBoss;
    final enemySize = enemy.size; // Usa el tamaño del modelo (hitbox)
    
    return Positioned(
      left: enemy.position.dx - (enemySize / 2),
      top: enemy.position.dy - (enemySize / 2),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Layout de interfaz que va encima del sprite
          Positioned(
            bottom: enemySize + 10,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [''';

  c = c.replaceFirst(oldM, newM);
  File(p).writeAsStringSync(c);
  print('done');
}
