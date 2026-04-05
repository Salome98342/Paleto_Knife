import 'dart:io';

void main() {
  var p = 'lib/widgets/combat_arena.dart';
  var c = File(p).readAsStringSync();
  
  if (!c.contains('package:flame/components.dart')) {
    c = 'import \\\'package:flame/components.dart\\\';\\nimport \\\'package:flame/widgets.dart\\\';\\nimport \\\'package:flame/sprite.dart\\\';\\n' + c;
    File(p).writeAsStringSync(c);
  }
}
