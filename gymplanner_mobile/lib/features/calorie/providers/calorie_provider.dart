import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gymplanner_mobile/core/models/calorie_entry_model.dart';
import 'package:gymplanner_mobile/core/models/calorie_target_model.dart';
import 'package:gymplanner_mobile/features/calorie/data/calorie_repository.dart';

final calorieRepositoryProvider =
    Provider<CalorieRepository>(
      (ref) => CalorieRepository(),
    );

class CalorieState {
  final CalorieTargetModel? target;
  final List<CalorieEntryModel> entries;
  final bool isLoading;
  final bool isSavingSettings;
  final bool isLoggingToday;
  final String? errorMessage;

  const CalorieState({
    this.target,
    this.entries = const [],
    this.isLoading = false,
    this.isSavingSettings = false,
    this.isLoggingToday = false,
    this.errorMessage,
  });

  CalorieState copyWith({
    CalorieTargetModel? target,
    List<CalorieEntryModel>? entries,
    bool? isLoading,
    bool? isSavingSettings,
    bool? isLoggingToday,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CalorieState(
      target: target ?? this.target,
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      isSavingSettings:
          isSavingSettings ??
          this.isSavingSettings,
      isLoggingToday:
          isLoggingToday ?? this.isLoggingToday,
      errorMessage: clearError
          ? null
          : (errorMessage ?? this.errorMessage),
    );
  }

  int? get todayCalories {
    final now = DateTime.now();
    final matches = entries.where(
      (e) =>
          e.date.year == now.year &&
          e.date.month == now.month &&
          e.date.day == now.day,
    );
    return matches.isEmpty
        ? null
        : matches.first.calories;
  }
}

class CalorieNotifier
    extends StateNotifier<CalorieState> {
  final CalorieRepository _repository;

  CalorieNotifier(this._repository)
    : super(const CalorieState()) {
    loadAll();
  }

  Future<void> loadAll() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
    );
    try {
      final target = await _repository
          .getTarget();
      final entries = await _repository
          .getEntries(days: 30);
      state = state.copyWith(
        target: target,
        entries: entries,
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

  Future<bool> updateActivityLevel(
    String activityLevel,
  ) async {
    state = state.copyWith(
      isSavingSettings: true,
      clearError: true,
    );
    try {
      await _repository.updateActivityLevel(
        activityLevel,
      );
      final newTarget = await _repository
          .getTarget();
      state = state.copyWith(
        target: newTarget,
        isSavingSettings: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSavingSettings: false,
        errorMessage: e.toString().replaceAll(
          'Exception: ',
          '',
        ),
      );
      return false;
    }
  }

  Future<bool> logTodayCalories(
    int calories,
  ) async {
    state = state.copyWith(
      isLoggingToday: true,
      clearError: true,
    );
    try {
      await _repository.logEntry(
        calories: calories,
      );
      final newEntries = await _repository
          .getEntries(days: 30);
      state = state.copyWith(
        entries: newEntries,
        isLoggingToday: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoggingToday: false,
        errorMessage: e.toString().replaceAll(
          'Exception: ',
          '',
        ),
      );
      return false;
    }
  }
}

final calorieProvider =
    StateNotifierProvider<
      CalorieNotifier,
      CalorieState
    >(
      (ref) => CalorieNotifier(
        ref.watch(calorieRepositoryProvider),
      ),
    );
