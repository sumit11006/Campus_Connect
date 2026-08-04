import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/lost_found.dart';
import '../services/lost_found_service.dart';
import '../providers/auth_provider.dart';

final lostFoundServiceProvider = Provider<LostFoundService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return LostFoundService(apiService: apiService);
});

// ─── State ─────────────────────────────────────────────────────────────────
class LostFoundState {
  final List<LostFoundItem> items;
  final bool isLoading;
  final String? error;

  LostFoundState({
    this.items = const [],
    this.isLoading = false,
    this.error,
  });

  LostFoundState copyWith({
    List<LostFoundItem>? items,
    bool? isLoading,
    String? error,
  }) =>
      LostFoundState(
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

// ─── Notifier ───────────────────────────────────────────────────────────────
class LostFoundNotifier extends StateNotifier<LostFoundState> {
  final LostFoundService _service;

  LostFoundNotifier(this._service) : super(LostFoundState()) {
    fetchItems();
  }

  Future<void> fetchItems({String? type}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _service.getItems(type: type);
      state = state.copyWith(items: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<bool> reportItem({
    required String type,
    required String itemName,
    required String description,
    required String location,
    String? imagePath,
  }) async {
    try {
      final item = await _service.reportItem(
        type: type,
        itemName: itemName,
        description: description,
        location: location,
        imagePath: imagePath,
      );
      state = state.copyWith(items: [item, ...state.items]);
      return true;
    } catch (e) {
      return false;
    }
  }
}

final lostFoundProvider =
    StateNotifierProvider<LostFoundNotifier, LostFoundState>((ref) {
  final service = ref.watch(lostFoundServiceProvider);
  return LostFoundNotifier(service);
});
