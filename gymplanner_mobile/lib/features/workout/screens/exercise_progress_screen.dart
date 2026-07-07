import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymplanner_mobile/core/models/exercise_progress_model.dart';
import 'package:gymplanner_mobile/features/workout/providers/exercise_progress_provider.dart';

class ExerciseProgressScreen
    extends ConsumerWidget {
  final int exerciseId;
  final String exerciseName;

  const ExerciseProgressScreen({
    super.key,
    required this.exerciseId,
    required this.exerciseName,
  });

  String _metricLabel(ProgressMetric metric) {
    switch (metric) {
      case ProgressMetric.maxWeight:
        return 'Maks. Ağırlık';
      case ProgressMetric.totalVolume:
        return 'Toplam Hacim';
      case ProgressMetric.estimated1RM:
        return 'Tahmini 1RM';
    }
  }

  double _metricValue(
    ExerciseProgressEntryModel entry,
    ProgressMetric metric,
  ) {
    switch (metric) {
      case ProgressMetric.maxWeight:
        return entry.maxWeight;
      case ProgressMetric.totalVolume:
        return entry.totalVolume;
      case ProgressMetric.estimated1RM:
        return entry.estimated1RM;
    }
  }

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final state = ref.watch(
      exerciseProgressProvider(exerciseId),
    );

    return Scaffold(
      appBar: AppBar(title: Text(exerciseName)),
      body: state.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : state.errorMessage != null &&
                state.history.isEmpty
          ? Center(
              child: Text(state.errorMessage!),
            )
          : state.history.isEmpty
          ? const Center(
              child: Text(
                'Bu hareket için henüz kayıt yok',
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SegmentedButton<ProgressMetric>(
                  segments: ProgressMetric.values
                      .map(
                        (m) => ButtonSegment(
                          value: m,
                          label: Text(
                            _metricLabel(m),
                          ),
                        ),
                      )
                      .toList(),
                  selected: {
                    state.selectedMetric,
                  },
                  onSelectionChanged: (selection) {
                    ref
                        .read(
                          exerciseProgressProvider(
                            exerciseId,
                          ).notifier,
                        )
                        .selectMetric(
                          selection.first,
                        );
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 220,
                  child: _ProgressChart(
                    history: state.history,
                    metric: state.selectedMetric,
                    valueGetter: _metricValue,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Geçmiş',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final entry
                    in state.history.reversed)
                  _HistoryDayCard(entry: entry),
              ],
            ),
    );
  }
}

class _ProgressChart extends StatelessWidget {
  final List<ExerciseProgressEntryModel> history;
  final ProgressMetric metric;
  final double Function(
    ExerciseProgressEntryModel,
    ProgressMetric,
  )
  valueGetter;

  const _ProgressChart({
    required this.history,
    required this.metric,
    required this.valueGetter,
  });

  @override
  Widget build(BuildContext context) {
    final spots = <FlSpot>[
      for (int i = 0; i < history.length; i++)
        FlSpot(
          i.toDouble(),
          valueGetter(history[i], metric),
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
                    index >= history.length)
                  return const SizedBox.shrink();
                final date = history[index].date;
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
        ],
      ),
    );
  }
}

class _HistoryDayCard extends StatelessWidget {
  final ExerciseProgressEntryModel entry;

  const _HistoryDayCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              '${entry.date.day}/${entry.date.month}/${entry.date.year}',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall
                  ?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            for (final set in entry.sets)
              Text(
                'Set ${set.setNumber}: ${set.reps} tekrar × ${set.weight} kg',
              ),
            const Divider(height: 16),
            Text(
              'Maks: ${entry.maxWeight} kg   •   Hacim: ${entry.totalVolume.toStringAsFixed(0)}   •   1RM: ${entry.estimated1RM} kg',
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
