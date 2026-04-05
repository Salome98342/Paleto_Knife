import 'dart:io';

void main() {
  var p = 'lib/widgets/combat_arena.dart';
  var c = File(p).readAsStringSync();
  if (!c.contains('package:flame/components.dart')) {
    c = c.replaceFirst('import \\\'package:flame/widgets.dart\\\';', 'import \\\'package:flame/widgets.dart\\\';\\nimport \\\'package:flame/components.dart\\\';');
    File(p).writeAsStringSync(c);
  }
}
