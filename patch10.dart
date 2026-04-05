import 'dart:io';

void main() {
  var p = 'lib/widgets/combat_arena.dart';
  var c = File(p).readAsStringSync();
  
  var oldM = '''    return Positioned(
      left: enemy.position.dx - (enemySize / 2),
      top: enemy.position.dy - (enemySize / 2) - 30,
      child: Column(
        children: [
          // Corona si es Boss''';
          
  var newM = '''    return Positioned(
      left: enemy.position.dx - (enemySize / 2),
      top: enemy.position.dy - (enemySize / 2),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: enemySize,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Corona si es Boss''';
                
  var oldM2 = '''          const SizedBox(height: 6),
          
          // Amalgama Culinaria Mutante
          Stack(
            alignment: Alignment.center,
            children: [
              // Glow effect para boss''';
              
  var newM2 = '''          const SizedBox(height: 6),
              ],
            ),
          ),
          
          // Amalgama Culinaria Mutante
          Stack(
            alignment: Alignment.center,
            children: [
              // Glow effect para boss''';
              
  if (c.contains(oldM)) {
      c = c.replaceFirst(oldM, newM);
      if (c.contains(oldM2)) {
          c = c.replaceFirst(oldM2, newM2);
          File(p).writeAsStringSync(c);
          print('Patched successfully');
      } else {
          print('Failed oldM2');
      }
  } else {
      print('Failed oldm');
  }
}
