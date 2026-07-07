import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymplanner_mobile/core/models/routine_exercise_model.dart';
import 'package:gymplanner_mobile/features/exercise/screens/add_exercise_screen.dart';
import 'package:gymplanner_mobile/features/workout/providers/workout_provider.dart';
import 'package:gymplanner_mobile/features/workout/screens/create_workout_screen.dart';
import 'package:gymplanner_mobile/features/workout/screens/exercise_progress_screen.dart';


class WorkoutDetailScreen
    extends ConsumerStatefulWidget {
  final int routineId;

  const WorkoutDetailScreen({
    super.key,
    required this.routineId,
  });

  @override
  ConsumerState<WorkoutDetailScreen>
  createState() => _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState
    extends ConsumerState<WorkoutDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(workoutProvider.notifier)
          .getRoutineById(widget.routineId);
    });
  }

  Map<String, List<RoutineExerciseModel>>
  _groupByDay(
    List<RoutineExerciseModel> exercises,
  ) {
    final Map<String, List<RoutineExerciseModel>>
    grouped = {};
    for (final exercise in exercises) {
      grouped.putIfAbsent(exercise.day, () => []);
      grouped[exercise.day]!.add(exercise);
    }
    return grouped;
  }

  Future<void> _deleteRoutine() async {
    await ref
        .read(workoutProvider.notifier)
        .deleteRoutine(widget.routineId);

    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _deleteExercise(
    RoutineExerciseModel exercise,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Egzersizi Sil'),
        content: Text(
          '${exercise.exerciseName ?? 'Bu egzersizi'} programdan kaldırmak istediğine emin misin?',
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
          .read(workoutProvider.notifier)
          .deleteRoutineExercise(
            routineExerciseId: exercise.id,
            routineId: widget.routineId,
          );
    }
  }

  void _showEditExerciseSheet(
    RoutineExerciseModel exercise,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EditExerciseSheet(
        exercise: exercise,
        routineId: widget.routineId,
        onSave: (day, targetSets, targetReps) {
          ref
              .read(workoutProvider.notifier)
              .updateRoutineExercise(
                routineExerciseId: exercise.id,
                routineId: widget.routineId,
                day: day,
                targetSets: targetSets,
                targetReps: targetReps,
              );
        },
      ),
    );
  }

  String _dayLabel(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return 'Pazartesi';
      case 'tuesday':
        return 'Salı';
      case 'wednesday':
        return 'Çarşamba';
      case 'thursday':
        return 'Perşembe';
      case 'friday':
        return 'Cuma';
      case 'saturday':
        return 'Cumartesi';
      case 'sunday':
        return 'Pazar';
      default:
        return day;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(workoutProvider);
    final routine = state.selectedRoutine;
    final hasSelectedRoutine =
        routine != null &&
        routine.id == widget.routineId;

    final body = _buildBody(
      state: state,
      hasSelectedRoutine: hasSelectedRoutine,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          hasSelectedRoutine
              ? routine.name
              : 'Program Detayı',
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.play_circle_outline,
            ),
            tooltip: 'Antrenmanı Başlat',
            onPressed: hasSelectedRoutine
                ? () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            CreateWorkoutScreen(
                              routine: routine,
                            ),
                      ),
                    );
                  }
                : null,
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
            ),
            onPressed: hasSelectedRoutine
                ? _deleteRoutine
                : null,
          ),
        ],
      ),
      body: body,
        floatingActionButton: FloatingActionButton(
        heroTag: 'add_exercise',
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AddExerciseScreen(
                routineId: widget.routineId,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody({
    required WorkoutState state,
    required bool hasSelectedRoutine,
  }) {
    if (state.isLoading && !hasSelectedRoutine) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state.errorMessage != null &&
        !hasSelectedRoutine) {
      return Center(
        child: Text(state.errorMessage!),
      );
    }

    if (!hasSelectedRoutine) {
      return const Center(
        child: Text('Program bulunamadı'),
      );
    }

    final routine = state.selectedRoutine!;
    final grouped = _groupByDay(
      routine.exercises,
    );

    const dayOrder = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    final sortedDays = grouped.keys.toList()
      ..sort(
        (a, b) => dayOrder
            .indexOf(a)
            .compareTo(dayOrder.indexOf(b)),
      );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final day in sortedDays) ...[
          Text(
            _dayLabel(day),
            style: Theme.of(
              context,
            ).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          for (final exercise
              in grouped[day]!) ...[
            Card(
              margin: const EdgeInsets.only(
                bottom: 10,
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                        children: [
                          Text(
                            exercise.exerciseName ??
                                'İsimsiz egzersiz',
                            style:
                                Theme.of(context)
                                    .textTheme
                                    .titleSmall,
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          Text(
                            '${exercise.targetSets} set × ${exercise.targetReps} tekrar',
                            style:
                                Theme.of(context)
                                    .textTheme
                                    .bodyMedium,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                      ),
                      onPressed: () {
                        _showEditExerciseSheet(
                          exercise,
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                      ),
                      onPressed: () {
                        _deleteExercise(exercise);
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.show_chart,
                      ),
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ExerciseProgressScreen(
                                  exerciseId: exercise
                                      .exerciseId!,
                                  exerciseName:
                                      exercise
                                          .exerciseName ??
                                      'Egzersiz',
                                ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 6),
        ],
      ],
    );
  }
}

class _EditExerciseSheet extends StatefulWidget {
  final RoutineExerciseModel exercise;
  final int routineId;
  final Function(
    String day,
    int targetSets,
    int targetReps,
  )
  onSave;

  const _EditExerciseSheet({
    required this.exercise,
    required this.routineId,
    required this.onSave,
  });

  @override
  State<_EditExerciseSheet> createState() =>
      _EditExerciseSheetState();
}

class _EditExerciseSheetState
    extends State<_EditExerciseSheet> {
  final _setController = TextEditingController();
  final _repController = TextEditingController();
  final List<String> _days = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  late String _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.exercise.day;
    _setController.text = widget
        .exercise
        .targetSets
        .toString();
    _repController.text = widget
        .exercise
        .targetReps
        .toString();
  }

  @override
  void dispose() {
    _setController.dispose();
    _repController.dispose();
    super.dispose();
  }

  String _dayLabel(String day) {
    switch (day) {
      case 'Monday':
        return 'Pazartesi';
      case 'Tuesday':
        return 'Salı';
      case 'Wednesday':
        return 'Çarşamba';
      case 'Thursday':
        return 'Perşembe';
      case 'Friday':
        return 'Cuma';
      case 'Saturday':
        return 'Cumartesi';
      case 'Sunday':
        return 'Pazar';
      default:
        return day;
    }
  }

  void _save() {
    final targetSets = int.tryParse(
      _setController.text.trim(),
    );
    final targetReps = int.tryParse(
      _repController.text.trim(),
    );

    if (targetSets == null ||
        targetReps == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Set ve tekrar sayıları geçerli olmalı',
          ),
        ),
      );
      return;
    }

    widget.onSave(
      _selectedDay,
      targetSets,
      targetReps,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(
      context,
    ).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: bottomInset + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.stretch,
          children: [
            Text(
              'Egzersizi Düzenle',
              style: Theme.of(
                context,
              ).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedDay,
              decoration: const InputDecoration(
                labelText: 'Gün',
              ),
              items: _days
                  .map(
                    (day) =>
                        DropdownMenuItem<String>(
                          value: day,
                          child: Text(
                            _dayLabel(day),
                          ),
                        ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _selectedDay = value;
                });
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _setController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Set',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _repController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tekrar',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}
