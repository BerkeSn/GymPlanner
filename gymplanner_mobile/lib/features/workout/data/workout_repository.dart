import 'package:dio/dio.dart';
import 'package:gymplanner_mobile/core/constants/api_constants.dart';
import 'package:gymplanner_mobile/core/models/workout_routine_detail_model.dart';
import 'package:gymplanner_mobile/core/network/dio_client.dart';

class WorkoutRepository {
  final Dio _dio = DioClient.instance;

  // 1. Program listesi
  Future<List<WorkoutRoutineDetailModel>>
  getWorkoutRoutines() async {
    try {
      final response = await _dio.get(
        ApiConstants.getWorkoutRoutines,
      );
      final List data =
          response.data['workoutRoutines'] ?? [];
      return data
          .map(
            (e) =>
                WorkoutRoutineDetailModel.fromJson(
                  e,
                ),
          )
          .toList();
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          'Rutinler alınamadı.';
      throw Exception(message);
    }
  }

  // Program detayları
  Future<WorkoutRoutineDetailModel>
  getWorkoutRoutineById(int id) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.getWorkoutRoutineById}/$id',
      );
      final data =
          response.data['workoutRoutine'];
      return WorkoutRoutineDetailModel.fromJson(
        data,
      );
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          'Rutin detayları alınamadı.';
      throw Exception(message);
    }
  }

  // 3. Program oluştur

  Future<void> createWorkoutRoutine({
    required String name,
    required String description,
    required bool isActive,
  }) async {
    try {
      await _dio.post(
        ApiConstants.createWorkoutRoutine,
        data: {
          'name': name,
          'description': description,
          'isActive': isActive,
        },
      );
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          'Rutin oluşturulamadı.';
      throw Exception(message);
    }
  }

  // 4. Program güncelle
  Future<void> updateWorkoutRoutine({
    required int id,
    String? name,
    String? description,
    bool? isActive,
  }) async {
    try {
      await _dio.post(
        '${ApiConstants.updateWorkoutRoutine}/$id',
        data: {
          'id': id,
          'name': name,
          'description': description,
          'isActive': isActive,
        },
      );
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          'Rutin güncellenemedi.';
      throw Exception(message);
    }
  }

  // 5. Program sil
  Future<void> deleteWorkoutRoutine(
    int id,
  ) async {
    try {
      await _dio.delete(
        '${ApiConstants.deleteWorkoutRoutine}/$id',
      );
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          'Rutin silinemedi.';
      throw Exception(message);
    }
  }

  // delete routineExercises
  Future<void> deleteRoutineExercise(
    int routineExerciseId,
  ) async {
    try {
      await _dio.delete(
        '${ApiConstants.deleteRoutineExercise}/$routineExerciseId',
      );
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          'Rutin egzersizi silinemedi.';
      throw Exception(message);
    }
  }

  // update routineExercises
  Future<void> updateRoutineExercise({
    required int routineExerciseId,
    String? day,
    int? targetSets,
    int? targetReps,
  }) async {
    try {
      await _dio.post(
        '${ApiConstants.updateRoutineExercise}/$routineExerciseId',
        data: {
          'day': ?day,
          'targetSets': ?targetSets,
          'targetReps': ?targetReps,
        },
      );
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          'Rutin egzersizi güncellenemedi.';
      throw Exception(message);
    }
  }
}
