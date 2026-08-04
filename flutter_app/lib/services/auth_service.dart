import 'package:dio/dio.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService apiService;

  AuthService({required this.apiService});

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await apiService.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data;
      if (data['success'] == true) {
        final token = data['token'] as String;
        final user = User.fromJson(data['user']);
        await apiService.saveToken(token);
        return {'user': user, 'token': token};
      } else {
        throw Exception(data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Network or server error';
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String role,
    String? branch,
    int? year,
  }) async {
    try {
      final payload = <String, dynamic>{
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      };
      if (branch != null) payload['branch'] = branch;
      if (year != null) payload['year'] = year;

      final response = await apiService.dio.post(
        '/auth/register',
        data: payload,
      );

      final data = response.data;
      if (data['success'] == true) {
        final token = data['token'] as String;
        final user = User.fromJson(data['user']);
        await apiService.saveToken(token);
        return {'user': user, 'token': token};
      } else {
        throw Exception(data['message'] ?? 'Registration failed');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Network or server error';
      throw Exception(message);
    }
  }

  Future<User> getProfile() async {
    try {
      final response = await apiService.dio.get('/users/profile');
      final data = response.data;
      if (data['success'] == true) {
        return User.fromJson(data['user']);
      } else {
        throw Exception(data['message'] ?? 'Failed to load profile');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Network or server error';
      throw Exception(message);
    }
  }

  Future<User> updateProfile({
    String? name,
    String? bio,
    String? branch,
    int? year,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (name != null) payload['name'] = name;
      if (bio != null) payload['bio'] = bio;
      if (branch != null) payload['branch'] = branch;
      if (year != null) payload['year'] = year;

      final response = await apiService.dio.put(
        '/users/profile',
        data: payload,
      );

      final data = response.data;
      if (data['success'] == true) {
        return User.fromJson(data['user']);
      } else {
        throw Exception(data['message'] ?? 'Failed to update profile');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Network error';
      throw Exception(message);
    }
  }

  Future<String> uploadAvatar(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath),
      });

      final response = await apiService.dio.post(
        '/users/profile/avatar',
        data: formData,
      );

      final data = response.data;
      if (data['success'] == true) {
        return data['avatarUrl'] as String;
      } else {
        throw Exception(data['message'] ?? 'Avatar upload failed');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Network error';
      throw Exception(message);
    }
  }

  Future<void> logout() async {
    await apiService.deleteToken();
  }
}
