import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gymplanner_mobile/core/models/workout_set_log_model.dart';
import 'package:gymplanner_mobile/features/workout/data/workout_log_repository.dart';

final workoutLogRepositoryProvider =
    Provider<WorkoutLogRepository>(
      (ref) => WorkoutLogRepository(),
    );

class ActiveWorkoutState {
  final int? workoutLogId;
  final Map<int, List<WorkoutSetLogModel>>
  setsByExercise;
  final bool isStarting;
  final Set<int> savingExerciseIds;
  final String? errorMessage;

  const ActiveWorkoutState({
    this.workoutLogId,
    this.setsByExercise = const {},
    this.isStarting = false,
    this.savingExerciseIds = const {},
    this.errorMessage,
  });

  ActiveWorkoutState copyWith({
    int? workoutLogId,
    Map<int, List<WorkoutSetLogModel>>?
    setsByExercise,
    bool? isStarting,
    Set<int>? savingExerciseIds,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ActiveWorkoutState(
      workoutLogId:
          workoutLogId ?? this.workoutLogId,
      setsByExercise:
          setsByExercise ?? this.setsByExercise,
      isStarting: isStarting ?? this.isStarting,
      savingExerciseIds:
          savingExerciseIds ??
          this.savingExerciseIds,
      errorMessage: clearError
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}

class ActiveWorkoutNotifier
    extends StateNotifier<ActiveWorkoutState> {
  final WorkoutLogRepository _repository;

  ActiveWorkoutNotifier(this._repository)
    : super(const ActiveWorkoutState());

  Future<void> startWorkout(int routineId) async {
    state = state.copyWith(
      isStarting: true,
      clearError: true,
    );
    try {
      final workoutLogId = await _repository
          .startWorkoutLog(routineId);
      state = ActiveWorkoutState(
        workoutLogId: workoutLogId,
      );
    } catch (e) {
      state = state.copyWith(
        isStarting: false,
        errorMessage: e.toString().replaceAll(
          'Exception: ',
          '',
        ),
      );
    }
  }

  Future<bool> addSet({
    required int exerciseId,
    required int reps,
    required double weight,
  }) async {
    final workoutLogId = state.workoutLogId;
    if (workoutLogId == null) return false;

    state = state.copyWith(
      savingExerciseIds: {
        ...state.savingExerciseIds,
        exerciseId,
      },
      clearError: true,
    );

    try {
      final currentSets =
          state.setsByExercise[exerciseId] ?? [];
      final newSet = await _repository.addSet(
        workoutLogId: workoutLogId,
        exerciseId: exerciseId,
        setNumber: currentSets.length + 1,
        reps: reps,
        weight: weight,
      );

      final updatedMap =
          Map<int, List<WorkoutSetLogModel>>.from(
            state.setsByExercise,
          );
      updatedMap[exerciseId] = [
        ...currentSets,
        newSet,
      ];

      state = state.copyWith(
        setsByExercise: updatedMap,
        savingExerciseIds: {
          ...state.savingExerciseIds,
        }..remove(exerciseId),
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        savingExerciseIds: {
          ...state.savingExerciseIds,
        }..remove(exerciseId),
        errorMessage: e.toString().replaceAll(
          'Exception: ',
          '',
        ),
      );
      return false;
    }
  }

  Future<void> removeSet({
    required int exerciseId,
    required int setId,
  }) async {
    final workoutLogId = state.workoutLogId;
    if (workoutLogId == null) return;

    try {
      await _repository.removeSet(
        workoutLogId: workoutLogId,
        setId: setId,
      );
      final currentSets =
          state.setsByExercise[exerciseId] ?? [];
      final updatedMap =
          Map<int, List<WorkoutSetLogModel>>.from(
            state.setsByExercise,
          );
      updatedMap[exerciseId] = currentSets
          .where((s) => s.id != setId)
          .toList();
      state = state.copyWith(
        setsByExercise: updatedMap,
      );
    } catch (e) {
      state = state.copyWith(
        errorMessage: e.toString().replaceAll(
          'Exception: ',
          '',
        ),
      );
    }
  }

  void finishWorkout() {
    state = const ActiveWorkoutState();
  }
}

final activeWorkoutProvider =
    StateNotifierProvider.autoDispose<
      ActiveWorkoutNotifier,
      ActiveWorkoutState
    >(
      (ref) => ActiveWorkoutNotifier(
        ref.watch(workoutLogRepositoryProvider),
      ),
    );
