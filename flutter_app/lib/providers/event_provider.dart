import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import 'auth_provider.dart';

final eventServiceProvider = Provider<EventService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return EventService(apiService: apiService);
});

class EventListState {
  final List<CampusEvent> events;
  final bool isLoading;
  final String? error;

  EventListState({
    this.events = const [],
    this.isLoading = false,
    this.error,
  });

  EventListState copyWith({
    List<CampusEvent>? events,
    bool? isLoading,
    String? error,
  }) {
    return EventListState(
      events: events ?? this.events,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class EventListNotifier extends StateNotifier<EventListState> {
  final EventService _eventService;

  EventListNotifier(this._eventService) : super(EventListState()) {
    fetchEvents();
  }

  Future<void> fetchEvents({String? clubId}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final events = await _eventService.getAllEvents(clubId: clubId);
      state = state.copyWith(events: events, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<bool> createEvent({
    required String title,
    required String description,
    required DateTime date,
    required String location,
    String? clubId,
    String? imageUrl,
    int? capacity,
  }) async {
    try {
      final newEvent = await _eventService.createEvent(
        title: title,
        description: description,
        date: date,
        location: location,
        clubId: clubId,
        imageUrl: imageUrl,
        capacity: capacity,
      );
      state = state.copyWith(events: [newEvent, ...state.events]);
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }
}

final eventListProvider =
    StateNotifierProvider<EventListNotifier, EventListState>((ref) {
  final service = ref.watch(eventServiceProvider);
  return EventListNotifier(service);
});
