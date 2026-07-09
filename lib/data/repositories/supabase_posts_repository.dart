import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:social_media_app/domain/entities/comment_entity.dart';
import 'package:social_media_app/domain/entities/post_entity.dart';
import 'package:social_media_app/domain/repositories/posts_repository.dart';

class SupabasePostsRepository implements PostsRepository {
  final SupabaseClient _client;

  SupabasePostsRepository({required SupabaseClient client}) : _client = client;

  String get _currentUserId => _client.auth.currentUser?.id ?? '';

  PostEntity _toPostEntity(Map<String, dynamic> row) {
    final profile = row['profiles'] as Map<String, dynamic>?;
    final hashtagsRaw = row['hashtags'];
    final hashtags = hashtagsRaw is List
        ? hashtagsRaw.map((e) => e.toString()).toList()
        : <String>[];

    return PostEntity(
      id: row['id'] as String,
      authorName: profile?['name'] as String? ?? 'Usuário',
      authorAvatarUrl: profile?['avatar_url'] as String? ?? '',
      imageUrl: row['picture'] as String?,
      caption: row['caption'] as String? ?? '',
      hashtags: hashtags,
      likesCount: row['likes_count'] as int? ?? 0,
      commentsCount: (row['comments'] as List?)?.length ?? 0,
      likedByMe: false,
      createdAt: DateTime.parse(row['created_at'] as String),
    );
  }

  @override
  Future<List<PostEntity>> fetchFeed() async {
    final rows = await _client
        .from('posts')
        .select('*, profiles(name, avatar_url), comments(id)')
        .order('created_at', ascending: false)
        .limit(30);

    return (rows as List)
        .map((row) => _toPostEntity(row as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> toggleLike({required String postId, required bool like}) async {
    await _client.rpc('increment_post_comments'); // placeholder de exemplo
  }

  @override
  Stream<List<CommentEntity>> watchComments(String postId) {
    return _client
        .from('comments')
        .stream(primaryKey: ['id'])
        .eq('post_id', postId)
        .order('created_at')
        .map((rows) => rows
            .map((row) => CommentEntity(
                  id: row['id'] as String,
                  postId: row['post_id'] as String,
                  authorName: 'Usuário',
                  authorAvatarUrl: '',
                  content: row['content'] as String,
                  createdAt: DateTime.parse(row['created_at'] as String),
                ))
            .toList());
  }

  @override
  Future<void> addComment({required String postId, required String content}) async {
    await _client.from('comments').insert({
      'post_id': postId,
      'author_id': _currentUserId,
      'content': content,
    });
  }
}
