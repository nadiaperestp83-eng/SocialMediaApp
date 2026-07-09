class CommentEntity {
  final String id;
  final String postId;
  final String authorName;
  final String authorAvatarUrl;
  final String content;
  final DateTime createdAt;

  const CommentEntity({
    required this.id,
    required this.postId,
    required this.authorName,
    required this.authorAvatarUrl,
    required this.content,
    required this.createdAt,
  });
}
