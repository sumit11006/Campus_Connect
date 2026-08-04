import 'package:dio/dio.dart';
import '../models/post.dart';
import '../models/comment.dart';
import 'api_service.dart';

class PostService {
  final ApiService apiService;

  PostService({required this.apiService});

  Future<List<Post>> getAllPosts({int page = 1, int limit = 20}) async {
    try {
      final response = await apiService.dio.get(
        '/posts',
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response.data;
      if (data['success'] == true) {
        final list = data['posts'] as List;
        return list.map((json) => Post.fromJson(json)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch feed');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Network error';
      throw Exception(message);
    }
  }

  Future<Post> createPost({
    required String content,
    String? imagePath,
  }) async {
    try {
      dynamic payload;
      if (imagePath != null && imagePath.isNotEmpty) {
        payload = FormData.fromMap({
          'content': content,
          'image': await MultipartFile.fromFile(imagePath),
        });
      } else {
        payload = {'content': content};
      }

      final response = await apiService.dio.post('/posts', data: payload);
      final data = response.data;
      if (data['success'] == true) {
        return Post.fromJson(data['post']);
      } else {
        throw Exception(data['message'] ?? 'Failed to create post');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Network error';
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>> toggleLike(String postId) async {
    try {
      final response = await apiService.dio.post('/posts/$postId/like');
      final data = response.data;
      if (data['success'] == true) {
        return {
          'likesCount': data['likesCount'] as int,
          'isLiked': data['isLiked'] as bool,
        };
      } else {
        throw Exception(data['message'] ?? 'Failed to toggle like');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Network error';
      throw Exception(message);
    }
  }

  Future<List<CommentItem>> getPostComments(String postId) async {
    try {
      final response = await apiService.dio.get('/posts/$postId/comments');
      final data = response.data;
      if (data['success'] == true) {
        final list = data['comments'] as List;
        return list.map((json) => CommentItem.fromJson(json)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch comments');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Network error';
      throw Exception(message);
    }
  }

  Future<CommentItem> addComment(String postId, String text) async {
    try {
      final response = await apiService.dio.post(
        '/posts/$postId/comments',
        data: {'text': text},
      );
      final data = response.data;
      if (data['success'] == true) {
        return CommentItem.fromJson(data['comment']);
      } else {
        throw Exception(data['message'] ?? 'Failed to add comment');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Network error';
      throw Exception(message);
    }
  }
}
