import 'package:social_media_app/domain/entities/chat_message_entity.dart';
import 'package:social_media_app/domain/entities/chat_summary_entity.dart';
import 'package:social_media_app/domain/entities/profile_search_result.dart';

abstract class ChatRepository {
  Future<void> init();
  Stream<List<ChatSummaryEntity>> watchChatList();
  Stream<List<ChatMessageEntity>> watchMessages(String otherUserId);
  Future<void> sendMessage({required String receiverId, required String content});
  Future<void> markConversationRead(String otherUserId);
  Future<List<ProfileSearchResult>> searchUsers(String query);
  Future<void> dispose();
}
