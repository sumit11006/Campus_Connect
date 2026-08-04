import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/club.dart';
import '../services/club_service.dart';
import 'auth_provider.dart';

final clubServiceProvider = Provider<ClubService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ClubService(apiService: apiService);
});

class ClubListState {
  final List<Club> clubs;
  final bool isLoading;
  final String? error;

  ClubListState({
    this.clubs = const [],
    this.isLoading = false,
    this.error,
  });

  ClubListState copyWith({
    List<Club>? clubs,
    bool? isLoading,
    String? error,
  }) {
    return ClubListState(
      clubs: clubs ?? this.clubs,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class ClubListNotifier extends StateNotifier<ClubListState> {
  final ClubService _clubService;

  ClubListNotifier(this._clubService) : super(ClubListState()) {
    fetchClubs();
  }

  Future<void> fetchClubs() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final clubs = await _clubService.getAllClubs();
      state = state.copyWith(clubs: clubs, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<bool> createClub({
    required String name,
    required String description,
    String? category,
    String? bannerUrl,
  }) async {
    try {
      final newClub = await _clubService.createClub(
        name: name,
        description: description,
        category: category,
        bannerUrl: bannerUrl,
      );
      state = state.copyWith(clubs: [newClub, ...state.clubs]);
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }
}

final clubListProvider =
    StateNotifierProvider<ClubListNotifier, ClubListState>((ref) {
  final service = ref.watch(clubServiceProvider);
  return ClubListNotifier(service);
});
