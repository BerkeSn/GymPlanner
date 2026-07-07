import 'package:dio/dio.dart';
import 'package:gymplanner_mobile/core/constants/api_constants.dart';
import 'package:gymplanner_mobile/core/models/exercise_progress_model.dart';
import 'package:gymplanner_mobile/core/models/workout_set_log_model.dart';
import 'package:gymplanner_mobile/core/network/dio_client.dart';

class WorkoutLogRepository {
  final Dio _dio = DioClient.instance;

  Future<int> startWorkoutLog(
    int routineId,
  ) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.startWorkoutLog}/$routineId',
      );
      return response.data['workoutLog']['id']
          as int;
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.message ??
          'Antrenman başlatılamadı.';
      throw Exception(message);
    }
  }

  Future<WorkoutSetLogModel> addSet({
    required int workoutLogId,
    required int exerciseId,
    required int setNumber,
    required int reps,
    required double weight,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.addSetToWorkoutLog}/$workoutLogId',
        data: {
          'exerciseId': exerciseId,
          'setNumber': setNumber,
          'reps': reps,
          'weight': weight,
        },
      );
      return WorkoutSetLogModel.fromJson(
        response.data['setLog'],
      );
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.message ??
          'Set kaydedilemedi.';
      throw Exception(message);
    }
  }

  Future<void> removeSet({
    required int workoutLogId,
    required int setId,
  }) async {
    try {
      await _dio.delete(
        '${ApiConstants.removeSetFromWorkoutLog}/$workoutLogId/$setId',
      );
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.message ??
          'Set silinemedi.';
      throw Exception(message);
    }
  }

  Future<List<ExerciseProgressEntryModel>>
  getExerciseProgress(int exerciseId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.getExerciseProgress}/$exerciseId',
      );
      final List data =
          response.data['history'] ?? [];
      return data
          .map(
            (e) =>
                ExerciseProgressEntryModel.fromJson(
                  e,
                ),
          )
          .toList();
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.message ??
          'İlerleme verisi alınamadı.';
      throw Exception(message);
    }
  }
}
