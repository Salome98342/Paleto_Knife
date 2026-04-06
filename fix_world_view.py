# -*- coding: utf-8 -*-
with open("lib/screens/world_view.dart", "r", encoding="utf-8") as f:
    text = f.read()

replacement = r"""                  Text("% LIBERADO","""
correct = r"""                  Text("${world.getLiberation(loc.name).toStringAsFixed(0)}% LIBERADO","""
text = text.replace(replacement, correct)

replacement2 = r"""  Text("% RESTANTE","""
correct2 = r"""  Text("${(100.0 - world.getLiberation(loc.name)).toStringAsFixed(0)}% RESTANTE","""
text = text.replace(replacement2, correct2)

with open("lib/screens/world_view.dart", "w", encoding="utf-8") as f:
    f.write(text)
