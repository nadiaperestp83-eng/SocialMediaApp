import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:social_media_app/domain/entities/friend_entity.dart';
import 'package:social_media_app/domain/entities/friendship_entity.dart';
import 'package:social_media_app/domain/repositories/friends_repository.dart';

class SupabaseFriendsRepository implements FriendsRepository {
  final SupabaseClient _client;

  SupabaseFriendsRepository({required SupabaseClient client}) : _client = client;

  String get _me => _client.auth.currentUser?.id ?? '';

  @override
  Future<FriendshipStatus> getStatus(String userId) async {
    final rows = await _client
        .from('friendships')
        .select('requester_id, addressee_id, status')
        .or('and(requester_id.eq.$_me,addressee_id.eq.$userId),and(requester_id.eq.$userId,addressee_id.eq.$_me)')
        .limit(1);

    if ((rows as List).isEmpty) return FriendshipStatus.none;

    final row = rows.first as Map<String, dynamic>;
    if (row['status'] == 'accepted') return FriendshipStatus.friends;
    if (row['requester_id'] == _me) return FriendshipStatus.pendingSent;
    return FriendshipStatus.pendingReceived;
  }

  @override
  Future<void> sendFriendRequest(String userId) async {
    await _client.from('friendships').insert({
      'requester_id': _me,
      'addressee_id': userId,
      'status': 'pending',
    });
  }

  @override
  Future<void> cancelRequest(String userId) async {
    await _client
        .from('friendships')
        .delete()
        .or('and(requester_id.eq.$_me,addressee_id.eq.$userId),and(requester_id.eq.$userId,addressee_id.eq.$_me)');
  }

  @override
  Future<void> acceptRequest(String userId) async {
    await _client
        .from('friendships')
        .update({'status': 'accepted'})
        .eq('requester_id', userId)
        .eq('addressee_id', _me);
  }

  @override
  Future<List<FriendEntity>> fetchFriends() async {
    if (_me.isEmpty) return [];

    final rows = await _client
        .from('friendships')
        .select('requester_id, addressee_id')
        .eq('status', 'accepted')
        .or('requester_id.eq.$_me,addressee_id.eq.$_me');

    final otherIds = (rows as List)
        .map((r) => (r['requester_id'] == _me) ? r['addressee_id'] as String : r['requester_id'] as String)
        .toSet()
        .toList();

    if (otherIds.isEmpty) return [];

    final profiles = await _client
        .from('profiles')
        .select('id, name, username, avatar_url')
        .inFilter('id', otherIds);

    return (profiles as List)
        .map((p) => FriendEntity(
              id: p['id'] as String,
              name: p['name'] as String? ?? '',
              username: p['username'] as String? ?? '',
              avatarUrl: p['avatar_url'] as String? ?? '',
            ))
        .toList();
  }
}
