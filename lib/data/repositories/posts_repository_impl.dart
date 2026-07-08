import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:social_media_app/data/post_model.dart';
import 'package:social_media_app/domain/entities/post_entity.dart';
import 'package:social_media_app/domain/repositories/posts_repository.dart';

/// Implementação atual: lê `assets/json/data_post.json`, o mesmo arquivo
/// que o PostCubit original usava. Quando o backend Supabase estiver
/// pronto, basta criar uma nova classe implementando PostsRepository
/// (ex: SupabasePostsRepository) e trocar o provider — nada na UI muda.
class LocalJsonPostsRepository implements PostsRepository {
  final Map<String, bool> _likedOverrides = {};
  final Map<String, int> _likesOverrides = {};

  Future<List<PostModel>> _loadRawPosts() async {
    final raw = await rootBundle.loadString('assets/json/data_post.json');
    final jsonResult = json.decode(raw) as List<dynamic>;
    return jsonResult
        .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  PostEntity _toEntity(PostModel model, int index) {
    final id = 'post_$index';
    final baseLikes = int.tryParse(model.like.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

    return PostEntity(
      id: id,
      authorName: model.name,
      authorAvatarUrl: model.imgProfile,
      imageUrl: model.picture,
      caption: model.caption,
      hashtags: model.hashtags,
      likesCount: _likesOverrides[id] ?? baseLikes,
      commentsCount: int.tryParse(model.comment.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
      sharesCount: int.tryParse(model.share.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0,
      likedByMe: _likedOverrides[id] ?? false,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<List<PostEntity>> fetchFeed() async {
    final raw = await _loadRawPosts();
    return [for (var i = 0; i < raw.length; i++) _toEntity(raw[i], i)];
  }

  @override
  Future<void> toggleLike({required String postId, required bool like}) async {
    _likedOverrides[postId] = like;
    final current = _likesOverrides[postId] ?? 0;
    _likesOverrides[postId] = like ? current + 1 : (current - 1).clamp(0, 1 << 31);
  }
}
