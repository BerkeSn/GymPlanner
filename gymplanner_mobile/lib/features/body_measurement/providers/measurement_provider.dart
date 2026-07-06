import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:gymplanner_mobile/core/models/body_measurement_model.dart';
import 'package:gymplanner_mobile/features/body_measurement/data/measurement_repository.dart';

final measurementRepositoryProvider =
    Provider<MeasurementRepository>(
      (ref) => MeasurementRepository(),
    );

class MeasurementState {
  final List<BodyMeasurementModel> measurements;
  final bool isLoading;
  final bool isSaving;
  final String? errorMessage;

  MeasurementState({
    required this.measurements,
    required this.isLoading,
    required this.isSaving,
    this.errorMessage,
  });

  MeasurementState copyWith({
    List<BodyMeasurementModel>? measurements,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
  }) {
    return MeasurementState(
      measurements:
          measurements ?? this.measurements,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage:
          errorMessage ?? this.errorMessage,
    );
  }
}

class MeasurementNotifier
    extends StateNotifier<MeasurementState> {
  final MeasurementRepository _repository;

  MeasurementNotifier(this._repository)
    : super(
        MeasurementState(
          measurements: const [],
          isLoading: false,
          isSaving: false,
        ),
      );

  Future<void> loadMeasurements() async {
    state = state.copyWith(isLoading: true);

    try {
      final measurements = await _repository
          .getAllMeasurements();
      state = state.copyWith(
        measurements: measurements,
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

  Future<bool> createMeasurement({
    required double weight,
    required double height,
    String? date,
    double? neck,
    double? waist,
    double? bodyFatPercentage,
    double? muscleMass,
    String? goal,
  }) async {
    state = state.copyWith(isSaving: true);

    try {
      await _repository.createMeasurement(
        weight: weight,
        height: height,
        date: date,
        neck: neck,
        waist: waist,
        bodyFatPercentage: bodyFatPercentage,
        muscleMass: muscleMass,
        goal: goal,
      );
      await loadMeasurements();
      state = state.copyWith(isSaving: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        errorMessage: e.toString().replaceAll(
          'Exception: ',
          '',
        ),
      );
      return false;
    }
  }

  Future<bool> deleteMeasurement(int id) async {
    state = state.copyWith(isLoading: true);

    try {
      await _repository.deleteMeasurement(id);
      await loadMeasurements();
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll(
          'Exception: ',
          '',
        ),
      );
      return false;
    }
  }
}

final measurementProvider =
    StateNotifierProvider<
      MeasurementNotifier,
      MeasurementState
    >(
      (ref) => MeasurementNotifier(
        ref.watch(measurementRepositoryProvider),
      ),
    );
