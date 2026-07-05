import 'package:dio/dio.dart';
import 'package:gymplanner_mobile/core/constants/api_constants.dart';
import 'package:gymplanner_mobile/core/models/exercise_model.dart';
import 'package:gymplanner_mobile/core/models/muscle_group_model.dart';
import 'package:gymplanner_mobile/core/network/dio_client.dart';

class ExerciseRepository {
  final Dio _dio = DioClient.instance;

  Future<List<MuscleGroupModel>>
  getAllMuscleGroups() async {
    try {
      final response = await _dio.get(
        ApiConstants.getAllMuscleGroups,
      );
      final List data =
          response.data['muscleGroups'] ?? [];
      return data
          .map(
            (e) => MuscleGroupModel.fromJson(e),
          )
          .toList();
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          'Kas grupları alınamadı.';
      throw Exception(message);
    }
  }

  Future<List<ExerciseModel>>
  getExercisesByMuscleGroup(
    int muscleGroupId,
  ) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.getExercisesByMuscleGroup}/$muscleGroupId',
      );
      final List data =
          response.data['exercises'] ?? [];
      return data
          .map((e) => ExerciseModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          'Egzersizler alınamadı.';
      throw Exception(message);
    }
  }

  Future<Set<int>>
  getMyFavoriteExerciseIds() async {
    try {
      final response = await _dio.get(
        ApiConstants.getMyFavorites,
      );
      final List data =
          response.data['favorites'] ?? [];
      return data
          .map<int?>(
            (e) => e['exerciseId'] as int?,
          )
          .whereType<int>()
          .toSet();
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          'Favoriler alınamadı.';
      throw Exception(message);
    }
  }

  Future<bool> toggleFavorite(
    int exerciseId,
  ) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.toggleFavorite}/$exerciseId',
      );
      return response.data['isFavorite']
              as bool? ??
          false;
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          'Favori işlemi başarısız.';
      throw Exception(message);
    }
  }
}
