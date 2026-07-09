class PostMentionEntity {
  final String userId;
  final String username;

  const PostMentionEntity({
    required this.userId,
    required this.username,
  });

  factory PostMentionEntity.fromJson(Map<String, dynamic> json) {
    return PostMentionEntity(
      userId: json['id'] as String? ?? '',
      username: json['username'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': userId,
        'username': username,
      };
}
