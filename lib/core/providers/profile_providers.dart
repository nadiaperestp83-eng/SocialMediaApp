import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:social_media_app/core/providers/repository_providers.dart';
import 'package:social_media_app/core/providers/supabase_providers.dart';
import 'package:social_media_app/data/repositories/supabase_profile_repository.dart';
import 'package:social_media_app/domain/entities/friend_entity.dart';
import 'package:social_media_app/domain/entities/post_entity.dart';
import 'package:social_media_app/domain/entities/profile_entity.dart';
import 'package:social_media_app/domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return SupabaseProfileRepository(client: ref.watch(supabaseClientProvider));
});

final myProfileProvider =
    StateNotifierProvider<MyProfileNotifier, AsyncValue<ProfileEntity>>((ref) {
  return MyProfileNotifier(ref.watch(profileRepositoryProvider));
});

class MyProfileNotifier extends StateNotifier<AsyncValue<ProfileEntity>> {
  final ProfileRepository _repository;

  MyProfileNotifier(this._repository) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _repository.fetchMyProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => _load();

  Future<void> updateProfile({
    required String name,
    required String bio,
    required String city,
  }) async {
    final updated = await _repository.updateProfile(name: name, bio: bio, city: city);
    state = AsyncValue.data(updated);
  }

  Future<void> updateAvatar(Uint8List bytes, String fileName) async {
    final url = await _repository.uploadAvatar(bytes: bytes, fileName: fileName);
    final current = state.valueOrNull;
    if (current != null) {
      state = AsyncValue.data(current.copyWith(avatarUrl: url));
    }
  }
}

class ProfileStats {
  final int postsCount;
  final int friendsCount;
  final int likesTotal;

  const ProfileStats({
    required this.postsCount,
    required this.friendsCount,
    required this.likesTotal,
  });
}

final profileStatsProvider = FutureProvider<ProfileStats>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final userId = client.auth.currentUser?.id ?? '';

  if (userId.isEmpty) {
    return const ProfileStats(postsCount: 0, friendsCount: 0, likesTotal: 0);
  }

  final postsRows = await client.from('posts').select('likes_count').eq('author_id', userId);
  final posts = postsRows as List;
  final postsCount = posts.length;
  final likesTotal = posts.fold<int>(0, (sum, row) => sum + ((row['likes_count'] as int?) ?? 0));

  final friends = await ref.watch(friendsRepositoryProvider).fetchFriends();

  return ProfileStats(postsCount: postsCount, friendsCount: friends.length, likesTotal: likesTotal);
});

final friendsListProvider = FutureProvider<List<FriendEntity>>((ref) {
  return ref.watch(friendsRepositoryProvider).fetchFriends();
});

/// Posts do próprio usuário (reaproveita o feed já buscado e filtra pelo
/// autor — não duplica a lógica de leitura da tabela `posts`).
final myPostsProvider = FutureProvider<List<PostEntity>>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final userId = client.auth.currentUser?.id ?? '';
  if (userId.isEmpty) return const [];

  final allPosts = await ref.watch(postsRepositoryProvider).fetchFeed();
  return allPosts.where((p) => p.authorId == userId).toList();
});

/// Fotos do próprio usuário — derivadas dos posts que têm imagem.
final myPhotosProvider = Provider<AsyncValue<List<String>>>((ref) {
  final postsAsync = ref.watch(myPostsProvider);
  return postsAsync.whenData(
    (posts) => posts
        .where((p) => (p.imageUrl ?? '').isNotEmpty)
        .map((p) => p.imageUrl!)
        .toList(),
  );
});
