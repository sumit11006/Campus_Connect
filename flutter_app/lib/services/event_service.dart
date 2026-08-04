import 'package:dio/dio.dart';
import '../models/event.dart';
import 'api_service.dart';

class EventService {
  final ApiService apiService;

  EventService({required this.apiService});

  Future<List<CampusEvent>> getAllEvents({String? clubId, bool upcoming = false}) async {
    try {
      final query = <String, dynamic>{};
      if (clubId != null) query['clubId'] = clubId;
      if (upcoming) query['upcoming'] = 'true';

      final response = await apiService.dio.get('/events', queryParameters: query);
      final data = response.data;
      if (data['success'] == true) {
        final list = data['events'] as List;
        return list.map((json) => CampusEvent.fromJson(json)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to fetch events');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Network error';
      throw Exception(message);
    }
  }

  Future<Map<String, dynamic>> getEventById(String id) async {
    try {
      final response = await apiService.dio.get('/events/$id');
      final data = response.data;
      if (data['success'] == true) {
        return {
          'event': CampusEvent.fromJson(data['event']),
          'isRegistered': data['isRegistered'] ?? false,
        };
      } else {
        throw Exception(data['message'] ?? 'Event not found');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Network error';
      throw Exception(message);
    }
  }

  Future<CampusEvent> createEvent({
    required String title,
    required String description,
    required DateTime date,
    required String location,
    String? clubId,
    String? imageUrl,
    int? capacity,
  }) async {
    try {
      final payload = <String, dynamic>{
        'title': title,
        'description': description,
        'date': date.toIso8601String(),
        'location': location,
      };
      if (clubId != null) payload['clubId'] = clubId;
      if (imageUrl != null) payload['imageUrl'] = imageUrl;
      if (capacity != null) payload['capacity'] = capacity;

      final response = await apiService.dio.post('/events', data: payload);
      final data = response.data;
      if (data['success'] == true) {
        return CampusEvent.fromJson(data['event']);
      } else {
        throw Exception(data['message'] ?? 'Failed to create event');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Network error';
      throw Exception(message);
    }
  }

  Future<int> registerForEvent(String eventId) async {
    try {
      final response = await apiService.dio.post('/events/$eventId/register');
      final data = response.data;
      if (data['success'] == true) {
        return data['registrationCount'] as int;
      } else {
        throw Exception(data['message'] ?? 'Failed to register for event');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Network error';
      throw Exception(message);
    }
  }

  Future<int> unregisterFromEvent(String eventId) async {
    try {
      final response = await apiService.dio.post('/events/$eventId/unregister');
      final data = response.data;
      if (data['success'] == true) {
        return data['registrationCount'] as int;
      } else {
        throw Exception(data['message'] ?? 'Failed to unregister from event');
      }
    } on DioException catch (e) {
      final message = e.response?.data['message'] ?? 'Network error';
      throw Exception(message);
    }
  }
}
