import 'package:dio/dio.dart';
import 'package:gymplanner_mobile/core/constants/api_constants.dart';
import 'package:gymplanner_mobile/core/models/friend_model.dart';
import 'package:gymplanner_mobile/core/models/friend_request_model.dart';
import 'package:gymplanner_mobile/core/models/user_search_result_model.dart';
import 'package:gymplanner_mobile/core/network/dio_client.dart';

class SocialRepository {
  final Dio _dio = DioClient.instance;

  Future<List<FriendModel>> getMyFriends() async {
    try {
      final response = await _dio.get(
        ApiConstants.getMyFriends,
      );
      final List data =
          response.data['friends'] ?? [];
      return data
          .map((e) => FriendModel.fromJson(e))
          .toList();
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.message ??
          'Bir hata oluştu.';
      throw Exception(message);
    }
  }

  Future<List<FriendRequestModel>>
  getPendingRequests() async {
    try {
      final response = await _dio.get(
        ApiConstants.getPendingRequests,
      );
      final List data =
          response.data['requests'] ?? [];
      return data
          .map(
            (e) => FriendRequestModel.fromJson(e),
          )
          .toList();
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.message ??
          'Bekleyen istekler alınamadı.';
      throw Exception(message);
    }
  }

  Future<void> sendFriendRequest(
    int receiverId,
  ) async {
    try {
      await _dio.post(
        '${ApiConstants.addFriend}/$receiverId',
      );
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.message ??
          'İstek gönderilemedi.';
      throw Exception(message);
    }
  }

  Future<void> respondToRequest({
    required int friendshipId,
    required String
    status, // 'accepted' | 'rejected'
  }) async {
    try {
      await _dio.post(
        '${ApiConstants.respondToRequest}/$friendshipId',
        data: {'status': status},
      );
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.message ??
          'Bir hata oluştu.';
      throw Exception(message);
    }
  }

  Future<List<UserSearchResultModel>> searchUsers(
    String query,
  ) async {
    try {
      final response = await _dio.get(
        ApiConstants.searchUsers,
        queryParameters: {'query': query},
      );
      final List data =
          response.data['users'] ?? [];
      return data
          .map(
            (e) =>
                UserSearchResultModel.fromJson(e),
          )
          .toList();
    } on DioException catch (e) {
      final message =
          e.response?.data['message'] ??
          e.message ??
          'Kullanıcı aranamadı.';
      throw Exception(message);
    }
  }
}
