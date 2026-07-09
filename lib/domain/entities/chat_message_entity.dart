class ChatMessageEntity {
  final String id;
  final String chatUserId;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime createdAt;
  final bool isMine;
  final String status; // sent | delivered | expired | received | read

  const ChatMessageEntity({
    required this.id,
    required this.chatUserId,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.createdAt,
    required this.isMine,
    required this.status,
  });
}
