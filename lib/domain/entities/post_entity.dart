class PostEntity {
  final String id;
  final String authorName;
  final String authorAvatarUrl;
  final String? imageUrl;
  final String caption;
  final List<String> hashtags;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final bool likedByMe;
  final DateTime createdAt;

  const PostEntity({
    required this.id,
    required this.authorName,
    required this.authorAvatarUrl,
    this.imageUrl,
    required this.caption,
    this.hashtags = const [],
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
      authorName: authorName,
      authorAvatarUrl: authorAvatarUrl,
      imageUrl: imageUrl,
      caption: caption,
      hashtags: hashtags,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount,
      sharesCount: sharesCount,
      likedByMe: likedByMe ?? this.likedByMe,
      createdAt: createdAt,
    );
  }
}
