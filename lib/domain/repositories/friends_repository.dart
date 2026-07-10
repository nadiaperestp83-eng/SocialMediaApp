import 'package:social_media_app/domain/entities/friend_entity.dart';
import 'package:social_media_app/domain/entities/friendship_entity.dart';

abstract class FriendsRepository {
  Future<FriendshipStatus> getStatus(String userId);
  Future<void> sendFriendRequest(String userId);
  Future<void> cancelRequest(String userId);
  Future<void> acceptRequest(String userId);
  Future<List<FriendEntity>> fetchFriends();
}
