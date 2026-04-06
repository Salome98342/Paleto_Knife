with open("lib/game/enemies/enemy.dart", "r", encoding="utf-8") as f:
    text = f.read()

text = text.replace('      _amalgamName = "JEFE: \\";', '      _amalgamName = "JEFE: $_amalgamName";')
# Wait, let's also fix the else block inside if(isBoss). Wait, looking at the previous output:
# if (isBoss) {
#   size = Vector2(100, 100);
#   hp = 250.0 + (game.currentWave * 150.0); // Jefe tiene mucha maas vida
#   _amalgamName = "JEFE: \";
#   size = Vector2(40, 40);
#   hp = 10.0 + (game.currentWave * 12.0); // Escala de vida ajustada a oleadas
# }
# Oh no, the else block got pasted inside `if (isBoss)`! Let's check the actual file directly
