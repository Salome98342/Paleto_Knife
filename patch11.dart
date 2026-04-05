import 'dart:io';

void main() {
  var p = 'lib/widgets/combat_arena.dart';
  var lines = File(p).readAsLinesSync();
  
  for(int i = 240; i < 255; ++i) {
      if (lines[i].contains('top: enemy.position.dy')) {
          lines[i] = '      top: enemy.position.dy - (enemySize / 2),';
      }
      if (lines[i].contains('child: Column(')) {
          lines[i] = '      child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [ Positioned(bottom: enemySize, child: Column(mainAxisSize: MainAxisSize.min, children: [';
      }
      if (lines[i].contains('// Amalgama Culinaria Mutante')) {
          lines[i] = '          ],)),\\n          // Amalgama Culinaria Mutante';
      }
  }
  
  File(p).writeAsStringSync(lines.join('\\n'));
  print('Patched successfully');
}
