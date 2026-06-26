import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymplanner_mobile/core/models/body_measurement_model.dart';
import 'package:gymplanner_mobile/core/models/workout_log_model.dart';
import 'package:gymplanner_mobile/features/auth/providers/auth_provider.dart';
import 'package:gymplanner_mobile/features/home/providers/home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(
    BuildContext context,
    WidgetRef ref,
  ) {
    final homeState = ref.watch(homeProvider);
    final userName = _resolveUserName(
      ref.watch(authProvider).user,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Merhaba, $userName!'),
      ),
      body: homeState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => _ErrorState(
          message: error.toString().replaceFirst(
            'Exception: ',
            '',
          ),
        ),
        data: (dashboard) => RefreshIndicator(
          onRefresh: () => ref
              .read(homeProvider.notifier)
              .refresh(),
          child: SingleChildScrollView(
            physics:
                const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                _GreetingSection(
                  userName: userName,
                ),
                const SizedBox(height: 12),
                _NextWorkoutCard(
                  nextWorkoutDay:
                      dashboard.nextWorkoutDay,
                ),
                const SizedBox(height: 12),
                _LastWorkoutCard(
                  lastWorkoutLog:
                      dashboard.lastWorkoutLog,
                ),
                const SizedBox(height: 12),
                _ActiveRoutinesCard(
                  activeRoutineCount: dashboard
                      .activeRoutineCount,
                ),
                const SizedBox(height: 12),
                _LastMeasurementCard(
                  measurement:
                      dashboard.lastMeasurement,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _resolveUserName(
    Map<String, dynamic>? user,
  ) {
    final name = user?['name']?.toString().trim();
    final username = user?['username']
        ?.toString()
        .trim();

    if (name != null && name.isNotEmpty) {
      return name;
    }
    if (username != null && username.isNotEmpty) {
      return username;
    }

    return 'Sporcu';
  }
}

class _GreetingSection extends StatelessWidget {
  final String userName;

  const _GreetingSection({
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              'Bugun nasilsin, $userName?',
              style: Theme.of(
                context,
              ).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(now),
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Ocak',
      'Subat',
      'Mart',
      'Nisan',
      'Mayis',
      'Haziran',
      'Temmuz',
      'Agustos',
      'Eylul',
      'Ekim',
      'Kasim',
      'Aralik',
    ];
    const weekdays = [
      'Pazartesi',
      'Sali',
      'Carsamba',
      'Persembe',
      'Cuma',
      'Cumartesi',
      'Pazar',
    ];

    final weekday = weekdays[date.weekday - 1];
    final month = months[date.month - 1];
    return '$weekday, ${date.day} $month ${date.year}';
  }
}

class _NextWorkoutCard extends StatelessWidget {
  final String? nextWorkoutDay;

  const _NextWorkoutCard({
    required this.nextWorkoutDay,
  });

  @override
  Widget build(BuildContext context) {
    final value = nextWorkoutDay ?? 'Planlanmadi';
    return _InfoCard(
      title: 'Sonraki Antrenman',
      value: value,
      icon: Icons.event_available,
    );
  }
}

class _LastWorkoutCard extends StatelessWidget {
  final WorkoutLogModel? lastWorkoutLog;

  const _LastWorkoutCard({
    required this.lastWorkoutLog,
  });

  @override
  Widget build(BuildContext context) {
    final value = lastWorkoutLog == null
        ? 'Henuz antrenman yok'
        : '${_formatDate(lastWorkoutLog!.date)} - ${lastWorkoutLog!.routineName ?? 'Rutin bilgisi yok'}';

    return _InfoCard(
      title: 'Son Antrenman',
      value: value,
      icon: Icons.fitness_center,
    );
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
}

class _ActiveRoutinesCard
    extends StatelessWidget {
  final int activeRoutineCount;

  const _ActiveRoutinesCard({
    required this.activeRoutineCount,
  });

  @override
  Widget build(BuildContext context) {
    return _InfoCard(
      title: 'Aktif Program Sayisi',
      value: activeRoutineCount.toString(),
      icon: Icons.list_alt,
    );
  }
}

class _LastMeasurementCard
    extends StatelessWidget {
  final BodyMeasurementModel? measurement;

  const _LastMeasurementCard({
    required this.measurement,
  });

  @override
  Widget build(BuildContext context) {
    final value = measurement == null
        ? 'Henuz olcum yok'
        : '${measurement!.weight.toStringAsFixed(1)} kg - ${_formatDate(measurement!.date)}';

    return _InfoCard(
      title: 'Son Olcum',
      value: value,
      icon: Icons.monitor_weight,
    );
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
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(icon),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 36,
            ),
            const SizedBox(height: 8),
            Text(
              'Bir hata olustu',
              style: Theme.of(
                context,
              ).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
