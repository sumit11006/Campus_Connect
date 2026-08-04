import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post.dart';
import '../services/post_service.dart';
import 'auth_provider.dart';

final postServiceProvider = Provider<PostService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PostService(apiService: apiService);
});

class PostListState {
  final List<Post> posts;
  final bool isLoading;
  final String? error;

  PostListState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
  });

  PostListState copyWith({
    List<Post>? posts,
    bool? isLoading,
    String? error,
  }) {
    return PostListState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class PostListNotifier extends StateNotifier<PostListState> {
  final PostService _postService;

  PostListNotifier(this._postService) : super(PostListState()) {
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final posts = await _postService.getAllPosts();
      state = state.copyWith(posts: posts, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  Future<bool> createPost({
    required String content,
    String? imagePath,
  }) async {
    try {
      final newPost = await _postService.createPost(
        content: content,
        imagePath: imagePath,
      );
      state = state.copyWith(posts: [newPost, ...state.posts]);
      return true;
    } catch (e) {
      state = state.copyWith(
        error: e.toString().replaceAll('Exception: ', ''),
      );
      return false;
    }
  }

  Future<void> toggleLike(String postId) async {
    try {
      final result = await _postService.toggleLike(postId);
      final newLikesCount = result['likesCount'] as int;
      final isLiked = result['isLiked'] as bool;

      state = state.copyWith(
        posts: state.posts.map((p) {
          if (p.id == postId) {
            return p.copyWith(
              likesCount: newLikesCount,
              isLiked: isLiked,
            );
          }
          return p;
        }).toList(),
      );
    } catch (e) {
      // Ignore or log error
    }
  }
}

final postListProvider =
    StateNotifierProvider<PostListNotifier, PostListState>((ref) {
  final service = ref.watch(postServiceProvider);
  return PostListNotifier(service);
});
