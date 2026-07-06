import 'package:dio/dio.dart';
import 'package:gymplanner_mobile/core/constants/api_constants.dart';
import 'package:gymplanner_mobile/core/network/dio_client.dart';
import 'package:gymplanner_mobile/core/network/token_storage.dart';

class AuthRepository {
  final Dio _dio = DioClient.instance;

  Future<Map<String, dynamic>> login({
    required String loginInput,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'loginInput': loginInput,
          'password': password,
        },
      );

      final data = response.data;

      if (data['success'] == true) {
        await TokenStorage.saveToken(
          data['token'],
        );
        await TokenStorage.saveUserId(
          data['user']['id'].toString(),
        );
      }

      return data;
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.message ??
          'Bir hata oluştu.';
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
    required String name,
    required String surname,
    required String gender,
    String? phone,
    String? birthdate,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'username': username,
          'email': email,
          'password': password,
          'name': name,
          'surname': surname,
          'gender': gender,
          'phone':
              (phone == null || phone.isEmpty)
              ? null
              : phone,
          'birthdate':
              (birthdate == null ||
                  birthdate.isEmpty)
              ? null
              : birthdate,
        },
      );

      final data = response.data;

      if (data['token'] != null) {
        await TokenStorage.saveToken(
          data['token'],
        );
        await TokenStorage.saveUserId(
          data['user']['id'].toString(),
        );
      }

      return data;
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.message ??
          'Bir hata oluştu.';
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>>
  getProfile() async {
    try {
      final response = await _dio.get(
        ApiConstants.getProfile,
      );
      return response.data['user']
          as Map<String, dynamic>;
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.message ??
          'Profil bilgisi alınamadı.';
      throw Exception(message);
    }
  }

  Future<void> logout() async {
    await TokenStorage.clearAll();
  }
}
