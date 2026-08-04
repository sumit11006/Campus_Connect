import 'package:dio/dio.dart';
import '../models/lost_found.dart';
import 'api_service.dart';

class LostFoundService {
  final ApiService apiService;

  LostFoundService({required this.apiService});

  Future<List<LostFoundItem>> getItems({String? type}) async {
    try {
      final query = <String, dynamic>{};
      if (type != null && type.isNotEmpty) query['type'] = type;

      final response = await apiService.dio.get('/lostfound', queryParameters: query);
      final data = response.data;
      if (data['success'] == true) {
        final list = data['items'] as List;
        return list.map((json) => LostFoundItem.fromJson(json)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch items');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Network error';
      throw Exception(message);
    }
  }

  Future<LostFoundItem> reportItem({
    required String type,
    required String itemName,
    required String description,
    required String location,
    String? imagePath,
  }) async {
    try {
      dynamic payload;
      if (imagePath != null && imagePath.isNotEmpty) {
        payload = FormData.fromMap({
          'type': type,
          'itemName': itemName,
          'description': description,
          'location': location,
          'image': await MultipartFile.fromFile(imagePath),
        });
      } else {
        payload = {
          'type': type,
          'itemName': itemName,
          'description': description,
          'location': location,
        };
      }

      final response = await apiService.dio.post('/lostfound', data: payload);
      final data = response.data;
      if (data['success'] == true) {
        return LostFoundItem.fromJson(data['item']);
      } else {
        throw Exception(data['message'] ?? 'Failed to report item');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Network error';
      throw Exception(message);
    }
  }
}
