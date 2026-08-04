import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/note.dart';
import '../services/note_service.dart';
import '../providers/auth_provider.dart';

final noteServiceProvider = Provider<NoteService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return NoteService(apiService: apiService);
});

// ─── State ─────────────────────────────────────────────────────────────────
class NoteState {
  final List<NoteItem> notes;
  final bool isLoading;
  final String? error;

  NoteState({
    this.notes = const [],
    this.isLoading = false,
    this.error,
  });

  NoteState copyWith({
    List<NoteItem>? notes,
    bool? isLoading,
    String? error,
  }) =>
      NoteState(
        notes: notes ?? this.notes,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

// ─── Notifier ───────────────────────────────────────────────────────────────
class NoteNotifier extends StateNotifier<NoteState> {
  final NoteService _service;

  NoteNotifier(this._service) : super(NoteState()) {
    fetchNotes();
  }

  Future<void> fetchNotes({String? subject}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _service.getNotes(subject: subject);
      state = state.copyWith(notes: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<bool> uploadNote({
    required String title,
    required String subject,
    required String filePath,
    String? description,
  }) async {
    try {
      final note = await _service.uploadNote(
        title: title,
        subject: subject,
        filePath: filePath,
        description: description,
      );
      state = state.copyWith(notes: [note, ...state.notes]);
      return true;
    } catch (e) {
      return false;
    }
  }
}

final noteProvider =
    StateNotifierProvider<NoteNotifier, NoteState>((ref) {
  final service = ref.watch(noteServiceProvider);
  return NoteNotifier(service);
});
