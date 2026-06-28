import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gymplanner_mobile/core/models/workout_routine_detail_model.dart';
import 'package:gymplanner_mobile/features/workout/data/workout_repository.dart';

final workoutRepositoryProvider =
    Provider<WorkoutRepository>(
      (ref) => WorkoutRepository(),
    );

class WorkoutState {
  final List<WorkoutRoutineDetailModel> routines;
  final bool isLoading;
  final String? errorMessage;

  WorkoutState({
    required this.routines,
    required this.isLoading,
    required this.errorMessage,
  });

  WorkoutState copyWith({
    List<WorkoutRoutineDetailModel>? routines,
    bool? isLoading,
    String? errorMessage,
  }) {
    return WorkoutState(
      routines: routines ?? this.routines,
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
          errorMessage ?? this.errorMessage,
    );
  }
}

class WorkoutNotifier
    extends StateNotifier<WorkoutState> {
  final WorkoutRepository _repository;

  WorkoutNotifier(this._repository)
    : super(
        WorkoutState(
          routines: const [],
          isLoading: false,
          errorMessage: null,
        ),
      );

  // listeyi yükle
  Future<void> getRoutines() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      final routines = await _repository
          .getWorkoutRoutines();
      state = state.copyWith(
        routines: _sortRoutines(routines),
        isLoading: false,
        errorMessage: null,
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

  // program oluştur
  Future<void> createRoutine({
    required String name,
    required String description,
    required bool isActive,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      await _repository.createWorkoutRoutine(
        name: name,
        description: description,
        isActive: isActive,
      );
      await getRoutines();
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

  // program güncelle
  Future<void> updateRoutine({
    required int id,
    String? name,
    String? description,
    bool? isActive,
  }) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      await _repository.updateWorkoutRoutine(
        id: id,
        name: name,
        description: description,
        isActive: isActive,
      );
      await getRoutines();
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

  // program sil
  Future<void> deleteRoutine(int id) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
    );

    try {
      await _repository.deleteWorkoutRoutine(id);
      await getRoutines();
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

  List<WorkoutRoutineDetailModel> _sortRoutines(
    List<WorkoutRoutineDetailModel> routines,
  ) {
    final sortedRoutines =
        List<WorkoutRoutineDetailModel>.from(
          routines,
        );

    sortedRoutines.sort((a, b) {
      if (a.isActive != b.isActive) {
        return a.isActive ? -1 : 1;
      }

      final aCreatedAt =
          a.createdAt ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final bCreatedAt =
          b.createdAt ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return bCreatedAt.compareTo(aCreatedAt);
    });

    return sortedRoutines;
  }
}

final workoutProvider =
    StateNotifierProvider<
      WorkoutNotifier,
      WorkoutState
    >(
      (ref) => WorkoutNotifier(
        ref.watch(workoutRepositoryProvider),
      ),
    );
