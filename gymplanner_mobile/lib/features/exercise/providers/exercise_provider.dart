import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gymplanner_mobile/core/models/exercise_model.dart';
import 'package:gymplanner_mobile/core/models/muscle_group_model.dart';
import 'package:gymplanner_mobile/features/exercise/data/exercise_repository.dart';

final exerciseRepositoryProvider =
    Provider<ExerciseRepository>(
      (ref) => ExerciseRepository(),
    );

class ExerciseState {
  final List<MuscleGroupModel> muscleGroups;
  final List<ExerciseModel> exercises;
  final int? selectedMuscleGroupId;
  final Set<int> favoriteExerciseIds;
  final bool isLoading;
  final String? errorMessage;

  ExerciseState({
    required this.muscleGroups,
    required this.exercises,
    this.selectedMuscleGroupId,
    required this.favoriteExerciseIds,
    required this.isLoading,
    this.errorMessage,
  });

  ExerciseState copyWith({
    List<MuscleGroupModel>? muscleGroups,
    List<ExerciseModel>? exercises,
    int? selectedMuscleGroupId,
    Set<int>? favoriteExerciseIds,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ExerciseState(
      muscleGroups: muscleGroups ?? this.muscleGroups,
      exercises: exercises ?? this.exercises,
      selectedMuscleGroupId:
          selectedMuscleGroupId ??
          this.selectedMuscleGroupId,
      favoriteExerciseIds:
          favoriteExerciseIds ??
          this.favoriteExerciseIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }
}

class ExerciseNotifier
    extends StateNotifier<ExerciseState> {
  final ExerciseRepository _repository;

  ExerciseNotifier(this._repository)
    : super(
        ExerciseState(
          muscleGroups: const [],
          exercises: const [],
          favoriteExerciseIds: const {},
          isLoading: false,
        ),
      );

  Future<void> loadMuscleGroups() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );
    try {
      final results = await Future.wait([
        _repository.getAllMuscleGroups(),
        _repository.getMyFavoriteExerciseIds(),
      ]);

      final muscleGroups =
          results[0] as List<MuscleGroupModel>;
      final favoriteIds = results[1] as Set<int>;

      state = state.copyWith(
        muscleGroups: muscleGroups,
        favoriteExerciseIds: favoriteIds,
        isLoading: false,
      );

      if (muscleGroups.isNotEmpty) {
        await selectMuscleGroup(
          muscleGroups.first.id,
        );
      }
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

  Future<void> selectMuscleGroup(
    int muscleGroupId,
  ) async {
    state = state.copyWith(
      selectedMuscleGroupId: muscleGroupId,
      isLoading: true,
      clearError: true,
    );
    try {
      final exercises = await _repository
          .getExercisesByMuscleGroup(
            muscleGroupId,
          );
      state = state.copyWith(
        exercises: exercises,
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

  Future<void> toggleFavorite(
    int exerciseId,
  ) async {
    final optimistic = Set<int>.from(
      state.favoriteExerciseIds,
    );
    final wasFavorite = optimistic.contains(
      exerciseId,
    );

    wasFavorite
        ? optimistic.remove(exerciseId)
        : optimistic.add(exerciseId);
    state = state.copyWith(
      favoriteExerciseIds: optimistic,
    );

    try {
      await _repository.toggleFavorite(
        exerciseId,
      );
    } catch (e) {
      // Başarısız olursa eski haline geri al
      final reverted = Set<int>.from(
        state.favoriteExerciseIds,
      );
      wasFavorite
          ? reverted.add(exerciseId)
          : reverted.remove(exerciseId);
      state = state.copyWith(
        favoriteExerciseIds: reverted,
        errorMessage: e.toString().replaceAll(
          'Exception: ',
          '',
        ),
      );
    }
  }
}

final exerciseProvider =
    StateNotifierProvider<ExerciseNotifier, ExerciseState>(
      (ref) => ExerciseNotifier(
        ref.watch(exerciseRepositoryProvider),
      ),
    );