import 'package:dio/dio.dart';
import 'package:gymplanner_mobile/core/constants/api_constants.dart';
import 'package:gymplanner_mobile/core/models/calorie_entry_model.dart';
import 'package:gymplanner_mobile/core/models/calorie_target_model.dart';
import 'package:gymplanner_mobile/core/network/dio_client.dart';

class CalorieRepository {
  final Dio _dio = DioClient.instance;

  Future<CalorieTargetModel> getTarget() async {
    try {
      final response = await _dio.get(
        ApiConstants.getCalorieTarget,
      );
      return CalorieTargetModel.fromJson(
        response.data['target'],
      );
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.message ??
          'Hedef kalori alınamadı.';
      throw Exception(message);
    }
  }

  Future<void> updateActivityLevel(
    String activityLevel,
  ) async {
    try {
      await _dio.post(
        ApiConstants.updateCalorieSettings,
        data: {'activityLevel': activityLevel},
      );
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.message ??
          'Ayarlar güncellenemedi.';
      throw Exception(message);
    }
  }

  Future<void> logEntry({
    required int calories,
    String? date,
  }) async {
    try {
      await _dio.post(
        ApiConstants.logCalorieEntry,
        data: {
          'calories': calories,
          'date': date,
        },
      );
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.message ??
          'Kalori kaydedilemedi.';
      throw Exception(message);
    }
  }

  Future<List<CalorieEntryModel>> getEntries({
    int days = 30,
  }) async {
    try {
      final response = await _dio.get(
        ApiConstants.getCalorieEntries,
        queryParameters: {'days': days},
      );
      final List data =
          response.data['entries'] ?? [];
      return data
          .map(
            (e) => CalorieEntryModel.fromJson(e),
          )
          .toList();
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.message ??
          'Kalori geçmişi alınamadı.';
      throw Exception(message);
    }
  }
}
