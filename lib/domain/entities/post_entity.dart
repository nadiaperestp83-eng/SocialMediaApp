import 'package:social_media_app/domain/entities/link_preview_entity.dart';
import 'package:social_media_app/domain/entities/post_mention_entity.dart';

class PostEntity {
  final String id;
  final String authorId;
  final String authorName;
  final String authorAvatarUrl;
  final String? imageUrl;
  final String caption;
  final List<String> hashtags;
  final List<PostMentionEntity> mentions;
  final LinkPreviewEntity? linkPreview;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final bool likedByMe;
  final DateTime createdAt;

  const PostEntity({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorAvatarUrl,
    this.imageUrl,
    required this.caption,
    this.hashtags = const [],
    this.mentions = const [],
    this.linkPreview,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.likedByMe = false,
    required this.createdAt,
  });

  PostEntity copyWith({
    bool? likedByMe,
    int? likesCount,
  }) {
    return PostEntity(
      id: id,
      authorId: authorId,
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      imageUrl: imageUrl,
      caption: caption,
      hashtags: hashtags,
      mentions: mentions,
      linkPreview: linkPreview,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount,
      sharesCount: sharesCount,
      likedByMe: likedByMe ?? this.likedByMe,
      createdAt: createdAt,
    );
  }
}
