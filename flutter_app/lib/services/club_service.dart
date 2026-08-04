import 'package:dio/dio.dart';
import '../models/club.dart';
import 'api_service.dart';

class ClubService {
  final ApiService apiService;

  ClubService({required this.apiService});

  Future<List<Club>> getAllClubs() async {
    try {
      final response = await apiService.dio.get('/clubs');
      final data = response.data;
      if (data['success'] == true) {
        final list = data['clubs'] as List;
        return list.map((json) => Club.fromJson(json)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch clubs');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Network error';
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>> getClubById(String id) async {
    try {
      final response = await apiService.dio.get('/clubs/$id');
      final data = response.data;
      if (data['success'] == true) {
        return {
          'club': Club.fromJson(data['club']),
          'isMember': data['isMember'] ?? false,
        };
      } else {
        throw Exception(data['message'] ?? 'Club not found');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Network error';
      throw Exception(message);
    }
  }

  Future<Club> createClub({
    required String name,
    required String description,
    String? category,
    String? bannerUrl,
  }) async {
    try {
      final payload = <String, dynamic>{
        'name': name,
        'description': description,
      };
      if (category != null) payload['category'] = category;
      if (bannerUrl != null) payload['bannerUrl'] = bannerUrl;

      final response = await apiService.dio.post(
        '/clubs',
        data: payload,
      );

      final data = response.data;
      if (data['success'] == true) {
        return Club.fromJson(data['club']);
      } else {
        throw Exception(data['message'] ?? 'Failed to create club');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Network error';
      throw Exception(message);
    }
  }

  Future<int> joinClub(String clubId) async {
    try {
      final response = await apiService.dio.post('/clubs/$clubId/join');
      final data = response.data;
      if (data['success'] == true) {
        return data['memberCount'] as int;
      } else {
        throw Exception(data['message'] ?? 'Failed to join club');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Network error';
      throw Exception(message);
    }
  }

  Future<int> leaveClub(String clubId) async {
    try {
      final response = await apiService.dio.post('/clubs/$clubId/leave');
      final data = response.data;
      if (data['success'] == true) {
        return data['memberCount'] as int;
      } else {
        throw Exception(data['message'] ?? 'Failed to leave club');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Network error';
      throw Exception(message);
    }
  }

  Future<List<ClubMemberItem>> getClubMembers(String clubId) async {
    try {
      final response = await apiService.dio.get('/clubs/$clubId/members');
      final data = response.data;
      if (data['success'] == true) {
        final list = data['members'] as List;
        return list.map((json) => ClubMemberItem.fromJson(json)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch members');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Network error';
      throw Exception(message);
    }
  }
}
