import 'package:flutter_riverpod/legacy.dart';
import 'package:gymplanner_mobile/core/models/exercise_progress_model.dart';
import 'package:gymplanner_mobile/features/workout/data/workout_log_repository.dart';
import 'package:gymplanner_mobile/features/workout/providers/workout_log_provider.dart';

class ExerciseProgressState {
  final List<ExerciseProgressEntryModel> history;
  final ProgressMetric selectedMetric;
  final bool isLoading;
  final String? errorMessage;

  const ExerciseProgressState({
    this.history = const [],
    this.selectedMetric =
        ProgressMetric.maxWeight,
    this.isLoading = false,
    this.errorMessage,
  });

  ExerciseProgressState copyWith({
    List<ExerciseProgressEntryModel>? history,
    ProgressMetric? selectedMetric,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ExerciseProgressState(
      history: history ?? this.history,
      selectedMetric:
          selectedMetric ?? this.selectedMetric,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}

class ExerciseProgressNotifier
    extends StateNotifier<ExerciseProgressState> {
  final WorkoutLogRepository _repository;
  final int exerciseId;

  ExerciseProgressNotifier(
    this._repository,
    this.exerciseId,
  ) : super(const ExerciseProgressState()) {
    loadProgress();
  }

  Future<void> loadProgress() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );
    try {
      final history = await _repository
          .getExerciseProgress(exerciseId);
      state = state.copyWith(
        history: history,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll(
          'Exception: ',
          '',
        ),
      );
    }
  }

  void selectMetric(ProgressMetric metric) {
    state = state.copyWith(
      selectedMetric: metric,
    );
  }
}

final exerciseProgressProvider =
    StateNotifierProvider.autoDispose.family<
      ExerciseProgressNotifier,
      ExerciseProgressState,
      int
    >(
      (ref, exerciseId) =>
          ExerciseProgressNotifier(
            ref.watch(
              workoutLogRepositoryProvider,
            ),
            exerciseId,
          ),
    );
