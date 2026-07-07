import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gymplanner_mobile/core/models/routine_exercise_model.dart';
import 'package:gymplanner_mobile/core/models/workout_routine_detail_model.dart';
import 'package:gymplanner_mobile/features/workout/providers/workout_log_provider.dart';

class CreateWorkoutScreen
    extends ConsumerStatefulWidget {
  final WorkoutRoutineDetailModel routine;

  const CreateWorkoutScreen({
    super.key,
    required this.routine,
  });

  @override
  ConsumerState<CreateWorkoutScreen>
  createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState
    extends ConsumerState<CreateWorkoutScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(activeWorkoutProvider.notifier)
          .startWorkout(widget.routine.id);
    });
  }

  List<RoutineExerciseModel>
  get _uniqueExercises {
    final seen = <int>{};
    final result = <RoutineExerciseModel>[];
    for (final e in widget.routine.exercises) {
      final id = e.exerciseId;
      if (id != null && seen.add(id)) {
        result.add(e);
      }
    }
    return result;
  }

  void _finish() {
    ref
        .read(activeWorkoutProvider.notifier)
        .finishWorkout();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      activeWorkoutProvider,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routine.name),
      ),
      body: state.isStarting
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : state.workoutLogId == null
          ? Center(
              child: Text(
                state.errorMessage ??
                    'Antrenman başlatılamadı.',
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (state.errorMessage != null)
                  Padding(
                    padding:
                        const EdgeInsets.only(
                          bottom: 12,
                        ),
                    child: Text(
                      state.errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                    ),
                  ),
                for (final exercise
                    in _uniqueExercises)
                  _ExerciseLogCard(
                    exerciseId:
                        exercise.exerciseId!,
                    exerciseName:
                        exercise.exerciseName ??
                        'Egzersiz',
                    targetSets:
                        exercise.targetSets,
                    targetReps:
                        exercise.targetReps,
                  ),
              ],
            ),
      floatingActionButton:
          FloatingActionButton.extended(
            heroTag: 'finishWorkoutFab',
            onPressed: _finish,
            icon: const Icon(Icons.check),
            label: const Text('Antrenmanı Bitir'),
          ),
    );
  }
}

class _ExerciseLogCard
    extends ConsumerStatefulWidget {
  final int exerciseId;
  final String exerciseName;
  final int targetSets;
  final int targetReps;

  const _ExerciseLogCard({
    required this.exerciseId,
    required this.exerciseName,
    required this.targetSets,
    required this.targetReps,
  });

  @override
  ConsumerState<_ExerciseLogCard> createState() =>
      _ExerciseLogCardState();
}

class _ExerciseLogCardState
    extends ConsumerState<_ExerciseLogCard> {
  final _repsController = TextEditingController();
  final _weightController =
      TextEditingController();

  @override
  void dispose() {
    _repsController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<void> _addSet() async {
    final reps = int.tryParse(
      _repsController.text.trim(),
    );
    final weight = double.tryParse(
      _weightController.text.trim(),
    );
    if (reps == null || weight == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Geçerli tekrar ve kilo gir.',
          ),
        ),
      );
      return;
    }

    final success = await ref
        .read(activeWorkoutProvider.notifier)
        .addSet(
          exerciseId: widget.exerciseId,
          reps: reps,
          weight: weight,
        );

    if (success) {
      _repsController.clear();
      _weightController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(
      activeWorkoutProvider,
    );
    final sets =
        state.setsByExercise[widget.exerciseId] ??
        [];
    final isSaving = state.savingExerciseIds
        .contains(widget.exerciseId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              widget.exerciseName,
              style: Theme.of(
                context,
              ).textTheme.titleMedium,
            ),
            Text(
              'Hedef: ${widget.targetSets} set × ${widget.targetReps} tekrar',
              style: Theme.of(
                context,
              ).textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            for (final set in sets)
              Padding(
                padding:
                    const EdgeInsets.symmetric(
                      vertical: 2,
                    ),
                child: Row(
                  children: [
                    Text(
                      'Set ${set.setNumber}: ${set.reps} tekrar × ${set.weight} kg',
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                      ),
                      onPressed: () => ref
                          .read(
                            activeWorkoutProvider
                                .notifier,
                          )
                          .removeSet(
                            exerciseId:
                                widget.exerciseId,
                            setId: set.id,
                          ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _repsController,
                    keyboardType:
                        TextInputType.number,
                    decoration:
                        const InputDecoration(
                          labelText: 'Tekrar',
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _weightController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                    decoration:
                        const InputDecoration(
                          labelText: 'Kilo (kg)',
                        ),
                  ),
                ),
                const SizedBox(width: 8),
                isSaving
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
                    : IconButton(
                        icon: const Icon(
                          Icons.add_circle,
                          color: Colors.orange,
                        ),
                        onPressed: _addSet,
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
