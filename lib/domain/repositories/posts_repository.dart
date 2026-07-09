import 'dart:typed_data';

import 'package:social_media_app/domain/entities/comment_entity.dart';
import 'package:social_media_app/domain/entities/link_preview_entity.dart';
import 'package:social_media_app/domain/entities/post_entity.dart';

abstract class PostsRepository {
  Future<List<PostEntity>> fetchFeed();
  Future<void> toggleLike({required String postId, required bool like});

  /// Cria uma nova publicação. Se [imageBytes] for informado, a imagem é
  /// enviada ao Supabase Storage antes do insert. Hashtags (#) e menções (@)
  /// são extraídas automaticamente do [caption]; as menções são resolvidas
  /// contra usuários reais da tabela `profiles`.
  Future<PostEntity> createPost({
    required String caption,
    Uint8List? imageBytes,
    String? imageFileName,
    LinkPreviewEntity? linkPreview,
  });

  /// Stream ao vivo dos comentários de um post (Supabase Realtime).
  Stream<List<CommentEntity>> watchComments(String postId);

  Future<void> addComment({required String postId, required String content});
}
