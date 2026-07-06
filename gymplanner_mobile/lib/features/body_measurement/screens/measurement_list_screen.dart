import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymplanner_mobile/core/constants/app_colors.dart';
import 'package:gymplanner_mobile/core/models/body_measurement_model.dart';
import 'package:gymplanner_mobile/features/body_measurement/providers/measurement_provider.dart';
import 'package:gymplanner_mobile/features/body_measurement/screens/add_measurement_screen.dart';

class MeasurementListScreen
    extends ConsumerStatefulWidget {
  const MeasurementListScreen({super.key});

  @override
  ConsumerState<MeasurementListScreen>
  createState() => _MeasurementListScreenState();
}

class _MeasurementListScreenState
    extends ConsumerState<MeasurementListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(measurementProvider.notifier)
          .loadMeasurements();
    });
  }

  Future<void> _handleDelete(
    BodyMeasurementModel measurement,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Ölçümü Sil'),
        content: const Text(
          'Bu ölçüm kaydını silmek istediğine emin misin?',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () =>
                Navigator.pop(context, true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(measurementProvider.notifier)
          .deleteMeasurement(measurement.id);
    }
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(
      2,
      '0',
    );
    final month = date.month.toString().padLeft(
      2,
      '0',
    );
    return '$day/$month/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(measurementProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ölçümler')),
      body: RefreshIndicator(
        onRefresh: () => ref
            .read(measurementProvider.notifier)
            .loadMeasurements(),
        child: _buildBody(state),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'add_measurement',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  const AddMeasurementScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(MeasurementState state) {
    if (state.isLoading &&
        state.measurements.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.errorMessage != null &&
        state.measurements.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            state.errorMessage!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (state.measurements.isEmpty) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 120),
          Center(
            child: Text('Henüz ölçüm eklenmedi'),
          ),
        ],
      );
    }

    // Backend en yeni tarihten en eskiye sıralıyor,
    // grafik için kronolojik sıraya çeviriyoruz.
    final chronological = state.measurements.reversed
        .toList();

    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        if (chronological.length > 1)
          Card(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                8,
                20,
                16,
                12,
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(
                      left: 8,
                      bottom: 12,
                    ),
                    child: Text(
                      'Kilo Grafiği',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 180,
                    child: LineChart(
                      LineChartData(
                        gridData: const FlGridData(
                          show: false,
                        ),
                        titlesData: const FlTitlesData(
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                            ),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 36,
                            ),
                          ),
                        ),
                        borderData: FlBorderData(
                          show: false,
                        ),
                        lineBarsData: [
                          LineChartBarData(
                            spots: [
                              for (
                                var i = 0;
                                i < chronological.length;
                                i++
                              )
                                FlSpot(
                                  i.toDouble(),
                                  chronological[i]
                                      .weight,
                                ),
                            ],
                            isCurved: true,
                            color: AppColors.primary,
                            barWidth: 3,
                            dotData: const FlDotData(
                              show: true,
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppColors
                                  .primary
                                  .withValues(
                                    alpha: 0.15,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 16),
        for (final measurement
            in state.measurements)
          Card(
            margin: const EdgeInsets.only(
              bottom: 10,
            ),
            child: ListTile(
              title: Text(
                '${measurement.weight.toStringAsFixed(1)} kg',
              ),
              subtitle: Text(
                '${_formatDate(measurement.date)}'
                '${measurement.bodyFatPercentage != null ? ' · Yağ: %${measurement.bodyFatPercentage!.toStringAsFixed(1)}' : ''}',
              ),
              trailing: IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                ),
                onPressed: () =>
                    _handleDelete(measurement),
              ),
            ),
          ),
      ],
    );
  }
}