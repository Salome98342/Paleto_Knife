import 'dart:async';
import 'package:flutter/material.dart';
import '../models/player.dart';
import 'projectile_system.dart';

/// Controlador que maneja toda la lógica del jugador
class PlayerController {
  Player _player;
  final ProjectileSystem _projectileSystem;
  
  Timer? _attackTimer;
  double _attackCooldown = 0;

  PlayerController({
    required Player player,
    required ProjectileSystem projectileSystem,
  })  : _player = player,
        _projectileSystem = projectileSystem;

  /// Obtiene el jugador actual
  Player get player => _player;

  /// Mueve el jugador horizontalmente
  void moveLeft(double deltaTime, double screenWidth) {
    final distance = -_player.movementSpeed * deltaTime;
    _player.move(distance, screenWidth);
  }

  void moveRight(double deltaTime, double screenWidth) {
    final distance = _player.movementSpeed * deltaTime;
    _player.move(distance, screenWidth);
  }

  /// Mueve el jugador a una posición específica
  void moveTo(double x, double screenWidth) {
    const playerWidth = 50.0;
    final clampedX = x.clamp(playerWidth / 2, screenWidth - playerWidth / 2);
    _player.position = Offset(clampedX, _player.position.dy);
  }

  /// Activa el poder especial
  bool activatePower() {
    return _player.activatePower();
  }

  /// Actualiza el estado del jugador
  void update(double deltaTime) {
    // Actualizar poder especial
    _player.updatePower(deltaTime);
    
    // Actualizar cooldown de ataque
    if (_attackCooldown > 0) {
      _attackCooldown -= deltaTime;
    }
  }

  /// Intenta atacar (disparar proyectil)
  bool tryAttack() {
    if (_attackCooldown <= 0) {
      // Calcular cooldown basado en velocidad de ataque
      double attackSpeedMultiplier = _player.powerActive ? 1.5 : 1.0;
      _attackCooldown = 1.0 / (_player.attackSpeed * attackSpeedMultiplier);
      
      // Verificar precisión (si el ataque acierta)
      if (!_player.rollAccuracy()) {
        // Miss! No crear proyectil
        return false;
      }
      
      // Crear proyectil con daño calculado
      _projectileSystem.spawnPlayerProjectile(
        position: Offset(
          _player.position.dx,
          _player.position.dy - 30, // Desde arriba del jugador
        ),
        damage: _player.calculateDamage(),
      );
      
      return true;
    }
    return false;
  }

  /// Inicia el ataque automático
  void startAutoAttack() {
    _attackTimer?.cancel();
    
    _attackTimer = Timer.periodic(
      const Duration(milliseconds: 50),
      (timer) {
        tryAttack();
      },
    );
  }

  /// Detiene el ataque automático
  void stopAutoAttack() {
    _attackTimer?.cancel();
    _attackTimer = null;
  }

  /// Recibe daño
  void takeDamage(double damage) {
    _player.takeDamage(damage);
  }

  /// Cura al jugador
  void heal(double amount) {
    _player.heal(amount);
  }

  /// Verifica si el jugador está vivo
  bool get isAlive => _player.isAlive;

  /// Reinicia el jugador
  void reset() {
    _player.reset();
    _attackCooldown = 0;
  }

  /// Actualiza las estadísticas del jugador para un nuevo mundo
  void upgradeForWorld(int worldLevel) {
    // Aumentar estadísticas base por nivel de mundo
    _player = _player.copyWith(
      attackSpeed: 1.0 + (worldLevel - 1) * 0.1, // +10% por nivel
      baseDamage: 10.0 + (worldLevel - 1) * 2, // +2 daño por nivel
      maxHealth: 100.0 + (worldLevel - 1) * 20, // +20 HP por nivel
    );
    _player.health = _player.maxHealth; // Restaurar vida completa
  }

  /// Limpia recursos
  void dispose() {
    _attackTimer?.cancel();
  }
}
