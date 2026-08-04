import 'package:dio/dio.dart';
import '../models/note.dart';
import 'api_service.dart';

class NoteService {
  final ApiService apiService;

  NoteService({required this.apiService});

  Future<List<NoteItem>> getNotes({String? subject}) async {
    try {
      final query = <String, dynamic>{};
      if (subject != null && subject.isNotEmpty) query['subject'] = subject;

      final response = await apiService.dio.get('/notes', queryParameters: query);
      final data = response.data;
      if (data['success'] == true) {
        final list = data['notes'] as List;
        return list.map((json) => NoteItem.fromJson(json)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch notes');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Network error';
      throw Exception(message);
    }
  }

  Future<NoteItem> uploadNote({
    required String title,
    required String subject,
    required String filePath,
    String? description,
  }) async {
    try {
      final formData = FormData.fromMap({
        'title': title,
        'subject': subject,
        'description': description ?? '',
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await apiService.dio.post('/notes', data: formData);
      final data = response.data;
      if (data['success'] == true) {
        return NoteItem.fromJson(data['note']);
      } else {
        throw Exception(data['message'] ?? 'Failed to upload note');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Network error';
      throw Exception(message);
    }
  }
}
