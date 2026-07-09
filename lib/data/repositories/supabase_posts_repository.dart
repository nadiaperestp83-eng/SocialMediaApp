import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:social_media_app/domain/entities/comment_entity.dart';
import 'package:social_media_app/domain/entities/link_preview_entity.dart';
import 'package:social_media_app/domain/entities/post_entity.dart';
import 'package:social_media_app/domain/entities/post_mention_entity.dart';
import 'package:social_media_app/domain/repositories/posts_repository.dart';

class SupabasePostsRepository implements PostsRepository {
  final SupabaseClient _client;

  SupabasePostsRepository({required SupabaseClient client}) : _client = client;

  static const _postSelect = '*, profiles(name, avatar_url), comments(id)';
  static const _storageBucket = 'post-images';

  String get _currentUserId => _client.auth.currentUser?.id ?? '';

  PostEntity _toPostEntity(Map<String, dynamic> row) {
    final profile = row['profiles'] as Map<String, dynamic>?;

    final hashtagsRaw = row['hashtags'];
    final hashtags = hashtagsRaw is List
        ? hashtagsRaw.map((e) => e.toString()).toList()
        : <String>[];

    final mentionsRaw = row['mentions'];
    final mentions = mentionsRaw is List
        ? mentionsRaw
            .whereType<Map<String, dynamic>>()
            .map((m) => PostMentionEntity.fromJson(m))
            .toList()
        : <PostMentionEntity>[];

    final linkPreviewRaw = row['link_preview'];
    final linkPreview = linkPreviewRaw is Map<String, dynamic>
        ? LinkPreviewEntity.fromJson(linkPreviewRaw)
        : null;

    return PostEntity(
      id: row['id'] as String,
      authorId: row['author_id'] as String? ?? '',
      authorName: profile?['name'] as String? ?? 'Usuário',
      authorAvatarUrl: profile?['avatar_url'] as String? ?? '',
      imageUrl: row['picture'] as String?,
      caption: row['caption'] as String? ?? '',
      hashtags: hashtags,
      mentions: mentions,
      linkPreview: linkPreview,
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
        .select(_postSelect)
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

  List<String> _extractHashtags(String text) {
    final matches = RegExp(r'#(\w+)', unicode: true).allMatches(text);
    final seen = <String>{};
    final result = <String>[];
    for (final m in matches) {
      final tag = '#${m.group(1)}';
      if (seen.add(tag.toLowerCase())) result.add(tag);
    }
    return result;
  }

  List<String> _extractMentionTokens(String text) {
    final matches = RegExp(r'@(\w+)', unicode: true).allMatches(text);
    final seen = <String>{};
    final result = <String>[];
    for (final m in matches) {
      final username = m.group(1)!;
      if (seen.add(username.toLowerCase())) result.add(username);
    }
    return result;
  }

  Future<List<PostMentionEntity>> _resolveMentions(String caption) async {
    final tokens = _extractMentionTokens(caption);
    if (tokens.isEmpty) return [];

    final rows = await _client
        .from('profiles')
        .select('id, username')
        .inFilter('username', tokens);

    return (rows as List)
        .map((r) => PostMentionEntity(
              userId: r['id'] as String,
              username: r['username'] as String,
            ))
        .toList();
  }

  Future<String> _uploadImage(Uint8List bytes, String fileName) async {
    final path = '$_currentUserId/${DateTime.now().microsecondsSinceEpoch}_$fileName';

    await _client.storage.from(_storageBucket).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(upsert: true, contentType: 'image/jpeg'),
        );

    return _client.storage.from(_storageBucket).getPublicUrl(path);
  }

  @override
  Future<PostEntity> createPost({
    required String caption,
    Uint8List? imageBytes,
    String? imageFileName,
    LinkPreviewEntity? linkPreview,
  }) async {
    if (_currentUserId.isEmpty) {
      throw Exception('Usuário não autenticado.');
    }

    String? pictureUrl;
    if (imageBytes != null) {
      pictureUrl = await _uploadImage(imageBytes, imageFileName ?? 'post.jpg');
    }

    final hashtags = _extractHashtags(caption);
    final mentions = await _resolveMentions(caption);

    final row = await _client
        .from('posts')
        .insert({
          'author_id': _currentUserId,
          'caption': caption,
          'picture': pictureUrl,
          'hashtags': hashtags,
          'mentions': mentions.map((m) => m.toJson()).toList(),
          'link_preview': linkPreview?.toJson(),
        })
        .select(_postSelect)
        .single();

    return _toPostEntity(row);
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
