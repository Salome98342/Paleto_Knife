import 'package:flutter/material.dart';
import '../game_logic/enemy_system/enemy_types.dart';
import '../game_logic/enemy_system/attack_pattern.dart';
import '../game_logic/enemy_system/enemy_behavior.dart';
import 'retro_style.dart';

class EnemyDetailsDialog extends StatelessWidget {
  final EnemyTypeDefinition enemy;

  const EnemyDetailsDialog({
    Key? key,
    required this.enemy,
  }) : super(key: key);

  String _getAttackPatternName(AttackPatternType type) {
    switch (type) {
      case AttackPatternType.straight:
        return 'Disparo Directo';
      case AttackPatternType.spread:
        return 'Abanico';
      case AttackPatternType.radial:
        return 'Círculo Completo';
      case AttackPatternType.aimed:
        return 'Apuntado';
    }
  }

  String _getBehaviorName(BehaviorType type) {
    switch (type) {
      case BehaviorType.chase:
        return 'Persigue';
      case BehaviorType.keepDistance:
        return 'Mantiene Distancia';
      case BehaviorType.wander:
        return 'Vaga';
      case BehaviorType.circlePlayer:
        return 'Rodea';
      case BehaviorType.stationary:
        return 'Estático';
    }
  }

  String _getRoleName(String role) {
    switch (role.toLowerCase()) {
      case 'grunt':
        return 'Soldado';
      case 'bruiser':
        return 'Bruto';
      case 'shooter':
        return 'Tirador';
      case 'tank':
        return 'Tanque';
      case 'elite':
        return 'Élite';
      case 'boss':
        return '👑 JEFE';
      default:
        return role;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 8,
              offset: const Offset(4, 4),
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con nombre y botón cerrar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        enemy.name.toUpperCase(),
                        style: RetroStyle.font(
                          size: 14,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 2),
                          color: Colors.red,
                        ),
                        child: const Center(
                          child: Text(
                            '×',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Divider
                Container(
                  height: 2,
                  color: Colors.black,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                ),

                // Rol
                Row(
                  children: [
                    Text(
                      'TIPO: ',
                      style: RetroStyle.font(size: 10, color: Colors.black),
                    ),
                    Text(
                      _getRoleName(enemy.role),
                      style: RetroStyle.font(
                        size: 10,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Descripción
                Text(
                  'DESCRIPCIÓN:',
                  style: RetroStyle.font(size: 9, color: Colors.black),
                ),
                const SizedBox(height: 4),
                Text(
                  enemy.description,
                  style: RetroStyle.font(size: 8, color: Colors.black87),
                ),
                const SizedBox(height: 12),

                // Lore
                Text(
                  'LORE:',
                  style: RetroStyle.font(size: 9, color: Colors.black),
                ),
                const SizedBox(height: 4),
                Text(
                  enemy.lore,
                  style: RetroStyle.font(size: 8, color: Colors.black87),
                ),
                const SizedBox(height: 12),

                // Características
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    color: Colors.grey.shade100,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CARACTERÍSTICAS',
                        style: RetroStyle.font(
                          size: 10,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Vida Base:',
                            style: RetroStyle.font(size: 8, color: Colors.black),
                          ),
                          Text(
                            '${enemy.baseHealth.toInt()} HP',
                            style: RetroStyle.font(
                              size: 8,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Movimiento:',
                            style: RetroStyle.font(size: 8, color: Colors.black),
                          ),
                          Text(
                            _getBehaviorName(enemy.behavior.type),
                            style: RetroStyle.font(
                              size: 8,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Forma de Ataque
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black, width: 2),
                    color: Colors.yellow.shade50,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'FORMA DE ATAQUE',
                        style: RetroStyle.font(
                          size: 10,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tipo:',
                            style: RetroStyle.font(size: 8, color: Colors.black),
                          ),
                          Text(
                            _getAttackPatternName(enemy.attackPattern.type),
                            style: RetroStyle.font(
                              size: 8,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Cadencia:',
                            style: RetroStyle.font(size: 8, color: Colors.black),
                          ),
                          Text(
                            '${enemy.attackPattern.cooldown.toStringAsFixed(1)}s',
                            style: RetroStyle.font(
                              size: 8,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Daño por proyectil:',
                            style: RetroStyle.font(size: 8, color: Colors.black),
                          ),
                          Text(
                            '${enemy.attackPattern.bulletDamage.toStringAsFixed(1)}',
                            style: RetroStyle.font(
                              size: 8,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Proyectiles:',
                            style: RetroStyle.font(size: 8, color: Colors.black),
                          ),
                          Text(
                            '${enemy.attackPattern.bulletCount}',
                            style: RetroStyle.font(
                              size: 8,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Información Visual
                if (enemy.visualDescription.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'APARIENCIA:',
                        style: RetroStyle.font(size: 9, color: Colors.black),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        enemy.visualDescription,
                        style: RetroStyle.font(size: 8, color: Colors.black87),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),

                // Botón cerrar
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RetroStyle.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                        side: const BorderSide(color: Colors.black, width: 2),
                      ),
                    ),
                    child: Text(
                      'CERRAR',
                      style: RetroStyle.font(size: 9, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
