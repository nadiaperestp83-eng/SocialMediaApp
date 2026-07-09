import 'package:social_media_app/domain/entities/comment_entity.dart';
import 'package:social_media_app/domain/entities/post_entity.dart';

abstract class PostsRepository {
  Future<List<PostEntity>> fetchFeed();
  Future<void> toggleLike({required String postId, required bool like});

  /// Stream ao vivo dos comentários de um post (Supabase Realtime).
  Stream<List<CommentEntity>> watchComments(String postId);

  Future<void> addComment({required String postId, required String content});
}
