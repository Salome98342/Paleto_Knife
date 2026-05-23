import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../controllers/chef_controller.dart';
import '../controllers/economy_controller.dart';
import '../controllers/quest_controller.dart';
import '../services/audio_service.dart';
import '../widgets/retro_style.dart';

class QuestsView extends StatefulWidget {
  const QuestsView({super.key});

  @override
  State<QuestsView> createState() => _QuestsViewState();
}

class _QuestsViewState extends State<QuestsView> {
  Timer? _clockTimer;
  bool _notificationInFlight = false;

  @override
  void initState() {
    super.initState();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final eco = context.read<EconomyController>();
      context.read<QuestController>().syncWithEconomy(eco);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eco = context.watch<EconomyController>();
    final quests = context.watch<QuestController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<QuestController>().syncWithEconomy(eco);
      _showAchievementNotifications();
    });

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 80.0),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFF160F0A),
                border: Border.all(color: RetroStyle.accent, width: 2),
              ),
              child: TabBar(
                isScrollable: true,
                indicatorColor: RetroStyle.accent,
                indicatorWeight: 4,
                labelStyle: RetroStyle.font(size: 11, color: RetroStyle.accent),
                unselectedLabelStyle: RetroStyle.font(
                  size: 9,
                  color: Colors.white70,
                ),
                onTap: (_) => AudioService.instance.playClickSound(),
                tabs: const [
                  Tab(text: 'DIARIOS'),
                  Tab(text: 'SEMANALES'),
                  Tab(text: 'LOGROS'),
                ],
              ),
            ),
          ),
          Expanded(
            child: quests.isInitialized
                ? TabBarView(
                    children: [
                      _buildQuestList(QuestPeriod.daily, eco, quests),
                      _buildQuestList(QuestPeriod.weekly, eco, quests),
                      _buildQuestList(QuestPeriod.achievement, eco, quests),
                    ],
                  )
                : const Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestList(
    QuestPeriod period,
    EconomyController eco,
    QuestController quests,
  ) {
    final progress = quests.progressFor(period, eco);

    return ListView.separated(
      padding: const EdgeInsets.only(
        top: 24.0,
        left: 16.0,
        right: 16.0,
        bottom: 110.0,
      ),
      itemBuilder: (context, index) {
        if (index == 0) return _buildPeriodHeader(period, quests);
        return _buildQuestCard(progress[index - 1]);
      },
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemCount: progress.length + 1,
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.12);
  }

  Widget _buildPeriodHeader(QuestPeriod period, QuestController quests) {
    final title = switch (period) {
      QuestPeriod.daily => 'RETOS DIARIOS',
      QuestPeriod.weekly => 'RETOS SEMANALES',
      QuestPeriod.achievement => 'LOGROS',
    };
    final subtitle = switch (period) {
      QuestPeriod.daily =>
        'Reinicio en ${_formatDuration(quests.timeUntilDailyReset)}',
      QuestPeriod.weekly =>
        'Reinicio semanal en ${_formatDuration(quests.timeUntilWeeklyReset)}',
      QuestPeriod.achievement => 'Progreso permanente de la cuenta',
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.black.withValues(alpha: 0.92),
            const Color(0xFF22160D).withValues(alpha: 0.98),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: RetroStyle.accent, width: 3),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: RetroStyle.accent.withValues(alpha: 0.18),
              border: Border.all(color: RetroStyle.accent, width: 2),
            ),
            child: Icon(
              period == QuestPeriod.achievement
                  ? Icons.emoji_events
                  : Icons.timer,
              color: RetroStyle.accent,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: RetroStyle.font(size: 11, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: RetroStyle.font(size: 8, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestCard(QuestProgress progress) {
    final quest = progress.quest;
    final isCompleted = progress.completed;
    final isClaimed = progress.claimed;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isClaimed
              ? [Colors.grey.shade500, Colors.grey.shade300]
              : [const Color(0xFF1B140E), const Color(0xFF2B2016)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: isClaimed
              ? Colors.grey.shade600
              : (isCompleted ? RetroStyle.primary : Colors.black),
          width: 4,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quest.title,
                      style: RetroStyle.font(
                        size: 11,
                        color: isClaimed
                            ? Colors.grey.shade800
                            : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      quest.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: RetroStyle.font(
                        size: 8,
                        color: isClaimed
                            ? Colors.grey.shade700
                            : Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRewardChips(quest.rewards, isClaimed),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildProgressBlocks(progress, isClaimed)),
              const SizedBox(width: 8),
              Text(
                '${progress.current.clamp(0, progress.target)}/${progress.target}',
                style: RetroStyle.font(
                  size: 8,
                  color: isClaimed ? Colors.grey.shade700 : RetroStyle.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: _buildActionButton(progress),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardChips(List<QuestReward> rewards, bool isClaimed) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.start,
      children: rewards.map((reward) {
        final color = isClaimed ? Colors.grey : reward.color;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isClaimed ? Colors.grey.shade500 : Colors.black.withValues(alpha: 0.85),
            border: Border.all(color: color, width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(reward.icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(reward.label, style: RetroStyle.font(size: 8, color: color)),
            ],
          ),
        ).animate(target: isClaimed ? 0 : 1).shimmer(duration: 2.seconds);
      }).toList(),
    );
  }

  Widget _buildProgressBlocks(QuestProgress progress, bool isClaimed) {
    return Row(
      children: List.generate(10, (index) {
        final isFilled = index < (progress.ratio * 10).floor();
        return Expanded(
          child: Container(
            height: 14,
            margin: const EdgeInsets.only(right: 3),
            decoration: BoxDecoration(
              color: isFilled
                  ? (isClaimed ? Colors.grey : RetroStyle.primary)
                  : Colors.black.withValues(alpha: 0.3),
              border: Border.all(color: Colors.black54, width: 2),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildActionButton(QuestProgress progress) {
    if (progress.claimed) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Text(
          'RECLAMADO',
          style: RetroStyle.font(size: 10, color: Colors.grey.shade600),
        ),
      );
    }

    if (!progress.completed) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: RetroStyle.box(color: Colors.grey.shade400),
        child: Text(
          'PENDIENTE',
          style: RetroStyle.font(size: 10, color: Colors.grey.shade700),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _claimQuest(progress.quest),
      child:
          Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                decoration: RetroStyle.box(color: RetroStyle.accent).copyWith(
                  boxShadow: [
                    BoxShadow(
                      color: RetroStyle.accent.withValues(alpha: 0.8),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Text(
                  'RECLAMAR',
                  style: RetroStyle.font(size: 10, color: Colors.white),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .scaleXY(begin: 1.0, end: 1.05, duration: 600.ms)
              .shimmer(duration: 1000.ms, color: Colors.white54),
    );
  }

  Future<void> _claimQuest(QuestDefinition quest) async {
    AudioService.instance.playClickSound();
    final result = await context.read<QuestController>().claim(
      quest,
      context.read<EconomyController>(),
      context.read<ChefController>(),
    );
    if (!mounted || result == null) return;

    RetroStyle.showSuccess(
      context,
      '!MISION CUMPLIDA!\n${result.messages.join('\n')}',
      icon: quest.period == QuestPeriod.achievement
          ? Icons.emoji_events
          : result.rolls.isNotEmpty
          ? Icons.card_giftcard
          : Icons.check_circle,
    );
  }

  Future<void> _showAchievementNotifications() async {
    if (_notificationInFlight) return;
    _notificationInFlight = true;
    try {
      final completed = await context
          .read<QuestController>()
          .consumeCompletedAchievementNotifications(
            context.read<EconomyController>(),
          );
      if (!mounted || completed.isEmpty) return;

      RetroStyle.showSuccess(
        context,
        '!LOGRO COMPLETADO!\n${completed.first.title}',
        icon: Icons.emoji_events,
      );
    } finally {
      _notificationInFlight = false;
    }
  }

  String _formatDuration(Duration duration) {
    final safe = duration.isNegative ? Duration.zero : duration;
    final days = safe.inDays;
    final hours = safe.inHours.remainder(24).toString().padLeft(2, '0');
    final minutes = safe.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = safe.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (days > 0) return '${days}d $hours:$minutes:$seconds';
    return '$hours:$minutes:$seconds';
  }
}
