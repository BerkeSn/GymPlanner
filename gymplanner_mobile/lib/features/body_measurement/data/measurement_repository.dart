import 'package:dio/dio.dart';
import 'package:gymplanner_mobile/core/constants/api_constants.dart';
import 'package:gymplanner_mobile/core/models/body_measurement_model.dart';
import 'package:gymplanner_mobile/core/network/dio_client.dart';

class MeasurementRepository {
  final Dio _dio = DioClient.instance;

  Future<List<BodyMeasurementModel>>
  getAllMeasurements() async {
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
          e.message ??
          'Bir hata oluştu.';
      throw Exception(message);
    }
  }

  Future<BodyMeasurementModel> createMeasurement({
    required double weight,
    required double height,
    String? date,
    double? neck,
    double? waist,
    double? bodyFatPercentage,
    double? muscleMass,
    String? goal,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.createMeasurement,
        data: {
          'weight': weight,
          'height': height,
          'date': ?date,
          'neck': ?neck,
          'waist': ?waist,
          'bodyFatPercentage': ?bodyFatPercentage,
          'muscleMass': ?muscleMass,
          'goal': ?goal,
        },
      );
      final data = response.data['measurement'];
      return BodyMeasurementModel.fromJson(data);
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.message ??
          'Ölçüm kaydedilemedi.';
      throw Exception(message);
    }
  }

  Future<BodyMeasurementModel> updateMeasurement({
    required int id,
    double? weight,
    double? height,
    String? date,
    double? neck,
    double? waist,
    double? bodyFatPercentage,
    double? muscleMass,
    String? goal,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.updateMeasurement}/$id',
        data: {
          'weight': ?weight,
          'height': ?height,
          'date': ?date,
          'neck': ?neck,
          'waist': ?waist,
          'bodyFatPercentage': ?bodyFatPercentage,
          'muscleMass': ?muscleMass,
          'goal': ?goal,
        },
      );
      final data = response.data['measurement'];
      return BodyMeasurementModel.fromJson(data);
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.message ??
          'Ölçüm güncellenemedi.';
      throw Exception(message);
    }
  }

  // NOT: Backend'de bu endpoint DELETE değil PUT metoduyla tanımlı.
  Future<void> deleteMeasurement(int id) async {
    try {
      await _dio.put(
        '${ApiConstants.deleteMeasurement}/$id',
      );
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.message ??
          'Bir hata oluştu.';
      throw Exception(message);
    }
  }
}
