import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymplanner_mobile/core/models/calorie_entry_model.dart';
import 'package:gymplanner_mobile/core/models/calorie_target_model.dart';
import 'package:gymplanner_mobile/features/calorie/providers/calorie_provider.dart';

class CalorieTrackingScreen
    extends ConsumerStatefulWidget {
  const CalorieTrackingScreen({super.key});

  @override
  ConsumerState<CalorieTrackingScreen>
  createState() => _CalorieTrackingScreenState();
}

class _CalorieTrackingScreenState
    extends ConsumerState<CalorieTrackingScreen> {
  final _calorieInputController =
      TextEditingController();

  @override
  void dispose() {
    _calorieInputController.dispose();
    super.dispose();
  }

  String _activityLabel(String level) {
    switch (level) {
      case 'sedentary':
        return 'Hareketsiz';
      case 'light':
        return 'Az Hareketli';
      case 'moderate':
        return 'Orta';
      case 'active':
        return 'Çok Hareketli';
      default:
        return level;
    }
  }

  String _goalLabel(String goal) {
    switch (goal) {
      case 'Lose Weight':
        return 'Kilo Ver';
      case 'Gain Muscle':
        return 'Kas Kazan';
      case 'Maintain':
        return 'Koru';
      default:
        return goal;
    }
  }

  Future<void> _logToday() async {
    final calories = int.tryParse(
      _calorieInputController.text.trim(),
    );
    if (calories == null || calories <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Geçerli bir kalori miktarı gir.',
          ),
        ),
      );
      return;
    }
    final success = await ref
        .read(calorieProvider.notifier)
        .logTodayCalories(calories);
    if (success && mounted) {
      _calorieInputController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Bugünün kalorisi kaydedildi.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(calorieProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalori Takibi'),
      ),
      body:
          state.isLoading && state.target == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : state.errorMessage != null &&
                state.target == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: () => ref
                  .read(calorieProvider.notifier)
                  .loadAll(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (state.target != null)
                    _TargetCard(
                      target: state.target!,
                      goalLabel: _goalLabel,
                    ),
                  const SizedBox(height: 20),
                  _TodayEntryCard(
                    controller:
                        _calorieInputController,
                    isLoading:
                        state.isLoggingToday,
                    todayCalories:
                        state.todayCalories,
                    onSubmit: _logToday,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Son 30 Gün',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: _CalorieChart(
                      entries: state.entries,
                      targetCalories: state
                          .target
                          ?.targetCalories,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Aktivite Seviyesi',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  _ActivityLevelSelector(
                    current:
                        state
                            .target
                            ?.activityLevel ??
                        'moderate',
                    isSaving:
                        state.isSavingSettings,
                    labelFor: _activityLabel,
                    onSelected: (level) => ref
                        .read(
                          calorieProvider
                              .notifier,
                        )
                        .updateActivityLevel(
                          level,
                        ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _TargetCard extends StatelessWidget {
  final CalorieTargetModel target;
  final String Function(String) goalLabel;

  const _TargetCard({
    required this.target,
    required this.goalLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Günlük Hedef',
              style: Theme.of(
                context,
              ).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              '${target.targetCalories} kcal',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(
                      context,
                    ).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hedef: ${goalLabel(target.goal)}',
            ),
            const SizedBox(height: 4),
            Text(
              'BMR: ${target.bmr} kcal  •  TDEE: ${target.tdee} kcal',
              style: Theme.of(
                context,
              ).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayEntryCard extends StatelessWidget {
  final TextEditingController controller;
  final bool isLoading;
  final int? todayCalories;
  final VoidCallback onSubmit;

  const _TodayEntryCard({
    required this.controller,
    required this.isLoading,
    required this.todayCalories,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              todayCalories != null
                  ? 'Bugün girilen: $todayCalories kcal'
                  : 'Bugün için henüz kalori girmedin',
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType:
                        TextInputType.number,
                    decoration: const InputDecoration(
                      hintText:
                          'Bugünün kalorisi (kcal)',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(
                          8,
                        ),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child:
                              CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: onSubmit,
                        child: const Text(
                          'Kaydet',
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CalorieChart extends StatelessWidget {
  final List<CalorieEntryModel> entries;
  final int? targetCalories;

  const _CalorieChart({
    required this.entries,
    required this.targetCalories,
  });

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const Center(
        child: Text('Henüz kalori kaydı yok'),
      );
    }

    final spots = <FlSpot>[
      for (int i = 0; i < entries.length; i++)
        FlSpot(
          i.toDouble(),
          entries[i].calories.toDouble(),
        ),
    ];

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(
              showTitles: false,
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 ||
                    index >= entries.length)
                  return const SizedBox.shrink();
                final date = entries[index].date;
                return Padding(
                  padding: const EdgeInsets.only(
                    top: 6,
                  ),
                  child: Text(
                    '${date.day}/${date.month}',
                    style: const TextStyle(
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
          if (targetCalories != null)
            LineChartBarData(
              spots: [
                FlSpot(
                  0,
                  targetCalories!.toDouble(),
                ),
                FlSpot(
                  (entries.length - 1).toDouble(),
                  targetCalories!.toDouble(),
                ),
              ],
              isCurved: false,
              barWidth: 1.5,
              dashArray: [6, 4],
              dotData: const FlDotData(
                show: false,
              ),
              color: Colors.grey,
            ),
        ],
      ),
    );
  }
}

class _ActivityLevelSelector
    extends StatelessWidget {
  final String current;
  final bool isSaving;
  final String Function(String) labelFor;
  final ValueChanged<String> onSelected;

  const _ActivityLevelSelector({
    required this.current,
    required this.isSaving,
    required this.labelFor,
    required this.onSelected,
  });

  static const _levels = [
    'sedentary',
    'light',
    'moderate',
    'active',
  ];

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isSaving ? 0.5 : 1,
      child: Wrap(
        spacing: 8,
        children: _levels.map((level) {
          final isSelected = level == current;
          return ChoiceChip(
            label: Text(labelFor(level)),
            selected: isSelected,
            onSelected: isSaving
                ? null
                : (_) => onSelected(level),
          );
        }).toList(),
      ),
    );
  }
}
