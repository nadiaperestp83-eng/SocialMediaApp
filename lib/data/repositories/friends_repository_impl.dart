import 'package:social_media_app/domain/entities/friendship_entity.dart';
import 'package:social_media_app/domain/repositories/friends_repository.dart';

/// Implementação provisória em memória — troque por Supabase quando
/// o schema de `friendships` estiver conectado (já desenhamos esse
/// schema anteriormente: tabela `friendships` com status pending/accepted).
class InMemoryFriendsRepository implements FriendsRepository {
  final Map<String, FriendshipStatus> _statuses = {};

  @override
  Future<FriendshipStatus> getStatus(String userId) async {
    return _statuses[userId] ?? FriendshipStatus.none;
  }

  @override
  Future<void> sendFriendRequest(String userId) async {
    _statuses[userId] = FriendshipStatus.pendingSent;
  }

  @override
  Future<void> cancelRequest(String userId) async {
    _statuses[userId] = FriendshipStatus.none;
  }
}
