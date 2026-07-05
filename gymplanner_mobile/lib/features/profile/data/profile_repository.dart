import 'package:dio/dio.dart';
import 'package:gymplanner_mobile/core/constants/api_constants.dart';
import 'package:gymplanner_mobile/core/models/user_model.dart';
import 'package:gymplanner_mobile/core/network/dio_client.dart';

class ProfileRepository {
  final Dio _dio = DioClient.instance;

  Future<UserModel> getProfile() async {
    try {
      final response = await _dio.get(
        ApiConstants.getProfile,
      );
      final data = response.data['user'];
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          'Profil bilgisi alınamadı.';
      throw Exception(message);
    }
  }

  Future<UserModel> updateProfile({
    String? username,
    String? name,
    String? surname,
    String? phone,
    String? birthdate,
    String? gender,
    String? locationPreference,
    String? email,
  }) async {
    try {
      final response = await _dio.put(
        ApiConstants.updateProfile,
        data: {
          'username': ?username,
          'name': ?name,
          'surname': ?surname,
          'phone': ?phone,
          'birthdate': ?birthdate,
          'gender': ?gender,
          'locationPreference':
              ?locationPreference,
          'email': ?email,
        },
      );
      final data = response.data['user'];
      return UserModel.fromJson(data);
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          'Profil güncellenemedi.';
      throw Exception(message);
    }
  }
}
