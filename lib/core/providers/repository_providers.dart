import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:social_media_app/data/repositories/friends_repository_impl.dart';
import 'package:social_media_app/data/repositories/posts_repository_impl.dart';
import 'package:social_media_app/domain/entities/post_entity.dart';
import 'package:social_media_app/domain/repositories/friends_repository.dart';
import 'package:social_media_app/domain/repositories/posts_repository.dart';

final postsRepositoryProvider = Provider<PostsRepository>((ref) {
  return LocalJsonPostsRepository();
});

final friendsRepositoryProvider = Provider<FriendsRepository>((ref) {
  return InMemoryFriendsRepository();
});

final feedProvider =
    StateNotifierProvider<FeedNotifier, AsyncValue<List<PostEntity>>>((ref) {
  return FeedNotifier(ref.watch(postsRepositoryProvider));
});

class FeedNotifier extends StateNotifier<AsyncValue<List<PostEntity>>> {
  final PostsRepository _repository;

  FeedNotifier(this._repository) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final posts = await _repository.fetchFeed();
      state = AsyncValue.data(posts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleLike(String postId, bool like) async {
    await _repository.toggleLike(postId: postId, like: like);
    final current = state.value;
    if (current == null) return;
    state = AsyncValue.data([
      for (final post in current)
        if (post.id == postId)
          post.copyWith(
            likedByMe: like,
            likesCount: like ? post.likesCount + 1 : post.likesCount - 1,
          )
        else
          post,
    ]);
  }
}
