import 'package:social_media_app/domain/entities/post_entity.dart';

abstract class PostsRepository {
  Future<List<PostEntity>> fetchFeed();
  Future<void> toggleLike({required String postId, required bool like});
}
