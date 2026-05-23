import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chef_controller.dart';
import 'economy_controller.dart';

enum QuestPeriod { daily, weekly, achievement }

enum QuestStat { monstersKilled, chefsLeveledUp, gamesPlayed, coinsSpent }

enum QuestRewardType { coins, gems, characterBox, knifeBox }

class QuestReward {
  final QuestRewardType type;
  final int amount;

  const QuestReward(this.type, this.amount);

  String get label {
    switch (type) {
      case QuestRewardType.coins:
        return '+$amount MONEDAS';
      case QuestRewardType.gems:
        return '+$amount GEMAS';
      case QuestRewardType.characterBox:
        return '$amount CAJA${amount == 1 ? '' : 'S'} CHEF';
      case QuestRewardType.knifeBox:
        return '$amount CAJA${amount == 1 ? '' : 'S'} CUCHILLO';
    }
  }

  IconData get icon {
    switch (type) {
      case QuestRewardType.coins:
        return Icons.monetization_on;
      case QuestRewardType.gems:
        return Icons.diamond;
      case QuestRewardType.characterBox:
        return Icons.restaurant;
      case QuestRewardType.knifeBox:
        return Icons.hardware;
    }
  }

  Color get color {
    switch (type) {
      case QuestRewardType.coins:
        return Colors.amber;
      case QuestRewardType.gems:
        return Colors.lightBlueAccent;
      case QuestRewardType.characterBox:
        return Colors.purpleAccent;
      case QuestRewardType.knifeBox:
        return Colors.deepOrangeAccent;
    }
  }
}

class QuestDefinition {
  final String id;
  final String title;
  final String description;
  final QuestPeriod period;
  final QuestStat stat;
  final int target;
  final List<QuestReward> rewards;

  const QuestDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.period,
    required this.stat,
    required this.target,
    required this.rewards,
  });
}

class QuestProgress {
  final QuestDefinition quest;
  final int current;
  final bool claimed;

  const QuestProgress({
    required this.quest,
    required this.current,
    required this.claimed,
  });

  int get target => quest.target;
  bool get completed => current >= target;
  double get ratio => target == 0 ? 1 : (current / target).clamp(0.0, 1.0);
}

class QuestClaimResult {
  final QuestDefinition quest;
  final List<String> messages;
  final List<RollResult> rolls;

  const QuestClaimResult({
    required this.quest,
    required this.messages,
    this.rolls = const [],
  });
}

class QuestController extends ChangeNotifier {
  static const _dailyKeyPref = 'quest_daily_key';
  static const _weeklyKeyPref = 'quest_weekly_key';
  static const _dailyClaimedPref = 'quest_daily_claimed';
  static const _weeklyClaimedPref = 'quest_weekly_claimed';
  static const _achievementClaimedPref = 'quest_achievement_claimed';
  static const _achievementNotifiedPref = 'quest_achievement_notified';

  SharedPreferences? _prefs;
  bool _initialized = false;
  bool _syncing = false;
  String _dailyKey = '';
  String _weeklyKey = '';
  Set<String> _dailyClaimed = {};
  Set<String> _weeklyClaimed = {};
  Set<String> _achievementClaimed = {};
  Set<String> _achievementNotified = {};

  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    _dailyKey = _prefs!.getString(_dailyKeyPref) ?? '';
    _weeklyKey = _prefs!.getString(_weeklyKeyPref) ?? '';
    _dailyClaimed = (_prefs!.getStringList(_dailyClaimedPref) ?? []).toSet();
    _weeklyClaimed = (_prefs!.getStringList(_weeklyClaimedPref) ?? []).toSet();
    _achievementClaimed = (_prefs!.getStringList(_achievementClaimedPref) ?? [])
        .toSet();
    _achievementNotified =
        (_prefs!.getStringList(_achievementNotifiedPref) ?? []).toSet();
    _initialized = true;
    notifyListeners();
  }

  Future<void> syncWithEconomy(EconomyController eco) async {
    if (!_initialized || _syncing) return;
    _syncing = true;
    try {
      final now = DateTime.now();
      final today = _dateKey(now);
      final week = _weekKey(now);

      if (_dailyKey != today) {
        _dailyKey = today;
        _dailyClaimed = {};
        await _prefs!.setString(_dailyKeyPref, _dailyKey);
        await _prefs!.setStringList(_dailyClaimedPref, const []);
        await _saveBaselines(QuestPeriod.daily, eco);
      } else {
        await _ensureBaselines(QuestPeriod.daily, eco);
      }

      if (_weeklyKey != week) {
        _weeklyKey = week;
        _weeklyClaimed = {};
        await _prefs!.setString(_weeklyKeyPref, _weeklyKey);
        await _prefs!.setStringList(_weeklyClaimedPref, const []);
        await _saveBaselines(QuestPeriod.weekly, eco);
      } else {
        await _ensureBaselines(QuestPeriod.weekly, eco);
      }

      notifyListeners();
    } finally {
      _syncing = false;
    }
  }

  List<QuestProgress> progressFor(QuestPeriod period, EconomyController eco) {
    final definitions = _definitionsFor(period);
    return definitions.map((quest) {
      final current = _currentProgress(quest, eco);
      return QuestProgress(
        quest: quest,
        current: current,
        claimed: _claimedSet(period).contains(quest.id),
      );
    }).toList();
  }

  Future<QuestClaimResult?> claim(
    QuestDefinition quest,
    EconomyController eco,
    ChefController chefs,
  ) async {
    if (!_initialized) return null;
    final progress = _currentProgress(quest, eco);
    final claimed = _claimedSet(quest.period);
    if (progress < quest.target || claimed.contains(quest.id)) return null;

    final messages = <String>[];
    final rolls = <RollResult>[];

    for (final reward in quest.rewards) {
      switch (reward.type) {
        case QuestRewardType.coins:
          eco.addCoins(reward.amount);
          messages.add(reward.label);
          break;
        case QuestRewardType.gems:
          eco.addGems(reward.amount);
          messages.add(reward.label);
          break;
        case QuestRewardType.characterBox:
          final results = chefs.rollGacha(true, reward.amount, 'Raro', eco);
          rolls.addAll(results);
          messages.add(_rollSummary('CAJA CHEF', results));
          break;
        case QuestRewardType.knifeBox:
          final results = chefs.rollGacha(false, reward.amount, 'Raro', eco);
          rolls.addAll(results);
          messages.add(_rollSummary('CAJA CUCHILLO', results));
          break;
      }
    }

    claimed.add(quest.id);
    await _saveClaimed(quest.period);
    notifyListeners();

    return QuestClaimResult(quest: quest, messages: messages, rolls: rolls);
  }

  Future<List<QuestDefinition>> consumeCompletedAchievementNotifications(
    EconomyController eco,
  ) async {
    if (!_initialized) return const [];
    final completed = _definitionsFor(QuestPeriod.achievement).where((quest) {
      return !_achievementClaimed.contains(quest.id) &&
          !_achievementNotified.contains(quest.id) &&
          _currentProgress(quest, eco) >= quest.target;
    }).toList();

    if (completed.isEmpty) return const [];
    _achievementNotified.addAll(completed.map((quest) => quest.id));
    await _prefs!.setStringList(
      _achievementNotifiedPref,
      _achievementNotified.toList(),
    );
    return completed;
  }

  Duration get timeUntilDailyReset {
    final now = DateTime.now();
    final next = DateTime(now.year, now.month, now.day + 1);
    return next.difference(now);
  }

  Duration get timeUntilWeeklyReset {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final daysUntilMonday = 8 - today.weekday;
    final nextMonday = today.add(Duration(days: daysUntilMonday));
    return nextMonday.difference(now);
  }

  List<QuestDefinition> _definitionsFor(QuestPeriod period) {
    switch (period) {
      case QuestPeriod.daily:
        return _dailyDefinitions();
      case QuestPeriod.weekly:
        return _weeklyDefinitions();
      case QuestPeriod.achievement:
        return _achievementDefinitions();
    }
  }

  List<QuestDefinition> _dailyDefinitions() {
    final seed = _hash(_dailyKey);
    final killTarget = 35 + (seed % 4) * 15;
    final gamesTarget = 1 + (seed % 3);
    final spendTarget = 500 + (seed % 4) * 250;
    final levelTarget = 1;
    final bonusReward = seed.isEven
        ? const QuestReward(QuestRewardType.characterBox, 1)
        : const QuestReward(QuestRewardType.knifeBox, 1);

    return [
      QuestDefinition(
        id: 'daily_kill_$_dailyKey',
        title: 'Limpieza rapida',
        description: 'Elimina enemigos durante el dia actual.',
        period: QuestPeriod.daily,
        stat: QuestStat.monstersKilled,
        target: killTarget,
        rewards: const [
          QuestReward(QuestRewardType.gems, 20),
          QuestReward(QuestRewardType.coins, 450),
        ],
      ),
      QuestDefinition(
        id: 'daily_games_$_dailyKey',
        title: 'Turno completo',
        description: 'Termina partidas para cerrar el turno.',
        period: QuestPeriod.daily,
        stat: QuestStat.gamesPlayed,
        target: gamesTarget,
        rewards: const [QuestReward(QuestRewardType.gems, 15)],
      ),
      QuestDefinition(
        id: 'daily_spend_$_dailyKey',
        title: 'Inversion de cocina',
        description: 'Gasta monedas en mejoras.',
        period: QuestPeriod.daily,
        stat: QuestStat.coinsSpent,
        target: spendTarget,
        rewards: [bonusReward],
      ),
      QuestDefinition(
        id: 'daily_level_$_dailyKey',
        title: 'Chef en practica',
        description: 'Sube de nivel cualquier chef.',
        period: QuestPeriod.daily,
        stat: QuestStat.chefsLeveledUp,
        target: levelTarget,
        rewards: const [
          QuestReward(QuestRewardType.gems, 25),
          QuestReward(QuestRewardType.characterBox, 1),
        ],
      ),
    ];
  }

  List<QuestDefinition> _weeklyDefinitions() {
    final seed = _hash(_weeklyKey);
    return [
      QuestDefinition(
        id: 'weekly_kill_$_weeklyKey',
        title: 'Semana de limpieza',
        description: 'Derrota una gran cantidad de enemigos esta semana.',
        period: QuestPeriod.weekly,
        stat: QuestStat.monstersKilled,
        target: 220 + (seed % 4) * 40,
        rewards: const [
          QuestReward(QuestRewardType.gems, 90),
          QuestReward(QuestRewardType.characterBox, 1),
        ],
      ),
      QuestDefinition(
        id: 'weekly_games_$_weeklyKey',
        title: 'Servicio constante',
        description: 'Juega varias partidas durante la semana.',
        period: QuestPeriod.weekly,
        stat: QuestStat.gamesPlayed,
        target: 8 + (seed % 3),
        rewards: const [
          QuestReward(QuestRewardType.coins, 3500),
          QuestReward(QuestRewardType.knifeBox, 1),
        ],
      ),
      QuestDefinition(
        id: 'weekly_spend_$_weeklyKey',
        title: 'Cocina equipada',
        description: 'Invierte monedas en mejoras.',
        period: QuestPeriod.weekly,
        stat: QuestStat.coinsSpent,
        target: 4500 + (seed % 4) * 750,
        rewards: const [QuestReward(QuestRewardType.gems, 120)],
      ),
      QuestDefinition(
        id: 'weekly_level_$_weeklyKey',
        title: 'Entrenamiento serio',
        description: 'Sube chefs de nivel varias veces.',
        period: QuestPeriod.weekly,
        stat: QuestStat.chefsLeveledUp,
        target: 3,
        rewards: const [
          QuestReward(QuestRewardType.characterBox, 1),
          QuestReward(QuestRewardType.knifeBox, 1),
        ],
      ),
    ];
  }

  List<QuestDefinition> _achievementDefinitions() {
    return const [
      QuestDefinition(
        id: 'ach_kills_100',
        title: 'Primer banquete',
        description: 'Elimina 100 enemigos en total.',
        period: QuestPeriod.achievement,
        stat: QuestStat.monstersKilled,
        target: 100,
        rewards: [
          QuestReward(QuestRewardType.gems, 75),
          QuestReward(QuestRewardType.characterBox, 1),
        ],
      ),
      QuestDefinition(
        id: 'ach_kills_1000',
        title: 'Maestro de limpieza',
        description: 'Elimina 1000 enemigos en total.',
        period: QuestPeriod.achievement,
        stat: QuestStat.monstersKilled,
        target: 1000,
        rewards: [
          QuestReward(QuestRewardType.gems, 250),
          QuestReward(QuestRewardType.knifeBox, 2),
        ],
      ),
      QuestDefinition(
        id: 'ach_games_25',
        title: 'Veterano del servicio',
        description: 'Termina 25 partidas.',
        period: QuestPeriod.achievement,
        stat: QuestStat.gamesPlayed,
        target: 25,
        rewards: [
          QuestReward(QuestRewardType.coins, 8000),
          QuestReward(QuestRewardType.characterBox, 1),
        ],
      ),
      QuestDefinition(
        id: 'ach_spend_10000',
        title: 'Inversionista',
        description: 'Gasta 10000 monedas en mejoras.',
        period: QuestPeriod.achievement,
        stat: QuestStat.coinsSpent,
        target: 10000,
        rewards: [
          QuestReward(QuestRewardType.gems, 180),
          QuestReward(QuestRewardType.knifeBox, 1),
        ],
      ),
      QuestDefinition(
        id: 'ach_level_10',
        title: 'Escuela de chefs',
        description: 'Sube chefs de nivel 10 veces.',
        period: QuestPeriod.achievement,
        stat: QuestStat.chefsLeveledUp,
        target: 10,
        rewards: [
          QuestReward(QuestRewardType.gems, 200),
          QuestReward(QuestRewardType.characterBox, 2),
        ],
      ),
    ];
  }

  int _currentProgress(QuestDefinition quest, EconomyController eco) {
    final raw = _statValue(eco, quest.stat);
    if (quest.period == QuestPeriod.achievement) return raw;
    final baseline = _baseline(quest.period, quest.stat);
    return (raw - baseline).clamp(0, 1 << 31);
  }

  int _statValue(EconomyController eco, QuestStat stat) {
    switch (stat) {
      case QuestStat.monstersKilled:
        return eco.monstersKilled;
      case QuestStat.chefsLeveledUp:
        return eco.chefsLeveledUp;
      case QuestStat.gamesPlayed:
        return eco.gamesPlayed;
      case QuestStat.coinsSpent:
        return eco.coinsSpent;
    }
  }

  Set<String> _claimedSet(QuestPeriod period) {
    switch (period) {
      case QuestPeriod.daily:
        return _dailyClaimed;
      case QuestPeriod.weekly:
        return _weeklyClaimed;
      case QuestPeriod.achievement:
        return _achievementClaimed;
    }
  }

  Future<void> _saveClaimed(QuestPeriod period) async {
    switch (period) {
      case QuestPeriod.daily:
        await _prefs!.setStringList(_dailyClaimedPref, _dailyClaimed.toList());
        break;
      case QuestPeriod.weekly:
        await _prefs!.setStringList(
          _weeklyClaimedPref,
          _weeklyClaimed.toList(),
        );
        break;
      case QuestPeriod.achievement:
        await _prefs!.setStringList(
          _achievementClaimedPref,
          _achievementClaimed.toList(),
        );
        break;
    }
  }

  Future<void> _ensureBaselines(
    QuestPeriod period,
    EconomyController eco,
  ) async {
    for (final stat in QuestStat.values) {
      final key = _baselineKey(period, stat);
      if (!_prefs!.containsKey(key)) {
        await _prefs!.setInt(key, _statValue(eco, stat));
      }
    }
  }

  Future<void> _saveBaselines(QuestPeriod period, EconomyController eco) async {
    for (final stat in QuestStat.values) {
      await _prefs!.setInt(_baselineKey(period, stat), _statValue(eco, stat));
    }
  }

  int _baseline(QuestPeriod period, QuestStat stat) {
    return _prefs?.getInt(_baselineKey(period, stat)) ?? 0;
  }

  String _baselineKey(QuestPeriod period, QuestStat stat) {
    return 'quest_${period.name}_baseline_${stat.name}';
  }

  String _rollSummary(String label, List<RollResult> results) {
    if (results.isEmpty) return label;
    final names = results.map((result) => result.entity.name).join(', ');
    return '$label: $names';
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${_two(date.month)}-${_two(date.day)}';
  }

  String _weekKey(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    final monday = day.subtract(Duration(days: day.weekday - 1));
    return '${monday.year}-W${_two(_weekNumber(monday))}';
  }

  int _weekNumber(DateTime date) {
    final firstDay = DateTime(date.year, 1, 1);
    final diff = date.difference(firstDay).inDays;
    return (diff / 7).floor() + 1;
  }

  String _two(int value) => value.toString().padLeft(2, '0');

  int _hash(String value) {
    var hash = 0;
    for (final code in value.codeUnits) {
      hash = 0x1fffffff & (hash + code);
      hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
      hash ^= hash >> 6;
    }
    return hash.abs();
  }
}
