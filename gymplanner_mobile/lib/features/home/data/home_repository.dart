import 'package:dio/dio.dart';
import 'package:gymplanner_mobile/core/constants/api_constants.dart';
import 'package:gymplanner_mobile/core/models/body_measurement_model.dart';
import 'package:gymplanner_mobile/core/models/workout_log_model.dart';
import 'package:gymplanner_mobile/core/models/workout_routine_model.dart';
import 'package:gymplanner_mobile/core/network/dio_client.dart';

class HomeRepository {
  final Dio _dio = DioClient.instance;

  Future<List<WorkoutLogModel>>
  _getWorkoutLogs() async {
    try {
      final response = await _dio.get(
        ApiConstants.getWorkoutLogs,
      );
      final List data = response.data ?? [];
      return data
          .map((e) => WorkoutLogModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          'Antrenman logları alınamadı.';
      throw Exception(message);
    }
  }

  Future<List<WorkoutRoutineModel>>
  _getRoutines() async {
    try {
      final response = await _dio.get(
        ApiConstants.getWorkoutRoutines,
      );
      final List data =
          response.data['workoutRoutines'] ?? [];
      return data
          .map(
            (e) =>
                WorkoutRoutineModel.fromJson(e),
          )
          .toList();
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          'Rutinler alınamadı.';
      throw Exception(message);
    }
  }

  Future<List<BodyMeasurementModel>>
  _getMeasurements() async {
    try {
      final response = await _dio.get(
        ApiConstants.getAllBodyMeasurements,
      );
      final List data =
          response.data['bodyMeasurements'] ?? [];
      return data
          .map(
            (e) =>
                BodyMeasurementModel.fromJson(e),
          )
          .toList();
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          'Ölçümler alınamadı.';
      throw Exception(message);
    }
  }

  Future<
    ({
      List<WorkoutLogModel> workoutLogs,
      List<WorkoutRoutineModel> routines,
      List<BodyMeasurementModel> measurements,
    })
  >
  getDashboardData() async {
    final results = await Future.wait([
      _getWorkoutLogs(),
      _getRoutines(),
      _getMeasurements(),
    ]);

    return (
      workoutLogs:
          results[0] as List<WorkoutLogModel>,
      routines:
          results[1] as List<WorkoutRoutineModel>,
      measurements:
          results[2]
              as List<BodyMeasurementModel>,
    );
  }
}
