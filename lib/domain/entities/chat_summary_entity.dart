class ChatSummaryEntity {
  final String otherUserId;
  final String otherUserName;
  final String otherUsername;
  final String otherUserAvatarUrl;
  final String lastMessage;
  final DateTime lastMessageAt;
  final bool lastMessageIsMine;
  final String lastMessageStatus;
  final int unreadCount;

  const ChatSummaryEntity({
    required this.otherUserId,
    required this.otherUserName,
    required this.otherUsername,
    required this.otherUserAvatarUrl,
    required this.lastMessage,
    required this.lastMessageAt,
    required this.lastMessageIsMine,
    required this.lastMessageStatus,
    required this.unreadCount,
  });

  ChatSummaryEntity copyWith({
    String? otherUserName,
    String? otherUsername,
    String? otherUserAvatarUrl,
  }) {
    return ChatSummaryEntity(
      otherUserId: otherUserId,
      otherUserName: otherUserName ?? this.otherUserName,
      otherUsername: otherUsername ?? this.otherUsername,
      otherUserAvatarUrl: otherUserAvatarUrl ?? this.otherUserAvatarUrl,
      lastMessage: lastMessage,
      lastMessageAt: lastMessageAt,
      lastMessageIsMine: lastMessageIsMine,
      lastMessageStatus: lastMessageStatus,
      unreadCount: unreadCount,
    );
  }
}
